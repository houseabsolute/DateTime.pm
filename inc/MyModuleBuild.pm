package inc::MyModuleBuild;

use Moose;
use Moose::Autobox;

extends 'Dist::Zilla::Plugin::ModuleBuild';

sub setup_installer {
    return;
}
