# The perl/C checking voodoo is stolen from Graham Barr's
# Scalar-List-Utils distribution.

use strict;

use ExtUtils::MakeMaker;
use Config qw(%Config);

my $no_xs;
for (@ARGV)
{
    /^--pm/ and $no_xs = 1;
    /^--xs/ and $no_xs = 0;
}

write_makefile();

exit if defined $no_xs;

print "Testing if you have a C compiler\n";

unless ( open F, ">test.c" )
{
    warn "Cannot write test.c, skipping test compilation and install pure Perl version.\n";
    no_cc();
}

print F <<'EOF';
int main() { return 0; }
EOF

close F or no_cc();

my $make = $^O =~ /win32/i ? 'nmake' : 'make';
system("$make test$Config{obj_ext}") and no_cc();

sub write_makefile
{
    WriteMakefile( NAME         => 'DateTime',
                   VERSION_FROM => 'lib/DateTime.pm',
                   AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
                   ABSTRACT     => 'DateTime base objects',
                   clean        => { FILES => 'test.c' },

                   PREREQ_PM    => { 'Class::Factory::Util' => 1.3,
                                     'DateTime::TimeZone' => 0.10,
                                     'Params::Validate' => 0.52,
                                     'Test::More'  => 0,
                                     'Time::Local' => 0,
                                   },
                 );
}

sub init
{
    my $hash = $_[1];

    if ($no_xs)
    {
        @{ $hash }{ 'XS', 'C' } = ( {}, [] );
    }

    $hash;
}

sub no_cc
{
    $no_xs = 1;
    print <<'EOF';

 I cannot determine if you have a C compiler
 so I will install a perl-only implementation

 You can force installation of the XS version with

    perl Makefile.PL --xs

EOF

    write_makefile();
    exit;
}
