# test suite stolen shamelessly from TimeDate distro
use strict;
use warnings;
use utf8;

use Test::More 0.96;

use DateTime;
use DateTime::Locale;

for my $o (
    Test::Builder->new->output,
    Test::Builder->new->failure_output,
    Test::Builder->new->todo_output
) {

    binmode $o, ':encoding(UTF-8)' or die $!;
}

test_strftime_for_locale( 'en-US', en_tests() );
test_strftime_for_locale( 'de',    de_tests() );
test_strftime_for_locale( 'it',    it_tests() );

subtest(
    'strftime with multiple params',
    sub {
        my $dt = DateTime->new(
            year      => 1800,
            month     => 1,
            day       => 10,
            time_zone => 'UTC',
        );

        my ( $y, $d ) = $dt->strftime( '%Y', '%d' );
        is( $y, 1800, 'first value is year' );
        is( $d, 10,   'second value is day' );

        $y = $dt->strftime( '%Y', '%d' );
        is( $y, 1800, 'scalar context returns year' );
    }
);

subtest(
    'hour formatting',
    sub {
        my $dt = DateTime->new(
            year   => 2003,
            hour   => 0,
            minute => 0
        );

        is(
            $dt->strftime('%I %M %p'), '12 00 AM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), '12 00 AM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 1 );
        is(
            $dt->strftime('%I %M %p'), '01 00 AM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), ' 1 00 AM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 11 );
        is(
            $dt->strftime('%I %M %p'), '11 00 AM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), '11 00 AM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 12 );
        is(
            $dt->strftime('%I %M %p'), '12 00 PM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), '12 00 PM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 13 );
        is(
            $dt->strftime('%I %M %p'), '01 00 PM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), ' 1 00 PM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 23 );
        is(
            $dt->strftime('%I %M %p'), '11 00 PM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), '11 00 PM',
            'formatting of hours as 1-12'
        );

        $dt->set( hour => 0 );
        is(
            $dt->strftime('%I %M %p'), '12 00 AM',
            'formatting of hours as 1-12'
        );
        is(
            $dt->strftime('%l %M %p'), '12 00 AM',
            'formatting of hours as 1-12'
        );
    }
);

subtest(
    '%V',
    sub {
        is(
            DateTime->new( year => 2003, month => 1, day => 1 )
                ->strftime('%V'),
            '01', '%V is 01'
        );
    }
);

subtest(
    '%% and %{method}',
    sub {
        my $dt = DateTime->new(
            year   => 2004, month  => 8,  day        => 16,
            hour   => 15,   minute => 30, nanosecond => 123456789,
            locale => 'en',
        );

        # Should print '%{day_name}', prints '30onday'!
        is(
            $dt->strftime('%%{day_name}%n'), "%{day_name}\n",
            '%%{day_name}%n bug'
        );

        # Should print '%6N', prints '123456'
        is( $dt->strftime('%%6N%n'), "%6N\n", '%%6N%n bug' );
    }
);

subtest(
    'nanosecond formatting',
    sub {
        subtest(
            'nanosecond floating point rounding',
            sub {
                # Internally this becomes 119999885 nanoseconds (floating point math is awesome)
                my $epoch = 1297777805.12;
                my $dt = DateTime->from_epoch( epoch => $epoch );

                my @vals = (
                    1,
                    12,
                    120,
                    1200,
                    12000,
                    120000,
                    1200000,
                    12000000,
                    120000000,
                    1200000000,
                );

                my $x = 1;
                for my $val (@vals) {
                    my $spec = '%' . $x++ . 'N';
                    is(
                        $dt->strftime($spec), $val,
                        "strftime($spec) for $epoch == $val"
                    );
                }
            }
        );
        subtest(
            'nanosecond rounding in strftime',
            sub {
                my $dt = DateTime->new(
                    'year'     => 1999,
                    month      => 9,
                    day        => 7,
                    hour       => 13,
                    minute     => 2,
                    second     => 42,
                    nanosecond => 12345678,
                );

                my %tests = (
                    '%N'   => '012345678',
                    '%3N'  => '012',
                    '%6N'  => '012345',
                    '%10N' => '0123456780',
                );
                for my $fmt ( sort { lc $a cmp lc $b } keys %tests ) {
                    is(
                        $dt->strftime($fmt), $tests{$fmt},
                        "$fmt is $tests{$fmt}"
                    );
                }
            }
        );
    }
);

subtest(
    '0 nanoseconds',
    sub {
        my $dt = DateTime->new( year => 2011 );

        for my $i ( 1 .. 9 ) {
            my $spec   = '%' . $i . 'N';
            my $expect = '0' x $i;

            is(
                $dt->strftime($spec), $expect,
                "strftime $spec with 0 nanoseconds"
            );
        }
    }
);

subtest(
    'week-year formatting',
    sub {
        my $dt = DateTime->new( 'year' => 2012, month => 1, day => 1 );
        subtest(
            $dt->ymd,
            sub {
                my %tests = (
                    '%U' => '01',
                    '%W' => '00',
                    '%j' => '001',
                );
                for my $fmt ( sort { lc $a cmp lc $b } keys %tests ) {
                    is(
                        $dt->strftime($fmt), $tests{$fmt},
                        "$fmt is $tests{$fmt}"
                    );
                }
            }
        );

        $dt = DateTime->new( 'year' => 2012, month => 1, day => 10 );
        subtest(
            $dt->ymd,
            sub {
                my %tests = (
                    '%U' => '02',
                    '%W' => '02',
                    '%j' => '010',
                );
                for my $fmt ( sort { lc $a cmp lc $b } keys %tests ) {
                    is(
                        $dt->strftime($fmt), $tests{$fmt},
                        "$fmt is $tests{$fmt}"
                    );
                }
            }
        );
    }
);

subtest(
    '%F with 3 digit years',
    sub {
        my $dt = DateTime->new( year => 123 );
        is(
            $dt->strftime('%F'),
            '123-01-01',
            '%F does not zero-pad 3 digit year'
        );
    }
);

done_testing();

sub test_strftime_for_locale {
    my $locale = shift;
    my $tests  = shift;

    my $dt = DateTime->new(
        year       => 1999,
        month      => 9,
        day        => 7,
        hour       => 13,
        minute     => 2,
        second     => 42,
        nanosecond => 123456789,
        time_zone  => 'UTC',
        locale     => $locale,
    );

    subtest(
        $locale,
        sub {
            for my $fmt ( sort { lc $a cmp lc $b } keys %{$tests} ) {
                is(
                    $dt->strftime($fmt),
                    $tests->{$fmt},
                    "$fmt is $tests->{$fmt}"
                );
            }
        }
    );
}

sub en_tests {
    my $en_locale = DateTime::Locale->load('en-US');

    my $c_format = $en_locale->datetime_format;
    $c_format
        =~ s/\{1\}/$en_locale->month_format_abbreviated->[8] . ' 7, 1999'/e;
    $c_format =~ s/\{0\}/'1:02:42 ' . $en_locale->am_pm_abbreviated->[1]/e;

    return {
        '%%'        => '%',
        '%10N'      => '1234567890',
        '%3N'       => '123',
        '%6N'       => '123456',
        '%a'        => $en_locale->day_format_abbreviated->[1],
        '%A'        => $en_locale->day_format_wide->[1],
        '%b'        => $en_locale->month_format_abbreviated->[8],
        '%B'        => $en_locale->month_format_wide->[8],
        '%c'        => $c_format,
        '%C'        => '19',
        '%d'        => '07',
        '%D'        => '09/07/99',
        '%e'        => ' 7',
        '%E'        => '%E',
        '%F'        => '1999-09-07',
        '%G'        => '1999',
        '%g'        => '99',
        '%h'        => $en_locale->month_format_abbreviated->[8],
        '%H'        => '13',
        '%I'        => '01',
        '%j'        => '250',
        '%k'        => '13',
        '%l'        => ' 1',
        '%m'        => '09',
        '%M'        => '02',
        '%n'        => "\n",
        '%N'        => '123456789',
        '%p'        => $en_locale->am_pm_abbreviated->[1],
        '%P'        => lc $en_locale->am_pm_abbreviated->[1],
        '%r'        => '01:02:42 ' . $en_locale->am_pm_abbreviated->[1],
        '%R'        => '13:02',
        '%s'        => '936709362',
        '%S'        => '42',
        '%t'        => "\t",
        '%T'        => '13:02:42',
        '%u'        => '2',
        '%U'        => '36',
        '%V'        => '36',
        '%w'        => '2',
        '%W'        => '36',
        '%x'        => $en_locale->month_format_abbreviated->[8] . ' 7, 1999',
        '%X'        => '1:02:42 ' . $en_locale->am_pm_abbreviated->[1],
        '%y'        => '99',
        '%Y'        => '1999',
        '%z'        => '+0000',
        '%Z'        => 'UTC',
        '%{foobar}' => '%{foobar}',
        '%{month}'  => '9',
        '%{year}'   => '1999',
    };
}

sub de_tests {
    my $de_locale = DateTime::Locale->load('de');
    return {
        '%%'       => '%',
        '%a'       => $de_locale->day_format_abbreviated->[1],
        '%A'       => $de_locale->day_format_wide->[1],
        '%b'       => $de_locale->month_format_abbreviated->[8],
        '%B'       => $de_locale->month_format_wide->[8],
        '%C'       => '19',
        '%d'       => '07',
        '%D'       => '09/07/99',
        '%e'       => ' 7',
        '%H'       => '13',
        '%I'       => '01',
        '%j'       => '250',
        '%k'       => '13',
        '%l'       => ' 1',
        '%M'       => '02',
        '%m'       => '09',
        '%p'       => $de_locale->am_pm_abbreviated->[1],
        '%r'       => '01:02:42 ' . $de_locale->am_pm_abbreviated->[1],
        '%R'       => '13:02',
        '%S'       => '42',
        '%s'       => '936709362',
        '%T'       => '13:02:42',
        '%U'       => '36',
        '%V'       => '36',
        '%w'       => '2',
        '%W'       => '36',
        '%Y'       => '1999',
        '%y'       => '99',
        '%z'       => '+0000',
        '%Z'       => 'UTC',
        '%{month}' => '9',
        '%{year}'  => '1999',
    };
}

sub it_tests {
    my $it_locale = DateTime::Locale->load('it');
    return {
        '%%'       => '%',
        '%a'       => $it_locale->day_format_abbreviated->[1],
        '%A'       => $it_locale->day_format_wide->[1],
        '%b'       => $it_locale->month_format_abbreviated->[8],
        '%b'       => $it_locale->month_format_abbreviated->[8],
        '%B'       => $it_locale->month_format_wide->[8],
        '%C'       => '19',
        '%d'       => '07',
        '%D'       => '09/07/99',
        '%e'       => ' 7',
        '%H'       => '13',
        '%I'       => '01',
        '%j'       => '250',
        '%k'       => '13',
        '%l'       => ' 1',
        '%M'       => '02',
        '%m'       => '09',
        '%p'       => $it_locale->am_pm_abbreviated->[1],
        '%r'       => '01:02:42 ' . $it_locale->am_pm_abbreviated->[1],
        '%R'       => '13:02',
        '%S'       => '42',
        '%s'       => '936709362',
        '%T'       => '13:02:42',
        '%U'       => '36',
        '%V'       => '36',
        '%w'       => '2',
        '%W'       => '36',
        '%Y'       => '1999',
        '%y'       => '99',
        '%z'       => '+0000',
        '%Z'       => 'UTC',
        '%{month}' => '9',
        '%{year}'  => '1999',
    };
}
