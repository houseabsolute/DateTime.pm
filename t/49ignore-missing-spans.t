use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Fatal;

use DateTime;
use Try::Tiny;

{
    my $error;

    try {
        my $dt = DateTime->new(
            year      => 2018,
            month     => 3,
            day       => 11,
            hour      => 2,
            minute    => 30,
            second    => 0,
            time_zone => 'America/New_York',
        );
    }
    catch {
        $error = $_;
    };

    like( $error, qr/invalid local time/i, 'got correct error' );
}

{
    my $dt = DateTime->new(
        year                 => 2018,
        month                => 3,
        day                  => 11,
        hour                 => 2,
        minute               => 30,
        second               => 0,
        time_zone            => 'America/New_York',
        ignore_missing_spans => 1,
    );

    ok( $dt, 'got a datetime object' );

    is( $dt->offset, -14400, 'offset is -4 (DST)' );
    is( "$dt", '2018-03-11T03:30:00', 'Time moved forward an hour' );
    ok( $dt->is_dst, 'we are now DST' );
}

done_testing();

