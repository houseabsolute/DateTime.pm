use strict;

use Test::More tests => 13;

use DateTime;

my $date1 = DateTime->new( year => 1997, month => 10, day => 24,
                           hour => 12, minute => 0, second => 0,
                           time_zone => 0 );
my $date2 = DateTime->new( year => 1997, month => 10, day => 24,
                           hour => 12, minute => 0, second => 0,
                           time_zone => 0 );


# make sure that comparing to itself eq 0
my $identity = $date1->compare($date2);
ok($identity == 0, "Identity comparison");

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 12, minute => 0, second => 1,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 second diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 12, minute => 1, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 minute diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 13, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 hour diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 25,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 day diff');

$date2 = DateTime->new( year => 1997, month => 11, day => 24,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 month diff');

$date2 = DateTime->new( year => 1998, month => 10, day => 24,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 year diff');

# $a > $b tests

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 11, minute => 59, second => 59,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 second diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 11, minute => 59, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 minute diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 24,
                        hour => 11, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 hour diff');

$date2 = DateTime->new( year => 1997, month => 10, day => 23,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 day diff');

$date2 = DateTime->new( year => 1997, month => 9, day => 24,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 month diff');

$date2 = DateTime->new( year => 1996, month => 10, day => 24,
                        hour => 12, minute => 0, second => 0,
                        time_zone => 0 );
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 year diff');



