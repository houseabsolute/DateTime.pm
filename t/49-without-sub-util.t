use strict;
use warnings;

use Test::More 0.88;
use Test::Without::Module qw( Sub::Util );

undef $ENV{PERL_DATETIME_DEFAULT_TZ};

use_ok('DateTime');

done_testing();
