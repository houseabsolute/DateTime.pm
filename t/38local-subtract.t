#!/usr/bin/perl -w

use strict;

use Test::More tests => 45;

use DateTime;

# These tests should be the final word on dt subtraction involving a
# DST-changing time zone

{
    my $dt1 = DateTime->new( year => 2003, month => 5, day => 6,
                             time_zone => 'America/Chicago',
                           );

    my $dt2 = DateTime->new( year => 2003, month => 11, day => 6,
                             time_zone => 'America/Chicago',
                           );

    my $dur1 = $dt2->subtract_datetime($dt1);
    my %deltas1 = $dur1->deltas;
    is( $deltas1{months}, 6, 'delta_months is 6' );
    is( $deltas1{days}, 0, 'delta_days is 0' );
    is( $deltas1{minutes}, 60, 'delta_minutes is 60' );
    is( $deltas1{seconds}, 0, 'delta_seconds is 0' );
    is( $deltas1{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    my $dur2 = $dt1->subtract_datetime($dt2);
    my %deltas2 = $dur2->deltas;
    is( $deltas2{months}, -6, 'delta_months is -6' );
    is( $deltas2{days}, 0, 'delta_days is 0' );
    is( $deltas2{minutes}, -60, 'delta_minutes is -60' );
    is( $deltas2{seconds}, 0, 'delta_seconds is 0' );
    is( $deltas2{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    my $dur3 = $dt2->delta_md($dt1);
    my %deltas3 = $dur3->deltas;
    is( $deltas3{months}, 6, 'delta_months is 6' );
    is( $deltas3{days}, 0, 'delta_days is 0' );
    is( $deltas3{minutes}, 0, 'delta_minutes is 0' );
    is( $deltas3{seconds}, 0, 'delta_seconds is 0' );
    is( $deltas3{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    is( $dt1->clone->truncate( to => 'month' )->add_duration($dur3),
        $dt2->clone->truncate( to => 'month' ),
        'delta_md is reversible' );

    is( $dt2->clone->truncate( to => 'month' )->subtract_duration($dur3),
        $dt1->clone->truncate( to => 'month' ),
        'delta_md is doubly reversible' );
}

# The important thing here is that after a subtraction, we can use the
# duration to get from one date to the other, regardless of the type
# of subtraction done.
{
    my $dt1 = DateTime->new( year => 2003, month => 5, day => 6,
                             time_zone => 'America/Chicago',
                           );

    my $dt2 = DateTime->new( year => 2003, month => 11, day => 6,
                             time_zone => 'America/Chicago',
                           );

    my $dur1 = $dt2->subtract_datetime_absolute($dt1);

    my %deltas1 = $dur1->deltas;
    is( $deltas1{months}, 0, 'delta_months is 0' );
    is( $deltas1{days}, 0, 'delta_days is 0' );
    is( $deltas1{minutes}, 0, 'delta_minutes is 0' );
    is( $deltas1{seconds}, 15901200, 'delta_seconds is 15901200' );
    is( $deltas1{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    is( $dt1->clone->add_duration($dur1), $dt2, 'subtraction is reversible' );
    is( $dt2->clone->subtract_duration($dur1), $dt1, 'subtraction is doubly reversible' );

    my $dur2 = $dt1->subtract_datetime_absolute($dt2);

    my %deltas2 = $dur2->deltas;
    is( $deltas2{months}, 0, 'delta_months is 0' );
    is( $deltas2{days}, 0, 'delta_days is 0' );
    is( $deltas2{minutes}, 0, 'delta_minutes is 0' );
    is( $deltas2{seconds}, -15901200, 'delta_seconds is -15901200' );
    is( $deltas2{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    is( $dt2->clone->add_duration($dur2), $dt1, 'subtraction is reversible' );
    is( $dt1->clone->subtract_duration($dur2), $dt2, 'subtraction is doubly reversible' );
}

{
    my $dt1 = DateTime->new( year => 2003, month => 4, day => 6,
                             hour => 1, minute => 58,
                             time_zone => "America/Chicago",
                           );

    my $dt2 = DateTime->new( year => 2003, month => 4, day => 6,
                             hour => 3, minute => 1,
                             time_zone => "America/Chicago",
                           );

    my $dur = $dt2->subtract_datetime($dt1);

    my %deltas = $dur->deltas;
    is( $deltas{months}, 0, 'delta_months is 0' );
    is( $deltas{days}, 0, 'delta_days is 0' );
    is( $deltas{minutes}, 3, 'delta_minutes is 3' );
    is( $deltas{seconds}, 0, 'delta_seconds is 0' );
    is( $deltas{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    is( $dt1->clone->add_duration($dur), $dt2, 'subtraction is reversible' );
    is( $dt2->clone->subtract_duration($dur), $dt1, 'subtraction is doubly reversible' );
}

{
    my $dt1 = DateTime->new( year => 2003, month => 4, day => 5,
                             hour => 1, minute => 58,
                             time_zone => "America/Chicago",
                           );

    my $dt2 = DateTime->new( year => 2003, month => 4, day => 6,
                             hour => 3, minute => 1,
                             time_zone => "America/Chicago",
                           );

    my $dur = $dt2->subtract_datetime($dt1);

    my %deltas = $dur->deltas;
    is( $deltas{months}, 0, 'delta_months is 0' );
    is( $deltas{days}, 1, 'delta_days is 1' );
    is( $deltas{minutes}, 3, 'delta_minutes is 3' );
    is( $deltas{seconds}, 0, 'delta_seconds is 0' );
    is( $deltas{nanoseconds}, 0, 'delta_nanoseconds is 0' );

    is( $dt1->clone->add_duration($dur), $dt2, 'subtraction is reversible' );
    is( $dt2->clone->subtract_duration($dur->time_duration)->subtract_duration($dur->date_duration),
        $dt1, 'subtraction is doubly reversible (using time & date portions separately)' );
}
