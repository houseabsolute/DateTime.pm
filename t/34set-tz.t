use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use DateTime;

# These tests are for a bug related to a bad interaction between the
# horrid ->_handle_offset_modifier method and calling ->set_time_zone
# on a real Olson time zone.  When _handle_offset_modifier was called
# from set_time_zone, it tried calling ->_offset_for_local_datetime,
# which was bogus, because at that point it doesn't know the local
# date time any more, only UTC.
#
# The fix is to have ->_handle_offset_modifier call ->offset when it
# knows that UTC is valid, which is determined by an arg to
# ->_handle_offset_modifier

# These tests come from one of the zdump-generated test files in
# DT::TZ
{
    my $dt = DateTime->new(
        year      => 1934, month  => 2,  day    => 26,
        hour      => 0,    minute => 59, second => 59,
        time_zone => 'UTC',
    );
    $dt->set_time_zone('Africa/Niamey');

    is( $dt->year,  1934, 'local year should be 1934 (1934-02-25 23:59:59)' );
    is( $dt->month, 2,    'local month should be 2 (1934-02-25 23:59:59)' );
    is( $dt->day,   25,   'local day should be 25 (1934-02-25 23:59:59)' );
    is( $dt->hour,  23,   'local hour should be 23 (1934-02-25 23:59:59)' );
    is( $dt->minute, 59, 'local minute should be 59 (1934-02-25 23:59:59)' );
    is( $dt->second, 59, 'local second should be 59 (1934-02-25 23:59:59)' );

    ok( !$dt->is_dst, 'is_dst should be false (1934-02-25 23:59:59)' );
    is( $dt->offset, -3600, 'offset should be -3600 (1934-02-25 23:59:59)' );
}

{
    my $dt = DateTime->new(
        year      => 2013,
        month     => 3,
        day       => 10,
        hour      => 2,
        minute    => 4,
        time_zone => 'floating',
    );

    like(
        exception { $dt->set_time_zone('America/Los_Angeles') },
        qr/\QInvalid local time for date in time zone/,
        'got an exception when trying to set time zone when it leads to invalid local time'
    );

    is(
        $dt->time_zone()->name(),
        'floating',
        'time zone was not changed after set_time_zone() throws an exception'
    );
}

{
    my $dt = DateTime->now( time_zone => 'America/Chicago' );

    ok(
        $dt->set_time_zone('America/Chicago'),
        'set_time_zone returns object when time zone name is same as current'
    );

    ok(
        $dt->set_time_zone( $dt->time_zone() ),
        'set_time_zone returns object when time zone object is same as current'
    );
}

done_testing();
