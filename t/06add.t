use strict;

use Test::More tests => 531;

use DateTime;

use lib './t';
require 'testlib.pl';

my $t = DateTime->new( year => 1996, month => 11, day => 22,
                       hour => 18, minute => 30, second => 20,
                       time_zone => 'UTC',
                     );
$t->add( weeks => 8);

is( $t->year, 1997, "year rollover");
is( $t->month, 1, "month set on year rollover");
is( fake_ical($t), '19970117T183020Z', 'ical is okay on year rollover' );

$t->add( weeks => 2 );
is( fake_ical($t), '19970131T183020Z', 'Adding weeks as attribute' );

$t->add( seconds => 15 );
is( fake_ical($t), '19970131T183035Z', 'Adding seconds as attribute' );

$t->add( minutes => 12 );
is( fake_ical($t), '19970131T184235Z', 'Adding minutes as attribute' );

$t->add( minutes => 25, hours => 3, seconds => 7 );
is( fake_ical($t), '19970131T220742Z', 'Adding h,m,s as attributes' );

# Now, test the adding of durations
$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( minutes => 1, seconds => 12 );
is( fake_ical($t), '19860128T163912Z', "Adding durations with minutes and seconds works");

$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( seconds => 30 );
is( fake_ical($t), '19860128T163830Z', "Adding durations with seconds only works");

$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( hours => 1, minutes => 10 );
is( fake_ical($t), '19860128T174800Z', "Adding durations with hours and minutes works");

$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( days => 3 );
is( fake_ical($t), '19860131T163800Z', "Adding durations with days only works");


$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( days => 3, hours => 2 );
is( fake_ical($t), '19860131T183800Z', "Adding durations with days and hours works");


$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( days => 3, hours => 2, minutes => 20, seconds => 15 );
is( fake_ical($t), '19860131T185815Z', "Adding durations with days, hours, minutes, and seconds works");

# Add 15M - this test failed at one point in N::I::Time
$t = DateTime->new( year => 2001, month => 4, day => 5,
                    hour => 16,
                    time_zone => 'UTC' );

$t->add( minutes => 15 );
is( fake_ical($t), '20010405T161500Z', "Adding minutes to an ical string");

# Subtract a duration
$t->add( minutes => -15 );
is( fake_ical($t), '20010405T160000Z', "Back where we started");

undef $t;

$t = DateTime->new( year => 1986, month => 1, day => 28,
                    hour => 16, minute => 38,
                    time_zone => 'UTC' );

$t->add( seconds => 60 );
is( fake_ical($t), "19860128T163900Z", "adding positive seconds with seconds works" );
$t->add( seconds => -120 );
is( fake_ical($t), "19860128T163700Z", "adding negative seconds with seconds works" );

# test sub months
$t = DateTime->new( year => 2001, month => 1, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010201Z', 'february 1st' );

$t = DateTime->new( year => 2001, month => 2, day => 28,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010301Z', 'march 1st' );

$t = DateTime->new( year => 2001, month => 3, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010401Z', 'april 1st' );

$t = DateTime->new( year => 2001, month => 4, day => 30,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010501Z', 'may 1st' );

$t = DateTime->new( year => 2001, month => 5, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010601Z', 'june 1st' );

$t = DateTime->new( year => 2001, month => 6, day => 30,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010701Z', 'july 1st' );

$t = DateTime->new( year => 2001, month => 7, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010801Z', 'august 1st' );

$t = DateTime->new( year => 2001, month => 8, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20010901Z', 'september 1st' );

$t = DateTime->new( year => 2001, month => 9, day => 30,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20011001Z', 'october 1st' );

$t = DateTime->new( year => 2001, month => 10, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20011101Z', 'november 1st' );

$t = DateTime->new( year => 2001, month => 11, day => 30,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20011201Z', 'december 1st' );

$t = DateTime->new( year => 2001, month => 12, day => 31,
                    time_zone => 'UTC',
                  );
$t->add(days => 1);
is( fake_ical($t), '20020101Z', 'january 1st' );

# Adding years

# Before leap day, not a leap year ...
$t = DateTime->new( year => 2001, month => 2, day => 28,
                    time_zone => 'UTC',
                  );
$t->add( years => 1 );
is( fake_ical($t), '20020228Z', 'Adding a year' );
$t->add( years => 17 );
is( fake_ical($t), '20190228Z', 'Adding 17 years' );

# After leap day, not a leap year ...
$t = DateTime->new( year => 2001, month => 3, day => 28,
                    time_zone => 'UTC',
                  );
$t->add( years => 1 );
is( fake_ical($t), '20020328Z', 'Adding a year' );
$t->add( years => 17 );
is( fake_ical($t), '20190328Z', 'Adding 17 years' );

# On leap day, in a leap year ...
$t = DateTime->new( year => 2000, month => 2, day => 29,
                    time_zone => 'UTC',
                  );
$t->add( years => 1 );
is( fake_ical($t), '20010301Z', 'Adding a year' );
$t->add( years => 17 );
is( fake_ical($t), '20180301Z', 'Adding 17 years' );

# Before leap day, in a leap year ...
$t = DateTime->new( year => 2000, month => 2, day => 28,
                    time_zone => 'UTC',
                  );
$t->add( years => 1 );
is( fake_ical($t), '20010228Z', 'Adding a year' );
$t->add( years => 17 );
is( fake_ical($t), '20180228Z', 'Adding 17 years' );

# After leap day, in a leap year ...
$t = DateTime->new( year => 2000, month => 3, day => 28,
                    time_zone => 'UTC',
                  );
$t->add( years => 1 );
is( fake_ical($t), '20010328Z', 'Adding a year' );
$t->add( years => 17 );
is( fake_ical($t), '20180328Z', 'Adding 17 years' );

# Test a bunch of years, before leap day
for (1..99) {
    $t = DateTime->new( year => 2000, month => 2, day => 28,
                        time_zone => 'UTC',
                      );
    $t->add( years => $_ );
    my $x = sprintf '%02d', $_;
    is( fake_ical($t), '20' . $x . '0228Z', "Adding $_ years");
}

# Test a bunch of years, after leap day
for (1..99) {
    $t = DateTime->new( year => 2000, month => 3, day => 28,
                        time_zone => 'UTC',
                      );
    $t->add( years => $_ );
    my $x = sprintf '%02d', $_;
    is( fake_ical($t), '20' . $x . '0328Z', "Adding $_ years");
}

# And more of the same, starting on a non-leap year

# Test a bunch of years, before leap day
for (1..97) {
    $t = DateTime->new( year => 2002, month => 2, day => 28,
                        time_zone => 'UTC',
                      );
    $t->add( years => $_ );
    my $x = sprintf '%02d', $_ + 2;
    is( fake_ical($t), '20' . $x . '0228Z', "Adding $_ years");
}

# Test a bunch of years, after leap day
for (1..97) {
    $t = DateTime->new( year => 2002, month => 3, day => 28,
                        time_zone => 'UTC',
                      );
    $t->add( years => $_ );
    my $x = sprintf '%02d', $_ + 2;
    is( fake_ical($t), '20' . $x . '0328Z', "Adding $_ years");
}

# subtract years
for (1..97) {
    $t = DateTime->new( year => 1999, month => 3, day => 1,
                        time_zone => 'UTC',
                      );
    $t->add( years => -$_ );
    my $x = sprintf '%02d', 99 - $_;
    is( fake_ical($t), '19' . $x . '0301Z', "Subtracting $_ years");
}

# test some old bugs

# bug adding months where current month + months added were > 25
$t = DateTime->new( year => 1997, month => 12, day => 1,
                    time_zone => 'UTC',
                  );
$t->add( months => 14 );
is( fake_ical($t), '19990201Z', 'Adding months--rollover year' );

# bug subtracting months with year rollover
$t = DateTime->new( year => 1997, month => 1, day => 1,
                    time_zone => 'UTC',
                  );
$t->add( months => -1 );
is( fake_ical($t), '19961201Z', 'Subtracting months--rollover year' );

my $new = $t + DateTime::Duration->new( years => 2 );
is( fake_ical($new), '19981201Z', 'test + overloading' );
