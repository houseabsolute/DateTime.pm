package DateTime;

use strict;

use vars qw($VERSION);

$VERSION = '0.01';

use Carp;
use Class::Data::Inheritable;
use Date::Leapyear ();
use DateTime::Duration;
use DateTime::TimeZone;
use DateTime::TimeZone::UTC;
use Params::Validate qw( validate validate_with SCALAR BOOLEAN OBJECT );
use Time::Local ();

use base 'Class::Data::Inheritable';

use Exception::Class ( 'DateTime::Exception' );
DateTime::Exception->Trace(1);

# for some reason, overloading doesn't work unless fallback is listed
# early.
use overload ( 'fallback' => 1,
               '<=>' => 'compare',
               '-' => 'subtract',
               '+' => \&_add_overload,
               '""' => '_stringify',
             );

my( @MonthLengths, @LeapYearMonthLengths,
    @EndofMonthDayOfYear, @EndofMonthDayOfLeapYear,
    %AddUnits );

{
    # I'd rather use Class::Data::Inheritable for this, but there's no
    # way to add the module-loading behavior to an accessor it
    # creates, despite what its docs say!
    my $DefaultLanguageClass;
    sub DefaultLanguageClass {
        my $class = shift;

        if (@_) {
            my $lang_class = shift;

            $lang_class = "DateTime::Language::$lang_class"
                unless $lang_class =~ /^DateTime::Language::/;

            eval "use $lang_class";
            die $@ if $@;

            $DefaultLanguageClass = $lang_class;
        }

        return $DefaultLanguageClass;
    }
}
__PACKAGE__->DefaultLanguageClass('English');

__PACKAGE__->mk_classdata('ErrorHandler');
__PACKAGE__->ErrorHandler( sub { DateTime::Exception->throw( $_[0] ) } );

__PACKAGE__->mk_classdata('RaiseError');
__PACKAGE__->RaiseError(0);

__PACKAGE__->mk_classdata('PrintError');
__PACKAGE__->PrintError(0);

sub new {
    my $class = shift;
    my %args =
        eval { validate( @_,
                         { year   => { type => SCALAR },
                           month  => { type => SCALAR },
                           day    => { type => SCALAR },
                           hour   => { type => SCALAR, default => 0 },
                           minute => { type => SCALAR, default => 0 },
                           second => { type => SCALAR, default => 0 },
                           language  => { type => SCALAR, optional => 1 },
                           time_zone => { type => SCALAR | OBJECT, optional => 1 }, # isa ?
                         }
                       ) };
    return $class->_error($@) if $@;

    my $self = {};

    if ( $args{language} ) {
        my $class = 'DateTime::Language::' . ucfirst lc $args{language};
        $self->{language} = $class->new;
    } else {
        $self->{language} = $class->DefaultLanguageClass->new;
    }

    $args{time_zone} = 'UTC' unless exists $args{time_zone};

    $self->{tz} =
        ( ref $args{time_zone} ?
          $args{time_zone} :
          DateTime::TimeZone->new( name => $args{time_zone} )
        );

    $self->{local_rd_days} = greg2rd( @args{ qw( year month day ) } );
    $self->{local_rd_secs} = time_as_seconds( @args{ qw( hour minute second ) } );

    bless $self, $class;

    $self->_calc_utc_rd;

    return $self;
}

sub _calc_utc_rd {
    my $self = shift;

    # We must short circuit for UTC times or else we could end up with
    # loops between DateTime.pm and DateTime::TimeZone
    if ( $self->{tz}->is_utc ) {
        $self->{utc_rd_days} = $self->{local_rd_days};
        $self->{utc_rd_secs} = $self->{local_rd_secs};

        return;
    }

    $self->{utc_rd_days} = $self->{local_rd_days};
    $self->{utc_rd_secs} = $self->{local_rd_secs} + $self->offset;

    _normalize_seconds( $self->{utc_rd_days}, $self->{utc_rd_secs} );
}

sub _calc_local_rd {
    my $self = shift;

    # We must short circuit for UTC times or else we could end up with
    # loops between DateTime.pm and DateTime::TimeZone
    if ( $self->{tz}->is_utc ) {
        $self->{local_rd_days} = $self->{utc_rd_days};
        $self->{local_rd_secs} = $self->{utc_rd_secs};

        return;
    }

    $self->{local_rd_days} = $self->{utc_rd_days};
    $self->{local_rd_secs} = $self->{utc_rd_secs} - $self->offset;

    _normalize_seconds( $self->{local_rd_days}, $self->{local_rd_secs} );
}

sub from_epoch {
    my $class = shift;
    my %args =
        eval { validate( @_,
                         { epoch => { type => SCALAR },
                           language  => { type => SCALAR, optional => 1 },
                           time_zone => { type => SCALAR | OBJECT, optional => 1 },
                         } ) };
    return $class->_error($@) if $@;

    my %p;

    # Note, for very large negative values this may give a blatantly
    # wrong answer.
    @p{ qw( second minute hour day month year ) } =
        ( gmtime( delete $args{epoch} ) )[ 0, 1, 2, 3, 4, 5 ];
    $p{year} += 1900;
    $p{month}++;

    # pass other args like time_zone to constructor
    return $class->new( %args, %p );
}

# use scalar time in case someone's loaded Time::Piece
sub now { shift->from_epoch( epoch => (scalar time), @_ ) }

sub clone {
    return bless { %{ $_[0] } }, ref $_[0];
}

sub utc_datetime {
    my $self = shift;

    my $dt = $self->clone;

    $dt->{tz} = DateTime::TimeZone->new( name => 'UTC' );

    return $dt;
}

sub add {
    my $self = shift;
    carp "DateTime::add was called without an attribute arg" unless @_;
    ( $self->{utc_rd_days}, $self->{utc_rd_secs} ) =
        _add($self->{utc_rd_days}, $self->{utc_rd_secs}, @_);

    $self->_calc_local_rd;

    return $self;
}

=begin internal

    Add (or subtract) to a date/time.  First two parameters are
    the jd and secs of the day.  For the rest, see the add method.
    Returns the adjusted jd and secs.

=end internal

# for each unit, specify what it changes by (0=day, 1=second, 2=month)
# and by what factor

=cut

%AddUnits = ( years   => [2, 12],
              months  => [2, 1],
              weeks   => [0, 7],
              days    => [0, 1],
              hours   => [1, 3600],
              minutes => [1, 60],
              seconds => [1, 1],
            );

# redo this to just accept params like a normal freaking method!
sub _add {
    my ($rd, $secs) = splice(@_, 0, 2);
    my $eom_mode = 0;
    my ($add, $unit, $count);

    # loop through unit=>count parameters
    while (($unit, $count) = splice(@_, 0, 2)) {

        if ($unit eq 'duration') { # add a duration string
            my %dur;
            @dur{'days','seconds','months'} = duration_value($count);

            # pretend these were passed to us as e.g. month=>1, day=>1, second=>1.
            # since months/years come first in the duration string, we
            # put them first.
            unshift @_, map $dur{$_} ? ($_,$dur{$_}) : (),
                            'months', 'days', 'seconds';
            next;
        } elsif ($unit eq 'eom_mode') {
            if ($count eq 'wrap') { $eom_mode = 0 }
            elsif ($count eq 'limit') { $eom_mode = 1 }
            elsif ($count eq 'preserve') { $eom_mode = 2 }
            else { carp "Unrecognized eom_mode, $count, ignored" }
        } else {
            unless ($add = $AddUnits{$unit}) {
                carp "Unrecognized time unit, $unit, skipped";
                next;
            }

            $count = 1 if !defined $count; # count defaults to 1
            $count *= $add->[1]; # multiply by the factor for this unit

            if ($add->[0] == 0) { # add to days
                $rd += $count;
            } elsif ($add->[0] == 1) { # add to seconds
                $secs += $count;
            } else {            # add to months
                my ($y, $mo, $d);

                _normalize_seconds( $rd, $secs );
                if ($eom_mode == 2) { # sticky eom mode
                    # if it is the last day of the month, make it the 0th
                    # day of the following month (which then will normalize
                    # back to the last day of the new month).
                    ($y, $mo, $d) = rd2greg( $rd+1 );
                    --$d;
                } else {
                    ($y, $mo, $d) = rd2greg( $rd );
                }

                if ($eom_mode && $d > 28) { # limit day to last of new month
                    # find the jd of the last day of our target month
                    $rd = greg2rd( $y, $mo+$count+1, 0 );

                    # what day of the month is it? (discard year and month)
                    my $lastday = scalar rd2greg( $rd );

                    # if our original day was less than the last day,
                    # use that instead
                    $rd -= $lastday - $d if $lastday > $d;
                } else {
                    $rd = greg2rd( $y, $mo+$count, $d );
                }
            }
        }
    }

    _normalize_seconds( $rd, $secs );
}

sub duration_value {
    my $str = shift;

    my @temp = $str =~ m{
            ([\+\-])?   (?# Sign)
            (P)     (?# 'P' for period? This is our magic character)
            (?:
                (?:(\d+)Y)? (?# Years)
                (?:(\d+)M)? (?# Months)
                (?:(\d+)W)? (?# Weeks)
                (?:(\d+)D)? (?# Days)
            )?
            (?:T        (?# Time prefix)
                (?:(\d+)H)? (?# Hours)
                (?:(\d+)M)? (?# Minutes)
                (?:(\d+)S)? (?# Seconds)
            )?
                }x;
    my ( $sign, $magic ) = @temp[ 0 .. 1 ];
    my ( $years, $months, $weeks, $days, $hours, $mins, $secs ) =
      map { defined($_) ? $_ : 0 } @temp[ 2 .. $#temp ];

    unless ( defined($magic) ) {
        carp "Invalid duration: $str";
        return undef;
    }
    $sign = ( ( defined($sign) && $sign eq '-' ) ? -1 : 1 );

    my $s = $sign * ( $secs + ( $mins * 60 ) + ( $hours * 3600 ) );
    my $d = $sign * ( $days + ( $weeks * 7 ) );
    my $m = $sign * ( $months + ( $years * 12 ) );
    return ( $d, $s, $m );
}

sub _add_overload {
    my $one = shift;
    my $two = shift;

    my $ret = $one->clone;

    if ( ref $two ) {
        $ret->add( duration => $two->as_ical );
    } else {
        $ret->add( duration => $two );
    }

    return $ret;
}

=begin internal

    ($rd, $secs) = _normalize_seconds( $rd, $secs );

    Corrects seconds that have gone into following or previous day(s).
    Adjusts the passed days and seconds as well as returning them.

=end internal

=cut

sub _normalize_seconds {
    my $adj;

    if ($_[1] < 0) {
        $adj = int( ($_[1]-86399)/86400 );
    } else {
        $adj = int( $_[1]/86400 );
    }
    ($_[0] += $adj), ($_[1] -= $adj*86400);
}

sub subtract {
    my ( $date1, $date2, $reversed ) = @_;
    my $dur;

    # If the order of the arguments was reversed, overload tells us
    # about it in the third argument.
    if ($reversed) {
        ( $date2, $date1 ) = ( $date1, $date2 );
    }

    if (ref $date1 && ref $date2) {
    # If $date1 is a DateTime object, and $date2 is a Duration object,
    # then we should subtract and get a date.
        if ((ref $date2) eq 'DateTime::Duration') {
            my $seconds = $date2->as_seconds;
            my $ret = $date1->clone;
            $ret->add( seconds => -1 * $seconds );
            return $ret;

        } else {
    # If $date2 is a DateTime object, or some class thereof, we should
    # subtract and get a duration

            my $days = $date1->{utc_rd_days} - $date2->{utc_rd_days};
            my $secs = $date1->{utc_rd_secs} - $date2->{utc_rd_secs};

            return DateTime::Duration->new(
              days    => $days,
              seconds => $secs
            );
        }
    } elsif ( ref $date1 &&
              ( $dur = DateTime::Duration->new( ical => $date2 ) )
            ) {
    # If $date1 is a DateTime object, and $date2 is a duration string,
    # we should subtract and get a date
        return $date1 - $dur; # Is that cheating?

    # Otherwise, we should call them nasty names and return undef
    } else {
        # this must go - dave
        warn "Moron";
        return;
    }

}

sub compare {
    my ( $class, $dt1, $dt2 ) = ref $_[0] ? ( undef, @_ ) : @_;

    return undef unless defined $dt2;

    # One or more days different
    if ( $dt1->{utc_rd_days} < $dt2->{utc_rd_days} ) {
        return -1;
    } elsif ( $dt1->{utc_rd_days} > $dt2->{utc_rd_days} ) {
        return 1;

    # They are the same day
    } elsif ( $dt1->{utc_rd_secs} < $dt2->{utc_rd_secs} ) {
        return -1;
    } elsif ( $dt1->{utc_rd_secs} > $dt2->{utc_rd_secs} ) {
        return 1;
    }

    # must be equal
    return 0;
}

sub epoch {
    my $self = shift;

    # timegm may die if given components outside of the ranges it
    # can handle.  In that case return undef.
    return
        eval { Time::Local::timegm( $self->sec,
                                    $self->min,
                                    $self->hour,
                                    $self->day,
                                    $self->month_0,
                                    $self->year - 1900,
                                  ) };
}

sub offset { $_[0]->{tz}->offset_for_datetime( $_[0] ) }

=begin internal

    time_as_seconds( $args{hour}, $args{min}, $args{sec} );

Returns the time of day as the number of seconds in the day.

=end internal

=cut

sub time_as_seconds {
    my ( $hour, $min, $sec ) = @_;

    $hour ||= 0;
    $min ||= 0;
    $sec ||= 0;

    my $secs = $hour * 3600 + $min * 60 + $sec;
    return $secs;
}

sub rd2greg {
    use integer;
    my $d = shift;
    my $yadj = 0;
    my ( $c, $y, $m );

    # add 306 days to make relative to Mar 1, 0; also adjust $d to be
    # within a range (1..2**28-1) where our calculations will work
    # with 32bit ints
    if ( $d > 2**28 - 307 ) {

        # avoid overflow if $d close to maxint
        $yadj = ( $d - 146097 + 306 ) / 146097 + 1;
        $d -= $yadj * 146097 - 306;
      } elsif ( ( $d += 306 ) <= 0 )
    {
        $yadj =
          -( -$d / 146097 + 1 );    # avoid ambiguity in C division of negatives
        $d -= $yadj * 146097;
    }

    $c =
      ( $d * 4 - 1 ) / 146097;      # calc # of centuries $d is after 29 Feb of yr 0
    $d -= $c * 146097 / 4;          # (4 centuries = 146097 days)
    $y = ( $d * 4 - 1 ) / 1461;     # calc number of years into the century,
    $d -= $y * 1461 / 4;            # again March-based (4 yrs =~ 146[01] days)
    $m =
      ( $d * 12 + 1093 ) / 367;     # get the month (3..14 represent March through
    $d -= ( $m * 367 - 1094 ) / 12; # February of following year)
    $y += $c * 100 + $yadj * 400;   # get the real year, which is off by
    ++$y, $m -= 12 if $m > 12;      # one if month is January or February
    return ( $y, $m, $d );
}

sub greg2rd {
    use integer;
    my ( $y, $m, $d ) = @_;
    my $adj;

    # make month in range 3..14 (treat Jan & Feb as months 13..14 of
    # prev year)
    if ( $m <= 2 ) {
        $y -= ( $adj = ( 14 - $m ) / 12 );
        $m += 12 * $adj;
    } elsif ( $m > 14 ) {
        $y += ( $adj = ( $m - 3 ) / 12 );
        $m -= 12 * $adj;
    }

    # make year positive (oh, for a use integer 'sane_div'!)
    if ( $y < 0 ) {
        $d -= 146097 * ( $adj = ( 399 - $y ) / 400 );
        $y += 400 * $adj;
    }

    # add: day of month, days of previous 0-11 month period that began
    # w/March, days of previous 0-399 year period that began w/March
    # of a 400-multiple year), days of any 400-year periods before
    # that, and 306 days to adjust from Mar 1, year 0-relative to Jan
    # 1, year 1-relative (whew)

    $d += ( $m * 367 - 1094 ) / 12 + $y % 100 * 1461 / 4 +
      ( $y / 100 * 36524 + $y / 400 ) - 306;
}

=begin internal

Calculates the day of the year at the end of a month.

=end internal

=cut

BEGIN {

    @MonthLengths =
        ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

    @LeapYearMonthLengths = @MonthLengths;
    $LeapYearMonthLengths[1]++;

    my $x = 0;
    foreach my $length ( @MonthLengths )
    {
        push @EndofMonthDayOfYear, $x;
        $x += $length;
    }

    @EndofMonthDayOfLeapYear = @EndofMonthDayOfYear;

    for ( 1 .. 11 ) {
        $EndofMonthDayOfLeapYear[$_] = $EndofMonthDayOfYear[$_] + 1;
    }
}

sub end_of_month_day_of_year {
    return Date::Leapyear::isleap(shift) ? @EndofMonthDayOfLeapYear : @EndofMonthDayOfYear;
}

sub last_day_of_month {
    shift;
    my %p = validate( @_, { year  => { type => SCALAR },
                            month => { type => SCALAR },
                          } );

    return
        ( Date::Leapyear::isleap( $p{year} ) ?
          $MonthLengths[ $p{month} - 1 ] :
          $LeapYearMonthLengths[ $p{month} - 1 ]
        );
}

sub week {
     my $self = shift;

     my $mid_week = $self->clone;
     # mid week if Sunday is the first day of the week
     $mid_week->add( days => 4 - ( ( $self->{local_rd_days} % 7 ) + 1 ) );
     my $week_year = $mid_week->year;

     my $jan_four = greg2rd( $week_year, 1, 4 );
     my $first_week = $jan_four - ( $jan_four % 7 );
     my $week_number = int( ($self->{local_rd_days} - $first_week) / 7 ) + 1;

     return ( $week_year, $week_number );
}

sub week_year   { ($_[0]->week)[0] }
sub week_number { ($_[0]->week)[1] }

sub year {
    my $self = shift;
    return ( $self->_as_greg )[0];
}

sub year_0 { $_[0]->year - 1 }

sub month {
    my $self = shift;
    return ( $self->_as_greg )[1];
}
*mon = \&month;

sub month_0 { $_[0]->month - 1 };
*mon_0 = \&month_0;

sub month_name {
    my $self = shift;
    return $self->{language}->month_name( $self->month_0 );
}

sub month_abbr {
    my $self = shift;
    return $self->{language}->month_abbreviation( $self->month_0 );
}

sub day_of_year {
    my $self = shift;
    my @m = end_of_month_day_of_year($self->year);
    return $m[$self->month_0] + $self->day;
}

sub day_of_year_0 { $_[0]->day_of_year - 1 }

sub day_of_month {
    my $self = shift;
    return ( $self->_as_greg )[2];
}
*day  = \&day_of_month;
*mday = \&day_of_month;

sub day_of_month_0 { $_[0]->day_of_month - 1 }
*day_0  = \&day_of_month_0;
*mday_0 = \&day_of_month_0;

sub day_of_week {
    my $self = shift;
    return ($self->{local_rd_days} + 6) % 7 + 1;
}
*wday = \&day_of_week;
*dow  = \&day_of_week;

sub day_of_week_0 { $_[0]->day_of_week - 1 }
*wday_0 = \&day_of_week_0;
*dow_0  = \&day_of_week_0;

sub day_name {
    my $self = shift;
    return $self->{language}->day_name( $self->day_of_week_0 );
}

sub day_abbr {
    my $self = shift;
    return $self->{language}->day_abbreviation( $self->day_of_week_0 );
}

sub ymd {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%02d$sep%02d$sep%02d", $self->_as_greg );
}
*date = \&ymd;

sub mdy {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%02d$sep%02d$sep%02d", ($self->_as_greg)[1,2,0] );
}

sub dmy {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%02d$sep%02d$sep%02d", reverse $self->_as_greg );
}

sub hour {
    my $self = shift;
    return ( $self->parsetime )[2];
}

sub minute {
    my $self = shift;
    return ( $self->parsetime )[1];
}
*min = \&minute;

sub second {
    my $self = shift;
    return ( $self->parsetime )[0];
}
*sec = \&second;

sub hms {
    my ( $self, $sep ) = @_;
    $sep = ':' unless defined $sep;
    return sprintf( "%02d$sep%02d$sep%02d", reverse $self->parsetime );
}
# don't want to override CORE::time()
*DateTime::time = \&hms;

sub iso8601 {
    my $self = shift;
    return join 'T', $self->ymd('-'), $self->hms(':');
}
*datetime = \&iso8601;

sub is_leap_year { Date::Leapyear::isleap( $_[0]->year ) }

sub _as_greg { rd2greg( $_[0]->{local_rd_days} ) }

my %formats =
    ( 'a' => sub { $_[0]->day_abbr },
      'A' => sub { $_[0]->day_name },
      'b' => sub { $_[0]->month_abbr },
      'B' => sub { $_[0]->month_name },
      'c' => sub { $_[0]->strftime( $_[0]->{language}->preferred_datetime_format ) },
      'C' => sub { int( $_[0]->year / 100 ) },
      'd' => sub { sprintf( '%02d', $_[0]->day_of_month ) },
      'D' => sub { $_[0]->strftime( '%m/%d/%y' ) },
      'e' => sub { sprintf( '%2d', $_[0]->day_of_month ) },
      'F' => sub { $_[0]->ymd('-') },
      'g' => sub { substr( $_[0]->week_year, -2 ) },
      'G' => sub { $_[0]->week_year },
      'H' => sub { sprintf( '%02d', $_[0]->hour ) },
      'I' => sub { my $h = $_[0]->hour; $h -= 12 if $h >= 12; sprintf( '%02d', $h ) },
      'j' => sub { $_[0]->day_of_year },
      'k' => sub { sprintf( '%2d', $_[0]->hour ) },
      'l' => sub { my $h = $_[0]->hour; $h -= 12 if $h >= 12; sprintf( '%2d', $h ) },
      'm' => sub { sprintf( '%02d', $_[0]->month ) },
      'M' => sub { sprintf( '%02d', $_[0]->minute ) },
      'n' => sub { "\n" }, # should this be OS-sensitive?
      'p' => sub { $_[0]->{language}->am_pm( $_[0] ) },
      'P' => sub { lc $_[0]->{language}->am_pm( $_[0] ) },
      'r' => sub { $_[0]->strftime( '%I:%M:%S %p' ) },
      'R' => sub { $_[0]->strftime( '%H:%M' ) },
      's' => sub { $_[0]->epoch },
      'S' => sub { sprintf( '%02d', $_[0]->second ) },
      't' => sub { "\t" },
      'T' => sub { $_[0]->strftime( '%H:%M:%S' ) },
      'u' => sub { $_[0]->day_of_week },
      # algorithm from Date::Format::wkyr
      'U' => sub { my $dow = $_[0]->day_of_week;
                   $dow = 0 if $dow == 7; # convert to 0-6, Sun-Sat
                   my $doy = $_[0]->day_of_year - 1;
                   return int( ( $doy - $dow + 13 ) / 7 - 1 )
                 },
      'w' => sub { my $dow = $_[0]->day_of_week;
                   return $dow % 7;
                 },
      'W' => sub { my $dow = $_[0]->day_of_week;
                   my $doy = $_[0]->day_of_year - 1;
                   return int( ( $doy - $dow + 13 ) / 7 - 1 )
                 },
      'x' => sub { $_[0]->strftime( $_[0]->{language}->preferred_date_format ) },
      'X' => sub { $_[0]->strftime( $_[0]->{language}->preferred_time_format ) },
      'y' => sub { sprintf( '%02d', substr( $_[0]->year, -2 ) ) },
      'Y' => sub { return $_[0]->year },
      'z' => sub { $_[0]->{tz}->short_name_for_datetime( $_[0] ) },
      'Z' => sub { DateTime::TimeZone::offset_as_string( $_[0]->offset ) },
      '%' => sub { '%' },
    );

$formats{h} = $formats{b};

sub strftime {
    my $self = shift;
    # make a copy or caller's scalars get munged
    my @formats = @_;

    my @r;
    foreach my $f (@formats)
    {
        # regex from Date::Format - thanks Graham!
        $f =~ s/
	        %([OE]?[%a-zA-Z])
	       /
                $formats{$1} ? $formats{$1}->($self) : $1
               /sgex;

        return $f unless wantarray;

        push @r, $f;
    }

    return @r;
}

# like "scalar localtime()" in Perl
sub _stringify { $_[0]->strftime( '%a, %d %b %Y %H:%M:%S %Z' ) }

=begin internal

 ( $sec, $min, $hour ) = parsetime( $seconds );

Given the number of seconds so far today, returns the seconds,
minutes, and hours of the current time.

=end internal

=cut

sub parsetime {
    my $self = shift;
    my $time = $self->{local_rd_secs};

    my $hour = int( $time / 3600 );
    $time -= $hour * 3600;

    my $min = int( $time / 60 );
    $time -= $min * 60;

    return ( int($time), $min, $hour );
}

sub _error {
    my $class = shift;
    my $error = shift;

    warn $error if $class->PrintError;

    my $h = $class->ErrorHandler;
    if ( defined $h && $h ) {
        return $h->($error);
    }

    die "$error\n" if $class->RaiseError;

    return;
}

1;

__END__

=head1 NAME

DateTime - Reference implement for Perl DateTime objects

=head1 SYNOPSIS

  use DateTime;

  $dt = DateTime->new( year   => 1964,
                       month  => 10,
                       day    => 16,
                       hour   => 16,
                       minute => 12,
                       second => 47,
                     );

  $dt = DateTime->new( ical => '19971024T120000' );

  $dt = DateTime->new( epoch => time );

  $year   = $dt->year;          # ?-neg 1, 1-..
  $month  = $dt->month;         # 1-12
  # also $dt->mon

  $day    = $dt->day;           # 1-31
  # also $dt->day_of_month, $dt->mday

  $dow    = $dt->day_of_week;   # 1-7 (Monday is 1)
  # also $dt->dow, $dt->wday

  $hour   = $dt->hour;          # 0-23
  $minute = $dt->minute;        # 0-59
  # also $dt->min

  $second = $dt->second;        # 0-60 (leap seconds!)
  # also $dt->sec

  $doy    = $dt->day_of_year    # 1-366 (leap years)

  # all of the start-at-1 methods above have correponding start-at-0
  # methods, such as $dt->day_of_month_0, $dt->month_0 and so on

  $ymd    = $dt->ymd            # 2002-12-06
  $ymd    = $dt->ymd('/')       # 2002/12/06
  # also $dt->date

  $mdy    = $dt->mdy            # 12-06-2002
  $mdy    = $dt->mdy('/')       # 12/06/2002

  $dmy    = $dt->dmy            # 06-12-2002
  $dmy    = $dt->dmy('/')       # 06/12/2002

  $hms    = $dt->hms            # 14:02:29
  $hms    = $dt->hms('!')       # 14!02!29
  # also $dt->time

  $datetime = $dt->datetime     # 2002-12-06T14:02:29
  # also $dt->iso8601

  $is_leap  = $dt->is_leap_year;

  # these are localizable, see LANGUAGES section
  $month_name  = $dt->month_name # January, February
  $month_abbr  = $dt->month_abbr # Jan, Feb
  $day_name    = $dt->day_name   # Sunday, Monday
  $day_abbr    = $dt->day_abbr   # Sun, Mon

  $ical_string = $dt->ical;
  $epoch_time  = $dt->epoch;     # may return undef for none epoch times

  $dt2 = $ical + $duration;

(Where $duration is either a duration string, like 'P2W3DT7H9M', or a
DateTime::Duration object.

  $dt += 'P6DT12H';

  $duration = $dt1 - $dt2;
  $dt3 = $ical1 - $duration;

=head1 DESCRIPTION

DateTime is the reference implementation for the base DateTime object
API.  For details on the Perl DateTime Suite project please see
L<http://perl-date-time.sf.net>.

See http://dates.rcbowen.com/unified.txt for details

=head1 LANGUAGES

write me

=head1 METHODS

DateTime has the following methods available:

=head2 new

A new DateTime object can be created with any valid ICal string:

  my $dt = DateTime->new( ical => '19971024T120000' );
  # will default to the timezone specified in $TZ, see below

Or with any epoch time:

  my $dt = DateTime->new( epoch => time );

Or, better still, create it with components

  my $dt = DateTime->new( day => 25,
                          month => 10,
                          year => 1066,
                          hour => 7,
                          minute => 15,
                          second => 47,
                        );

If you call new without any arguments, you'll get a DateTime object that is
set to the time right now.

  my $dt = DateTime->new();
  # same as
  my $dt = DateTime->new( epoch => time );

The new() method handles timezones. It defaults times to UTC
(Greenwich Mean Time, also called Zulu). If you want to set up a time
that's in the US "Pacific" timezone, which is GMT-8, use something
like:

  my $ical = DateTime->new( ical   => '19971024T120000',
                            offset => '-0800');

The new() method tries to be intelligent about figuring out your local
time zone. If you enter a time that's not *explicitly* in UTC, it
looks at the environment variable C<TZ>, if it exists, to determine
your local offset.  If the C<TZ> environment variable is not set, then
an offset of 0 is used.

=head2 ical

  $ical_string = $dt->ical;

Retrieves, or sets, the date on the object, using any valid ICal date/time
string. Output is in UTC (ends with a "Z") by default. To get
output in localtime relative to the current machine, do:

  $ical_string = $dt->ical( localtime => 1 );

To get output relative to an arbitrary offset, do:

  $ical_string = $dt->ical( offset => '+0545' );

=head2 epoch

  $epoch_time = $dt->epoch;
  $dt->epoch( 98687431 );

Sets, or retrieves, the epoch time represented by the object, if it is
representable as such. (Dates before 1971 or after 2038 will not have an epoch
representation.)

Internals note: The ICal representation of the date is considered the only
authoritative one. This means that we may need to reconstruct the epoch time
from the ICal representation if we are not sure that they are in synch. We'll
need to do clever things to keep track of when the two may not be in synch.
And, of course, the same will go for any subclasses of this class.

=head2 offset

  $offset = $dt->offset;

  $dt->offset( '+1100' ); # a number of hours and minutes: UTC+11
  $dt->offset( 0 );       # reset to UTC

Sets or retrieves the offset from UTC for this time. This allows
timezone support, assuming you know what your local (or non-local)
UTC offset is.  Defaults to 0.

Internals note: all times are internally stored in UTC, even though they
may have some offset information. Offsets are internally stored in
signed integer seconds.

BE CAREFUL about using this function on objects that were initialized
with an offset. If you started an object with:

  my $d = new(ical=>'19700101120000', offset=>'+0100');

and you then call:

  $d->offset('+0200');

you'll be saying "Yeah, I know I *said* it was in +0100, but really I
want it to be in +0200 now and forever." Which may be your intention,
if you're trying to transpose a whole set of dates to another timezone---
but you can also do that at the presentation level, with
the ical() method. Either way will work.

=head2 add

  $dt->add( years   => 3,
            months  => 2,
            weeks   => 1,
            days    => 12,
            hours   => 1,
            minutes => 34,
            seconds => 59,
          );

  # add 1 wk, 1 hr, 1 min, and 1 sec
  $dt->add( duration => 'P1WT1H1M1S' );

Adds a duration to a DateTime object.

Supported paraters are: duration, eom_mode, year, month, week, day,
hour, min, sec or seconds.

'duration' is an ICalendar duration string.

If a value is undefined or omitted, 1 is assumed:

    $dt->add( 'minute' ); # add a minute

The result will be normalized. That is, the output time will have
meaningful values, rather than being 48:73 pm on the 34th of
hexadecember.

Adding months or years can be done via three different methods,
specified by the eom_mode parameter, which then applies to all
additions (or subtractions) of months or years following it in the
parameter list.

The default, eom_mode => 'wrap', means adding months or years that
result in days beyond the end of the new month will roll over into the
following month.  For instance, adding one year to Feb 29 will result
in Mar 1.

If you specify eom_mode => 'limit', the end of the month is never
crossed.  Thus, adding one year to Feb 29, 2000 will result in Feb 28,
2001.  However, adding three more years will result in Feb 28, 2004,
not Feb 29.

If you specify eom_mode => 'preserve', the same calculation is done as
for 'limit' except that if the original date is at the end of the
month the new date will also be.  For instance, adding one month to
Feb 29, 2000 will result in Mar 31, 2000.

All additions are performed in the order specified.  For instance,
with the default setting of eom_mode => 'wrap', adding one day and one
month to Feb 29 will result in Apr 1, while adding one month and one
day will result in Mar 30.

=head2 subtract

  $duration = $dt1 - $dt2;

Subtract one DateTime object from another to give a duration - the
length of the interval between the two dates. The return value is a
DateTime::Duration object (qv) and allows you to get at each of the
individual components, or the entire duration string:

  $d = $dt1 - $X;

Note that $X can be any of the following:

If $X is another DateTime object (or subclass thereof) then $d will be
a DateTime::Duration object.

  $week = $d->weeks; # how many weeks apart?
  $days = $d->as_days; # How many days apart?

If $X is a duration string, or a DateTime::Duration object, then $d
will be an object in the same class as $dt1;

  $newdate = $dt - $duration;

=head2 clone

  $copy = $dt->clone;

Returns a replica of the date object, including all attributes.

=head2 compare

  $cmp = DateTime->compare($dt1, $dt2);

  @dates = sort { DateTime->compare($a, $b) } @dates;

Compare two DateTime objects. Semantics are compatible with sort;
returns -1 if $a < $b, 0 if $a == $b, 1 if $a > $b.

=head2 day

  my $day = $dt->day;

Returns the day of the month.

Day is in the range 1..31

=head2 month

  my $month = $dt->month;

Returns the month of the year.

Month is returned as a number in the range 1..12

=head2 year

  my $year = $dt->year;

Returns the year.

=head2 day_of_year

  $yday = $dt->day_of_year;

Returns the day of the year.  Analogous to the yday attribute of
gmtime (or localtime) except that it works outside of the epoch.

=head2 day_of_week

  $day_of_week = $dt->day_of_week

Returns the day of the week as a number, from 1 to 7, with 1 being
Monday and 7 being Sunday.

=head2 hour

  $hour = $dt->hour

Returns the hour of the day.

Hour is in the range 0..23

=head2 min

  $min = $dt->min;

Returns the minute.

Minute is in the range 0..59

=head2 sec

  $sec = $dt->sec;

Returns the second.

Second is in the range 0..60. The value of 60 is (maybe) needed for
leap seconds. But I'm not sure if we're going to go there.

=head2 week

 ($week_year, $week_number) = $dt->week

Returns information about the calendar week which contains this
datetime object. The values returned by this method are also available
separately through the week_year and week_number methods, below.

The first week of the year is defined as the one which contains the
fourth of January, which is equivalent to saying that it's the first
week to overlap the new year by at least four days.

Typically the week_year will be the same as the year that the datetime
object is in, but dates at the very begining of a calendar year often
end up in the last week of the prior year, and similarly, the final
few days of the year may be placed in the first week of the next year.

=head2 week_year

Returns the year of the week, such as 1968 or 2003.

=head2 week_number

Returns the week of the year as a number in the range 1..53.

=head1 0-BASED VERSUS 1-BASED NUMBERS

The DateTime.pm module follows a simple consistent logic for
determining whether or not a given number is 0-based or 1-based.

All I<date>-related numbers such as year, month, day of
month/week/year, are 1-based.

All I<time>-related numbers such as hour, minute, and second are
0-based.

=head1 AUTHOR

The core implementation of this module comes from Date::ICal by Rich
Bowen <rbowen@rcbowen.com> and the Reefknot team.

Parts of the API come from Time::Piece, by Matt Sergeant
<matt@sergeant.org>, who had help from Jarkko Hietaniemi <jhi@iki.fi>

The DateTime::Language functionality is largely based on the
Date::Language modules that come with Graham Barr's <gbarr@pobox.com>
TimeDate module suite.  The strftime and strptime methods in this
module also borrow heavily from Graham's implementation.

Dave Rolsky <autarch@urth.org> jammed all the round pegs in the square
holes until they fit, in order to produce DateTime.pm and its
associated helpers.

=head1 SEE ALSO

datetime@perl.org mailing list

http://perl-date-time.sf.net/

http://dates.rcbowen.com/

=cut
