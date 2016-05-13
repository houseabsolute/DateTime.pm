use strict;
use warnings;

use Test::More;

use DateTime;

## no critic (Variables::ProhibitPackageVars)
ok(
    !$DateTime::IsPurePerl,
    'XS implementation is loaded by default'
);

done_testing();
