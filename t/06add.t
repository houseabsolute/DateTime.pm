use strict;

use Test::More;
plan tests => 530;

use DateTime;

my $t = DateTime->new( ical => '19961122T183020Z' );
$t->add( week => 8);

is($t->year, 1997, "year rollover");
is($t->month, 1, "month set on year rollover");
is($t->ical, '19970117T183020Z', 'ical is okay on year rollover' );

$t->add( week => 2 );
is($t->ical, '19970131T183020Z', 'Adding weeks as attribute' );

$t->add( sec => 15 );
is($t->ical, '19970131T183035Z', 'Adding seconds as attribute' );

$t->add( min => 12 );
is($t->ical, '19970131T184235Z', 'Adding minutes as attribute' );

$t->add( min=>25, hour=>3, sec=>7 );
is($t->ical, '19970131T220742Z', 'Adding h,m,s as attributes' );

# Now, test the adding of durations
$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'PT1M12S');
is ($t->ical, '19860128T163912Z', "Adding durations with minutes and seconds works");

$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'PT30S');
is ($t->ical, '19860128T163830Z', "Adding durations with seconds only works");

$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'PT1H10M');
is ($t->ical, '19860128T174800Z', "Adding durations with hours and minutes works");


$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'P3D');
# XXX: what is "right" in the following test? should the result
# just be a date, or a date and time?
is ($t->ical, '19860131T163800Z', "Adding durations with days only works");


$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'P3DT2H');
is ($t->ical, '19860131T183800Z', "Adding durations with days and hours works");


$t = DateTime->new (ical => '19860128T163800Z');

$t->add(duration => 'P3DT2H20M15S');
is ($t->ical, '19860131T185815Z', "Adding durations with days, hours, minutes, and seconds works");

# Add 15M - this test failed at one point in N::I::Time
$t = DateTime->new( ical =>  '20010405T160000Z');
$t->add( duration => 'PT15M' );
is( $t->ical, '20010405T161500Z', "Adding minutes to an ical string");

# Subtract a duration
$t->add( duration => '-PT15M' );
is( $t->ical, '20010405T160000Z', "Back where we started");

undef $t;

$t = DateTime->new (ical => '19860128T163800Z');
$t->add(seconds => '60');
is($t->ical, "19860128T163900Z", "adding positive seconds with seconds works" );
$t->add(seconds => '-120');
is($t->ical, "19860128T163700Z", "adding negative seconds with seconds works" );

# test sub months
$t = DateTime->new (ical => '20010131Z');
$t->add (day => 1);
is($t->ical, '20010201Z', 'february 1st');
$t = DateTime->new (ical => '20010228Z');
$t->add (day => 1);
is($t->ical, '20010301Z', 'march 1st');
$t = DateTime->new (ical => '20010331Z');
$t->add (day => 1);
is($t->ical, '20010401Z', 'april 1st');
$t = DateTime->new (ical => '20010430Z');
$t->add (day => 1);
is($t->ical, '20010501Z', 'may 1st');
$t = DateTime->new (ical => '20010531Z');
$t->add (day => 1);
is($t->ical, '20010601Z', 'june 1st');
$t = DateTime->new (ical => '20010630Z');
$t->add (day => 1);
is($t->ical, '20010701Z', 'july 1st');
$t = DateTime->new (ical => '20010731Z');
$t->add (day => 1);
is($t->ical, '20010801Z', 'august 1st');
$t = DateTime->new (ical => '20010831Z');
$t->add (day => 1);
is($t->ical, '20010901Z', 'september 1st');
$t = DateTime->new (ical => '20010930Z');
$t->add (day => 1);
is($t->ical, '20011001Z', 'october 1st');
$t = DateTime->new (ical => '20011031Z');
$t->add (day => 1);
is($t->ical, '20011101Z', 'november 1st');
$t = DateTime->new (ical => '20011130Z');
$t->add (day => 1);
is($t->ical, '20011201Z', 'december 1st');
$t = DateTime->new (ical => '20011231Z');
$t->add (day => 1);
is($t->ical, '20020101Z', 'january 1st');

# Adding years

# Before leap day, not a leap year ...
$t = DateTime->new( ical => '20010228Z');
$t->add(year=>1);
is($t->ical, '20020228Z', 'Adding a year');
$t->add(year=>17);
is($t->ical, '20190228Z', 'Adding 17 years');

# After leap day, not a leap year ...
$t = DateTime->new( ical => '20010328Z');
$t->add(year=>1);
is($t->ical, '20020328Z', 'Adding a year');
$t->add(year=>17);
is($t->ical, '20190328Z', 'Adding 17 years');

# On leap day, in a leap year ...
$t = DateTime->new( ical => '20000229Z');
$t->add(year=>1);
is($t->ical, '20010301Z', 'Adding a year');
$t->add(year=>17);
is($t->ical, '20180301Z', 'Adding 17 years');

# Before leap day, in a leap year ...
$t = DateTime->new( ical => '20000228Z');
$t->add(year=>1);
is($t->ical, '20010228Z', 'Adding a year');
$t->add(year=>17);
is($t->ical, '20180228Z', 'Adding 17 years');

# After leap day, in a leap year ...
$t = DateTime->new( ical => '20000328Z');
$t->add(year=>1);
is($t->ical, '20010328Z', 'Adding a year');
$t->add(year=>17);
is($t->ical, '20180328Z', 'Adding 17 years');

# Test a bunch of years, before leap day
for (1..99) {
    $t = DateTime->new(ical => '20000228Z');
    $t->add(year => $_);
    my $x = sprintf '%02d', $_;
    is($t->ical, '20' . $x . '0228Z', "Adding $_ years");
}

# Test a bunch of years, after leap day
for (1..99) {
    $t = DateTime->new(ical => '20000328Z');
    $t->add(year => $_);
    my $x = sprintf '%02d', $_;
    is($t->ical, '20' . $x . '0328Z', "Adding $_ years");
}

# And more of the same, starting on a non-leap year

# Test a bunch of years, before leap day
for (1..97) {
    $t = DateTime->new(ical => '20020228Z');
    $t->add(year => $_);
    my $x = sprintf '%02d', $_ + 2;
    is($t->ical, '20' . $x . '0228Z', "Adding $_ years");
}

# Test a bunch of years, after leap day
for (1..97) {
    $t = DateTime->new(ical => '20020328Z');
    $t->add(year => $_);
    my $x = sprintf '%02d', $_ + 2;
    is($t->ical, '20' . $x . '0328Z', "Adding $_ years");
}

# subtract years
for (1..97) {
    $t = DateTime->new(ical => '19990301Z');
    $t->add(year => -$_);
    my $x = sprintf '%02d', 99 - $_;
    is($t->ical, '19' . $x . '0301Z', "Subtracting $_ years");
}

# test some old bugs

# bug adding months where current month + months added were > 25
$t = DateTime::->new(ical=>'19971201Z');
$t->add( month=>14 );
is($t->ical, '19990201Z', 'Adding months--rollover year' );

# bug subtracting months with year rollover
$t = DateTime::->new(ical=>'19970101Z');
$t->add( month=>-1 );
is($t->ical, '19961201Z', 'Subtracting months--rollover year');

