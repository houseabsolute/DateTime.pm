package DateTime::Language;

use strict;

use Class::Factory::Util;

sub available
{
    return Class::Factory::Util::subclasses(__PACKAGE__);
}

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

sub month_name  { $_[0]->{month_names}[ $_[1]->month_0 ] }

sub day_names { $_[0]->{day_names} }

sub day_name  { $_[0]->{day_names}[ $_[1]->day_of_week_0 ] }

sub month_abbreviations { $_[0]->{month_abbreviations} }

sub month_abbreviation  { $_[0]->{month_abbreviations}[ $_[1]->month_0 ] }

sub day_abbreviations { $_[0]->{day_abbreviations} }

sub day_abbreviation  { $_[0]->{day_abbreviations}[ $_[1]->day_of_week_0 ] }

sub am_pm { $_[0]->{am_pm}[ $_[1]->hour < 12 ? 0 : 1 ] }

#sub preferred_datetime_format { '%m/%d/%y %H:%M:%S' }
#sub preferred_date_format { '%m/%d/%y' }
#sub preferred_time_format { '%H:%M:%S' }

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

=head1 USAGE

This module provides one somewhat interesting function,
C<available()>.  Calling this method returns a list of subclass names,
minus the leading "DateTime::Language::" portion.

=head1 SUBCLASSING

People who want to add support for new languages may be interested in
subclassing this module.

The simplest way to do this is to simply declare your new module,
let's call it C<DateTime::Language::Inhumi>, a subclass of
C<DateTime::Language>, and to define a set of global variables in your
namespace.

These globals are:

=over 4

=item * @DayNames

The names of each day, starting with Monday.

=item * @DayAbbreviations

Abbreviated names for each day.

=item * @MonthNames

The names of each month, starting with January.

=item * @MonthAbbreviations

Abbreviated names for each month.

=item * @AMPM

The terms used for AM and PM in the language you are implementing.

=back

The C<DateTime::Language> module implements methods that use these
globals as needed.  If you need to implement more complex algorithms,
you can override the following methods:

=over 4

=item * month_names

Returns a list of month names.

=item * month_name( $dt )

Given a C<DateTime> object, this method should return the correct
month name.

=item * month_abbreviations

Returns a list of month abbreviations.

=item * month_abbreviation( $dt )

Given a C<DateTime> object, this method should return the correct
month abbreviation.

=item * day_names

Returns a list of day names.

=item * day_name( $dt )

Given a C<DateTime> object, this method should return the correct day
name.

=item * day_abbreviations

Returns a list of day abbreviations.

=item * day_abbreviation( $dt )

Given a C<DateTime> object, this method should return the correct day
abbreviation.

=item * am_pm( $dt )

Given a C<DateTime> object, returns the correct AM or PM abbreviation.

=back

=head1 SUPPORT

Support for this module is provided via the datetime@perl.org email
list.  See http://lists.perl.org/ for more details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

However, please see the CREDITS file for more details on who I really
stole all the code from.

=head1 COPYRIGHT

Copyright (c) 2003 David Rolsky.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

Portions of the code in this distribution are derived from other
works.  Please see the CREDITS file for more details.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

datetime@perl.org mailing list

http://datetime.perl.org/

=cut
