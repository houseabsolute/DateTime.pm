use strict;

use Test::More;
plan tests => 25;

use DateTime;

# Tests creating objects from epoch time

my $t1 = DateTime->new(epoch => 0, offset => 0);
ok ($t1->epoch() eq '0', 'creation test from epoch (compare to epoch)');
ok ($t1->ical() eq '19700101Z', 'creation test from epoch (compare to ical)');

ok($t1->second == 0, "seconds are correct on epoch 0");
ok($t1->minute == 0, "minutes are correct on epoch 0");
ok($t1->hour == 0, "hours are correct on epoch 0");
ok($t1->day == 1, "days are correct on epoch 0");
ok($t1->month == 1, "months are correct on epoch 0");
ok($t1->year == 1970, "year is correct on epoch 0");


$t1 = DateTime->new(epoch => '3600');
ok ($t1->epoch == 3600, 'creation test from epoch = 3600 (compare to epoch)');
ok ($t1->ical eq '19700101T010000Z', 'creation test from epoch (compare to ical = 19700101T010000Z)');

my $now = time;
my $nowtest = DateTime->new( offset => 0);
my $nowtest2 = DateTime->new( epoch => $now, offset => 0 );
is( $nowtest->hour, $nowtest2->hour, "Hour: Create without args");
is( $nowtest->month, $nowtest2->month, "Month : Create without args");
is( $nowtest->minute, $nowtest2->minute, "Minute: Create without args");

my $epochtest = DateTime->new(epoch => '997122970', offset => 0);
is ( $epochtest->epoch( 997121000 ), 997121000,
    "Setting epoch returns correct value");
is( $epochtest->epoch, 997121000, "And the value stuck" );
is( $epochtest->hour, 18, "Hour, after setting epoch" );
is( $epochtest->min, 3, "Min, after setting epoch" );

is( $epochtest->epoch(0), 0, "Setting epoch to 0 returns correct value" );
is( $epochtest->epoch, 0, "Epoch value is now 0" );
is( $epochtest->year, 1970, "Year is 1970" );
is( $epochtest->month, 1, "Month is 1" );
is( $epochtest->day, 1, "Day is 1" );
is( $epochtest->hour, 0, "Hour is 0" );
is( $epochtest->minute, 0, "Minute is 0" );
is( $epochtest->second, 0, "Second is 0" );
