package DateTime::Language;

use strict;

use Class::Factory::Util;
use Params::Validate qw( validate SCALAR );

my %ISOMap;
foreach my $set ( [ 'aa', 'aar'                 => 'Afar' ],
                  [ 'am', 'amh'                 => 'Amharic' ],
                  [ 'cz', 'ces', 'cze'          => 'Czech' ],
                  [ 'de', 'deu', 'ger'          => 'German' ],
                  [ 'de-at', 'deu-at', 'ger-at' => 'Austrian' ],
                  [ 'dk', 'dan'                 => 'Danish' ],
                  [ 'en', 'eng'                 => 'English' ],
                  [ 'es', 'esl', 'spa'          => 'Spanish' ],
                  [ 'fr', 'fra', 'fre'          => 'French' ],
                  [ 'x-drs', 'sil-drs'          => 'Gedeo' ],
                  [ 'it', 'ita'                 => 'Italian' ],
                  [ 'nl', 'dut', 'nla'          => 'Dutch' ],
                  [ 'no', 'nor'                 => 'Norwegian' ],
                  [ 'om', 'orm'                 => 'Oromo' ],
                  [ 'pt', 'por','pt-br', 'por-br',
                                                => 'Portuguese' ],
                  [ 'sid'                       => 'Sidama' ],
                  [ 'so', 'som'                 => 'Somali' ],
                  [ 'sv', 'sve', 'swe'          => 'Swedish' ],
                  [ 'ti-et', 'tig-et'           => 'TigrinyaEthiopian' ],
                  [ 'ti-er', 'tig-er'           => 'TigrinyaEritrean' ],
                  [ 'tig'                       => 'Tigre' ],
             )
{
    my $module = pop @$set;
    @ISOMap{ @$set } = ($module) x @$set;
}

sub new
{
    my $class = shift;
    my %p = validate( @_,
                      { language => { type => SCALAR, optional => 1 } },
                    );

    my $real_class =
        defined $p{language} ? $class->load( $p{language} ) : $class;

    my $obj = bless {}, $real_class;

    $obj->_init;

    return $obj;
}

sub languages { $_[0]->subclasses }
sub iso_codes { keys %ISOMap }

sub load
{
    my $class = shift;
    my $lang = shift;

    my $real_lang;
    if ( $lang =~ /^((?:x-)?\w\w\w?)(?:-\w\w\w?)?$/ )
    {
        $real_lang =
            ( exists $ISOMap{$lang} ?
              $ISOMap{$lang} :
              $1 ?
              $ISOMap{$1} :
              undef
            );

        die "Unsupported or invalid ISO language code, $lang"
            unless defined $real_lang;
    }
    else
    {
        $real_lang = $lang;
    }

    my $real_class = "DateTime::Language::$real_lang";
    eval "use $real_class";
    die $@ if $@;

    return $real_class;
}

sub _init
{
    my $self = shift;
    my $class = ref $self;

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
}

sub name { (split /::/, ref $_[0])[-1] }

sub month_names { $_[0]->{month_names} }

sub month_name  { $_[0]->{month_names}[ $_[1]->month_0 ] }

sub day_names { $_[0]->{day_names} }

sub day_name  { $_[0]->{day_names}[ $_[1]->day_of_week_0 ] }

sub month_abbreviations { $_[0]->{month_abbreviations} }

sub month_abbreviation  { $_[0]->{month_abbreviations}[ $_[1]->month_0 ] }

sub day_abbreviations { $_[0]->{day_abbreviations} }

sub day_abbreviation  { $_[0]->{day_abbreviations}[ $_[1]->day_of_week_0 ] }

sub am_pm_list { $_[0]->{am_pm} }

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
provides a set of data structures containing things like day and
months names.

This module is a factory for language subclasses, and can load a class
either based on the language portion of its name, such as "English",
or based on its ISO code, such as "en" or "eng".

=head1 USAGE

This module provides the following methods:

=over 4

=item * new( language => $language )

This method loads the requested language and returns an object of the
appropriate class.  The "language" parameter may be the name of the
language subclass to be used, such as "English", as returned by the
C<languages()> method.  It can also be an ISO 639 two-letter language
code.  The language code may include an ISO 3166 two-letter country
after a dash, so things like "en" or "en-us" are both legal.  If a
country code is given, then the most specific match is used.  For
example, if "en-au" (English, Australian) is given, then the nearest
match will be "en", which will be used instead.

If you want to subclass this module outside of the DateTime::Language
namespace, simply call C<new()> on your subclass, without a "language"
parameter.  For example, you can simply do this:

  package Foo::Language::PigLatin;
  use base 'DateTime::Language';

  ...

  DateTime->new( ..., language => Foo::Language::PigLatin->new );

=item * load( $language )

This tells the module to load the specified language without creating
an object.  The language given can be anything accepted by the
C<new()> method.

=item * languages

Returns a list of supported language names.

=item * iso_codes

Returns a list of supported ISO language codes.  See the C<new()>
method documentation for details.

=back

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

=item * name

Returns the language name, which is the module name without the
leading "DateTime::Language::" piece.

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

=item * am_pm_list

Returns a list of the AM/PM texts. First item should be the AM, the
second should be the PM.

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
