#!/usr/bin/perl -w

use strict;

use Test::More tests => 80;

use DateTime;

use lib './t';
require 'testlib.pl';

{
    my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
			       hour => 4, minute => 3, second => 2,
			       nanosecond => 12,
			       time_zone => 'UTC' );

    my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
			       hour => 5, minute => 7, second => 23,
			       nanosecond => 7,
			       time_zone => 'UTC' );

    my $diff = $date2 - $date1;

    is( $diff->delta_months, 1, 'delta_years should be 1' );
    is( $diff->delta_days, 2, 'delta_days should be 2' );
    is( $diff->delta_minutes, 64, 'delta_minutes should be 64' );
    is( $diff->delta_seconds, 20, 'delta_seconds should be 20' );
    is( $diff->delta_nanoseconds, 999_999_995, 'delta_nanoseconds should be 999,999,995' );

    is( $diff->years,   0,  'Years' );
    is( $diff->months,  1,  'Months' );
    is( $diff->weeks,   0,  'Weeks' );
    is( $diff->days,    2,  'Days' );
    is( $diff->hours,   1,  'Hours' );
    is( $diff->minutes, 4,  'Minutes' );
    is( $diff->seconds, 20, 'Seconds' );
    is( $diff->nanoseconds, 999_999_995, 'Nanoseconds' );
}

{
    my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
			       hour => 4, minute => 3, second => 2,
			       time_zone => 'UTC' );

    my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
			       hour => 5, minute => 7, second => 23,
			       time_zone => 'UTC' );

    my $diff = $date1 - $date2;

    is( $diff->delta_months, -1, 'delta_months should be -1' );
    is( $diff->delta_days, -2, 'delta_days should be -2' );
    is( $diff->delta_minutes, -64, 'delta_minutes should be 64' );
    is( $diff->delta_seconds, -21, 'delta_seconds should be 20' );
    is( $diff->delta_nanoseconds, 0, 'delta_nanoseconds should be 0' );

    is( $diff->years,   0,  'Years' );
    is( $diff->months,  1,  'Months' );
    is( $diff->weeks,   0,  'Weeks' );
    is( $diff->days,    2,  'Days' );
    is( $diff->hours,   1,  'Hours' );
    is( $diff->minutes, 4,  'Minutes' );
    is( $diff->seconds, 21, 'Seconds' );
    is( $diff->nanoseconds, 0, 'Nanoseconds' );

    $diff = $date1 - $date1;
    is( $diff->delta_days, 0, 'date minus itself should have no delta days' );
    is( $diff->delta_seconds, 0, 'date minus itself should have no delta seconds' );

    my $new = $date1 - DateTime::Duration->new( years => 2 );
    is( fake_ical($new), '19990510T040302Z', 'test - overloading' );
}

{
    my $d = DateTime->new( year => 2001, month => 10, day => 19,
			   hour => 5, minute => 1, second => 1,
			   time_zone => 'UTC' );

    my $X = $d->clone;
    $X->subtract( weeks   => 1,
		  days    => 1,
		  hours   => 1,
		  minutes => 1,
		  seconds => 1,
		);

    ok( defined $X, 'Defined' );
    is( fake_ical($X), '20011011T040000Z', 'Subtract and get the right thing' );
}

# based on bug report from Eric Cholet
{
    my $dt1 = DateTime->new( year => 2003, month => 2, day => 9,
                             hour => 0, minute => 0, second => 1,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2003, month => 2, day => 7,
                             hour => 23, minute => 59, second => 59,
                             time_zone => 'UTC',
                           );

    my $diff1 = $dt1->subtract_datetime($dt2);

    is( $diff1->delta_days,    1, 'delta_days should be 1' );
    is( $diff1->delta_seconds, 2, 'delta_seconds should be 2' );

    my $dt3 = $dt2 + $diff1;

    is( DateTime->compare($dt1, $dt3), 0,
        'adding difference back to dt1 should give same datetime' );

    my $diff2 = $dt2->subtract_datetime($dt1);

    is( $diff2->delta_days,    -1, 'delta_days should be -1' );
    is( $diff2->delta_seconds, -2, 'delta_seconds should be -2' );

    my $dt4 = $dt1 + $diff2;

    is( DateTime->compare($dt2, $dt4), 0,
        'adding difference back to dt2 should give same datetime' );
}

# test if the day changes because of a nanosecond subtract
{
    my $dt = DateTime->new( year => 2001, month => 6, day => 12,
                            hour => 0, minute => 0, second => 0,
                            time_zone => 'UTC' );
    $dt->subtract( nanoseconds => 1 );
    is ( $dt->nanosecond, 999999999, 'negative nanoseconds normalize ok' );
    is ( $dt->second, 59, 'seconds normalize ok' );
    is ( $dt->minute, 59, 'minutes normalize ok' );
    is ( $dt->hour, 23, 'hours normalize ok' );
    is ( $dt->day, 11, 'days normalize ok' );
}

# test for a bug when nanoseconds were greater in earlier datetime
{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 1,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2000, month => 1, day => 6,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 0,
                             time_zone => 'UTC',
                           );
    my $dur = $dt2 - $dt1;

    is( $dur->delta_days, 0, 'delta_days is 0' );
    is( $dur->delta_minutes, 1439, 'delta_minutes is 1439' );
    is( $dur->delta_seconds, 59, 'delta_seconds is 59' );
    is( $dur->delta_nanoseconds, 999_999_999, 'delta_nanoseconds is 999,999,999' );
    ok( $dur->is_positive, 'duration is positive' );
}

{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 20,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 10,
                             time_zone => 'UTC',
                           );

    my $dur = $dt2 - $dt1;

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, 0, 'seconds is 0' );
    is( $dur->delta_nanoseconds, -10, 'nanoseconds is -10' );
    ok( $dur->is_negative, 'duration is negative' );
}

{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 11, second => 0,
                             nanosecond => 20,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 10,
                             time_zone => 'UTC',
                           );

    my $dur = $dt2 - $dt1;

    is( $dur->delta_days, 0, 'delta_days is 0' );
    is( $dur->delta_minutes, -1, 'delta_minutes is -1' );
    is( $dur->delta_seconds, 0, 'delta_seconds is 0' );
    is( $dur->delta_nanoseconds, -10, 'nanoseconds is -10' );
    ok( $dur->is_negative, 'duration is negative' );
}

{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 20,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 11, second => 0,
                             nanosecond => 10,
                             time_zone => 'UTC',
                           );

    my $dur = $dt2 - $dt1;

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, 59, 'seconds is 59' );
    is( $dur->delta_nanoseconds, 999_999_990, 'nanoseconds is 999,999,990' );
    ok( $dur->is_positive, 'duration is positive' );
}

{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 11, second => 0,
                             nanosecond => 10,
                             time_zone => 'UTC',
                           );

    my $dt2 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 10, second => 0,
                             nanosecond => 20,
                             time_zone => 'UTC',
                           );

    my $dur = $dt2 - $dt1;

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, -59, 'seconds is -59' );
    is( $dur->delta_nanoseconds, -999_999_990, 'nanoseconds is -999,999,990' );
    ok( $dur->is_negative, 'duration is negative' );
}

{
    my $dt1 = DateTime->new( year => 2000, month => 1, day => 5,
                             hour => 0, minute => 11, second => 0,
                             nanosecond => 20,
                             time_zone => 'UTC',
                           );

    my $dur = $dt1 - $dt1;

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, 0, 'seconds is 0' );
    is( $dur->delta_nanoseconds, 0, 'nanoseconds is 0' );
    ok( ! $dur->is_positive, 'not positive' );
    ok( ! $dur->is_negative, 'not negative' );
}

{
    my $dt1 = DateTime->new( year => 2003, month => 12, day => 31 );
    my $dt2 = $dt1->clone->subtract( months => 1 );

    is( $dt2->year, 2003, '2003-12-31 - 1 month = 2003-11-30' );
    is( $dt2->month, 11, '2003-12-31 - 1 month = 2003-11-30' );
    is( $dt2->day, 30, '2003-12-31 - 1 month = 2003-11-30' );
}

{
    my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
			       hour => 4, minute => 3, second => 2,
			       nanosecond => 12,
			       time_zone => 'UTC' );

    my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
			       hour => 5, minute => 7, second => 23,
			       nanosecond => 7,
			       time_zone => 'UTC' );

    my $diff = $date2->subtract_datetime_absolute($date1);

    is( $diff->delta_months, 0, 'delta_months is 0' );
    is( $diff->delta_minutes, 0, 'delta_minutes is 0' );
    is( $diff->delta_seconds, 2_855_060, 'delta_seconds is 2,855,060' );
    is( $diff->delta_nanoseconds, 999_999_995, 'delta_seconds is 999,999,995' );
}

{
    my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
			       hour => 4, minute => 3, second => 2,
			       time_zone => 'UTC' );

    my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
			       hour => 5, minute => 7, second => 23,
			       time_zone => 'UTC' );

    my $diff = $date1->subtract_datetime_absolute($date2);

    is( $diff->delta_months, 0, 'delta_months is 0' );
    is( $diff->delta_minutes, 0, 'delta_minutes is 0' );
    is( $diff->delta_seconds, -2_855_061, 'delta_seconds is -2,855,061' );
    is( $diff->delta_nanoseconds, 0, 'delta_nanoseconds is 0' );
}
