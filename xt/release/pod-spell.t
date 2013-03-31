use utf8;

use strict;
use warnings;

use Test::More;

eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for spell checking"
    if $@;

my @stopwords;
for (<DATA>) {
    chomp;
    push @stopwords, $_
        unless /\A (?: \# | \s* \z)/msx;    # skip comments, whitespace
}

add_stopwords(@stopwords);
set_spell_cmd('aspell list -l en');

# This prevents a weird segfault from the aspell command - see
# https://bugs.launchpad.net/ubuntu/+source/aspell/+bug/71322
local $ENV{LC_ALL} = 'en_US';
all_pod_files_spelling_ok();

__DATA__
Anno
BCE
CLDR
CPAN
DATETIME
DateTime
DateTimes
Datetime
Datetimes
Domini
EEEE
EEEEE
Flávio
Formatters
GGGG
GGGGG
Glock
IEEE
IEEE
LLL
LLLL
LLLLL
Liang's
MMM
MMMM
MMMMM
Measham's
POSIX
PayPal
QQQ
QQQQ
Rata
Rata
Rolsky
SU
Soibelmann
Storable
TZ
Tsai
UTC
VVVV
ZZZZ
afterwards
bian
ccc
cccc
ccccc
conformant
datetime
datetime's
datetimes
decrement
dian
durations
eee
eeee
eeeee
fallback
formatter
hh
iCal
ji
mutiplication
na
namespace
ni
nitty
other's
proleptic
qqq
qqqq
subclasses
uu
vvvv
wiki
yy
yyyy
yyyyy
zzzz
