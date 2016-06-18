## no critic (Modules::ProhibitExcessMainComplexity)
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use DateTime;
use Try::Tiny;

my %vals = (
    year       => 50,
    month      => 3,
    day        => 15,
    hour       => 10,
    minute     => 55,
    second     => 17,
    nanosecond => 1234,
);

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'second' );
    foreach my $f (qw( year month day hour minute second )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'minute' );
    foreach my $f (qw( year month day hour minute )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( second nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'hour' );
    foreach my $f (qw( year month day hour )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( minute second nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'day' );
    foreach my $f (qw( year month day )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( hour minute second nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'month' );
    foreach my $f (qw( year month )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( day )) {
        is( $dt->$f(), 1, "$f should be 1" );
    }

    foreach my $f (qw( hour minute second nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'year' );
    foreach my $f (qw( year )) {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f (qw( month day )) {
        is( $dt->$f(), 1, "$f should be 1" );
    }

    foreach my $f (qw( hour minute second nanosecond )) {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new( year => 2003, month => 11, day => 17 );

    for ( 1 .. 6 ) {
        my $trunc = $dt->clone->add( days => $_ )->truncate( to => 'week' );

        is(
            $trunc->day, 17,
            'truncate to week should always truncate to monday of week'
        );
    }

    {
        my $trunc = $dt->clone->add( days => 7 )->truncate( to => 'week' );

        is(
            $trunc->day, 24,
            'truncate to week should always truncate to monday of week'
        );
    }
}

{
    my $dt = DateTime->new( year => 2003, month => 10, day => 2 )
        ->truncate( to => 'week' );

    is( $dt->year,  2003, 'truncation to week across month boundary' );
    is( $dt->month, 9,    'truncation to week across month boundary' );
    is( $dt->day,   29,   'truncation to week across month boundary' );
}

{
    my $dt = DateTime->new(
        year   => 2013, month => 12, day => 16,
        locale => 'fr_FR'
    );

    for ( 1 .. 6 ) {
        my $trunc
            = $dt->clone->add( days => $_ )->truncate( to => 'local_week' );

        is(
            $trunc->day, 16,
            'truncate to local_week returns correct date - locale start is Monday'
        );
    }

    {
        my $trunc
            = $dt->clone->add( days => 7 )->truncate( to => 'local_week' );

        is(
            $trunc->day, 23,
            'truncate to local_week returns correct date - locale start is Monday'
        );
    }
}

{
    my $dt = DateTime->new(
        year   => 2013, month => 11, day => 2,
        locale => 'fr_FR'
    )->truncate( to => 'local_week' );

    is(
        $dt->year, 2013,
        'truncation to local_week across month boundary - locale start is Monday'
    );
    is(
        $dt->month, 10,
        'truncation to local_week across month boundary - locale start is Monday'
    );
    is(
        $dt->day, 28,
        'truncation to local_week across month boundary - locale start is Monday'
    );
}

{
    my $dt = DateTime->new(
        year   => 2013, month => 12, day => 15,
        locale => 'en_US'
    );

    for ( 1 .. 6 ) {
        my $trunc
            = $dt->clone->add( days => $_ )->truncate( to => 'local_week' );

        is(
            $trunc->day, 15,
            'truncate to local_week returns correct date - locale start is Sunday'
        );
    }

    {
        my $trunc
            = $dt->clone->add( days => 7 )->truncate( to => 'local_week' );

        is(
            $trunc->day, 22,
            'truncate to local_week returns correct date - locale start is Sunday'
        );
    }
}

{
    my $dt = DateTime->new(
        year   => 2013, month => 11, day => 2,
        locale => 'en_US'
    )->truncate( to => 'local_week' );

    is(
        $dt->year, 2013,
        'truncation to local_week across month boundary - locale start is Sunday'
    );
    is(
        $dt->month, 10,
        'truncation to local_week across month boundary - locale start is Sunday'
    );
    is(
        $dt->day, 27,
        'truncation to local_week across month boundary - locale start is Sunday'
    );
}

{
    my %months_to_quarter = (
        1  => 1,
        2  => 1,
        3  => 1,
        4  => 4,
        5  => 4,
        6  => 4,
        7  => 7,
        8  => 7,
        9  => 7,
        10 => 10,
        11 => 10,
        12 => 10,
    );

    for my $year ( -1, 100, 2016 ) {
        for my $month ( sort keys %months_to_quarter ) {
            for my $day ( 1, 15, 27 ) {
                my $dt = DateTime->new(
                    year  => $year,
                    month => $month,
                    day   => $day,
                );
                subtest(
                    'truncate to quarter - ' . $dt->ymd,
                    sub {
                        $dt->truncate( to => 'quarter' );
                        is(
                            $dt->year,
                            $year,
                            'year is unchanged'
                        );
                        is(
                            $dt->month,
                            $months_to_quarter{$month},
                            "month $month becomes month $months_to_quarter{$month}"
                        );
                        is(
                            $dt->day,
                            1,
                            'day is always 1'
                        );
                        is(
                            $dt->hour,
                            0,
                            'hour is always 0'
                        );
                        is(
                            $dt->minute,
                            0,
                            'minute is always 0'
                        );
                        is(
                            $dt->second,
                            0,
                            'second is always 0'
                        );
                        is(
                            $dt->nanosecond,
                            0,
                            'nanosecond is always 0'
                        );
                    }
                );
            }
        }
    }
}

{
    my $dt = DateTime->new(%vals);

    for my $bad (qw( seconds minutes year_foo month_bar )) {
        like(
            exception { $dt->truncate( to => $bad ) },
            qr/Validation failed for type named TruncationLevel/,
            "bad truncate parameter ($bad) throws an error"
        );
    }
}

{
    my $dt = DateTime->new(
        year      => 2010,
        month     => 3,
        day       => 25,
        hour      => 1,
        minute    => 5,
        time_zone => 'Asia/Tehran',
    );

    is(
        $dt->day_of_week(),
        4,
        'day of week is Thursday'
    );

    my $error;
    try {
        $dt->truncate( to => 'week' );
    }
    catch {
        $error = $_;
    };

    like(
        $error,
        qr/Invalid local time for date/,
        'truncate operation threw an error because of an invalid local datetime'
    );

    is(
        $dt->day_of_week(),
        4,
        'day of week does not change after failed truncate() call'
    );
}

done_testing();
