#!/usr/bin/perl -w

use strict;

use Test::More tests => 55;

use DateTime;

use lib './t';
require 'testlib.pl';

my $date1 = DateTime->new( year => 2001, month => 5, day => 10,
                           hour => 4, minute => 3, second => 2,
                           nanosecond => 12,
                           time_zone => 'UTC' );
my $date2 = DateTime->new( year => 2001, month => 6, day => 12,
                           hour => 5, minute => 7, second => 23,
                           nanosecond => 7,
                           time_zone => 'UTC' );

my $diff = $date2 - $date1;

is( $diff->delta_days, 33, 'delta_days should be 33' );
is( $diff->delta_seconds, 3860, 'delta_seconds should be 3860' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   0,  'Hours' );
is( $diff->minutes, 0,  'Min' );
is( $diff->seconds, 3860, 'Sec' );
is( $diff->nanoseconds, 999_999_995, 'ns' );

my $d = DateTime->new( year => 2001, month => 10, day => 19,
                       hour => 5, minute => 1, second => 1,
                       time_zone => 'UTC' );

$date1 = DateTime->new( year => 2001, month => 5, day => 10,
                        hour => 4, minute => 3, second => 2,
                        time_zone => 'UTC' );
$date2 = DateTime->new( year => 2001, month => 6, day => 12,
                        hour => 5, minute => 7, second => 23,
                        time_zone => 'UTC' );

$diff = $date1 - $date2;

is( $diff->delta_days, -33, 'Negative duration, days' );
is( $diff->weeks,   4,  'Weeks' );
is( $diff->days,    5,  'Days' );
is( $diff->hours,   0,  'Hours' );
is( $diff->minutes, 0,  'Min' );
is( $diff->seconds, 3861, 'Sec' );

$diff = $date1 - $date1;
is( $diff->delta_days, 0, 'date minus itself should have no delta days' );
is( $diff->delta_seconds, 0, 'date minus itself should have no delta seconds' );

my $new = $date1 - DateTime::Duration->new( years => 2 );
is( fake_ical($new), '19990510T040302Z', 'test - overloading' );

my $X = $d->clone;
$X->subtract( weeks   => 1,
              days    => 1,
              hours   => 1,
              minutes => 1,
              seconds => 1,
            );

ok( defined $X, 'Defined' );
is( fake_ical($X), '20011011T040000Z', 'Subtract and get the right thing' );

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

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, 86399, 'seconds is 86399' );
    is( $dur->delta_nanoseconds, 999_999_999, 'nanoseconds is 999,999,999' );
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

    is( $dur->delta_days, 0, 'days is 0' );
    is( $dur->delta_seconds, -60, 'seconds is -60' );
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
