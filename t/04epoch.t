use strict;

use Test::More tests => 14;

use DateTime;

# Tests creating objects from epoch time

my $t1 = DateTime->from_epoch(epoch => 0, time_zone => 0);
is( $t1->epoch, 0, "epoch should be 0" );

is( $t1->second, 0, "seconds are correct on epoch 0" );
is( $t1->minute, 0, "minutes are correct on epoch 0" );
is( $t1->hour, 0, "hours are correct on epoch 0" );
is( $t1->day, 1, "days are correct on epoch 0" );
is( $t1->month, 1, "months are correct on epoch 0" );
is( $t1->year, 1970, "year is correct on epoch 0" );


$t1 = DateTime->from_epoch(epoch => '3600');
is( $t1->epoch, 3600, 'creation test from epoch = 3600 (compare to epoch)');

# these tests could break if the time changed during the next three lines
my $now = time;
my $nowtest = DateTime->now();
my $nowtest2 = DateTime->from_epoch( epoch => $now, time_zone => 0 );
is( $nowtest->hour, $nowtest2->hour, "Hour: Create without args" );
is( $nowtest->month, $nowtest2->month, "Month : Create without args" );
is( $nowtest->minute, $nowtest2->minute, "Minute: Create without args" );

my $epochtest = DateTime->from_epoch(epoch => '997121000', time_zone => 0);

is( $epochtest->epoch, 997121000,
    "epoch method returns correct value");
is( $epochtest->hour, 18, "hour" );
is( $epochtest->min, 3, "minute" );
