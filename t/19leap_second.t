use strict;

use Test::More tests => 8;

use DateTime;

my $t = DateTime->new( year => 1971, month => 12, day => 31,
                       hour => 23, minute => 58, second => 20,
                       time_zone => 'UTC',
                     );
$t->add( seconds => 60);
is( $t->minute, 59, "min");
is( $t->second, 20, "sec");

$t->add( seconds => 60);
is( $t->minute, 0, "min");
is( $t->second, 19, "sec");


# floating time has no leap seconds

$t = DateTime->new( year => 1971, month => 12, day => 31,
                       hour => 23, minute => 58, second => 20,
                       time_zone => 'floating',
                     );
$t->add( seconds => 60);
is( $t->minute, 59, "min");
is( $t->second, 20, "sec");

$t->add( seconds => 60);
is( $t->minute, 0, "min");
is( $t->second, 20, "sec");


