package DateTime::Duration;

use strict;

use Params::Validate qw( validate SCALAR );

use overload ( fallback => 1,
               'cmp' => 'compare',
               '<=>' => 'compare',
               '+'   => '_add_overload',
               '-'   => '_subtract_overload',
             );

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
                           end_of_month => { type => SCALAR, default => 'wrap',
                                             regex => qr/^(?:wrap|limit|preserve)$/ },
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
        $self->{sign} = 1;
    }

    $self->{months} = ( abs( $p{years} * 12 ) + abs( $p{months} ) ) * $self->{sign};
    $self->{days}   = ( abs( ( $p{weeks} * 7 ) ) + abs( $p{days} ) ) * $self->{sign};
    $self->{seconds} =
        abs( ( $p{hours} * 3600 ) + ( $p{minutes} * 60 ) + $p{seconds} ) * $self->{sign};

    return $self;
}

sub clone { bless { %{ $_[0] } }, ref $_[0] }

sub years   { abs( int( $_[0]->{months} / 12 ) ) }
sub months  { int( abs( $_[0]->{months} ) % 12 ) }
sub weeks   { abs( int( $_[0]->{days} / 7 ) ) }
sub days    { abs( $_[0]->{days} ) % 7 }
sub hours   { abs( int( $_[0]->{seconds} / 3600 ) ) }
sub minutes { int( ( abs( $_[0]->{seconds} ) - ( $_[0]->hours * 3600 ) ) / 60 ) }
sub seconds { abs( $_[0]->{seconds} ) % 60 }

sub is_positive { $_[0]->{sign} == 1 ? 1 : 0 }
sub is_negative { $_[0]->{sign} == -1 ? 1 : 0 }

sub delta_months  { $_[0]->{months} }
sub delta_days    { $_[0]->{days} }
sub delta_seconds { $_[0]->{seconds} }

sub deltas { map { $_ => $_[0]->{$_} } qw( months days seconds ) }

sub is_wrap_mode     { $_[0]->{eom_mode} eq 'wrap'   ? 1 : 0 }
sub is_limit_mode    { $_[0]->{eom_mode} eq 'limit'  ? 1 : 0 }
sub is_preserve_mode { $_[0]->{eom_mode} eq 'preserve' ? 1 : 0 }

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
sub add_duration
{
    my ( $self, $dur ) = @_;

    foreach ( qw( months days seconds ) )
    {
        $self->{$_} += $dur->{$_};
    }

}

sub add { shift->add_duration( (ref $_[0])->new(@_) ) }

sub subtract_duration { $_[0]->add_duration( $_[1]->inverse ) }

sub subtract { shift->subtract_duration( (ref $_[0])->new(@_) ) }

sub _add_overload
{
    my ( $d1, $d2, $rev ) = @_;

    ($d1, $d2) = ($d2, $d1) if $rev;

    if ( UNIVERSAL::isa( $d2, 'DateTime' ) )
    {
        $d2->add_duration($d1);
        return;
    }

    # will also work if $d1 is a DateTime.pm object
    my $new = $d1->clone;
    $new->add_duration($d2);
    return $new;
}

sub _subtract_overload
{
    my ( $d1, $d2, $rev ) = @_;

    ($d1, $d2) = ($d2, $d1) if $rev;

    die "Cannot subtract a DateTime object from a DateTime::Duration object"
        if UNIVERSAL::isa( $d2, 'DateTime' );

    my $new = $d1->clone;
    $new->subtract_duration($d2);
    return $new;
}

sub compare
{
    my ( $class, $dur1, $dur2 ) = ref $_[0] ? ( undef, @_ ) : @_;

    my %deltas1 = $dur1->deltas;
    my %deltas2 = $dur2->deltas;

    foreach ( qw( months days seconds ) )
    {
        if ( $deltas1{$_} < $deltas2{$_} )
        {
            return -1;
        }
        elsif ( $deltas1{$_} > $deltas2{$_} )
        {
            return 1;
        }
    }

    return 0;
}


1;

__END__

=head1 NAME

DateTime::Duration - Duration objects for date math

=head1 SYNOPSIS

  use DateTime::Duration;

  $d = DateTime::Duration->new( years   => 3,
                                months  => 5,
                                weeks   => 1,
                                days    => 1,
                                hours   => 6,
                                minutes => 15,
                                seconds => 45, );

  # Human-readable accessors, always positive
  $d->years;
  $d->months;
  $d->weeks;
  $d->days;
  $d->hours;
  $d->minutes;
  $d->seconds;
  $d->sign;

  if ( $d->is_positive ) { ... }
  if ( $d->is_negative ) { ... }

  # The important parts for date math
  $d->delta_months
  $d->delta_days
  $d->delta_seconds

  my %deltas = $d->deltas

  $d->is_wrap_mode
  $d->is_limit_mode
  $d->is_preserve_mode

  # Multiple all deltas by -1
  my $opposite = $d->inverse;

  my $bigger  = $dur1 + $dur2;
  my $smaller = $dur1 - $dur2; # the result could be negative

=head1 DESCRIPTION

This is a simple class for representing duration objects.  These
objects are used whenever you do date math with DateTime.pm.

See the L<How Date Math is Done|DateTime/"How Date Math is Done">
section of the DateTime.pm documentation for more details.

=head1 METHODS

DateTime::Duration has the following methods:

=over 4

=item * new( ... )

This method takes the parameters "years", "months", "weeks", "days",
"hours", "minutes", "seconds", and "end_of_month".  All of these
except "end_of_month" are numbers.  If any of the numbers are
negative, the entire duration is negative.

Internally, years as just treated as 12 months.  Similarly, weeks are
treated as 7 days, and hours and minutes are both converted into
seconds.

The "end_of_month" parameter must be either "wrap", "limit", or
"preserve".  These specify how changes across the end of a month are
handled.

The default "end_of_month" mode, "wrap", means adding months or years
that result in days beyond the end of the new month will roll over
into the following month.  For instance, adding one year to Feb 29
will result in Mar 1.

If you specify "end_of_month" mode as "limit", the end of the month
is never crossed.  Thus, adding one year to Feb 29, 2000 will result
in Feb 28, 2001.  However, adding three more years will result in Feb
28, 2004, not Feb 29.

If you specify "end_of_month" mode as "preserve", the same calculation
is done as for "limit" except that if the original date is at the end
of the month the new date will also be.  For instance, adding one
month to Feb 29, 2000 will result in Mar 31, 2000.

=item * clone

Returns a new object with the same properties as the object on which
this method was called.

=item * years, months, weeks, days, hours, minutes, seconds

These methods return numbers indicating how many of the given unit the
object representations.  These numbers are always positive.

Note that the numbers returned by this method may not match the values
given to the constructor.  For example:

  my $dur = DateTime::Duration->new( years => 0, months => 15 );

  print $dur->years;  # prints 1
  print $dur->months; # prints 3

=item * delta_months, delta_days, delta_seconds

These methods provide the same information as those above, but in a
way suitable for doing date math.  The numbers returned may be
positive or negative.

=item * deltas

Returns a hash with the keys "months", "days", and "seconds",
containing all the delta information for the object.

=item * is_positive, is_negative

Indicates whether or not the duration is positive or negative.

=item * is_wrap_mode, is_limit_mode, is_preserve_mode

Indicates what mode is used for end of month wrapping.

=item * add_duration( $duration_object ), subtract_duration( $duration_object )

Adds or subtracts one duration from another.

=item * add( ... ), subtract( ... )

Syntactic sugar for addition and subtraction.  The parameters given to
these methods are used to create a new object, which is then passed to
C<add_duration()> or C<subtract_duration()>, as appropriate.

=back

=head2 Overloading

Addition, subtraction, and comparison are overloaded for objects of
this class.

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

