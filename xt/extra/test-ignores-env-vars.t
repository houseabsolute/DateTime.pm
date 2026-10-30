use strict;
use warnings;

use Test::More;

use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use File::Spec;
use TAP::Harness;

my $test_file = File::Spec->catfile(
    dirname( abs_path($0) ),
    File::Spec->updir, File::Spec->updir,
    't',               '04epoch.t',
);

local $ENV{PERL_DATETIME_DEFAULT_TZ} = 'America/Chicago';

# We use TAP::Harness instead of shelling out to prove so the test runs with $^X. The prove in the
# PATH may belong to a different perl, or it may be a shim from a tool like mise that can fail in
# the build directory.
my $harness    = TAP::Harness->new( { verbosity => -1 } );
my $aggregator = $harness->runtests($test_file);
ok(
    $aggregator->all_passed,
    'no error running test with PERL_DATETIME_DEFAULT_TZ env var set',
);

done_testing();
