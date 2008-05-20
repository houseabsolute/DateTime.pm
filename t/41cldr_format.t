use strict;
use warnings;
use utf8;

use Test::More tests => 90;

use DateTime;


if ( $] >= 5.008 )
{
    for my $fh ( Test::Builder->new()->output(),
                 Test::Builder->new()->failure_output(),
                 Test::Builder->new()->todo_output(),
               )
    {
        binmode $fh, ':utf8';
    }
}

{
    my $dt = DateTime->new( year       => 1976,
                            month      => 10,
                            day        => 20,
                            hour       => 18,
                            minute     => 34,
                            second     => 55,
                            nanosecond => 1_000_000,
                            locale     => 'en',
                            time_zone  => 'America/Chicago',
                          );

    my %tests = ( 'GGGGG'  => 'AD',
                  'GGGG'   => 'Anno Domini',
                  'GGG'    => 'AD',
                  'GG'     => 'AD',
                  'G'      => 'AD',

                  'yyyyy'  => '01976',
                  'yyyy'   => '1976',
                  'yyy'    => '1976',
                  'yy'     => '76',
                  'y'      => '1976',

                  'uuuuuu' => '001976',
                  'uuuuu'  => '01976',
                  'uuuu'   => '1976',
                  'uuu'    => '1976',
                  'uu'     => '1976',
                  'u'      => '1976',

                  'YYYYY'  => '01976',
                  'YYYY'   => '1976',
                  'YYY'    => '1976',
                  'YY'     => '1976',
                  'Y'      => '1976',

                  'QQQQ'   => '4th quarter',
                  'QQQ'    => 'Q4',
                  'QQ'     => '04',
                  'Q'      => '4',

                  'MMMMM'  => 'O',
                  'MMMM'   => 'October',
                  'MMM'    => 'Oct',
                  'MM'     => '10',
                  'M'      => '10',

                  'LLLLL'  => 'O',
                  'LLLL'   => 'October',
                  'LLL'    => 'Oct',
                  'LL'     => '10',
                  'L'      => '10',

                  'ww'     => '43',
                  'w'      => '43',
                  'W'      => '3',

                  'dd'     => '20',
                  'd'      => '20',

                  'DDD'    => '294',
                  'DD'     => '294',
                  'D'      => '294',

                  'F'      => '3',
                  'gggggg' => '043071',
                  'g'      => '43071',

                  'EEEEE'  => 'W',
                  'EEEE'   => 'Wednesday',
                  'EEE'    => 'Wed',
                  'EE'     => 'Wed',
                  'E'      => 'Wed',

                  'eeeee'  => 'W',
                  'eeee'   => 'Wednesday',
                  'eee'    => 'Wed',
                  'ee'     => '03',
                  'e'      => '3',

                  'ccccc'  => 'W',
                  'cccc'   => 'Wednesday',
                  'ccc'    => 'Wed',
                  'cc'     => '03',
                  'c'      => '3',

                  'a'      => 'PM',

                  'hh'     => '06',
                  'h'      => '6',
                  'HH'     => '18',
                  'H'      => '18',
                  'KK'     => '06',
                  'K'      => '6',
                  'kk'     => '18',
                  'kk'     => '18',
                  'jj'     => '18',
                  'j'      => '18',

                  'mm'     => '34',
                  'm'      => '34',

                  'ss'     => '55',
                  's'      => '55',
                  'SS'     => '00',
                  'SSSSSS' => '001000',
                  'A'      => '66895001',

                  'zzzz'   => 'America/Chicago',
                  'zzz'    => 'CDT',
                  'ZZZZ'   => 'CDT-0500',
                  'ZZZ'    => '-0500',
                  'vvvv'   => 'America/Chicago',
                  'vvv'    => 'CDT',
                  'VVVV'   => 'America/Chicago',
                  'VVV'    => 'CDT',

                  q{'one fine day'} => 'one fine day',
                  q{'yy''yy' yyyy}  => q{yy'yy 1976},

                  q{'yy''yy' 'hello' yyyy}  => q{yy'yy hello 1976},

                  # Non-pattern text should pass through unchanged
                  'd日' => '20日',
                );

    for my $k ( sort keys %tests )
    {
        is( $dt->format_cldr($k), $tests{$k},
            "format_cldr for $k" );
    }
}
