use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

like(
    exception { DateTime->new( year => 10.5 ) },
    qr/is an integer/,
    'year must be an integer'
);
like(
    exception { DateTime->new( year => -10.5 ) },
    qr/is an integer/,
    'year must be an integer'
);

like(
    exception { DateTime->new( year => 10, month => 2.5 ) },
    qr/an integer/,
    'month must be an integer'
);

like(
    exception { DateTime->new( year => 10, month => 2, day => 12.4 ) },
    qr/an integer/,
    'day must be an integer'
);

like(
    exception {
        DateTime->new( year => 10, month => 2, day => 12, hour => 4.1 );
    },
    qr/an integer/,
    'hour must be an integer'
);

like(
    exception {
        DateTime->new(
            year   => 10,
            month  => 2,
            day    => 12,
            hour   => 4,
            minute => 12.2
        );
    },
    qr/an integer/,
    'minute must be an integer'
);

like(
    exception {
        DateTime->new(
            year   => 10,
            month  => 2,
            day    => 12,
            hour   => 4,
            minute => 12,
            second => 51.8
        );
    },
    qr/an integer/,
    'second must be an integer'
);

like(
    exception {
        DateTime->new(
            year       => 10,
            month      => 2,
            day        => 12,
            hour       => 4,
            minute     => 12,
            second     => 51,
            nanosecond => 124512.12412
        );
    },
    qr/positive integer/,
    'nanosecond must be an integer'
);

like(
    exception {
        DateTime->new( year => 10, month => 2, day => 12 )->today;
    },
    qr/called with reference/,
    'today must be called as a class method, not an object method'
);

like(
    exception {
        DateTime->new( year => 10, month => 2, day => 12 )->now;
    },
    qr/called with reference/,
    'now must be called as a class method, not an object method'
);

done_testing();
