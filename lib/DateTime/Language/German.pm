##
## German tables
##

package DateTime::Language::German;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM $VERSION);
@ISA = qw(DateTime::Language);
$VERSION = "1.02";

@MonthNames  = qw(Januar Februar März April Mai Juni
	   Juli August September Oktober November Dezember);
@MonthAbbreviations = qw(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez);
@DayNames  = qw(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;

require DateTime::Language::English;
@AMPM = @{DateTime::Language::English::AMPM};

1;
