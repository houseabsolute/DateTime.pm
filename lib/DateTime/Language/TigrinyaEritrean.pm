##
## Tigrinya-Eritrean tables
##

package DateTime::Language::TigrinyaEritrean;

use strict;

# use DateTime::Language;
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

    @MonthNames = ( "\x{1325}\x{122a}",
                    "\x{1208}\x{12ab}\x{1272}\x{1275}",
                    "\x{1218}\x{130b}\x{1262}\x{1275}",
                    "\x{121a}\x{12eb}\x{12dd}\x{12eb}",
                    "\x{130d}\x{1295}\x{1266}\x{1275}",
                    "\x{1230}\x{1290}",
                    "\x{1213}\x{121d}\x{1208}",
                    "\x{1290}\x{1213}\x{1230}",
                    "\x{1218}\x{1235}\x{12a8}\x{1228}\x{121d}",
                    "\x{1325}\x{1245}\x{121d}\x{1272}",
                    "\x{1215}\x{12f3}\x{122d}",
                    "\x{1273}\x{1215}\x{1233}\x{1235}"
                  );

    @DayAbbreviations = map { substr($_,0,3) } @DayNames;
    @MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

    @AMPM = ( "\x{1295}/\x{1230}",
              "\x{12F5}/\x{1230}"
            );
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

    @MonthNames = ( "ጥሪ",
                    "ለካቲት",
                    "መጋቢት",
                    "ሚያዝያ",
                    "ግንቦት",
                    "ሰነ",
                    "ሓምለ",
                    "ነሓሰ",
                    "መስከረም",
                    "ጥቅምቲ",
                    "ሕዳር",
                    "ታሕሳስ"
                  );

    @DayAbbreviations = map { substr($_,0,9) } @DayNames;
    @MonthAbbreviations = map { substr($_,0,9) } @MonthNames;

    @AMPM = ( "ን/ሰ",
              "ድ/ሰ"
            );
}

1;
