##
## Tigrinya-Ethiopian tables
##

package DateTime::Language::TigrinyaEthiopian;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

if ( $] >= 5.006 )
{
    @DayNames = ( "\x{1230}\x{1295}\x{1260}\x{1275}",
                  "\x{1230}\x{1291}\x{12ed}",
                  "\x{1230}\x{1209}\x{1235}",
                  "\x{1228}\x{1261}\x{12d5}",
                  "\x{1213}\x{1219}\x{1235}",
                  "\x{12d3}\x{122d}\x{1262}",
                  "\x{1240}\x{12f3}\x{121d}"
                );

    @MonthNames = ( "\x{1303}\x{1295}\x{12e9}\x{12c8}\x{122a}",
                    "\x{134c}\x{1265}\x{1229}\x{12c8}\x{122a}",
                    "\x{121b}\x{122d}\x{127d}",
                    "\x{12a4}\x{1355}\x{1228}\x{120d}",
                    "\x{121c}\x{12ed}",
                    "\x{1301}\x{1295}",
                    "\x{1301}\x{120b}\x{12ed}",
                    "\x{12a6}\x{1308}\x{1235}\x{1275}",
                    "\x{1234}\x{1355}\x{1274}\x{121d}\x{1260}\x{122d}",
                    "\x{12a6}\x{12ad}\x{1270}\x{12cd}\x{1260}\x{122d}",
                    "\x{1296}\x{126c}\x{121d}\x{1260}\x{122d}",
                    "\x{12f2}\x{1234}\x{121d}\x{1260}\x{122d}"
                  );

    @DayAbbreviations = map { substr($_,0,3) } @DayNames;
    @MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

    @AMPM = ( "\x{1295}/\x{1230}", "\x{12F5}/\x{1230}" );
}
else
{
    @DayNames = ( "ሰንበት",
                  "ሰኑይ",
                  "ሰሉስ",
                  "ረቡዕ",
                  "ሓሙስ",
                  "ዓርቢ",
                  "ቀዳም"
                );

    @MonthNames = ( "ጃንዩወሪ",
                    "ፌብሩወሪ",
                    "ማርች",
                    "ኤፕረል",
                    "ሜይ",
                    "ጁን",
                    "ጁላይ",
                    "ኦገስት",
                    "ሴፕቴምበር",
                    "ኦክተውበር",
                    "ኖቬምበር",
                    "ዲሴምበር"
                  );

    @DayAbbreviations = map { substr($_,0,9) } @DayNames;
    @MonthAbbreviations = map { substr($_,0,9) } @MonthNames;

    @AMPM = ( "ን/ሰ",
              "ድ/ሰ"
            );
}

1;
