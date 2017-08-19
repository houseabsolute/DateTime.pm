use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

{
    package Formatter;

    sub new {
        return bless {}, __PACKAGE__;
    }

    sub format_datetime {
        $_[1]->strftime('%Y%m%d %T');
    }
}

my $formatter = Formatter->new();

{
    is(
        exception {
            DateTime->from_epoch( epoch => time(), formatter => $formatter )
        },
        undef,
        'passed formatter to from_epoch'
    );
}

{
    is(
        exception {
            DateTime->new(
                year      => 2004,
                month     => 9,
                day       => 2,
                hour      => 13,
                minute    => 23,
                second    => 34,
                formatter => $formatter
            );
        },
        undef,
        'passed formatter to new'
    );
}

{
    my $from = DateTime->new(
        year      => 2004,
        month     => 9,
        day       => 2,
        hour      => 13,
        minute    => 23,
        second    => 34,
        formatter => $formatter
    );
    my $dt;
    is(
        exception {
            $dt = DateTime->from_object(
                object    => $from,
                formatter => $formatter
            );
        },
        undef,
        'passed formatter to from_object'
    );

    is(
        $dt->formatter, $formatter,
        'check from_object copies formatter'
    );

    is( $dt->stringify(), '20040902 13:23:34', 'Format datetime' );

    # check stringification (with formatter)
    is( $dt->stringify, "$dt", 'Stringification (with formatter)' );

    # check that set() and truncate() don't lose formatter
    $dt->set( hour => 3 );
    is(
        $dt->stringify, '20040902 03:23:34',
        'formatter is preserved after set()'
    );

    $dt->truncate( to => 'minute' );
    is(
        $dt->stringify, '20040902 03:23:00',
        'formatter is preserved after truncate()'
    );

    # check if the default behavior works
    $dt->set_formatter(undef);
    is( $dt->stringify(), $dt->iso8601, 'Default iso8601 works' );

    # check stringification (default)
    is(
        $dt->stringify, "$dt",
        'Stringification (no formatter -> format_datetime)'
    );
    is(
        $dt->iso8601, "$dt",
        'Stringification (no formatter -> iso8601)'
    );
}

done_testing();
