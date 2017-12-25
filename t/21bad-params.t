use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

foreach my $p (
    { year => 2000, month => 13 },
    { year => 2000, month => 0 },
    { year => 2000, month => 12, day => 32 },
    { year => 2000, month => 12, day => 0 },
    { year => 2000, month => 12, day => 10, hour => -1 },
    { year => 2000, month => 12, day => 10, hour => 24 },
    { year => 2000, month => 12, day => 10, hour => 12, minute => -1 },
    { year => 2000, month => 12, day => 10, hour => 12, minute => 60 },
    { year => 2000, month => 12, day => 10, hour => 12, second => -1 },
    { year => 2000, month => 12, day => 10, hour => 12, second => 62 },
) {
    like(
        exception { DateTime->new(%$p) },
        qr/Validation failed/,
        'Parameters outside valid range should fail in call to new()'
    );

    like(
        exception { DateTime->new( year => 2000 )->set(%$p) },
        qr/Validation failed/,
        'Parameters outside valid range should fail in call to set()'
    );
}

{
    like(
        exception {
            DateTime->last_day_of_month(
                year  => 2000,
                month => 13,
            );
        },
        qr/Validation failed/,
        'Parameters outside valid range should fail in call to last_day_of_month()'
    );

    like(
        exception { DateTime->last_day_of_month( year => 2000, month => 0 ) },
        qr/Validation failed/,
        'Parameters outside valid range should fail in call to last_day_of_month()'
    );
}

{
    like(
        exception { DateTime->new( year => 2000, month => 4, day => 31 ) },
        qr/valid day of month/i,
        'Day past last day of month should fail'
    );

    like(
        exception { DateTime->new( year => 2001, month => 2, day => 29 ) },
        qr/valid day of month/i,
        'Day past last day of month should fail'
    );

    is(
        exception { DateTime->new( year => 2000, month => 2, day => 29 ) },
        undef,
        'February 29 should be valid in leap years'
    );
}

done_testing();
