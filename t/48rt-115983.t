use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;

# The bug here is that if DateTime doesn't clean it's namespace, it ends up
# having a catch method that is getting called here and being passed a hashref
# containing the return value of $dt->truncate. See
# https://rt.cpan.org/Ticket/Display.html?id=115983

my $dt = DateTime->now;
like(
    exception {
        try { } catch {
            $dt->truncate( to => 'hour' );
        };
    },
    qr/Can\'t locate object method "catch"/,
    'DateTime does not have a catch method'
);

done_testing();
