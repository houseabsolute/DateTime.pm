##
## Gedeo tables
##

package DateTime::Language::Gedeo;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw( Sanbbattaa Sanno Masano Roobe Hamusse Arbe Qiddamme);
@MonthNames = ( "Oritto",
                "Birre'a",
                "Onkkollessa",
                "Saddasa",
                "Arrasa",
                "Qammo",
                "Ella",
                "Waacibajje",
                "Canissa",
                "Addolessa",
                "Bittitotessa",
                "Hegeya"
              );

@DayAbbreviations = map { substr($_,0,3) } @DayNames;
$DayAbbreviations[0] = "Snb";
$DayAbbreviations[1] = "Sno";
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

@AMPM = qw(gorsa warreti-udumma);

1;
