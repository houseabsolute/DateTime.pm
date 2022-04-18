use strict;
use warnings;

use Test::More 0.88;

undef $ENV{PERL_DATETIME_DEFAULT_TZ};

use_ok('DateTime');

done_testing();
