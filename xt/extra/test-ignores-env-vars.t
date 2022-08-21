use strict;
use warnings;

use Test::More;

use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use File::Spec;

my $test_file = File::Spec->catfile(
    dirname( abs_path($0) ),
    File::Spec->updir, File::Spec->updir,
    't',               '04epoch.t',
);

local $ENV{PERL_DATETIME_DEFAULT_TZ} = 'America/Chicago';
is(
    system( qw( prove --quiet ), $test_file ), 0,
    'no error running test with PERL_DATETIME_DEFAULT_TZ env var set',
);

done_testing();
