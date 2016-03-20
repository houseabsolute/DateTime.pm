use strict;
use warnings;

use Test::More;

use DateTime;

ok(
    !$DateTime::IsPurePerl,
    'XS implementation is loaded by default'
);

done_testing();
