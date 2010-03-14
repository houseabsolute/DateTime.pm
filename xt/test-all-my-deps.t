use strict;
use warnings;

use Test::DependentModules qw( test_all_dependents );

$ENV{PERL_TEST_DM_LOG_DIR}
    = '/home/autarch/projects/DateTime/modules/DateTime.pm/tamd';

my $exclude = qr/(?:^App-)
                 |
                 ^(?:
                   Archive-RPM
                   |
                   Video-Xine
                  )$
                 /x;

test_all_dependents( 'DateTime', { exclude => $exclude } );
