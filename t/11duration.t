use strict;

use Test::More tests => 17;

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
                              time_zone => 0,
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
