##
## Austrian tables
##

package DateTime::Language::Austrian;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@MonthNames = qw(Jänner Feber März April Mai Juni
                 Juli August September Oktober November Dezember);
@MonthAbbreviations = qw(Jän Feb Mär Apr Mai Jun Jul Aug Sep Oct Nov Dez);
@DayNames = qw(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;

require DateTime::Language::English;
@AMPM = @DateTime::Language::English::AMPM;

1;
