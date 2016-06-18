# no pp test
# HARNESS-NO-PRELOAD

use strict;
use warnings;

use Test::Fatal;
use Test::More;

## no critic (TestingAndDebugging::ProhibitNoWarnings)
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

is(
    exception { require DateTime },
    undef,, 'No error loading DateTime without DateTime.so file'
);
## no critic (Variables::ProhibitPackageVars)
ok( $DateTime::IsPurePerl, '$DateTime::IsPurePerl is true' );

ok(
    DateTime->new( year => 2005 ),
    'can make DateTime object without DateTime.so file'
);

done_testing();
