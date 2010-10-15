use strict;
use warnings;

use Cwd qw( abs_path );
use Test::More;

BEGIN {
    plan skip_all =>
        'Must set DATETIME_TEST_ALL_DEPS to true in order to run these tests'
        unless $ENV{DATETIME_TEST_ALL_DEPS};
}

use Test::DependentModules qw( test_all_dependents );

$ENV{PERL_TEST_DM_LOG_DIR} = abs_path('.');

my $exclude = qr/(?:^App-)
                 |
                 ^(?:
                   Archive-RPM
                   |
                   Video-Xine
                  )$
                 /x;

test_all_dependents( 'DateTime', { exclude => $exclude } );
