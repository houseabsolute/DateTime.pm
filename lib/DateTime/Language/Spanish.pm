##
## Spanish tables, contributed by Flavio S. Glock (fglock@pucrs.br)
##

package DateTime::Language::Spanish;

use strict;

use DateTime::Language;
use vars qw(@ISA @DayNames @DayAbbreviations @MonthNames @MonthAbbreviations @AMPM);
@ISA = qw(DateTime::Language);

@DayNames = qw(Domingo Lunes Martes Miércoles Jueves Viernes Sábado);
@MonthNames = qw(Enero Febrero Marzo Abril Mayo Junio
	         Julio Agosto Septiembre Octubre Noviembre Diciembre);
@DayAbbreviations = map { substr($_,0,3) } @DayNames;
@MonthAbbreviations = qw(Ene Feb Mar Abr Mayo Jun
                         Jul Ago Set Oct Nov Dic);

require DateTime::Language::English;
@AMPM = @DateTime::Language::English::AMPM;

1;
