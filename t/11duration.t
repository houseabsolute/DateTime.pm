use strict;

use Test::More tests => 41;

use DateTime;
use DateTime::Duration;

use lib './t';
require 'testlib.pl';

{
    my %pairs = ( years   => 1,
                  months  => 2,
                  weeks   => 3,
                  days    => 4,
                  hours   => 6,
                  minutes => 7,
                  seconds => 8,
                );

    my $dur = DateTime::Duration->new(%pairs);

    while ( my ($unit, $val) = each %pairs )
    {
        is( $dur->$unit(), $val, "$unit should be $val" );
    }

    is( $dur->delta_months, 14, "delta_months" );
    is( $dur->delta_days, 25, "delta_days" );
    is( $dur->delta_seconds, 22028, "delta_seconds" );

    ok( $dur->is_positive, "should be positive" );
    ok( ! $dur->is_negative, "should not be negative" );

    ok( $dur->is_wrap_mode, "wrap mode" );
}

{
    my $dur = DateTime::Duration->new( days => 1, end_of_month => 'limit' );
    ok( $dur->is_limit_mode, "limit mode" );
}

{
    my $dur = DateTime::Duration->new( days => 1, end_of_month => 'preserve' );
    ok( $dur->is_preserve_mode, "preserve mode" );
}

my $leap_day = DateTime->new( year => 2004, month => 2, day => 29,
                              time_zone => 'UTC',
                            );

{
    my $new =
        $leap_day + DateTime::Duration->new( years => 1,
                                             end_of_month => 'wrap' );

    is( fake_ical($new), '20050301Z', "new date should be 2005-03-01" );
}

{
    my $new =
        $leap_day + DateTime::Duration->new( years => 1,
                                             end_of_month => 'limit' );

    is( fake_ical($new), '20050228Z', "new date should be 2005-02-28" );
}


{
    my $new =
        $leap_day + DateTime::Duration->new( years => 1,
                                             end_of_month => 'preserve' );

    is( fake_ical($new), '20050228Z', "new date should be 2005-02-28" );

    my $new2 =
        $leap_day + DateTime::Duration->new( months => 1,
                                             end_of_month => 'preserve' );
    is( fake_ical($new2), '20040331Z', "new date should be 2004-03-31" );
}

{
    my $inverse =
        DateTime::Duration->new( years => 1, months => 1,
                                 weeks => 1, days => 1,
                                 hours => 1, minutes => 2, seconds => 3, )->inverse;

    is( $inverse->years, 1, 'inverse years should be positive' );
    is( $inverse->months, 1, 'inverse months should be positive' );
    is( $inverse->weeks, 1, 'inverse weeks should be positive' );
    is( $inverse->days, 1, 'inverse days should be positive' );
    is( $inverse->hours, 1, 'inverse hours should be positive' );
    is( $inverse->minutes, 2, 'inverse minutes should be positive' );
    is( $inverse->seconds, 3, 'inverse minutes should be positive' );

    is( $inverse->delta_months, -13, 'inverse delta months should be negative' );
    is( $inverse->delta_days, -8, 'inverse delta months should be negative' );
    is( $inverse->delta_seconds, -3723, 'inverse delta seconds should be negative' );

    ok( $inverse->is_negative, "should be negative" );
    ok( ! $inverse->is_positive, "should not be positivea" );
}

{
    my $dur1 = DateTime::Duration->new( months => 6, days => 10 );

    my $dur2 = DateTime::Duration->new( months => 3, days => 7 );

    my $new1 = $dur1 + $dur2;
    is( $new1->delta_months, 9, 'test + overloading' );
    is( $new1->delta_days, 17, 'test + overloading' );

    my $new2 = $dur1 - $dur2;
    is( $new2->delta_months, 3, 'test - overloading' );
    is( $new2->delta_days, 3, 'test - overloading' );

    my $new3 = $dur2 - $dur1;
    is( $new3->delta_months, -3, 'test - overloading' );
    is( $new3->delta_days, -3, 'test - overloading' );

    is( DateTime::Duration->compare( $dur1, $dur2 ),  1, 'compare two deltas - first is larger' );
    is( DateTime::Duration->compare( $dur2, $dur1 ), -1, 'compare two deltas - second is larger' );
    is( DateTime::Duration->compare( $dur1, $dur1 ),  0, 'compare two deltas - same' );

    my @d = sort ($dur1, $dur2);

    is( $d[0]->delta_months, $dur2->delta_months,
        "smaller delta should come first in sorted list" );
}

