use strict;

use Test::More;
plan tests => 5;

use DateTime;

my $t = DateTime->new( year   => 1996,
                       month  => 11,
                       day    => 22,
                       hour   => 18,
                       minute => 30,
                       second => 20,
                       offset => 0,
                     );

# Add 2 months
# $t->add( month => 2);

#test 1 check year rollover works
# ok($t->year,1997);
#test 2 check month set on year rollover
# ok($t->month,1);

# $t->add( week => 2 );

#test 3 & 4 check year/month rollover with attrib setting
# $t->month(14);
# ok($t->year,1998);
# ok($t->month,2);

#test 5 & 6 test subtraction with attrib setting
# $t->month(-2);
# ok($t->year,1997);
# ok($t->month,10);

$t->add( days => 1 );
is($t->day, 23, 'Add one day');

$t->add( weeks => 1 );
is($t->day, 30, 'Add a week' );

$t->add( hours => 3 );
is($t->hour, 21, 'Add 3 hours' );

$t->add( days => 15 );
is( $t->month, 12, "2 weeks later, it is December" );
is( $t->day, 15, "December 15th to be precise" );

