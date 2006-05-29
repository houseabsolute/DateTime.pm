# The perl/C checking voodoo is stolen from Graham Barr's
# Scalar-List-Utils distribution.

use strict;

use Config qw(%Config);
use ExtUtils::MakeMaker;
use File::Spec;

my $no_xs;
for (@ARGV)
{
    /^--pm/ and $no_xs = 1;
    /^--xs/ and $no_xs = 0;
}

if ($no_xs)
{
    write_makefile();
    exit;
}

unless (defined $no_xs)
{
    check_for_compiler()
        or no_cc();

    if ( -d '.svn' )
    {
        local *DIR;
        opendir DIR, "t" or die "Cannot read t: $!";

        foreach my $file ( grep { /^\d.+\.t$/ } readdir DIR )
        {
            next if $file eq '26dt_leapsecond_pm.t';
            next if $file eq '99-pod.t';

            my $real_file = File::Spec->catfile( 't', $file );

            local *F;
            open F, "<$real_file" or die "Cannot read $real_file: $!";

            my $test = do { local $/; <F> };

            close F;

            $test = "#!/usr/bin/perl -w\n\nBEGIN { \$ENV{PERL_DATETIME_PP} = 1 }\n\n$test";

            my $new_file = File::Spec->catfile( 't', "zz_$file" );
            open F, ">$new_file" or die "Cannot write $new_file: $!";

            print F $test;

            close F;
        }
    }
}

write_makefile();

sub write_makefile
{
    my $zz = join ' ', glob File::Spec->catfile( 't', 'zz_*.t' );
    WriteMakefile( NAME         => 'DateTime',
                   VERSION_FROM => 'lib/DateTime.pm',
                   AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
                   ABSTRACT     => 'DateTime base objects',
                   clean        => { FILES => "test.c test.o $zz" },
                   CONFIGURE    => \&init,

                   PREREQ_PM    => { 'DateTime::Locale'   => 0.21,
                                     'DateTime::TimeZone' => 0.38,
                                     'Params::Validate'   => 0.76,
                                     'Pod::Man'           => 1.14,
                                     'Scalar::Util'       => 0,
                                     'Test::More'         => 0.34,
                                     'Time::Local'        => 1.04,
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

 I cannot find a C compiler so I will install a perl-only
 implementation

 You can force installation of the XS version with

    perl Makefile.PL --xs

EOF

    write_makefile();
    exit;
}

sub check_for_compiler
{
    print "Testing if you have a C compiler\n";

    eval { require ExtUtils::CBuilder };
    if ($@)
    {
        return _check_for_compiler_manually();
    }
    else
    {
        return _check_for_compiler_with_cbuilder();
    }
}

sub _check_for_compiler_with_cbuilder
{
    my $cb = ExtUtils::CBuilder->new( quiet => 1 );

    return $cb->have_compiler;
}

sub _check_for_compiler_manually
{
    unless ( open F, ">test.c" )
    {
        warn "Cannot write test.c, skipping test compilation and installing pure Perl version.\n";
        return 0;
    }

    print F <<'EOF';
int main() { return 0; }
EOF

    close F or return 0;

    system( "$Config{cc} -o test$Config{obj_ext} test.c" ) and return 0;

    return 1;
}
