##
## Czech tables
##
## Contributed by Honza Pazdziora 

package DateTime::Language::Czech;

use strict;

use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @MonthNames2 @AMPM $VERSION);
@ISA = qw(DateTime::LanguageDateTime::Format::Generic);


@MonthNames = qw(leden únor bøezen duben kvìten èerven èervenec srpen záøí
	      øíjen listopad prosinec);
@MonthAbbreviations = qw(led únor bøe dub kvì èvn èec srp záøí øíj lis pro);
@MonthNames2 = @MonthNames;
for (@MonthNames2)
      { s!en$!na! or s!ec$!ce! or s!ad$!adu! or s!or$!ora!; }

@DayNames = qw(pondìlí úterý støeda ètvrtek pátek sobota nedìle);
@DayAbbreviations = qw(Po Út St Èt Pá So Ne);

@AMPM = qw(dop. odp.);

# contact Honza to make sense of this before deleting! - dave

sub time2str {
      my $ref = shift;
      my @a = @_;
      $a[0] =~ s/(%[do]\.?\s?)%B/$1%Q/;
      $ref->SUPER::time2str(@a);
      }

sub strftime {
      my $ref = shift;
      my @a = @_;
      $a[0] =~ s/(%[do]\.?\s?)%B/$1%Q/;
      $ref->SUPER::time2str(@a);
      }

1;
