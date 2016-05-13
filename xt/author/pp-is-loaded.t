use strict;
use warnings;

use Test::More;

BEGIN {
    ## no critic (Variables::RequireLocalizedPunctuationVars)
    $ENV{PERL_DATETIME_PP} = 1;
}

use DateTime;

## no critic (Variables::ProhibitPackageVars)
ok(
    $DateTime::IsPurePerl,
    'PurePerl implementation is loaded when env var is set'
);

done_testing();
