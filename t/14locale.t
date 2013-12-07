use strict;
use warnings;

use Test::More;

use DateTime;
use DateTime::Locale;

eval { DateTime->new( year => 100, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime->now( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime->today( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime->from_epoch( epoch => 1, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval {
    DateTime->last_day_of_month( year => 100, month => 2, locale => 'en_US' );
};
is( $@, '', 'make sure constructor accepts locale parameter' );

{

    package DT::Object;
    sub utc_rd_values { ( 0, 0 ) }
}

eval {
    DateTime->from_object( object => ( bless {}, 'DT::Object' ),
        locale => 'en_US' );
};
is( $@, '', 'make sure constructor accepts locale parameter' );

eval {
    DateTime->new( year => 100, locale => DateTime::Locale->load('en_US') );
};
is( $@, '', 'make sure constructor accepts locale parameter as object' );

DateTime->DefaultLocale('it');
is( DateTime->now->locale->id, 'it', 'default locale should now be "it"' );

{
    my $dt = DateTime->new(
        year      => 2013, month => 10, day => 27, hour => 0,
        time_zone => 'UTC'
    );

    my $after_zone = $dt->clone()->set_time_zone('Europe/Rome');

    is(
        $after_zone->offset(),
        '7200',
        'offset is 7200 after set_time_zone()'
    );

    my $after_locale
        = $dt->clone()->set_time_zone('Europe/Rome')->set_locale('en_GB');

    is(
        $after_locale->offset(),
        '7200',
        'offset is 7200 after set_time_zone() and set_locale()'
    );
}

done_testing();
