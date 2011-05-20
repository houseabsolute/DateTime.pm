# no pp test

use strict;
use warnings;

use Test::More;

no warnings 'once', 'redefine';

require XSLoader;

my $orig = \&XSLoader::load;

my $sub = sub {
    if ( defined $_[0] && $_[0] eq 'DateTime' ) {
        die q{Can't locate loadable object for module DateTime in @INC};
    }
    else {
        goto $orig;
    }
};

*XSLoader::load = $sub;

eval { require DateTime };
is( $@, '', 'No error loading DateTime without DateTime.so file' );
ok( $DateTime::IsPurePerl, '$DateTime::IsPurePerl is true' );

ok(
    DateTime->new( year => 2005 ),
    'can make DateTime object without DateTime.so file'
);

done_testing();
