##
## Afar tables
##

package DateTime::Language::Afar;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw(Acaada Etleeni Talaata Arbaqa Kamiisi Gumqata Sabti);
@MonthNames = ( "Qunxa Garablu",
                "Kudo",
                "Ciggilta Kudo",
                "Agda Baxis",
                "Caxah Alsa",
                "Qasa Dirri",
                "Qado Dirri",
                "Liiqen",
                "Waysu",
                "Diteli",
                "Ximoli",
                "Kaxxa Garablu"
              );

@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

@AMPM = qw(saaku carra);

1;
