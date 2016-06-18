use strict;
use warnings;

use Test::More;
use Test::Warnings 0.005 ':all';

use DateTime;

my $year_5001_epoch = 95649120000;

## no critic (TestingAndDebugging::ProhibitNoWarnings)
SKIP:
{
    my $year = ( gmtime($year_5001_epoch) )[5];
    skip 'These tests require a 64-bit Perl', 2
        unless defined $year && $year == 3101;

    {
        like(
            warning {
                DateTime->from_epoch(
                    epoch     => $year_5001_epoch,
                    time_zone => 'Asia/Taipei',
                );
            },
            qr{\QYou are creating a DateTime object with a far future year (5001) and a time zone (Asia/Taipei).},
            'got a warning when calling ->from_epoch with a far future epoch and a time_zone'
        );
    }

    {
        no warnings 'DateTime';
        is_deeply(
            warning {
                DateTime->from_epoch(
                    epoch     => $year_5001_epoch,
                    time_zone => 'Asia/Taipei',
                );
            },
            [],
            'no warning when calling ->from_epoch with a far future epoch and a time_zone with DateTime warnings category suppressed'
        );
    }
}

{
    like(
        warning {
            DateTime->new(
                year      => 5001,
                time_zone => 'Asia/Taipei',
            );
        },
        qr{\QYou are creating a DateTime object with a far future year (5001) and a time zone (Asia/Taipei).},
        'got a warning when calling ->new with a far future year and a time_zone'
    );
}

{
    no warnings 'DateTime';
    is_deeply(
        warning {
            DateTime->new(
                year      => 5001,
                time_zone => 'Asia/Taipei',
            );
        },
        [],
        'no warning when calling ->new with a far future epoch and a time_zone with DateTime warnings category suppressed'
    );
}

{
    no warnings;
    is_deeply(
        warning {
            DateTime->new(
                year      => 5001,
                time_zone => 'Asia/Taipei',
            );
        },
        [],
        'no warning when calling ->new with a far future epoch and a time_zone with all warnings suppressed'
    );
}

done_testing();
