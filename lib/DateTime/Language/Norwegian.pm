##
## Norwegian tables
##

package DateTime::Language::Norwegian;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::Language);


@MonthNames  = qw(Januar Februar Mars April Mai Juni
	   Juli August September Oktober November Desember);
@MonthAbbreviations = qw(Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Des);
@DayNames  = qw(Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag);
@DayAbbreviations = qw(Søn Man Tir Ons Tor Fre Lør Søn);

require DateTime::Language::English;
@AMPM =   @{DateTime::Language::English::AMPM};
@OrdinalSuffixes =   @{DateTime::Language::English::OrdinalSuffixes};

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

1;
