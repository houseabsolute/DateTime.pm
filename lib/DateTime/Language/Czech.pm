##
## Czech tables
##
## Contributed by Honza Pazdziora 

package DateTime::Language::Czech;

use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @MonthNames2 @AMPM %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::LanguageDateTime::Format::Generic);


@MonthNames = qw(leden únor bøezen duben kvìten èerven èervenec srpen záøí
	      øíjen listopad prosinec);
@MonthAbbreviations = qw(led únor bøe dub kvì èvn èec srp záøí øíj lis pro);
@MonthNames2 = @MonthNames;
for (@MonthNames2)
      { s!en$!na! or s!ec$!ce! or s!ad$!adu! or s!or$!ora!; }

@DayNames = qw(nedìle pondìlí úterý støeda ètvrtek pátek sobota);
@DayAbbreviations = qw(Ne Po Út St Èt Pá So);

@AMPM = qw(dop. odp.);

@MonthNames{@MonthNames}  = (1 .. scalar(@MonthNames));
@MonthNames{@MonthAbbreviations} = (1 .. scalar(@MonthAbbreviations));
@DayNames{@DayNames}  = (0 .. scalar(@DayNames));
@DayNames{@DayAbbreviations} = (0 .. scalar(@DayAbbreviations));

# Formatting routines

sub format_a { $DayAbbreviations[$_[0]->[6]] }
sub format_A { $DayNames[$_[0]->[6]] }
sub format_b { $MonthAbbreviations[$_[0]->[4]] }
sub format_B { $MonthNames[$_[0]->[4]] }
sub format_h { $MonthAbbreviations[$_[0]->[4]] }
sub format_p { $_[0]->[2] >= 12 ?  $AMPM[1] : $AMPM[0] }

sub format_d { $_[0]->[3] }
sub format_m { $_[0]->[4] + 1 }
sub format_o { $_[0]->[3] . '.' }

sub format_Q { $MonthNames2[$_[0]->[4]] }

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
