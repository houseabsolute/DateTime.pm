use strict;

use Test::More tests => 50;

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
    is( $dur->delta_minutes, 367, "delta_minutes" );
    is( $dur->delta_seconds, 8, "delta_seconds" );

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
    is( $inverse->delta_minutes, -62, 'inverse delta minutes should be negative' );
    is( $inverse->delta_seconds, -3, 'inverse delta seconds should be negative' );

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
}

{
    my $dur1 = DateTime::Duration->new( months => 6, days => 10 );

    my $new1 = $dur1 * 4;
    is( $new1->delta_months, 24, 'test * overloading' );
    is( $new1->delta_days, 40, 'test * overloading' );

}

{
    my $dur1 = DateTime::Duration->new( months => 6, days => 10, seconds => 3, nanoseconds => 1200300400 );

    my $dur2 = DateTime::Duration->new( seconds => 1, nanoseconds => 500000000 );

    is( $dur1->delta_seconds, 4, 'test nanoseconds overflow' );
    is( $dur1->delta_nanoseconds, 200300400, 'test nanoseconds remainder' );

    my $new1 = $dur1 - $dur2;

    is( $new1->delta_seconds, 3, 'seconds is positive' );
    is( $new1->delta_nanoseconds, -299699600, 'nanoseconds remainder is negative' );

    $new1->add( nanoseconds => 500000000 );
    is( $new1->delta_seconds, 3, 'seconds are unaffected' );
    is( $new1->delta_nanoseconds, 200300400, 'nanoseconds are back' );

    my $new1 = $dur1 - $dur2;
    $new1->add( nanoseconds => 1500000000 );
    is( $new1->delta_seconds, 4, 'seconds go up' );
    is( $new1->delta_nanoseconds, 200300400, 'nanoseconds are normalized' );

    $new1->subtract( nanoseconds => 100000000 );
    is( $new1->delta_nanoseconds, 100300400, 'sub nanoseconds works' );
}
