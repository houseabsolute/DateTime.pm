##
## Brazilian tables, contributed by Christian Tosta (tosta@cce.ufmg.br)
##

package DateTime::Language::Portuguese;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw(Domingo Segunda Terça Quarta Quinta Sexta Sábado);
@MonthNames = qw(Janeiro Fevereiro Março Abril Maio Junho
	         Julho Agosto Setembro Outubro Novembro Dezembro);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = map { substr($_,0,3) } @MonthNames;

# 'Maio' has no abbreviation   (fglock)
$MonthAbbreviations[4] = $MonthNames[4];

require DateTime::Language::English;
@AMPM = @DateTime::Language::English::AMPM;

1;
