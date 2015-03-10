use strict;
use warnings;

use Test::More;

use DateTime;

ok( !$DateTime::IsPurePerl, 'Loading DateTime loaded the XS version' );

done_testing();
