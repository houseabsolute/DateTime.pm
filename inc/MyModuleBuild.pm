package inc::MyModuleBuild;

use strict;
use warnings;

use Moose;

extends 'Dist::Zilla::Plugin::ModuleBuild::XSOrPP';

around module_build_args => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    $args->{c_source} = 'c';

    return $args;
};

__PACKAGE__->meta()->make_immutable();

1;
