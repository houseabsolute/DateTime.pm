use strict;

use Test::More;
plan tests => 13;

use DateTime;

my $date1 = DateTime->new( ical => '19971024T120000');
my $date2 = DateTime->new( ical => '19971024T120000');


# make sure that comparing to itself eq 0
my $identity = $date1->compare($date2);
ok($identity == 0, "Identity comparison");

$date2 = DateTime->new( ical => '19971024T120001');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 second diff');

$date2 = DateTime->new( ical => '19971024T120100');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 minute diff');

$date2 = DateTime->new( ical => '19971024T130000');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 hour diff');

$date2 = DateTime->new( ical => '19971025T120000');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 day diff');

$date2 = DateTime->new( ical => '19971124T120000');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 month diff');

$date2 = DateTime->new( ical => '19981024T120000');
ok($date1->compare($date2) == -1, 'Comparison $a < $b, 1 year diff');

# $a > $b tests

$date2 = DateTime->new( ical => '19971024T115959');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 second diff');

$date2 = DateTime->new( ical => '19971024T115900');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 minute diff');

$date2 = DateTime->new( ical => '19971024T110000');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 hour diff');

$date2 = DateTime->new( ical => '19971023T120000');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 day diff');

$date2 = DateTime->new( ical => '19970924T120000');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 month diff');

$date2 = DateTime->new( ical => '19961024T120000');
ok($date1->compare($date2) == 1, 'Comparison $a > $b, 1 year diff');



