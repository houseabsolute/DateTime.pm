##
## French tables, contributed by Emmanuel Bataille (bem@residents.frmug.org)
##

package DateTime::Language::French;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::Language);
$VERSION = "1.02";

@DayNames = qw(dimanche lundi mardi mercredi jeudi vendredi samedi);
@MonthNames = qw(janvier février mars avril mai juin 
          juillet août septembre octobre novembre décembre);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,4) } @MonthNames; # 4 insteed of 3 'cause [juin] [juil]let
@AMPM = qw(AM PM);

# @OrdinalSuffixes = (qw(er e e e e e e e e e)) x 3;
# Not need..
# @OrdinalSuffixes[11,12,13] = qw(th th th);
# @OrdinalSuffixes[30,31] = qw(th st);
@OrdinalSuffixes = ((qw(er e e e e e e e e e)) x 3, 'er'); # ch@debian.org
# ^^^ recommended by Peter Samuelson <peter@cadcamlab.org>

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
