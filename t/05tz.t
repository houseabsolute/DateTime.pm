use strict;

use Test::More tests => 20;

use DateTime;

{
    my $dt = DateTime->new( year => 2000, month => 10, day => 5,
                            hour => 15, time_zone => 'America/Chicago',
                          );
    is( $dt->hour, 15, 'hour is 15' );
    is( $dt->offset, -18000, 'offset is -18000' );

    $dt->set_time_zone( 'America/New_York' );
    is( $dt->offset, -14400, 'offset is -14400' );
    is( $dt->hour, 16,
        'America/New_York is exactly one hour later than America/Chicago - hour' );
    is( $dt->minute, 0,
        'America/New_York is exactly one hour later than America/Chicago - minute' );
    is( $dt->second, 0,
        'America/New_York is exactly one hour later than America/Chicago - second' );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 1, minute => 59, second => 59,
                            time_zone => 'America/Chicago',
                          );
    is( $dt->offset, -18000, 'offset should be -18000' );

    $dt->add( seconds => 1 );

    is( $dt->offset, -21600, 'offset should be -21600' );
    is( $dt->hour, 1, "crossing DST bounday changes local hour -1" );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 2, time_zone => 'America/Chicago',
                          );

    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 26,
                            hour => 3, time_zone => 'America/Chicago',
                          );

    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 2, time_zone => 'America/Chicago',
                     )
    };
    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );

    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 2, minute => 59, second => 59,
                       time_zone => 'America/Chicago',
                     );
    };
    like( $@, qr/Invalid local time .+/, 'exception for invalid time' );

    eval
    {
        DateTime->new( year => 2003, month => 4, day => 6,
                       hour => 1, minute => 59, second => 59,
                       time_zone => 'America/Chicago',
                     );
    };
    ok( ! $@, 'no exception for valid time' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'America/Chicago',
                          );

    is( $dt->hour, 3, 'hour should be 3' );
    is( $dt->offset, -18000, 'offset should be -18000' );

    $dt->subtract( seconds => 1 );

    is( $dt->hour, 1, 'hour should be 1' );
    is( $dt->offset, -21600, 'offset should be -21600' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'floating',
                          );
    $dt->set_time_zone( 'America/Chicago' );

    is( $dt->hour, 3, 'hour should be 3 after switching from floating TZ' );
}

{
    my $dt = DateTime->new( year => 2003, month => 4, day => 6,
                            hour => 3, time_zone => 'America/Chicago',
                          );
    $dt->set_time_zone( 'floating' );

    is( $dt->hour, 3, 'hour should be 3 after switching to floating TZ' );
}
