# test suite stolen shamelessly from TimeDate distro

use strict;

use Test::More tests => 103;

use DateTime;

my $lang = 'English';
my $dt;
my $params;
while (<DATA>)
{
    chomp;
    if (/^year =>/)
    {
        $params = $_;
        $dt = eval "DateTime->new( $params, time_zone => 'UTC' )";
        next;
    }
    elsif (/^(\w+)/)
    {
        $lang = $1;
        eval "use DateTime::Language::$1";
        die $@ if $@;

        $dt = eval "DateTime->new( $params, time_zone => 'UTC', language => '$lang' )";
        next;
    }

    my ($fmt, $res) = split /\t+/,$_;

    is( $dt->strftime($fmt), $res );
}

# test use of strftime with multiple params - in list and scalar
# context
{
    my $dt = DateTime->new( year => 1800,
                            month => 1,
                            day => 10,
                            time_zone => 'UTC',
                          );

    my ($y, $d) = $dt->strftime( '%Y', '%d' );
    is( $y, 1800 );
    is( $d, 10 );

    $y = $dt->strftime( '%Y', '%d' );
    is( $y, 1800 );
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
year => 1999, month => 9, day => 7, hour => 13, minute => 2, second => 42, nanosecond => 123456789.123456
%y	99
%Y	1999
%%	%
%a	Tue
%A	Tuesday
%b	Sep
%B	September
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
%N	123456789
%3N	123
%6N	123456
%10N	1234567891
%p	PM
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%y	99
%Y	1999
%Z	UTC
%z	+0000
German
%y	99
%Y	1999
%%	%
%a	Die
%A	Dienstag
%b	Sep
%B	September
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
%y	99
%Y	1999
%Z	UTC
%z	+0000
Italian
%y	99
%Y	1999
%%	%
%a	Mar
%A	Martedi
%b	Set
%B	Settembre
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
%y	99
%Y	1999
%Z	UTC
%z	+0000
