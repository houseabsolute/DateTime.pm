##
## Italian tables
##

package DateTime::Language::Italian;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::Language);


@MonthNames  = qw(Gennaio Febbraio Marzo Aprile Maggio Giugno
	   Luglio Agosto Settembre Ottobre Novembre Dicembre);
@MonthAbbreviations = qw(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic);
@DayNames  = qw(Lunedi Martedi Mercoledi Giovedi Venerdi Sabato Domenica);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;

require DateTime::Language::English;
@AMPM =   @{DateTime::Language::English::AMPM};
@OrdinalSuffixes =   @{DateTime::Language::English::OrdinalSuffixes};

@MonthNames{@MonthNames}  = (1 .. scalar(@MonthNames));
@MonthNames{@MonthAbbreviations} = (1 .. scalar(@MonthAbbreviations));
@DayNames{@DayNames}  = (0 .. scalar(@DayNames));
@DayNames{@DayAbbreviations} = (0 .. scalar(@DayAbbreviations));

1;
