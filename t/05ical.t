use strict;

use Test::More;
plan tests => 12;

use DateTime;

# Testing object creation with ical string

my $acctest = DateTime->new(ical => "19920405T160708Z");

ok($acctest->sec == 8, "second accessor read is correct");
ok($acctest->minute == 7, "minute accessor read is correct");
ok($acctest->hour == 16, "hour accessor read is correct");
ok($acctest->day == 5, "day accessor read is correct");
ok($acctest->month == 4, "month accessor read is correct");
ok($acctest->year == 1992, "year accessor read is correct");

# extra-epoch dates?

my $preepoch = DateTime->new( ical => '18700523T164702Z' );
ok( $preepoch->year == 1870, 'Pre-epoch year' );
ok( $preepoch->month == 5, 'Pre-epoch month' );
ok( $preepoch->sec == 2, 'Pre-epoch seconds' );

my $postepoch = DateTime->new( ical => '23481016T041612Z' );
ok( $postepoch->year == 2348, "Post-epoch year" );
ok( $postepoch->day == 16, "Post-epoch day");
ok( $postepoch->hour == 04, "Post-epoch hour");


