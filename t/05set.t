use strict;

use Test::More tests => 27;

use DateTime;

use lib './t';
require 'testlib.pl';

{
    my $dt = DateTime->new( year => 1996, month => 11, day => 22,
                            hour => 18, minute => 30, second => 20,
                            time_zone => 'UTC',
                          );

    is( $dt->month, 11, 'check month' );

    $dt->set( month => 5 );
    is( $dt->year, 1996, 'check year after setting month' );
    is( $dt->month, 5, 'check month after setting it' );
    is( $dt->day, 22, 'check day after setting month' );
    is( $dt->hour, 18, 'check hour after setting month' );
    is( $dt->minute, 30, 'check minute after setting month' );
    is( $dt->second, 20, 'check second after setting month' );

    $dt->set_time_zone( -21601 );
    is( $dt->year, 1996, 'check year after setting time zone' );
    is( $dt->month, 5, 'check month after setting time zone' );
    is( $dt->day, 22, 'check day after setting time zone' );
    is( $dt->hour, 12, 'check hour after setting time zone' );
    is( $dt->minute, 30, 'check minute after setting time zone' );
    is( $dt->second, 19, 'check second after setting time zone' );
    is( $dt->offset, -21601,
        'check time zone offset after setting new time zone' );

    $dt->set_time_zone( 3600 );
    is( $dt->year, 1996, 'check year after setting time zone' );
    is( $dt->month, 5, 'check month after setting time zone' );
    is( $dt->day, 22, 'check day after setting time zone' );
    is( $dt->hour, 19, 'check hour after setting time zone' );
    is( $dt->minute, 30, 'check minute after setting time zone' );
    is( $dt->second, 20, 'check second after setting time zone' );
    is( $dt->offset, 3600,
        'check time zone offset after setting new time zone' );

    $dt->set( hour => 17 );
    is( $dt->year, 1996, 'check year after setting hour' );
    is( $dt->month, 5, 'check month after setting hour' );
    is( $dt->day, 22, 'check day after setting hour' );
    is( $dt->hour, 17, 'check hour after setting hour' );
    is( $dt->minute, 30, 'check minute after setting hour' );
    is( $dt->second, 20, 'check second after setting hour' );
}
