use strict;

use Test::More tests => 4;

use DateTime;

{
    my $dt = DateTime->new( year => 100, attributes => { foo => 'bar' } );

    ok( $dt->has_attribute('foo'), 'has foo attribute' );
    ok( ! $dt->has_attribute('bar'), 'does not have bar attribute' );
    is( $dt->attribute('foo'), 'bar', 'foo attribute is bar' );

    $dt->set_attribute( baz => 1 );
    is( $dt->attribute('baz'), 1, 'baz attribute is 1' );
}


