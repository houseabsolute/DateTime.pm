use strict;

use Test::More tests => 72;

use DateTime;

my $d = DateTime->new( year => 2001,
                       month => 7,
                       day => 5,
                       hour => 2,
                       minute => 12,
                       second => 50,
                       time_zone => 'UTC',
                     );

is( $d->year, 2001, '->year' );
is( $d->ce_year, 2001, '->ce_year' );
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
                            time_zone => 'UTC',
                          );

is( $leap_d->is_leap_year, 1, '->is_leap_year' );

my $sunday = DateTime->new( year   => 2003,
                            month  => 1,
                            day    => 26,
                            time_zone => 'UTC',
                          );

is( $sunday->day_of_week, 7, "Sunday is day 7" );

my $monday = DateTime->new( year   => 2003,
                            month  => 1,
                            day    => 27,
                            time_zone => 'UTC',
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
    is( $d->ce_year, 2001, '->ce_year' );
    is( $d->month, 7, '->month' );
    is( $d->day_of_month, 5, '->day_of_month' );
    is( $d->hour, 2, '->hour' );
    is( $d->minute, 12, '->minute' );
    is( $d->second, 50, '->second' );
}

{
    my $dt0 = DateTime->new( year => 1, time_zone => 'UTC' );

    is( $dt0->year, 1, "year 1 is year 1" );
    is( $dt0->ce_year, 1, "ce_year 1 is year 1" );

    $dt0->subtract( years => 1 );

    is( $dt0->year, 0, "year 1 minus 1 is year 0" );
    is( $dt0->ce_year, -1, "ce_year 1 minus 1 is year -1" );
}

{
    my $dt_neg = DateTime->new( year => -10, time_zone => 'UTC', );
    is( $dt_neg->year, -10, "Year -10 is -10" );
    is( $dt_neg->ce_year, -11, "year -10 is ce_year -11" );

    my $dt1 = $dt_neg + DateTime::Duration->new( years => 10 );
    is( $dt1->year, 0, "year is 0 after adding ten years to year -10" );
    is( $dt1->ce_year, -1, "ce_year is -1 after adding ten years to year -10" );
}

{
    my $dt = DateTime->new( year => 50, month => 2,
                            hour => 3, minute => 20, second => 5,
                            time_zone => 'UTC',
                          );

    is( $dt->ymd('%s'), '0050%s02%s01', 'use %s as separator in ymd' );
    is( $dt->mdy('%s'), '02%s01%s0050', 'use %s as separator in mdy' );
    is( $dt->dmy('%s'), '01%s02%s0050', 'use %s as separator in dmy' );

    is( $dt->hms('%s'), '03%s20%s05', 'use %s as separator in hms' );
}

# test doy in leap year
{
    my $dt = DateTime->new( year => 2000, month => 1, day => 5,
                            time_zone => 'UTC',
                          );

    is( $dt->day_of_year,   5, 'doy for 2000-01-05 should be 5' );
    is( $dt->day_of_year_0, 4, 'doy_0 for 2000-01-05 should be 4' );
}

{
    my $dt = DateTime->new( year => 2000, month => 2, day => 29,
                            time_zone => 'UTC',
                          );

    is( $dt->day_of_year,   60, 'doy for 2000-02-29 should be 60' );
    is( $dt->day_of_year_0, 59, 'doy_0 for 2000-02-29 should be 59' );
}

{
    my $dt = DateTime->new( year => -6, month => 2, day => 25,
                            time_zone => 'UTC',
                          );

    is( $dt->ymd, '-0006-02-25', 'ymd is -0006-02-25' );
    is( $dt->iso8601, '-0006-02-25T00:00:00', 'iso8601 is -0005-02-25T00:00:00' );
    is( $dt->year, -6, 'year is -6' );
    is( $dt->ce_year, -7, 'ce_year is -7' );
}
