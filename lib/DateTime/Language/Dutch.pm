##
## Dutch tables
## Contributed by Johannes la Poutre <jlpoutre@corp.nl.home.com>
##

package DateTime::Language::Dutch;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM @OrdinalSuffixes %MonthNames %DayNames $VERSION);
@ISA = qw(DateTime::Language);


@MonthNames  = qw(januari februari maart april mei juni juli
           augustus september oktober november december);
@MonthAbbreviations = map(substr($_, 0, 3), @MonthNames);
@DayNames  = map($_ . "dag", qw(maan dins woens donder vrij zater zon));
@DayAbbreviations = map(substr($_, 0, 2), @DayNames);

# these aren't normally used...
@AMPM = qw(VM NM);
@OrdinalSuffixes = ('e') x 31;


@MonthNames{@MonthNames}  = (1 .. scalar(@MonthNames));
@MonthNames{@MonthAbbreviations} = (1 .. scalar(@MonthAbbreviations));
@DayNames{@DayNames}  = (0 .. scalar(@DayNames));
@DayNames{@DayAbbreviations} = (0 .. scalar(@DayAbbreviations));

1;
