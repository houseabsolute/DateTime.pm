# no pp test

use strict;
use warnings;

use Test::More;

no warnings 'once', 'redefine';

my $sub
    = sub { die q{Can't locate loadable object for module DateTime in @INC} };

require XSLoader;
*XSLoader::load = $sub;

eval { require DateTime };
is( $@, '', 'No error loading DateTime without DateTime.so file' );
ok( $DateTime::IsPurePerl, '$DateTime::IsPurePerl is true' );

ok(
    DateTime->new( year => 2005 ),
    'can make DateTime object without DateTime.so file'
);

done_testing();
