#!/usr/bin/perl -w

use strict;

use Test::More tests => 53;

use DateTime;


# tests using UTC times
{
    # 1971-12-31T23:58:20 UTC
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 58, second => 20,
                           time_zone => 'UTC',
                         );
    my $t1 = $t->clone;

    # 1971-12-31T23:59:20 UTC
    $t->add( seconds => 60 );
    is( $t->minute, 59, "min");
    is( $t->second, 20, "sec");

    # 1972-01-01T00:00:19 UTC
    $t->add( seconds => 60 );
    is( $t->minute, 0, "min");
    is( $t->second, 19, "sec");

    # 1971-12-31T23:59:60 UTC
    $t->subtract( seconds => 20 );
    is( $t->minute, 59, "min");
    is( $t->second, 60, "sec");
    is( $t->{utc_rd_secs} , 86400, "rd_sec");


    # subtract_datetime
    my $t2 = DateTime->new( year => 1972, month => 1, day => 1,
                            hour => 0, minute => 0, second => 20,
                            time_zone => 'UTC',
                          );
    my $dur = $t2 - $t1;
    is( $dur->delta_seconds, 121, "delta_seconds is 121");

    $dur = $t1 - $t2;
    is( $dur->delta_seconds, -121, "delta_seconds is -121");
}

{
    # tests using floating times
    # a floating time has no leap seconds

    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 58, second => 20,
                           time_zone => 'floating',
                         );
    my $t1 = $t->clone;

    $t->add( seconds => 60);
    is( $t->minute, 59, "min");
    is( $t->second, 20, "sec");

    $t->add( seconds => 60);
    is( $t->minute, 0, "min");
    is( $t->second, 20, "sec");

    # subtract_datetime, using floating times

    my $t2 = DateTime->new( year => 1972, month => 1, day => 1,
                            hour => 0, minute => 0, second => 20,
                            time_zone => 'floating',
                          );
    my $dur = $t2 - $t1;
    is( $dur->delta_seconds, 120, "delta_seconds is 120");

    $dur = $t1 - $t2;
    is( $dur->delta_seconds, -120, "delta_seconds is -120");
}

{
    # tests using time zones
    # leap seconds occur during _UTC_ midnight

    # 1971-12-31 20:58:20 -03:00 = 1971-12-31 23:58:20 UTC
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 20, minute => 58, second => 20,
                           time_zone => 'America/Sao_Paulo',
                         );

    $t->add( seconds => 60 );
    is( $t->datetime, '1971-12-31T20:59:20', "normal add");
    is( $t->minute, 59, "min");
    is( $t->second, 20, "sec");

    $t->add( seconds => 60 );
    is( $t->datetime, '1971-12-31T21:00:19', "add over a leap second");
    is( $t->minute, 0, "min");
    is( $t->second, 19, "sec");

    $t->subtract( seconds => 20 );
    is( $t->datetime, '1971-12-31T20:59:60', "subtract over a leap second");
    is( $t->minute, 59, "min");
    is( $t->second, 60, "sec");
    is( $t->{utc_rd_secs} , 86400, "rd_sec");
}

# test that we can set second to 60
{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 20, minute => 59, second => 60,
                           time_zone => 'America/Sao_Paulo',
                         );

    is( $t->second, 60, 'second set to 60 in constructor' );
}

{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 20, minute => 59, second => 60,
                           time_zone => 'America/Sao_Paulo',
                         );

    $t->set_time_zone( 'UTC' );
    is( $t->second, 60, 'second after setting time zone' );
    is( $t->hour, 23, 'hour after setting time zone' );

    # and and subtract days so that _calc_utc_rd and _calc_local_rd
    # are both called
    $t->add( days => 1 );
    $t->subtract( days => 1 );

    is( $t->datetime, '1972-01-01T00:00:00',
        'add and subtract 1 day starting on leap second' );
}

{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 59, second => 59,
                           time_zone => 'UTC',
                         );

    is( $t->epoch, 63071999, 'epoch just before first leap second is 63071999' );

    $t->add( seconds => 1 );

    is( $t->epoch, 63072000, 'epoch of first leap second is 63072000' );

    $t->add( seconds => 1 );

    is( $t->epoch, 63072000, 'epoch of first second after first leap second is 63072000' );
}

# date math across leap seconds distinguishes between minutes and second
{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 59, second => 30,
                           time_zone => 'UTC' );

    $t->add( minutes => 1 );

    is( $t->year, 1972, '+1 minute, year == 1972' );
    is( $t->month, 1, '+1 minute, month == 1' );
    is( $t->day, 1, '+1 minute, day == 1' );
    is( $t->hour, 0, '+1 minute, hour == 0' );
    is( $t->minute, 0, '+1 minute, minute == 0' );
    is( $t->second, 30, '+1 minute, second == 30' );
}

{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 59, second => 30,
                           time_zone => 'UTC' );

    $t->add( seconds => 60 );

    is( $t->year, 1972, '+60 seconds, year == 1972' );
    is( $t->month, 1, '+60 seconds, month == 1' );
    is( $t->day, 1, '+60 seconds, day == 1' );
    is( $t->hour, 0, '+60 seconds, hour == 0' );
    is( $t->minute, 0, '+60 seconds, minute == 0' );
    is( $t->second, 29, '+60 seconds, second == 29' );
}

{
    my $t = DateTime->new( year => 1971, month => 12, day => 31,
                           hour => 23, minute => 59, second => 30,
                           time_zone => 'UTC' );

    $t->add( minutes => 1, seconds => 1 );

    is( $t->year, 1972, '+1 minute & 1 second, year == 1972' );
    is( $t->month, 1, '+1 minute & 1 second, month == 1' );
    is( $t->day, 1, '+1 minute & 1 second, day == 1' );
    is( $t->hour, 0, '+1 minute & 1 second, hour == 0' );
    is( $t->minute, 0, '+1 minute & 1 second, minute == 0' );
    is( $t->second, 31, '+1 minute & 1 second, second == 31' );
}

{
    eval { DateTime->new( year => 1971, month => 12, day => 31,
                          hour => 23, minute => 59, second => 61,
                          time_zone => 'UTC',
                        ) };
    ok( $@, "Cannot give second of 61 except when it matches a leap second" );

    eval { DateTime->new( year => 1971, month => 12, day => 31,
                          hour => 23, minute => 58, second => 60,
                          time_zone => 'UTC',
                        ) };
    ok( $@, "Cannot give second of 60 except when it matches a leap second" );

    eval { DateTime->new( year => 1971, month => 12, day => 31,
                          hour => 23, minute => 59, second => 60,
                          time_zone => 'floating',
                        ) };
    ok( $@, "Cannot give second of 60 with floating time zone" );
}
