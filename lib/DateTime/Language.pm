package DateTime::Language;

use strict;

# provides subclasses method
use Class::Factory::Util;

sub new
{
    my $class = shift;

    my $self;
    foreach my $key ( qw( day_names day_abbreviations month_names
                          month_abbreviations am_pm ordinal_suffixes
                          month_numbers day_numbers
                        )
                    )
    {
        my $var_name = join '', map { ucfirst } split /_/, $key;
        $var_name = 'AMPM' if $var_name eq 'AmPm';

        no strict 'refs';
        if ( $key =~ /numbers$/ )
        {
            $self->{$key} = \%{"$class\::$var_name"};
        }
        else
        {
            $self->{$key} = \@{"$class\::$var_name"};
        }
    }

    return bless $self, $class;
}

sub month_names { $_[0]->{month_names} }

sub month_name  { $_[0]->{month_names}[ $_[1] ] }

sub day_names { $_[0]->{day_names} }

sub day_name  { $_[0]->{day_names}[ $_[1] ] }

sub month_abbreviations { $_[0]->{month_abbreviations} }

sub month_abbreviation  { $_[0]->{month_abbreviations}[ $_[1] ] }

sub day_abbreviations { $_[0]->{day_abbreviations} }

sub day_abbreviation  { $_[0]->{day_abbreviations}[ $_[1] ] }

sub month_number { $_[0]->{month_numbers}{ $_[1] } }

sub day_number { $_[0]->{day_numbers}{ $_[1] } }

sub ampm { $_[0]->{am_pm}[ $_[1] > 12 ? 0 : 1 ] }

sub ordinal_suffixes { $_[0]->{ordinal_suffixes} }

1;

__END__

=head1 NAME

DateTime::Language - base class for DateTime.pm-related language localization

=head1 SYNOPSIS

  package DateTime::Language::Gibberish;

  use base qw(DateTime::Language);

=head1 DESCRIPTION

This class provides most of the methods needed to implement language
localization for DateTime.pm.  A subclass of this language simply

=cut
