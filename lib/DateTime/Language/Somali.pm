##
## Somali tables
##


package DateTime::Language::Somali;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM $VERSION);
@ISA = qw(DateTime::Language);
$VERSION = "0.10";

@DayNames = qw(Axad Isniin Salaaso Arbaco Khamiis Jimco Sabti);
@MonthNames = (
"Bisha Koobaad",
"Bisha Labaad",
"Bisha Saddexaad",
"Bisha Afraad",
"Bisha Shanaad",
"Bisha Lixaad",
"Bisha Todobaad",
"Bisha Sideedaad",
"Bisha Sagaalaad",
"Bisha Tobnaad",
"Bisha Kow iyo Tobnaad",
"Bisha Laba iyo Tobnaad"
);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = (
"Kob",
"Lab",
"Sad",
"Afr",
"Sha",
"Lix",
"Tod",
"Sid",
"Sag",
"Tob",
"KIT",
"LIT"
);
@AMPM = qw(SN GN);


1;
