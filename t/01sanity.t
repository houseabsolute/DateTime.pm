use strict;

use Test::More tests => 12;

use DateTime;

my $t4 = new DateTime( year => 1870, month => 10, day => 21,
                       hour => 12, minute => 10, second => 45,
                       time_zone => 'UTC' );
is( $t4->year, '1870', "Year accessor, outside of the epoch" );
is( $t4->month, '10',  "Month accessor, outside the epoch" );
is( $t4->day, '21',    "Day accessor, outside the epoch" );
is( $t4->hour, '12',   "Hour accessor, outside the epoch" );
is( $t4->minute, '10', "Minute accessor, outside the epoch" );
is( $t4->second, '45', "Second accessor, outside the epoch" );

my $t5 = DateTime->from_object( object => $t4 );
is( $t5->year, '1870', "Year should be identical" );
is( $t5->month, '10',  "Month should be identical" );
is( $t5->day, '21',    "Day should be identical" );
is( $t5->hour, '12',   "Hour should be identical" );
is( $t5->minute, '10', "Minute should be identical" );
is( $t5->second, '45', "Second should be identical" );
