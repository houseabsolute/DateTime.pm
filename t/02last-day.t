use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

my @last_day = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );
my @leap_last_day = @last_day;
$leap_last_day[1]++;

foreach my $month ( 1 .. 12 ) {
    my $dt = DateTime->last_day_of_month(
        year      => 2001,
        month     => $month,
        time_zone => 'UTC',
    );

    is( $dt->year,  2001,                    'check year' );
    is( $dt->month, $month,                  'check month' );
    is( $dt->day,   $last_day[ $month - 1 ], 'check day' );
}

foreach my $month ( 1 .. 12 ) {
    my $dt = DateTime->last_day_of_month(
        year      => 2004,
        month     => $month,
        time_zone => 'UTC',
    );

    is( $dt->year,  2004,                         'check year' );
    is( $dt->month, $month,                       'check month' );
    is( $dt->day,   $leap_last_day[ $month - 1 ], 'check day' );
}

{
    is(
        exception {
            DateTime->last_day_of_month(
                year       => 2000, month => 1,
                nanosecond => 2000
            );
        },
        undef,
        'last_day_of_month should accept nanosecond'
    );
}

done_testing();
