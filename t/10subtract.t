use strict;

use Test::More tests => 20;

use DateTime;

use lib './t';
require 'testlib.pl';

my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
                           hour => 4, minute => 3, second => 2,
                           time_zone => 0 );
my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
                           hour => 5, minute => 7, second => 23,
                           time_zone => 0 );

my $diff = $date2 - $date1;

is( $diff->as_days, 33, 'Total # of days' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   1,  'Hours' );
is( $diff->minutes, 4,  'Min' );
is( $diff->seconds, 21, 'Sec' );
is( $diff->as_ical, 'P4W5DT1H4M21S', 'Duration' );

my $d = DateTime->new( year => 2001, month => 10, day => 19,
                       hour => 5, minute => 1, second => 1,
                       time_zone => 0 );
my $dur = 'P1W1DT1H1M1S';

my $X = $d - $dur;

ok( defined $X, 'Defined' );
is( fake_ical($X), '20011011T040000Z', 'Subtract and get the right thing' );

my $Y = $d - 'P1W1DT1H1M1S';
ok( defined $Y, 'Defined' );
is( fake_ical($Y), '20011011T040000Z', 'Subtract and get the right thing' );

$date1 = DateTime->new( year => 2001, month => 5, day => 10,
                        hour => 4, minute => 3, second => 2,
                        time_zone => 0 );
$date2 = DateTime->new( year => 2001, month => 6, day => 12,
                        hour => 5, minute => 7, second => 23,
                        time_zone => 0 );

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

