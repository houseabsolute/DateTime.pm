use strict;

use Test::More tests => 63;

use DateTime;

my $d = DateTime->new( year => 2001,
                       month => 7,
                       day => 5,
                       hour => 2,
                       minute => 12,
                       second => 50,
                       time_zone => 0,
                     );

is( $d->year, 2001, '->year' );
is( $d->year_0, 2000, '->year_0' );
is( $d->month, 7, '->month' );
is( $d->month_0, 6, '->month_0' );
is( $d->month_name, 'July', '->month' );
is( $d->month_abbr, 'Jul', '->month' );
is( $d->day_of_month, 5, '->day_of_month' );
is( $d->day_of_month_0, 4, '->day_of_month' );
is( $d->day, 5, '->day' );
is( $d->day_0, 4, '->day_0' );
is( $d->mday, 5, '->mday' );
is( $d->mday_0, 4, '->mday_0' );
is( $d->mday, 5, '->mday' );
is( $d->mday_0, 4, '->mday' );
is( $d->hour, 2, '->hour' );
is( $d->minute, 12, '->minute' );
is( $d->min, 12, '->min' );
is( $d->second, 50, '->second' );
is( $d->sec, 50, '->sec' );

is( $d->day_of_year, 186, '->day_of_year' );
is( $d->day_of_year_0, 185, '->day_of_year' );
is( $d->day_of_week, 4, '->day_of_week' );
is( $d->day_of_week_0, 3, '->day_of_week' );
is( $d->wday, 4, '->wday' );
is( $d->wday_0, 3, '->wday' );
is( $d->dow, 4, '->dow' );
is( $d->dow_0, 3, '->dow' );
is( $d->day_name, 'Thursday', '->day_name' );
is( $d->day_abbr, 'Thu', '->day_abrr' );

is( $d->ymd, '2001-07-05', '->ymd' );
is( $d->ymd('!'), '2001!07!05', "->ymd('!')" );
is( $d->date, '2001-07-05', '->ymd' );

is( $d->mdy, '07-05-2001', '->mdy' );
is( $d->mdy('!'), '07!05!2001', "->mdy('!')" );

is( $d->dmy, '05-07-2001', '->dmy' );
is( $d->dmy('!'), '05!07!2001', "->dmy('!')" );

is( $d->hms, '02:12:50', '->hms' );
is( $d->hms('!'), '02!12!50', "->hms('!')" );
is( $d->time, '02:12:50', '->hms' );

is( $d->datetime, '2001-07-05T02:12:50', '->datetime' );
is( $d->iso8601, '2001-07-05T02:12:50', '->iso8601' );

is( $d->is_leap_year, 0, '->is_leap_year' );

my $leap_d = DateTime->new( year => 2004,
                            month => 7,
                            day => 5,
                            hour => 2,
                            minute => 12,
                            second => 50,
                            time_zone => 0,
                          );

is( $leap_d->is_leap_year, 1, '->is_leap_year' );

my $sunday = DateTime->new( year   => 2003,
                            month  => 1,
                            day    => 26,
                            time_zone => 0,
                          );

is( $sunday->day_of_week, 7, "Sunday is day 7" );

my $monday = DateTime->new( year   => 2003,
                            month  => 1,
                            day    => 27,
                            time_zone => 0,
                          );

is( $monday->day_of_week, 1, "Monday is day 1" );

{
    # time zone offset should not affect the values returned
    my $d = DateTime->new( year => 2001,
                           month => 7,
                           day => 5,
                           hour => 2,
                           minute => 12,
                           second => 50,
                           time_zone => -124,
                         );

    is( $d->year, 2001, '->year' );
    is( $d->month, 7, '->month' );
    is( $d->day_of_month, 5, '->day_of_month' );
    is( $d->hour, 2, '->hour' );
    is( $d->minute, 12, '->minute' );
    is( $d->second, 50, '->second' );
}

{
    my $dt0 = DateTime->new( year => 1 );

    is( $dt0->year,   1, "Year 1 is year 1" );
    is( $dt0->year_0, 0, "Year 1 is 0 in 0-index terms" );

    $dt0->subtract( years => 1 );

    is( $dt0->year,   -1, "Year -1 is year -1" );
    is( $dt0->year_0, -1, "Year -1 is -1 in 0-index terms" );
}

{
    my $dt_neg = DateTime->new( year => -10 );
    is( $dt_neg->year,   -10, "Year -10 is -10" );
    is( $dt_neg->year_0, -10, "Year -10 is -10 with 0-index" );

    my $dt1 = $dt_neg + DateTime::Duration->new( years => 10 );
    is( $dt1->year,   1, "year is 1 after adding ten years to year -10" );
    is( $dt1->year_0, 0, "year_0 is 0 after adding ten years to year -10" );
}

{
    my $dt = DateTime->new( year => 50, month => 2,
                            hour => 3, minute => 20, second => 5 );

    is( $dt->ymd('%s'), '0050%s02%s01', 'use %s as separator in ymd' );
    is( $dt->mdy('%s'), '02%s01%s0050', 'use %s as separator in mdy' );
    is( $dt->dmy('%s'), '01%s02%s0050', 'use %s as separator in dmy' );

    is( $dt->hms('%s'), '03%s20%s05', 'use %s as separator in hms' );
}
