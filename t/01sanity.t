use strict;

use Test::More;
plan tests => 21;

use DateTime;

#======================================================================
# BASIC INITIALIZATION TESTS
#====================================================================== 

my $t1 = new DateTime( epoch => 0 );
ok( $t1->epoch == 0, "Epoch time of 0" );

# Make sure epoch time is being handled sanely.
# FIXME: This will only work on unix systems.
ok( $t1->ical eq '19700101Z', "When does the epoch start?" );

ok( $t1->year == 1970, "Year accessor, start of epoch" );
ok( $t1->month == 1,   "Month accessor, start of epoch" );
ok( $t1->day == 1,     "Day accessor, start of epoch" );

# like the tests above, but starting with ical instead of epoch
my $t2 = new DateTime( ical => '19700101Z' );
ok( $t2->ical eq '19700101Z', "Start of epoch in ICal notation" );

# NOTE: this will FAIL unless you are in a UTC timezone. 
ok( $t2->epoch == 0, "Time should be stored in UTC anyway, right?" );

# Dates in December are giving a month of 0. Test for this
my $dec = DateTime->new( ical => '19961222Z' );
ok( $dec->month == 12, 'Date should be in December' );
$dec->add( week=>4 );
ok( $dec->month == 1, '4 weeks later, it is January' );

#======================================================================
# ACCESSOR READ TESTS
#====================================================================== 

my $t3 = new DateTime( ical => "20010203T183020Z" );

ok( $t3->year == 2001, "Year accessor" );
ok( $t3->month == 2,  "Month accessor" );
ok( $t3->day == 3,    "Day accessor" );
ok( $t3->hour == 18,   "Hour accessor" );
ok( $t3->minute == 30, "Minute accessor" );
ok( $t3->second == 20 || $t3->second == 19, "Second accessor" );
# XXX Round-off error

# TODO: test the timezone accessor, when there is one

#======================================================================
# ACCESSOR WRITE TESTS
#====================================================================== 

my $t4 = new DateTime( ical => "18701021T121045Z" );
ok( $t4->year eq '1870', "Year accessor, outside of the epoch" );
ok( $t4->month eq '10',  "Month accessor, outside the epoch" );
ok( $t4->day eq '21',    "Day accessor, outside the epoch" );
ok( $t4->hour eq '12',   "Hour accessor, outside the epoch" );
ok( $t4->minute eq '10', "Minute accessor, outside the epoch" );
ok( $t4->second eq '45', "Second accessor, outside the epoch" );

# OTHER TESTS WE NEED, once the code supports them:
# - timezone testing
# - UTC <-> localtime
# - arithmetic, with and without unit rollovers


