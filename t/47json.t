use strict;
use warnings;

use Test::Fatal;
use Test::More tests => 3;

use_ok('DateTime');

note( $INC{"DateTime.pm"} );

SKIP: {
    skip 'This test requires the JSON module to be installed', 2
        unless eval 'use JSON qw(to_json); return 1;';

    is(
        to_json(
            [
                DateTime->new(
                    year      => 2016,
                    month     => 1,
                    day       => 20,
                    hour      => 20,
                    minute    => 30,
                    second    => 40,
                    time_zone => 'UTC',
                )
            ],
            { convert_blessed => 1 }
        ),
        '["2016-01-20T20:30:40"]',
        'to_json fixed date'
    );

    my $dt = DateTime->now;
    is(
        to_json( [$dt], { convert_blessed => 1 } ),
        '["' . $dt->iso8601 . '"]', 'to_json now'
    );
}
