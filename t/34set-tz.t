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
        year      => 1922, month  => 8,  day    => 31,
        hour      => 23,   minute => 59, second => 59,
        time_zone => 'UTC',
    );
    $dt->set_time_zone('Africa/Accra');

    is( $dt->year,  1922, 'local year should be 1922 (1922-08-31 23:59:59)' );
    is( $dt->month, 8,    'local month should be 8 (1922-08-31 23:59:59)' );
    is( $dt->day,   31,   'local day should be 31 (1922-08-31 23:59:59)' );
    is( $dt->hour,  23,   'local hour should be 23 (1922-08-31 23:59:59)' );
    is( $dt->minute, 59, 'local minute should be 59 (1922-08-31 23:59:59)' );
    is( $dt->second, 59, 'local second should be 59 (1922-08-31 23:59:59)' );

    is( $dt->is_dst, 0, 'is_dst should be 0 (1922-08-31 23:59:59)' );
    is( $dt->offset, 0, 'offset should be 0 (1922-08-31 23:59:59)' );
    is(
        $dt->time_zone_short_name, 'GMT',
        'short name should be GMT (1922-08-31 23:59:59)'
    );
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
