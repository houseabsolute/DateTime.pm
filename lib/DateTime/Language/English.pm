package DateTime::Language::English;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw(Monday Tuesday Wednesday Thursday Friday Saturday Sunday);
@MonthNames = qw(January February March April May June
                 July August September October November December);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;
@AMPM = qw(AM PM);

1;
