use strict;
use warnings;

use Test::More;

use DateTime;

undef $ENV{PERL_DATETIME_DEFAULT_TZ};

no warnings 'redefine';
## no critic (Variables::ProtectPrivateVars)
local *DateTime::_core_time = sub {0};

my $dt = DateTime->now;

is(
    "$dt",
    '1970-01-01T00:00:00',
    'overriding DateTime::_core_time() works'
);

done_testing();
