##
## Danish tables
##

package DateTime::Language::Danish;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@MonthNames = qw(Januar Februar Marts April Maj Juni
                 Juli August September Oktober November December);
@DayNames = qw(Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

require DateTime::Language::English;
@AMPM = @DateTime::Language::English::AMPM;

1;

