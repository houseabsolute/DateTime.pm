##
## Oromo tables
##

package DateTime::Language::Oromo;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames   = qw(Dilbata Wiixata Qibxata Roobii Kamiisa Jimaata Sanbata);
@MonthNames = qw(Amajjii Guraandhala Bitooteessa Elba Caamsa Waxabajjii
                 Adooleessa Hagayya Fuulbana Onkololeessa Sadaasa Muddee);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;
@AMPM = qw(WD WB);


1;
