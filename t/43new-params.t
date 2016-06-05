use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

like(
    exception { DateTime->new( year => 10.5 ) },
    qr/Validation failed for type named Year/,
    'year must be an integer'
);
like(
    exception { DateTime->new( year => -10.5 ) },
    qr/Validation failed for type named Year/,
    'year must be an integer'
);

like(
    exception { DateTime->new( year => 10, month => 2.5 ) },
    qr/Validation failed for type named Month/,
    'month must be an integer'
);

like(
    exception { DateTime->new( year => 10, month => 2, day => 12.4 ) },
    qr/Validation failed for type named DayOfMonth/,
    'day must be an integer'
);

like(
    exception {
        DateTime->new( year => 10, month => 2, day => 12, hour => 4.1 );
    },
    qr/Validation failed for type named Hour/,
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
    qr/Validation failed for type named Minute/,
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
    qr/Validation failed for type named Second/,
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
    qr/Validation failed for type named Nanosecond/,
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
