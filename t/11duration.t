use strict;

use Test::More tests => 41;

use DateTime;

# Make sure all the methods we want exist.
ok( DateTime::Duration->can('weeks'),   "weeks() exists" );
ok( DateTime::Duration->can('days'),    "days() exists" );
ok( DateTime::Duration->can('hours'),   "hours() exists" );
ok( DateTime::Duration->can('minutes'), "minutes() exists" );
ok( DateTime::Duration->can('seconds'), "seconds() exists" );

ok( DateTime::Duration->can('as_ical'),     "as_ical() exists" );
ok( DateTime::Duration->can('as_seconds'),  "as_seconds() exists" );
ok( DateTime::Duration->can('as_elements'), "as_elements() exists" );

# Make sure new() traps invalid parameters
my $d = DateTime::Duration->new;
is( $d, undef, "new() with no arguments gives undef" );
undef $d;

# Test iCalendar string parsing

sub stringparse_ok {
    my ( $param, $expected, $explain ) = @_;
    my $parsed_string = DateTime::Duration::_parse_ical_string($param);

    # leave the line below in for help in debugging when you need it
    #use Data::Dumper; warn Dumper $parsed_string;

    ok( eq_hash( $parsed_string, $expected ), $explain );
}

my $str      = 'PT1H';
my $expected = {
    sign    => 1,
    weeks   => undef,
    days    => undef,
    hours   => 1,
    minutes => undef,
    seconds => undef
};

stringparse_ok( $str, $expected, "string $str parses okay" );

$str = 'P3DT1H';

# DEVELOPERS: should these be undefs or 0s? Opinions?
$expected = {
    sign    => 1,
    weeks   => undef,
    days    => 3,
    hours   => 1,
    minutes => undef,
    seconds => undef
};

stringparse_ok( $str, $expected, "string $str parses okay" );

# Test iCalendar string parsing
$str      = 'P1W2DT3H4M5S';
$expected = {
    sign    => 1,
    weeks   => 1,
    days    => 2,
    hours   => 3,
    minutes => 4,
    seconds => 5
};

stringparse_ok( $str, $expected, "string $str parses okay" );

#========================================================================
# Test creation with seconds only
$d = DateTime::Duration->new( seconds => 3600 );
is( $d->as_seconds, 3600,
  "new() with seconds only outputs correctly as_seconds" );
is( $d->as_ical, 'PT1H', "new() with seconds only outputs correctly as_ical" );
undef $d;

# Test creation with seconds and minutes
$d = DateTime::Duration->new( seconds => 45, minutes => 2 );

is( $d->{nsecs}, 2 * 60 + 45, "Internals: nsecs is being set" );
is( $d->{ndays}, undef, "Internals: ndays is being set" );
is( $d->{sign}, 1, "Internals: sign is being set" );

is( $d->as_seconds, ( 2 * 60 ) + 45,
  "new() with seconds and minutes outputs correctly as_seconds" );
is( $d->as_ical, 'PT2M45S',
  "new() with seconds and minutes outputs correctly as_ical" );
undef $d;

# Test creation with ical string
$d = DateTime::Duration->new( ical => "PT10H" );

ok( defined($d), "Simple creation from ical returns a defined object" );

#use Data::Dumper; warn Dumper $d;

is( $d->{nsecs}, 36000, "Internals: nsecs is being set" );
is( $d->{ndays}, undef, "Internals: ndays is being set" );
is( $d->{sign}, 1, "Internals: sign is being set" );

is( $d->as_ical, 'PT10H', "Simple creation from ical as_ical" );
is( $d->as_seconds, 36000, "Simple creation from ical as_seconds" );

# test elements and accessors behavior
$d = DateTime::Duration->new( ical => "P3W2DT10H30M20S" );

is( $d->sign,    1,  "sign accessor works " );
is( $d->weeks,   3,  "weeks accessor works " );
is( $d->days,    2,  "days accessor works " );
is( $d->hours,   10, "hours accessor works " );
is( $d->minutes, 30, "minutes accessor works " );
is( $d->seconds, 20, "seconds accessor works " );

undef $expected;
$expected = {
    sign    => 1,
    weeks   => 3,
    days    => 2,
    hours   => 10,
    minutes => 30,
    seconds => 20
};
my $result = $d->as_elements;
ok( eq_hash( $result, $expected ), 'Simple creation from ical as_elements' );

# Test reading values with as_elements

# Test creation with elements

# Test reading from accessors

# Make sure accessors cannot set values

# Test ical output

# Test seconds output

# Create a negative duration with components
$d = DateTime::Duration->new(
  days    => -2,
  hours   => -10,
  minutes => -12,
  seconds => -14
);

is( $d->sign,    -1,  'sign is negative' );
is( $d->days,    -2,  'days is still negative' );
is( $d->hours,   -10, 'hours is still negative' );
is( $d->minutes, -12, 'minutes is still negative' );
is( $d->seconds, -14, 'seconds is still negative' );
is( $d->as_ical, '-P2DT10H12M14S', 'Correct duration string' );

is( $d->as_days,    -2,      'As days' );
is( $d->as_seconds, -209534, 'As seconds' );
is( $d->weeks, undef, 'Weeks is undef' );

