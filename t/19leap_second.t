use strict;

use Test::More tests => 22;

use DateTime;


# tests using UTC times

my $t = DateTime->new( year => 1971, month => 12, day => 31,
                       hour => 23, minute => 58, second => 20,
                       time_zone => 'UTC',
                     );
my $t1 = $t->clone;

$t->add( seconds => 60 );
is( $t->minute, 59, "min");
is( $t->second, 20, "sec");

$t->add( seconds => 60 );
is( $t->minute, 0, "min");
is( $t->second, 19, "sec");

$t->subtract( seconds => 20 );
is( $t->minute, 0, "min");
TODO: {
    local $TODO = "can't show '60' seconds yet";
    is( $t->second, 60, "sec");
}
is( $t->{utc_rd_secs} , 86400, "rd_sec");


# subtract_datetime

my $t2 = DateTime->new( year => 1972, month => 1, day => 1,
                       hour => 0, minute => 0, second => 20,
                       time_zone => 'UTC',
                     );
my $dt = $t2 - $t1;
is( $dt->minutes, 2, "min duration");
is( $dt->seconds, 1, "sec duration");


# tests using floating times
# a floating time has no leap seconds

$t = DateTime->new( year => 1971, month => 12, day => 31,
                       hour => 23, minute => 58, second => 20,
                       time_zone => 'floating',
                     );
$t1 = $t->clone;

$t->add( seconds => 60);
is( $t->minute, 59, "min");
is( $t->second, 20, "sec");

$t->add( seconds => 60);
is( $t->minute, 0, "min");
is( $t->second, 20, "sec");

# subtract_datetime, using floating times

my $t2 = DateTime->new( year => 1972, month => 1, day => 1,
                       hour => 0, minute => 0, second => 20,
                       time_zone => 'floating',
                     );
my $dt = $t2 - $t1;
is( $dt->minutes, 2, "min duration");
is( $dt->seconds, 0, "sec duration");


# tests using time zones
# leap seconds occur during _UTC_ midnight

$t = DateTime->new( year => 1971, month => 12, day => 31,
                       hour => 23, minute => 58, second => 20,
                       time_zone => 'America/Sao_Paulo',
                     );
# $t1 = $t->clone;

$t->add( seconds => 60 );
is( $t->minute, 59, "min");
is( $t->second, 20, "sec");

TODO: {
    local $TODO = "can't use leap seconds with timezones yet";

$t->add( seconds => 60 );
is( $t->minute, 0, "min");
is( $t->second, 19, "sec");

$t->subtract( seconds => 20 );
is( $t->minute, 0, "min");
is( $t->second, 60, "sec");
is( $t->{utc_rd_secs} , 86400, "rd_sec");

} # /TODO

