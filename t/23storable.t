#!/usr/bin/perl -w

use strict;

use Test::More;

use DateTime;

if ( eval { require Storable; 1 } )
{
    plan tests => 5;
}
else
{
    plan skip_all => 'Cannot load Storable';
}

{
    my $dt =
        DateTime->new( year => 1950,
                       hour => 1,
                       nanosecond => 1,
                       time_zone => 'America/Chicago',
                       language => 'German'
                     );

    my $copy = Storable::thaw( Storable::nfreeze($dt) );

    is( $copy->time_zone->name, 'America/Chicago',
        'Storable freeze/thaw preserves tz' );

    is( ref $copy->locale, 'DateTime::Locale::de',
        'Storable freeze/thaw preserves locale' );

    is( $copy->year, 1950,
        'Storable freeze/thaw preserves rd values' );

    is( $copy->hour, 1,
        'Storable freeze/thaw preserves rd values' );

    is( $copy->nanosecond, 1,
        'Storable freeze/thaw preserves rd values' );
}

