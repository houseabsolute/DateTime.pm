##
## Sidama tables
##

package DateTime::Language::Sidama;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw(Sambata Sanyo Maakisanyo Roowe Hamuse Arbe Qidaame);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@AMPM = qw(soodo hawwaro);

require DateTime::Language::English;
@MonthNames = @DateTime::Language::English::MonthNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

1;

