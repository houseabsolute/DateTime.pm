package DateTime::Language::English;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNumbers %DayNumbers $VERSION);
@ISA = qw(DateTime::Language);


@DayNames = qw(Monday Tuesday Wednesday Thursday Friday Saturday Sunday);
@MonthNames = qw(January February March April May June
	  July August September October November December);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;
@AMPM = qw(AM PM);

@OrdinalSuffixes = (qw(th st nd rd th th th th th th)) x 3;
@OrdinalSuffixes[11,12,13] = qw(th th th);
@OrdinalSuffixes[30,31] = qw(th st);

@MonthNumbers{@MonthNames}  = (1 .. scalar(@MonthNames));
@MonthNumbers{@MonthAbbreviations} = (1 .. scalar(@MonthAbbreviations));
@DayNumbers{@DayNames}  = (0 .. scalar(@DayNames));
@DayNumbers{@DayAbbreviations} = (0 .. scalar(@DayAbbreviations));

1;
