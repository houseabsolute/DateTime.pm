##
## Italian tables
##

package DateTime::Language::Italian;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::Language);


@MonthNames  = qw(Gennaio Febbraio Marzo Aprile Maggio Giugno
	   Luglio Agosto Settembre Ottobre Novembre Dicembre);
@MonthAbbreviations = qw(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic);
@DayNames  = qw(Domenica Lunedi Martedi Mercoledi Giovedi Venerdi Sabato);
@DayAbbreviations = qw(Dom Lun Mar Mer Gio Ven Sab);

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
