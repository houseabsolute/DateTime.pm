use strict;

use Test::More tests => 17;

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

is( $diff->delta_days, 33, 'Total number of days' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   1,  'Hours' );
is( $diff->minutes, 4,  'Min' );
is( $diff->seconds, 21, 'Sec' );

my $d = DateTime->new( year => 2001, month => 10, day => 19,
                       hour => 5, minute => 1, second => 1,
                       time_zone => 0 );

my $X = $d->clone;
$X->subtract( weeks   => 1,
              days    => 1,
              hours   => 1,
              minutes => 1,
              seconds => 1,
            );

ok( defined $X, 'Defined' );
is( fake_ical($X), '20011011T040000Z', 'Subtract and get the right thing' );

$date1 = DateTime->new( year => 2001, month => 5, day => 10,
                        hour => 4, minute => 3, second => 2,
                        time_zone => 0 );
$date2 = DateTime->new( year => 2001, month => 6, day => 12,
                        hour => 5, minute => 7, second => 23,
                        time_zone => 0 );

$diff = $date1 - $date2;

is( $diff->delta_days, -33, 'Negative duration, days' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   1,  'Hours' );
is( $diff->minutes, 4,  'Min' );
is( $diff->seconds, 21, 'Sec' );

$diff = $date1 - $date1;
is( $diff->delta_days, 0, 'date minus itself should have no delta days' );
is( $diff->delta_seconds, 0, 'date minus itself should have no delta seconds' );

my $new = $date1 - DateTime::Duration->new( years => 2 );
is( fake_ical($new), '19990510T040302Z', 'test - overloading' );
