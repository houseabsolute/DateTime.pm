package DateTime;

use strict;

use vars qw($VERSION);

$VERSION = '0.05';

use Date::Leapyear ();
use DateTime::Duration;
use DateTime::TimeZone;
use DateTime::TimeZone::UTC;
use Params::Validate qw( validate SCALAR BOOLEAN OBJECT );
use Time::Local ();

# for some reason, overloading doesn't work unless fallback is listed
# early.
use overload ( 'fallback' => 1,
               '<=>' => 'compare',
               'cmp' => 'compare',
               '-' => '_subtract_overload',
               '+' => '_add_overload',
               '""' => '_stringify',
             );

my( @MonthLengths, @LeapYearMonthLengths,
    @BeginningOfMonthDayOfYear, @BeginningOfMonthDayOfLeapYear,
  );

{
    # I'd rather use Class::Data::Inheritable for this, but there's no
    # way to add the module-loading behavior to an accessor it
    # creates, despite what its docs say!
    my $DefaultLanguage;
    sub DefaultLanguage {
        my $class = shift;

        if (@_) {
            my $lang = shift;

            my $lang_class = 'DateTime::Language::' . ucfirst lc $lang;

            eval "use $lang_class";
            die $@ if $@;

            $DefaultLanguage = $lang;
        }

        return $DefaultLanguage;
    }
}
__PACKAGE__->DefaultLanguage('English');

sub new {
    my $class = shift;
    my %args = validate( @_,
                         { year   => { type => SCALAR },
                           month  => { type => SCALAR, default => 1 },
                           day    => { type => SCALAR, default => 1 },
                           hour   => { type => SCALAR, default => 0 },
                           minute => { type => SCALAR, default => 0 },
                           second => { type => SCALAR, default => 0 },
                           language  => { type => SCALAR | OBJECT,
                                          default => $class->DefaultLanguage },
                           time_zone => { type => SCALAR | OBJECT,
                                          default => 'local' },
                         }
                       );

    my $self = {};

    if ( ref $args{language} )
    {
        $self->{language} = $args{language};
    }
    else
    {
        my $lang_class = 'DateTime::Language::' . ucfirst lc $args{language};
        eval "use $lang_class";
        die $@ if $@;
        $self->{language} = $lang_class->new;
    }

    $self->{tz} =
        ( ref $args{time_zone} ?
          $args{time_zone} :
          DateTime::TimeZone->new( name => $args{time_zone} )
        );

    # if user gives us year -10 that's really -9 to us, since we start
    # at year 0 internally
    $args{year}++ if $args{year} < 0;
    $self->{local_rd_days} =
        $class->_greg2rd( @args{ qw( year month day ) } );

    $self->{local_rd_secs} =
        $class->time_as_seconds( @args{ qw( hour minute second ) } );

    bless $self, $class;

    $self->_calc_components;
    $self->_calc_utc_rd;

    return $self;
}

sub _calc_utc_rd {
    my $self = shift;

    if ( $self->{tz}->is_utc ) {
        $self->{utc_rd_days} = $self->{local_rd_days};
        $self->{utc_rd_secs} = $self->{local_rd_secs};

        return;
    }

    $self->{utc_rd_days} = $self->{local_rd_days};
    $self->{utc_rd_secs} =
        $self->{local_rd_secs} - $self->_offset_from_local_time;

    _normalize_seconds( $self->{utc_rd_days}, $self->{utc_rd_secs} );
}

sub _calc_local_rd {
    my $self = shift;

    # We must short circuit for UTC times or else we could end up with
    # loops between DateTime.pm and DateTime::TimeZone
    if ( $self->{tz}->is_utc ) {
        $self->{local_rd_days} = $self->{utc_rd_days};
        $self->{local_rd_secs} = $self->{utc_rd_secs};
    } else {
        $self->{local_rd_days} = $self->{utc_rd_days};
        $self->{local_rd_secs} = $self->{utc_rd_secs} + $self->offset;

        _normalize_seconds( $self->{local_rd_days}, $self->{local_rd_secs} );
    }

    $self->_calc_components;
}

sub _calc_components {
    my $self = shift;

    # c stands for components or cache ;)
    delete $self->{c};

    @{ $self->{c} }{ qw( year month day ) } =
        $self->_rd2greg( $self->{local_rd_days} );

    my $time = $self->{local_rd_secs};

    @{ $self->{c} }{ qw( hour minute second ) } =
        $self->_seconds_as_components( $self->{local_rd_secs} );

    $self->{c}{day_of_week} = ( ( $self->{local_rd_days} + 6) % 7 ) + 1;

    {
        my $d = $self->_beginning_of_month_day_of_year( $self->{c}{year},
                                                        $self->{c}{month},
                                                      );
        $self->{c}{day_of_year} = $d + $self->{c}{day};
    }
}

sub from_epoch {
    my $class = shift;
    my %args = validate( @_,
                         { epoch => { type => SCALAR },
                           language  => { type => SCALAR | OBJECT, optional => 1 },
                         }
                       );

    my %p;
    # Note, for very large negative values this may give a blatantly
    # wrong answer.
    @p{ qw( second minute hour day month year ) } =
        ( gmtime( delete $args{epoch} ) )[ 0..5 ];
    $p{year} += 1900;
    $p{month}++;

    # pass other args like time_zone to constructor
    return $class->new( %args, %p, time_zone => 'UTC' );
}

# use scalar time in case someone's loaded Time::Piece
sub now { shift->from_epoch( epoch => (scalar time), @_ ) }

sub from_object {
    my $class = shift;
    my %args = validate( @_,
                         { object => { type => OBJECT,
                                       can => 'utc_rd_values',
                                     },
                           language  => { type => SCALAR | OBJECT, optional => 1 },
                           time_zone => { type => SCALAR | OBJECT, optional => 1 },
                         },
                       );

    my $object = delete $args{object};

    my ( $rd_days, $rd_secs ) = $object->utc_rd_values;

    my %p;
    @p{ qw( year month day ) } = $class->_rd2greg($rd_days);
    @p{ qw( hour minute second ) } = $class->_seconds_as_components($rd_secs);

    return $class->new( %p, %args );
}

sub last_day_of_month {
    my $class = shift;
    my %p = validate( @_,
                      { year   => { type => SCALAR },
                        month  => { type => SCALAR },
                        hour   => { type => SCALAR, optional => 1 },
                        minute => { type => SCALAR, optional => 1 },
                        second => { type => SCALAR, optional => 1 },
                        language  => { type => SCALAR | OBJECT, optional => 1 },
                        time_zone => { type => SCALAR | OBJECT, optional => 1 },
                      }
                    );

    my $day = ( Date::Leapyear::isleap( $p{year} ) ?
                $LeapYearMonthLengths[ $p{month} - 1 ] :
                $MonthLengths[ $p{month} - 1 ]
              );

    return $class->new( %p, day => $day );
}

sub clone { bless { %{ $_[0] } }, ref $_[0] }

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

sub time_as_seconds {
    shift;
    my ( $hour, $min, $sec ) = @_;

    $hour ||= 0;
    $min ||= 0;
    $sec ||= 0;

    my $secs = $hour * 3600 + $min * 60 + $sec;
    return $secs;
}

sub _rd2greg {
    shift; # ignore class

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
    } elsif ( ( $d += 306 ) <= 0 ) {
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

sub _greg2rd {
    shift; # ignore class

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

sub _seconds_as_components {
    shift;
    my $time = shift;

    my $hour = int( $time / 3600 );
    $time -= $hour * 3600;

    my $minute = int( $time / 60 );

    my $second = $time - ( $minute * 60 );

    return ( $hour, $minute, $second );
}


BEGIN {

    @MonthLengths =
        ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

    @LeapYearMonthLengths = @MonthLengths;
    $LeapYearMonthLengths[1]++;

    my $x = 0;
    foreach my $length ( @MonthLengths )
    {
        push @BeginningOfMonthDayOfYear, $x;
        $x += $length;
    }

    @BeginningOfMonthDayOfLeapYear = @BeginningOfMonthDayOfYear;

    $BeginningOfMonthDayOfLeapYear[$_]++ for 2..11;
}

sub _beginning_of_month_day_of_year {
    shift;
    my ($y, $m) = @_;
    $m--;
    return
        ( Date::Leapyear::isleap($y) ?
          $BeginningOfMonthDayOfLeapYear[$m] :
          $BeginningOfMonthDayOfYear[$m]
        );
}

sub year    { $_[0]->{c}{year} <= 0 ? $_[0]->{c}{year} - 1 : $_[0]->{c}{year} }
sub year_0  { $_[0]->{c}{year} }

sub month   { $_[0]->{c}{month} }
*mon = \&month;

sub month_0 { $_[0]->{c}{month} - 1 };
*mon_0 = \&month_0;

sub month_name {
    my $self = shift;
    return $self->{language}->month_name($self);
}

sub month_abbr {
    my $self = shift;
    return $self->{language}->month_abbreviation($self);
}

sub day_of_month { $_[0]->{c}{day} }
*day  = \&day_of_month;
*mday = \&day_of_month;

sub day_of_month_0 { $_[0]->{c}{day} - 1 }
*day_0  = \&day_of_month_0;
*mday_0 = \&day_of_month_0;

sub day_of_week { $_[0]->{c}{day_of_week} }
*wday = \&day_of_week;
*dow  = \&day_of_week;

sub day_of_week_0 { $_[0]->{c}{day_of_week} - 1 }
*wday_0 = \&day_of_week_0;
*dow_0  = \&day_of_week_0;

sub day_name {
    my $self = shift;
    return $self->{language}->day_name($self);
}

sub day_abbr {
    my $self = shift;
    return $self->{language}->day_abbreviation($self);
}

sub day_of_year { $_[0]->{c}{day_of_year} }
*doy = \&day_of_year;

sub day_of_year_0 { $_[0]->{c}{day_of_year} - 1 }
*doy_0 = \&day_of_year_0;

sub ymd {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%0.4d%s%0.2d%s%0.2d",
                    $self->year, $sep,
                    $self->{c}{month}, $sep,
                    $self->{c}{day} );
}
*date = \&ymd;

sub mdy {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%0.2d%s%0.2d%s%0.4d",
                    $self->{c}{month}, $sep,
                    $self->{c}{day}, $sep,
                    $self->year );
}

sub dmy {
    my ( $self, $sep ) = @_;
    $sep = '-' unless defined $sep;
    return sprintf( "%0.2d%s%0.2d%s%0.4d",
                    $self->{c}{day}, $sep,
                    $self->{c}{month}, $sep,
                    $self->year );
}

sub hour   { $_[0]->{c}{hour} }

sub minute { $_[0]->{c}{minute} }
*min = \&minute;

sub second { $_[0]->{c}{second} }
*sec = \&second;

sub hms {
    my ( $self, $sep ) = @_;
    $sep = ':' unless defined $sep;
    return sprintf( "%0.2d%s%0.2d%s%0.2d",
                    $self->{c}{hour}, $sep,
                    $self->{c}{minute}, $sep,
                    $self->{c}{second} );
}
# don't want to override CORE::time()
*DateTime::time = \&hms;

sub iso8601 {
    my $self = shift;

    # ISO 8601 uses astronomical years
    my $ymd = sprintf( '%0.4d-%0.2d-%0.2d',
                       @{ $self->{c} }{ 'year', 'month', 'day' } );

    return join 'T', $ymd, $self->hms(':');
}
*datetime = \&iso8601;

sub is_leap_year { Date::Leapyear::isleap( $_[0]->year ) ? 1 : 0 }

sub week
{
    my $self = shift;

    unless ( defined $self->{c}{week_year} )
    {
        my $mid_week = $self->clone;
        # Thursday if Sunday is the first day of the week
        $mid_week->add( days => 4 - ( ( $self->{local_rd_days} % 7 ) + 1 ) );
        $self->{c}{week_year} = $mid_week->year;

        my $jan_four = $self->_greg2rd( $self->{c}{week_year}, 1, 4 );
        my $first_week = $jan_four - ( $jan_four % 7 );
        $self->{c}{week_number} =
            int( ( $self->{local_rd_days} - $first_week ) / 7 ) + 1;
    }

    return @{ $self->{c} }{ 'week_year', 'week_number' }
}

sub week_year   { ($_[0]->week)[0] }
sub week_number { ($_[0]->week)[1] }

sub time_zone { $_[0]->{tz} }

sub offset { $_[0]->{tz}->offset_for_datetime( $_[0] ) }
sub _offset_from_local_time { $_[0]->{tz}->offset_for_local_datetime( $_[0] ) }

sub is_dst { $_[0]->{tz}->is_dst_for_datetime( $_[0] ) }

sub time_zone_short_name { $_[0]->{tz}->short_name_for_datetime( $_[0] ) }

sub language { $_[0]->{language} }

sub utc_rd_values { @{ $_[0] }{ 'utc_rd_days', 'utc_rd_secs' } }

sub utc_rd_as_seconds   { ( $_[0]->{utc_rd_days} * 86400 )   + $_[0]->{utc_rd_secs} }
sub local_rd_as_seconds { ( $_[0]->{local_rd_days} * 86400 ) + $_[0]->{local_rd_secs} }

my %formats =
    ( 'a' => sub { $_[0]->day_abbr },
      'A' => sub { $_[0]->day_name },
      'b' => sub { $_[0]->month_abbr },
      'B' => sub { $_[0]->month_name },
#      'c' => sub { $_[0]->strftime( $_[0]->{language}->preferred_datetime_format ) },
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
#      'x' => sub { $_[0]->strftime( $_[0]->{language}->preferred_date_format ) },
#      'X' => sub { $_[0]->strftime( $_[0]->{language}->preferred_time_format ) },
      'y' => sub { sprintf( '%02d', substr( $_[0]->year, -2 ) ) },
      'Y' => sub { return $_[0]->year },
      'z' => sub { DateTime::TimeZone::offset_as_string( $_[0]->offset ) },
      'Z' => sub { $_[0]->{tz}->short_name_for_datetime( $_[0] ) },
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
	        %([%a-zA-Z])
	       /
                $formats{$1} ? $formats{$1}->($self) : $1
               /sgex;

        return $f unless wantarray;

        push @r, $f;
    }

    return @r;
}

sub epoch {
    my $self = shift;

    return $self->{c}{epoch} if exists $self->{c}{epoch};

    my ( $year, $month, $day )  = $self->_rd2greg( $self->{utc_rd_days} );
    my @hms = $self->_seconds_as_components( $self->{utc_rd_secs} );

    $self->{c}{epoch} =
        eval { Time::Local::timegm( ( reverse @hms ),
                                    $day,
                                    $month - 1,
                                    $year - 1900,
                                  ) };

    return $self->{c}{epoch};
}

sub add { shift->add_duration( DateTime::Duration->new(@_) ) }

sub subtract { shift->subtract_duration( DateTime::Duration->new(@_) ) }

sub subtract_duration { $_[0]->add_duration( $_[1]->inverse ) }

sub subtract_datetime {
    my $self = shift;
    my $dt = shift;

    # We only want a negative duration if $dt > $self.  If just the
    # seconds are greater (but the days are equal or less), then
    # returning a negative duration is wrong.

    if ( $self->{utc_rd_days} == $dt->{utc_rd_days} )
    {
        return
            DateTime::Duration->new
                ( seconds => $self->{utc_rd_secs} - $dt->{utc_rd_secs} );
    }
    elsif ( $self->{utc_rd_days} > $dt->{utc_rd_days} &&
            $self->{utc_rd_secs} < $dt->{utc_rd_secs} )
    {
        my $days = $self->{utc_rd_days} - 1;
        my $secs = $self->{utc_rd_secs} + 86400;

        return
            DateTime::Duration->new
                ( days    => $days - $dt->{utc_rd_days},
                  seconds => $secs - $dt->{utc_rd_secs} );
    }
    elsif ( $dt->{utc_rd_days} > $self->{utc_rd_days} &&
            $dt->{utc_rd_secs} < $self->{utc_rd_secs} )
    {
        my $days = $dt->{utc_rd_days} - 1;
        my $secs = $dt->{utc_rd_secs} + 86400;

        return
            DateTime::Duration->new
                ( days    => $self->{utc_rd_days} - $days,
                  seconds => $self->{utc_rd_secs} - $secs );
    }
    else
    {
        return
            DateTime::Duration->new
                ( days    => $self->{utc_rd_days} - $dt->{utc_rd_days},
                  seconds => $self->{utc_rd_secs} - $dt->{utc_rd_secs} );
    }
}

sub _add_overload {
    my ( $dt, $dur, $reversed ) = @_;

    if ($reversed) {
        ( $dur, $dt ) = ( $dt, $dur );
    }

    # how to handle non duration objects?

    my $new = $dt->clone;
    $new->add_duration($dur);
    return $new;
}

sub _subtract_overload {
    my ( $date1, $date2, $reversed ) = @_;

    if ($reversed) {
        ( $date2, $date1 ) = ( $date1, $date2 );
    }

    if ( UNIVERSAL::isa( $date2, 'DateTime::Duration' ) ) {
        my $new = $date1->clone;
        $new->add_duration( $date2->inverse );
        return $new;
    } else {
        return $date1->subtract_datetime($date2);
    }
    # handle other cases?
}

sub add_duration {
    my ( $self, $dur ) = @_;

    my %deltas = $dur->deltas;

    $self->{utc_rd_days} += $deltas{days} if $deltas{days};

    if ( $deltas{seconds} )
    {
        $self->{utc_rd_secs} += $deltas{seconds};
        _normalize_seconds( $self->{utc_rd_days}, $self->{utc_rd_secs} );
    }

    if ( $deltas{months} )
    {
        # For preserve mode, if it is the last day of the month, make
        # it the 0th day of the following month (which then will
        # normalize back to the last day of the new month).
        my ($y, $m, $d) = ( $dur->is_preserve_mode ?
                            $self->_rd2greg( $self->{utc_rd_days} + 1 ) :
                            $self->_rd2greg( $self->{utc_rd_days} )
                          );
        $d -= 1 if $dur->is_preserve_mode;

        if ( ! $dur->is_wrap_mode && $d > 28 )
        {
            # find the rd for the last day of our target month
            $self->{utc_rd_days} = $self->_greg2rd( $y, $m + $deltas{months} + 1, 0 );

            # what day of the month is it? (discard year and month)
            my $last_day = ($self->_rd2greg( $self->{utc_rd_days} ))[2];

            # if our original day was less than the last day,
            # use that instead
            $self->{utc_rd_days} -= $last_day - $d if $last_day > $d;
        }
        else
        {
            $self->{utc_rd_days} = $self->_greg2rd( $y, $m + $deltas{months}, $d );
        }
    }

    $self->_calc_local_rd;
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

sub set {
    my $self = shift;
    my %p = validate( @_,
                      { year     => { type => SCALAR, optional => 1 },
                        month    => { type => SCALAR, optional => 1 },
                        day      => { type => SCALAR, optional => 1 },
                        hour     => { type => SCALAR, optional => 1 },
                        minute   => { type => SCALAR, optional => 1 },
                        second   => { type => SCALAR, optional => 1 },
                        language => { type => SCALAR, optional => 1 },
                      } );

    my %old_p =
        ( map { $_ => $self->$_() }
          qw( year month day hour minute second language time_zone )
        );

    my $new_dt = (ref $self)->new( %old_p, %p );

    %$self = %$new_dt;
}

sub set_time_zone {
    my ( $self, $tz ) = @_;

    my $was_floating = $self->{tz}->is_floating;

    $self->{tz} = ref $tz ? $tz : DateTime::TimeZone->new( name => $tz );

    if ( $self->{tz}->is_floating && ! $was_floating )
    {
        $self->_calc_utc_rd;
    }
    elsif ( ! $was_floating )
    {
        $self->_calc_local_rd;
    }
}

# like "scalar localtime()" in Perl
sub _stringify { $_[0]->strftime( '%a, %d %b %Y %H:%M:%S %Z' ) }


1;

__END__

=head1 NAME

DateTime - Reference implementation for Perl DateTime objects

=head1 SYNOPSIS

  use DateTime;

  $dt = DateTime->new( year   => 1964,
                       month  => 10,
                       day    => 16,
                       hour   => 16,
                       minute => 12,
                       second => 47,
                       time_zone => 'Asia/Taipei',
                     );

  $dt = DateTime->from_epoch( epoch => $epoch );
  $dt = DateTime->now; # same as ( epoch => time() )

  $year   = $dt->year;          # there is no year 0
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
  # also $dt->doy

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

  $is_leap  = $dt->is_leap_year;

  # these are localizable, see LANGUAGES section
  $month_name  = $dt->month_name # January, February, ...
  $month_abbr  = $dt->month_abbr # Jan, Feb, ...
  $day_name    = $dt->day_name   # Monday, Tuesday, ...
  $day_abbr    = $dt->day_abbr   # Mon, Tue, ...

  $epoch_time  = $dt->epoch;
  # may return undef if the datetime is outside the range that is
  # representable by your OS's epoch system.

  $dt2 = $dt + $duration_object;

  $dt3 = $dt - $duration_object;

  $duration_object = $dt - $dt2;

  $dt->set( year => 1882 );

  $dt->set_time_zone( 'America/Chicago' );

=head1 DESCRIPTION

DateTime is the reference implementation for the base DateTime object
API.  For details on the Perl DateTime Suite project please see
L<http://perl-date-time.sf.net>.

=head1 LANGUAGES

Some methods are localizable by setting a language for a DateTime
object.  There is also a C<DefaultLanguage()> class method which may
be used to set the default language for all DateTime objects created.

Languages are defined by creating a DateTime::Language subclass.
Currently, the following language subclasses exist:

=over 4

=item * Austrian

=item * Czech

=item * Dutch

=item * English

=item * French

=item * German

=item * Italian

=item * Norwegian

=back

If there is neither a class default or language constructor parameter,
then the "default default" language is English.

Additional language subclasses are welcome.  See the Perl DateTime
Suite project page at http://perl-date-time.sf.net/ for more details.

=head1 ERROR HANDLING

Some errors may cause this module to die with an error string.  This
can only happen when calling constructor methods or methods that
change the object, such as C<set()>.  Methods that retrieve
information about the object, such as C<strftime()>, will never die.

=head1 METHODS

=head2 Constructors

All constructors can die when invalid parameters are given.

=over 4

=item * new( ... )

This class method accepts parameters for each date and time component,
"year", "month", "day", "hour", "minute", "second".  Additionally, it
accepts "language" and "time_zone" parameters.

  my $dt = DateTime->new( day => 25,
                          month => 10,
                          year => 1066,
                          hour => 7,
                          minute => 15,
                          second => 47,
                          time_zone => 'America/Chicago',
                        );

The behavior of this module when given parameters outside proper
boundaries (like a minute parameter of 72) is not defined, though
future versions may die.

Invalid parameter types (like an array reference) will cause the
constructor to die.

All of the parameters are optional except for "year".  The "month" and
"day" parameters both default to 1, while the "hour", "minute", and
"second" parameters all default to 0.

The language parameter should be a strict matching one of the valid
languages L<previously listed|/LANGUAGES>.

The time_zone parameter can be either a scalar or a
C<DateTime::TimeZone> object.  A string will simply be passed to the
C<< DateTime::TimeZone->new >> method as its "name" parameter.  This
string may be an Olson DB time zone name ("America/Chicago"), an
offset string ("+0630"), or the words "floating" or "local".  See the
C<DateTime::TimeZone> documentation for more details.

=item * from_epoch( epoch => $epoch, ... )

This class method can be used to construct a new DateTime object from
an epoch time instead of components.  Just as with the C<new()>
method, it accepts a "language" parameter.  The time zone will always
be "UTC" for any object created from an epoch.  This can be changed
once the object is created.

=item * now( ... )

This class method is equivalent to calling C<from_epoch()> with the
value returned from Perl's C<time()> function.

=item * from_object( object => $object, ... )

This class method can be used to construct a new DateTime object from
any object that implements the C<utc_rd_values()> method.  All
C<DateTime::Calendar> modules must implement this method in order to
provide cross-calendar compatibility.  Just as with the C<new()>
method, it accepts "language" and "time_zone" parameters.

=item * last_day_of_month( ... )

This constructor takes the same arguments as can be given to the
C<now()> method, except for "day".  Additionally, both "year" and
"month" are required.

=item * clone

This object method returns a replica of the given object.

=back

=head1 USAGE

=head2 0-based Versus 1-based Numbers

The DateTime.pm module follows a simple consistent logic for
determining whether or not a given number is 0-based or 1-based.

All I<date>-related numbers such as year, month, day of
month/week/year, are 1-based.  Any method that is one based also has
an equivalent 0-based method ending in "_0".  So for example, this
class provides both C<day_of_week()> and C<day_of_week_0()> methods.

The C<year_0> method treats the year -1 BCE as year 0, as is
conventional in astronomy.

The C<day_of_week_0> method still treats Monday as the first day of
the week.

All I<time>-related numbers such as hour, minute, and second are
0-based.

=head2 Methods

This module has quite a number of methods for retrieving information
about an object.

=over 4

=item * year

Returns the year.  There is no year 0.  The year before year 1 is year
-1.

=item * month

Returns the month of the year, from 1..12.

=item * month_name

Returns the name of the current month.  See the
L<LANGUAGES|/LANGUAGES> section for more details.

=item * month_abbr

Returns the abbreviated name of the current month.  See the
L<LANGUAGES|/LANGUAGES> section for more details.

=item * day_of_month, day, mday

Returns the day of the month, from 1..31.

=item * day_of_week, wday, dow

Returns the day of the week as a number, from 1..7, with 1 being
Monday and 7 being Sunday.

=item * day_name

Returns the name of the current day of the week.  See the
L<LANGUAGES|/LANGUAGES> section for more details.

=item * day_abbr

Returns the abbreviated name of the current day of the week.  See the
L<LANGUAGES|/LANGUAGES> section for more details.

=item * day_of_year, doy

Returns the day of the year.

=item * ymd( $optional_separator ), date

=item * mdy( $optional_separator )

=item * dmy( $optional_separator )

Each method returns the year, month, and day, in the order indicated
by the method name.  Years are zero-padded to four digits.  Months and
days are 0-padded to two digits.

By default, the values are separated by a dash (-), but this can be
overridden by passing a value to the method.

=item * hour

Returns the hour of the day, from 0..23.

=item * minute, min

Returns the minute of the hour, from 0..59.

=item * second, sec

Returns the second., from 0..61.  The values 60 and 61 are used for
leap seconds.

=item * hms( $optional_separator ), time

Returns the hour, minute, and second, all zero-padded to two digits.
If no separator is specified, a colon (:) is used by default.

=item * datetime, iso8601

This method is equivalent to:

  $dt->ymd('-') . 'T' . $dt->hms(':')

I<except> that the year is the year as returned by the C<year_0()>
method.

=item * is_leap_year

This method returns a true or false indicating whether or not the
datetime object is in a leap year.

=item * week

 ($week_year, $week_number) = $dt->week

Returns information about the calendar week which contains this
datetime object. The values returned by this method are also available
separately through the week_year and week_number methods.

The first week of the year is defined by ISO as the one which contains
the fourth day of January, which is equivalent to saying that it's the
first week to overlap the new year by at least four days.

Typically the week year will be the same as the year that the object
is in, but dates at the very begining of a calendar year often end up
in the last week of the prior year, and similarly, the final few days
of the year may be placed in the first week of the next year.

=item * week_year

Returns the year of the week.

=item * week_number

Returns the week of the year, from 1..53.

=item * time_zone

This returns the C<DateTime::TimeZone> object for the datetime object.

=item * offset

This returns the offset, in seconds, of the datetime object according
to the time zone.

=item * is_dst

Returns a boolean indicating whether or not the datetime object is
currently in Daylight Saving Time or not.

=item * time_zone_short_name

This method returns the time zone abbreviation for the current time
zone, such as "PST" or "GMT".  These names are B<not> definitive, and
should not be used in any application intended for general use by
users around the world.

=item * utc_rd_values

Returns the current UTC Rata Die days and seconds as a two element
list.  This exists primarily to allow other calendar modules to create
objects based on the values provided by this object.

=item * utc_rd_as_seconds

Returns the current UTC Rata Die days and seconds purely as seconds.
This is useful when you need a single number to represent a date.

=item * local_rd_as_seconds

Returns the current local Rata Die days and seconds purely as seconds.

=item * strftime( $format, ... )

This method implements functionality similar to the C<strftime()>
method in C.  However, if given multiple format strings, then it will
return multiple elements, one for each format string.

See the L<strftime Specifiers|/strftime Specifiers> section for a list of
all possible format specifiers.

=item * epoch

Return the epoch value for the datetime object.  Internally, this is
implemented using C<Time::Local>, which uses the Unix epoch even on
machines with a different epoch (such as MacOS).  Datetimes before the
start of the epoch will be returned as a negative number.

Since epoch times cannot represent many dates on most platforms, this
method may simply return undef in some cases.

Using your system's epoch time is not recommended, since they have
such a limited range, at least on 32-bit machines.

=back

Other methods provided by C<DateTime.pm> are:

=over 4

=item * set( .. )

This method can be used to change the local components of a date time,
or its language.  This method accepts any parameter allowed by the
C<new()> method except for "time_zone".  Time zones may be set using
the C<set_time_zone()> method.

=item * set_time_zone( $tz )

This method accepts either a time zone object or a string that can be
passed as the "name" parameter to C<< DateTime::TimeZone->new() >>.
If the new time zone's offset is different from the old time zone,
then the I<local> time is adjusted accordingly.

For example:

  my $dt = DateTime->new( year => 2000, month => 5, day => 10,
                          hour => 15, minute => 15,
                          time_zone => '-0600', );

  print $dt->hour; # prints 15

  $dt->set_time_zone( '-0400' );

  print $dt->hour; # prints 17

If the old time zone was a floating time zone, then no adjustments are
made.  If the new time zone is floating, then the I<UTC> time is
adjusted in order to leave the local time untouched.

Fans of Tsai Ming-Liang's films will be happy to know that this does
work:

  my $dt = DateTime::TimeZone->new( ..., time_zone => 'Asia/Taipei' );

  $dt->set_time_zone( 'Europe/Paris' );

Yes, now we can know "ni3 na1 bian1 ji3dian2?"

=item * add_duration( $duration_object )

This method adds a C<DateTime::Duration> to the current datetime.  See
the L<DateTime::TimeZone|DateTime::TimeZone> docs for more detais.

=item * add( DateTime::Duration->new parameters )

This method is syntactic sugar around the C<add_duration()> method.  It
simply creates a new C<DateTime::Duration> object using the parameters
given, and then calls the C<add_duration()> method.

=item * subtract_duration( $duration_object )

When given a C<DateTime::Duration> object, this method simply calls
C<invert()> on that object and passes that new duration to the
C<add_duration> method.

=item * subtract( DateTime::Duration->new parameters )

Like C<add()>, this is syntactic sugar for the C<subtract_duration()>
method.

=item * subtract_datetime( $datetime )

This method returns a new C<DateTime::Duration> object representing
the difference between the two dates.

=item * compare

  $cmp = DateTime->compare($dt1, $dt2);

  @dates = sort { DateTime->compare($a, $b) } @dates;

Compare two DateTime objects. Semantics are compatible with sort;
returns -1 if $a < $b, 0 if $a == $b, 1 if $a > $b.

Of course, since DateTime objects overload comparison operators, you
can just do this anyway:

  @dates = sort @dates;

=back

=head2 How Date Math is Done

It's important to have some understanding of how date math is
implemented in order to effectively use this module and
C<DateTime::Duration>.

The parts of a duration can be broken into three parts.  These are
months, days, and seconds.  Adding one month to a date is different
than adding 4 weeks or 28, 30, or 31 days.  Similarly, due to DST and
leap seconds, adding a day can be different than adding 86,400
seconds.

C<DateTime.pm> always adds (or subtracts) days and seconds first.
Then it normalizes the seconds to handle second values less than 0 or
greater than 86,400 (or 86,401).  Then it adds months.

This means that adding one month and one day to February 28, 2003 will
produce the date April 1, 2003, not March 29, 2003.

=head2 Overloading

This module explicitly overloads the addition (+), subtraction (-),
string and numbercomparison, and stringification operators.  This
means that the following all do sensible things:

  my $new_dt = $dt + $duration_obj;

  my $new_dt = $dt - $duration_obj;

  my $duration_obj = $dt - $new_dt;

  foreach my $dt ( sort @dts ) { ... }

Additionally, the fallback parameter is set to true, so other
derivable operators (+=, -=, etc.) will work properly.  Do not expect
increment (++) or decrement (--) to do anything useful.

The stringification is equivalent to that produced by C<scalar
localtime()>.

=head2 strftime Specifiers

The following specifiers are allowed in the format string:

=over 4

=item * %a

The abbreviated weekday name.

=item * %A

The full weekday name.

=item * %b

The abbreviated month name.

=item * %B

The full month name.

=item * %C

The century number (year/100) as a 2-digit integer.

=item * %d

The day of the month as a decimal number (range 01 to 31).

=item * %D

Equivalent to %m/%d/%y.  This is not a good standard format if you
have want both Americans and Europeans to understand the date!

=item * %e

Like %d, the day of the month as a decimal number, but a leading zero
is replaced by a space.

=item * %F

Equivalent to %Y-%m-%d (the ISO 8601 date format)

=item * %G

The ISO 8601 year with century as a decimal number.  The 4-digit year
corresponding to the ISO week number (see %V).  This has the same
format and value as %y, except that if the ISO week number belongs to
the previous or next year, that year is used instead. (TZ)

=item * %g

Like %G, but without century, i.e., with a 2-digit year (00-99).

=item * %h

Equivalent to %b.

=item * %H

The hour as a decimal number using a 24-hour clock (range 00 to 23).

=item * %I

The hour as a decimal number using a 12-hour clock (range 01 to 12).

=item * %j

The day of the year as a decimal number (range 001 to 366).

=item * %k

The hour (24-hour clock) as a decimal number (range 0 to 23); single
digits are preceded by a blank. (See also %H.)

=item * %l

The hour (12-hour clock) as a decimal number (range 1 to 12); single
digits are preceded by a blank. (See also %I.)

=item * %m

The month as a decimal number (range 01 to 12).

=item * %M

The minute as a decimal number (range 00 to 59).

=item * %n

A newline character.

=item * %p

Either `AM' or `PM' according to the given time value, or the
corresponding strings for the current locale.  Noon is treated as `pm'
and midnight as `am'.

=item * %P

Like %p but in lowercase: `am' or `pm' or a corresponding string for
the current locale.

=item * %r

The time in a.m.  or p.m. notation.  In the POSIX locale this is
equivalent to `%I:%M:%S %p'.

=item * %R

The time in 24-hour notation (%H:%M). (SU) For a version including the
seconds, see %T below.

=item * %s

The number of seconds since the epoch.

=item * %S

The second as a decimal number (range 00 to 61).

=item * %t

A tab character.

=item * %T

The time in 24-hour notation (%H:%M:%S).

=item * %u

The day of the week as a decimal, range 1 to 7, Monday being 1.  See
also %w.

=item * %U

The week number of the current year as a decimal number, range 00 to
53, starting with the first Sunday as the first day of week 01. See
also %V and %W.

=item * %V

The ISO 8601:1988 week number of the current year as a decimal number,
range 01 to 53, where week 1 is the first week that has at least 4
days in the current year, and with Monday as the first day of the
week. See also %U and %W.

=item * %w

The day of the week as a decimal, range 0 to 6, Sunday being 0.  See
also %u.

=item * %W

The week number of the current year as a decimal number, range 00 to
53, starting with the first Monday as the first day of week 01.

=item * %y

The year as a decimal number without a century (range 00 to 99).

=item * %Y

The year as a decimal number including the century.

=item * %z

The time-zone as hour offset from UTC.  Required to emit
RFC822-conformant dates (using "%a, %d %b %Y %H:%M:%S %z").

=item * %Z

The time zone or name or abbreviation.

=item * %%

A literal `%' character.

=back

=head1 SUPPORT

Support for this module is provided via the datetime@perl.org email
list.  See http://lists.perl.org/ for more details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

However, please see the CREDITS file for more details on who I really
stole all the code from.

=head1 COPYRIGHT

Copyright (c) 2003 David Rolsky.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

Portions of the code in this distribution are derived from other
works.  Please see the CREDITS file for more details.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

datetime@perl.org mailing list

http://datetime.perl.org/

=cut
