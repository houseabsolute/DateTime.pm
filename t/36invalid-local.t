use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

my $badlt_rx = qr/Invalid local time|local time [0-9\-:T]+ does not exist/;

{
    like(
        exception {
            DateTime->new(
                year => 2003, month     => 4, day => 6,
                hour => 2,    time_zone => 'America/Chicago',
            );
        },
        $badlt_rx,
        'exception for invalid time'
    );

    like(
        exception {
            DateTime->new(
                year      => 2003, month  => 4,  day    => 6,
                hour      => 2,    minute => 59, second => 59,
                time_zone => 'America/Chicago',
            );
        },
        $badlt_rx,
        'exception for invalid time'
    );
}

{
    is(
        exception {
            DateTime->new(
                year      => 2003, month  => 4,  day    => 6,
                hour      => 1,    minute => 59, second => 59,
                time_zone => 'America/Chicago',
            );
        },
        undef,
        'no exception for valid time'
    );

    my $dt = DateTime->new(
        year      => 2003, month => 4, day => 5,
        hour      => 2,
        time_zone => 'America/Chicago',
    );

    like(
        exception { $dt->add( days => 1 ) },
        $badlt_rx,
        'exception for invalid time produced via add'
    );

    $dt->add( days => 2 );

    my $dt2 = DateTime->new(
        year      => 2003, month => 4, day => 5,
        hour      => 2,
        time_zone => 'America/Chicago',
    )->add( days => 2 );

    is( $dt, $dt2, 'adding after failed addition leads to correct result' );
}

done_testing();
