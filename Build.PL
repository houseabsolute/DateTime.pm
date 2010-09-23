use strict;
use warnings;

use Module::Build;

my %module_build_args = (
    module_name          => 'DateTime',
    license              => 'artistic_2',
    c_source             => 'c',
    recursive_test_files => 1,
    requires             => {
        'DateTime::Locale'   => '0.41',
        'DateTime::TimeZone' => '1.09',
        'Params::Validate'   => '0.76',
        'Scalar::Util'       => '0',
        'Time::Local'        => '1.04'
    },
    build_requires => {
        'ExtUtils::CBuilder' => '0',
        'Module::Build'      => '0',
        'Pod::Man'           => '1.14',
        'Test::Exception'    => '0',
        'Test::More'         => '0.88'
    },
    configure_requires => { 'Module::Build' => '0' },
);

my $build = Module::Build->new(%module_build_args);

if ( grep { $_ eq '--pp' } @ARGV ) {
    $build->build_elements(
        [ grep { $_ ne 'xs' } @{ $build->build_elements() } ] );
}
elsif ( $ENV{AUTHOR_TESTING} || -d '.hg' ) {
    require File::Find::Rule;
    require File::Slurp;
    File::Slurp->import( qw( read_file write_file ));

    my @files;
    for my $t_file ( File::Find::Rule->name('*.t')->in('t') ) {
        my $content = read_file($t_file);

        next if $content =~ /^\#\s*no\s+pp\s+test\s*$/m;

        $content = <<"EOF";
use Test::More;

BEGIN {
    unless ( \$ENV{AUTHOR_TESTING} || -d '.hg' ) {
        plan skip_all => 'these tests are for testing by the author';
    }

    \$ENV{PERL_DATETIME_PP} = 1;
}

$content
EOF

        ( my $new_name = $t_file ) =~ s{/([^/]+)$}{/author-pp-$1};

        write_file( $new_name, $content );

        push @files, $new_name;
    }

    $build->add_to_cleanup(@files);
}

$build->create_build_script;
