#!/usr/bin/perl -w

use strict;

use Test::More tests => 3;

use DateTime;

my $dt1 = DateTime->new( year => 1970, hour => 1, nanosecond => 100 );

my $dt2 = DateTime->from_object( object => $dt1 );

is( $dt1->year, 1970, 'year is 1970' );
is( $dt1->hour, 1, 'hour is 1' );
is( $dt1->nanosecond, 100, 'nanosecond is 100' );
