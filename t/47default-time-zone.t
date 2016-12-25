use strict;
use warnings;

use Test::More;

use DateTime;

{
    my $dt = DateTime->new( year => 2000, month => 2, day => 21 );
    is(
        $dt->time_zone->name, 'floating',
        'Time zones for new DateTime objects should default to floating'
    );
    is(
        DateTime->last_day_of_month( year => 2000, month => 2 )
            ->time_zone->name,
        'floating',
        'last_day_of_month time zone also should default to floating'
    );
    is(
        DateTime->from_day_of_year( year => 2000, day_of_year => 212 )
            ->time_zone->name,
        'floating',
        'from_day_of_year time zone also should default to floating'
    );
    is(
        DateTime->now->time_zone->name, 'UTC',
        '... except for constructors which assume UTC'
    );
    is(
        DateTime->from_epoch( epoch => time() )->time_zone->name, 'UTC',
        '... except for constructors which assume UTC'
    );
}

{
    my $dt1 = DateTime->new( year => 1970, hour => 1, nanosecond => 100 );
    my $dt2 = DateTime->from_object( object => $dt1 );
    is(
        $dt2->time_zone->name, 'floating',
        'Copying DateTime objects from other DateTime objects should retain the timezone'
    );
}

{
    my $dt = DateTime->new( year => 2000, month => 2, day => 21 );
    local $ENV{PERL_DATETIME_DEFAULT_TZ} = 'America/Los_Angeles';
    is(
        $dt->time_zone->name, 'floating',
        'Setting PERL_DATETIME_DEFAULT_TZ env should not impact existing objects'
    );
    $dt = DateTime->new( year => 2000, month => 2, day => 21 );
    is(
        $dt->time_zone->name, $ENV{PERL_DATETIME_DEFAULT_TZ},
        '... but new objects should no longer default to the floating time zone'
    );
    is(
        DateTime->last_day_of_month( year => 2000, month => 2 )
            ->time_zone->name,
        $ENV{PERL_DATETIME_DEFAULT_TZ},
        'last_day_of_month time zone also should default to floating'
    );
    is(
        DateTime->from_day_of_year( year => 2000, day_of_year => 212 )
            ->time_zone->name,
        $ENV{PERL_DATETIME_DEFAULT_TZ},
        'from_day_of_year time zone also should default to floating'
    );
    is(
        DateTime->now->time_zone->name, 'UTC',
        '... and constructors which assume UTC should remain unchanged'
    );

    my $dt1 = DateTime->new( year => 1970, hour => 1, nanosecond => 100 );
    my $dt2 = DateTime->from_object( object => $dt1 );
    is(
        $dt2->time_zone->name, $ENV{PERL_DATETIME_DEFAULT_TZ},
        'Copying DateTime objects from other DateTime objects should retain the timezone'
    );
}

{
    my $dt = DateTime->new( year => 2000, month => 2, day => 21 );
    is(
        $dt->time_zone->name, 'floating',
        'Default time zone should revert to "floating" when PERL_DATETIME_DEFAULT_TZ no longer set'
    );
}

done_testing();
