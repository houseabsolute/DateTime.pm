package DateTime::Duration;

use strict;

use Params::Validate qw( validate SCALAR );

sub new
{
    my $class = shift;
    my %p = validate( @_,
                         { years   => { type => SCALAR, default => 0 },
                           months  => { type => SCALAR, default => 0 },
                           weeks   => { type => SCALAR, default => 0 },
                           days    => { type => SCALAR, default => 0 },
                           hours   => { type => SCALAR, default => 0 },
                           minutes => { type => SCALAR, default => 0 },
                           seconds => { type => SCALAR, default => 0 },
                           sign    => { type => SCALAR, default => '+' },
                           end_of_month => { type => SCALAR, default => 'wrap' },
                         } );

    my $self = bless { eom_mode => $p{end_of_month} }, $class;

    # if any component is negative we treat the whole duration as
    # negative
    if ( grep { $p{$_} < 0 } qw( years months days hours minutes seconds ) )
    {
        $self->{sign} = -1;
    }
    else
    {
        $self->{sign} = $p{sign} eq '-' ? -1 : 1;
    }

    $self->{months} = ( abs( $p{years} * 12 ) + abs( $p{months} ) ) * $self->{sign};
    $self->{days}   = ( abs( ( $p{weeks} * 7 ) ) + abs( $p{days} ) ) * $self->{sign};
    $self->{seconds} =
        abs( ( $p{hours} * 3600 ) + ( $p{minutes} * 60 ) + $p{seconds} ) * $self->{sign};

    return $self;
}

sub years   { int( $_[0]->{months} / 12 ) }
sub months  { ( abs( $_[0]->{months} ) % 12 ) * $_[0]->{sign} }
sub weeks   { int( $_[0]->{days} / 7 ) }
sub days    { ( abs( $_[0]->{days} ) % 7 ) * $_[0]->{sign} }
sub hours   { int( $_[0]->{seconds} / 3600 ) }
sub minutes { int( ( $_[0]->{seconds} - ( $_[0]->hours * 3600 ) ) / 60 ) }
sub seconds { ( abs( $_[0]->{seconds} ) % 60 ) * $_[0]->{sign} }

sub delta_months  { $_[0]->{months} }
sub delta_days    { $_[0]->{days} }
sub delta_seconds { $_[0]->{seconds} }

sub delta_units   { map { $_ => $_[0]->{$_} } qw( months days seconds ) }

sub is_preserve_mode { $_[0]->{eom_mode} eq 'preserve' ? 1 : 0 }
sub is_limit_mode    { $_[0]->{eom_mode} eq 'limit'  ? 1 : 0 }
sub is_wrap_mode     { $_[0]->{eom_mode} eq 'wrap'   ? 1 : 0 }

sub inverse
{
    my $self = shift;

    my %new = %$self;

    foreach ( qw( months days seconds sign ) )
    {
        $new{$_} *= -1;
    }

    return bless \%new, ref $self;
}


1;

__END__

=head1 NAME

DateTime::Duration - datetime durations for date math

=head1 VERSION

$Revision$

=head1 SYNOPSIS

    use DateTime::Duration;

    $d = DateTime::Duration->new( ical => '-P1W3DT2H3M45S' );

    $d = DateTime::Duration->new( weeks => 1,
                                  days => 1,
                                  hours => 6,
                                  minutes => 15,
                                  seconds => 45);

    # a one hour duration, without other components
    $d = DateTime::Duration->new( seconds => "3600");

    # Read-only accessors:
    $d->weeks;
    $d->days;
    $d->hours;
    $d->minutes;
    $d->seconds;
    $d->sign;

    $d->as_seconds;   # returns just seconds

=head1 DESCRIPTION

This is a trivial class for representing duration objects, for doing math
in DateTime

=head1 METHODS

DateTime::Duration has the following methods available:

=head2 new

A new DateTime::Duration object can be created with an iCalendar string :

    my $ical = DateTime::Duration->new ( ical => 'P3W2D' );
    # 3 weeks, 2 days, positive direction
    my $ical = DateTime::Duration->new ( ical => '-P6H3M30S' );
    # 6 hours, 3 minutes, 30 seconds, negative direction
    
Or with a number of seconds:

    my $ical = DateTime::Duration->new ( seconds => "3600" );
    # one hour positive

Or, better still, create it with components

    my $date = DateTime::Duration->new ( 
                           weeks => 6, 
                           days => 2, 
                           hours => 7,
                           minutes => 15,
                           seconds => 47,
                           sign => "+"
                           );

The sign defaults to "+", but "+" and "-" are legal values. 

=head2 sign, weeks, days, hours, minutes, seconds

Read-only accessors for the elements of the object. 

=head2 as_seconds

Returns the duration in raw seconds. 

WARNING -- this folds in the number of days, assuming that they are always 86400
seconds long (which is not true twice a year in areas that honor daylight
savings time).  If you're using this for date arithmetic, consider using the
I<add()> method from a L<DateTime> object, as this will behave better.
Otherwise, you might experience some error when working with times that are
specified in a time zone that observes daylight savings time.

=head2 as_days

    $days = $duration->as_days;

Returns the duration as a number of days. Not to be confused with the
C<days> method, this method returns the total number of days, rather
than mod'ing out the complete weeks. Thus, if we have a duration of 33
days, C<weeks> will return 4, C<days> will return 5, but C<as_days> will
return 33.

Note that this is a lazy convenience function which is just weeks*7 +
days.

=head2 as_ical

Return the duration in an iCalendar format value string (e.g., "PT2H0M0S")

=head2 as_elements

Returns the duration as a hashref of elements. 

=head1 INTERNALS

=head2 GENERAL MODEL

Internally, we store 3 data values: a number of days, a number of seconds (anything
shorter than a day), and a sign (1 or -1). We are assuming that a day is 24 hours for
purposes of this module; yes, we know that's not completely accurate because of
daylight-savings-time switchovers, but it's mostly correct. Suggestions are welcome.

NOTE: The methods below SHOULD NOT be relied on to stay the same in future versions.

=head2 _set_from_ical ($self, $duration_string)

Converts a RFC2445 DURATION format string to the internal storage format.

=head2 _parse_ical_string ($string)

Regular expression for parsing iCalendar into usable values. 

=head2 _set_from_components ($self, $hashref)

Converts from a hashref to the internal storage format.
The hashref can contain elements "sign", "weeks", "days", "hours", "minutes", "seconds".

=head2 _set_from_ical ($self, $num_seconds)

Sets internal data storage properly if we were only given seconds as a parameter.

=head1 AUTHOR

Rich Bowen (DrBacchus) <rbowen@rcbowen.com>

Dave Rolsky <autarch@urth.org>

And the Reefknot team.

=cut
