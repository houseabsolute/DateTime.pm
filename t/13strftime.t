# test suite stolen shamelessly from TimeDate distro

use strict;

use Test::More;
plan tests => 105;

use DateTime;

my $lang = 'English';
my $dt;
my $ical;
while (<DATA>)
{
    chomp;
    if (/^(\d+T\d+Z)/)
    {
        $ical = $1;
        $dt = DateTime->new( ical => $1, language => $lang );
        next;
    }
    elsif (/^(\w+)/)
    {
        $lang = $1;
        eval "use DateTime::Language::$1";
        die $@ if $@;

        $dt = DateTime->new( ical => $dt->ical, language => $lang );
        next;
    }

    my ($fmt, $res) = split /\t+/,$_;

    if ( $fmt =~ /z/i )
    {
        local $TODO = 'Needs TimeZone object to work';
        is( eval{ $dt->strftime($fmt) }, $res );
    }
    else
    {
        is( $dt->strftime($fmt), $res );
    }
}

# add these if we do roman-numeral stuff
# %Od	VII
# %Oe	VII
# %OH	XIII
# %OI	I
# %Oj	CCL
# %Ok	XIII
# %Ol	I
# %Om	IX
# %OM	II
# %Oq	III
# %OY	MCMXCIX
# %Oy	XCIX

__DATA__
19990907T130242Z # Tue Sep  7 11:22:42 1999 GMT
%y	99
%Y	1999
%%	%
%a	Tue
%A	Tuesday
%b	Sep
%B	September
%c	09/07/99 13:02:42
%C	19
%d	07
%e	 7
%D	09/07/99
%h	Sep
%H	13
%I	01
%j	250
%k	13
%l	 1
%m	09
%M	02
%p	PM
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
German
%y	99
%Y	1999
%%	%
%a	Die
%A	Dienstag
%b	Sep
%B	September
%c	09/07/99 13:02:42
%C	19
%d	07
%e	 7
%D	09/07/99
%h	Sep
%H	13
%I	01
%j	250
%k	13
%l	 1
%m	09
%M	02
%p	PM
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
Italian
%y	99
%Y	1999
%%	%
%a	Mar
%A	Martedi
%b	Set
%B	Settembre
%c	09/07/99 13:02:42
%C	19
%d	07
%e	 7
%D	09/07/99
%h	Set
%H	13
%I	01
%j	250
%k	13
%l	 1
%m	09
%M	02
%p	PM
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
