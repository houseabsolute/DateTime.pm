use strict;

use Test::More;
plan tests => 20;

use DateTime;

my $date1 = DateTime->new( ical => '20010510T040302Z' );
my $date2 = DateTime->new( ical => '20010612T050723Z' );

my $diff = $date2 - $date1;

is( $diff->as_days, 33, 'Total # of days' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   1,  'Hours' );
is( $diff->minutes, 4,  'Min' );
is( $diff->seconds, 21, 'Sec' );
is( $diff->as_ical, 'P4W5DT1H4M21S', 'Duration' );

my $d = DateTime->new( ical => '20011019T050101Z' );
my $dur = 'P1W1DT1H1M1S';

my $X = $d - $dur;

ok( defined $X, 'Defined' );
is( $X->ical, '20011011T040000Z', 'Subtract and get the right thing' );

my $Y = $d - 'P1W1DT1H1M1S';
ok( defined $Y, 'Defined' );
is( $Y->ical, '20011011T040000Z', 'Subtract and get the right thing' );

$date1 = DateTime->new( ical => '20010510T040302Z' );
$date2 = DateTime->new( ical => '20010612T050723Z' );

$diff = $date1 - $date2;

is( $diff->as_days, -33, 'Negative duration, days' );
is( $diff->weeks,   -4,  'Weeks' );
is( $diff->days,    -5,  'Days' );
is( $diff->hours,   -1,  'Hours' );
is( $diff->minutes, -4,  'Min' );
is( $diff->seconds, -21, 'Sec' );
is( $diff->as_ical, '-P4W5DT1H4M21S', 'Duration' );

$diff = $date1 - $date1;
is( $diff->as_ical, 'PT0S', 'Zero duration' );
is( $diff->weeks, undef, 'Just checking' );

