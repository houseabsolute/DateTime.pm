use strict;

use Test::More;
plan tests => 19;

use DateTime;

#======================================================================
# BASIC INITIALIZATION TESTS
#====================================================================== 

my $t1 = DateTime->from_epoch( epoch => 0 );
is( $t1->epoch, 0, "Epoch time of 0" );

# Make sure epoch time is being handled sanely.
# FIXME: This will only work on unix systems.
is( $t1->ymd('-'), '1970-01-01', "When does the epoch start?" );

is( $t1->year, 1970, "Year accessor, start of epoch" );
is( $t1->month, 1,   "Month accessor, start of epoch" );
is( $t1->day, 1,     "Day accessor, start of epoch" );

# Dates in December are giving a month of 0. Test for this
my $dec = new DateTime( year => 1996, month => 12, day => 22, offset => 0 );
is( $dec->month, 12, 'Date should be in December' );
$dec->add( weeks => 4 );
is( $dec->month, 1, '4 weeks later, it is January' );

my $t3 = new DateTime( year => 2001, month => 2, day => 3,
                       hour => 18, minute => 30, second => 20,
                       offset => 0 );

is( $t3->year, 2001, "Year accessor" );
is( $t3->month, 2,  "Month accessor" );
is( $t3->day, 3,    "Day accessor" );
is( $t3->hour, 18,   "Hour accessor" );
is( $t3->minute, 30, "Minute accessor" );
is( $t3->second, 20, "Second accessor" );
# XXX Round-off error could make this 19 ?????

# TODO: test the timezone accessor, when there is one

my $t4 = new DateTime( year => 1870, month => 10, day => 21,
                       hour => 12, minute => 10, second => 45,
                       offset => 0 );
is( $t4->year, '1870', "Year accessor, outside of the epoch" );
is( $t4->month, '10',  "Month accessor, outside the epoch" );
is( $t4->day, '21',    "Day accessor, outside the epoch" );
is( $t4->hour, '12',   "Hour accessor, outside the epoch" );
is( $t4->minute, '10', "Minute accessor, outside the epoch" );
is( $t4->second, '45', "Second accessor, outside the epoch" );

# OTHER TESTS WE NEED, once the code supports them:
# - timezone testing
# - UTC <-> localtime
# - arithmetic, with and without unit rollovers


