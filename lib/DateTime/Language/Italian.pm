##
## Italian tables
##

package DateTime::Language::Italian;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@MonthNames = qw(Gennaio Febbraio Marzo Aprile Maggio Giugno
                 Luglio Agosto Settembre Ottobre Novembre Dicembre);
@MonthAbbreviations = qw(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic);
@DayNames = qw(Lunedi Martedi Mercoledi Giovedi Venerdi Sabato Domenica);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;

require DateTime::Language::English;
@AMPM = @DateTime::Language::English::AMPM;

1;
