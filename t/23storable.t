use strict;
use warnings;

use Test::More;

use DateTime;

unless ( eval { require Storable; 1 } ) {
    plan skip_all => 'Cannot load Storable';
}

{
    my @dt = (
        DateTime->new(
            year       => 1950,
            hour       => 1,
            nanosecond => 1,
            time_zone  => 'America/Chicago',
            locale     => 'de'
        ),
        DateTime::Infinite::Past->new,
        DateTime::Infinite::Future->new,
    );

    foreach my $dt (@dt) {
        my $copy = Storable::thaw( Storable::nfreeze($dt) );

        is(
            $copy->time_zone->name, $dt->time_zone->name,
            'Storable freeze/thaw preserves tz'
        );

        is(
            ref $copy->locale, ref $dt->locale,
            'Storable freeze/thaw preserves locale'
        );

        is(
            $copy->year, $dt->year,
            'Storable freeze/thaw preserves rd values'
        );

        is(
            $copy->hour, $dt->hour,
            'Storable freeze/thaw preserves rd values'
        );

        is(
            $copy->nanosecond, $dt->nanosecond,
            'Storable freeze/thaw preserves rd values'
        );
    }
}

{
    my $dt1 = DateTime->now( locale => 'en-US' );
    my $dt2 = Storable::dclone($dt1);
    my $dt3 = Storable::thaw( Storable::nfreeze($dt2) );

    is(
        $dt1->iso8601, $dt2->iso8601,
        'dclone produces date equal to original'
    );
    is(
        $dt2->iso8601, $dt3->iso8601,
        'explicit freeze and thaw produces date equal to original'
    );

    # Back-compat shim for new DateTime::Locale. Remove once DT::Locale based
    # on CLDR 28+ is released.
    my $meth = $dt1->locale->can('code') ? 'code' : 'id';
    my $orig_code = $dt1->locale->$meth;
    is(
        $dt2->locale->$meth,
        $orig_code,
        'check locale id after dclone'
    );
    is(
        $dt3->locale->$meth,
        $orig_code,
        'check locale id after explicit freeze/thaw'
    );
}

{
    package Formatter;

    sub format_datetime { }
}

{
    my $dt = DateTime->new(
        year      => 2004,
        formatter => 'Formatter',
    );

    my $copy = Storable::thaw( Storable::nfreeze($dt) );

    is(
        $dt->formatter, $copy->formatter,
        'Storable freeze/thaw preserves formatter'
    );
}

done_testing();
