use strict;

use Test::More;
plan tests => 29;

use DateTime;

# Tests creating objects from GMT 

my $t1 = DateTime->new(epoch => '0');
ok ($t1->epoch() eq '0', 'creation test from epoch (compare to epoch)');
ok ($t1->ical() eq '19700101Z', 'creation test from epoch (compare to ical)');

ok ($t1->offset() eq '0', 'offset is 0 by default');

is ($t1->offset('+0100'), '+0100',
   'setting offset positive returns correct value');

is ($t1->ical, '19691231T230000Z', 'offset set correctly with positive value');


#-----------------------------------------------------------------------------
# some internals tests
is(DateTime::_offset_from_seconds(0), 0, 
    "_offset_from_seconds does the right thing on 0");
is(DateTime::_offset_from_seconds(3600), "+0100", 
    "_offset_from_seconds works on positive whole hours");
is(DateTime::_offset_from_seconds(-3600), "-0100", 
    "_offset_from_seconds works on negative whole hours");
is(DateTime::_offset_from_seconds(5400), "+0130", 
    "_offset_from_seconds works on positive half hours");
is(DateTime::_offset_from_seconds(-5400), "-0130", 
    "_offset_from_seconds works on negative half hours");

is(DateTime::_offset_from_seconds(20700), "+0545", 
    "_offset_from_seconds works on positive 15min zones");
is(DateTime::_offset_from_seconds(-20700), "-0545", 
    "_offset_from_seconds works on negative 15min zones");

is(DateTime::_offset_from_seconds(86400), "+0000", 
    "_offset_from_seconds rolls over properly on one full day of seconds");
is(DateTime::_offset_from_seconds(86400 + 3600), "+0100", 
    "_offset_from_seconds rolls over properly on one day + 1 hour of seconds");

# Need to write tests and code to handle bogus data gracefully. 
# For example, what if someone tells us they have an offset
# of 5 minutes and 30 seconds? Do we return 0005, 0006, or 0, and how
# loudly do we carp?

#-----------------------------------------------------------------------------
{
my $warn="";
local $SIG{__WARN__} = sub { $warn .= join('',@_); };

ok (!defined $t1->offset('hullaballo'), 'offset rejects bad args');
is ($t1->offset, '+0100', 'without changing the offset');
ok (scalar($warn =~ /^You gave an offset, hullaballo, that makes no sense/),
    'and with a warning');
}

is ($t1->offset('-0100'), '-0100',
    'setting offset negative returns correct value');

is($t1->ical, '19700101T010000Z', 'offset set correctly with negative value');

$t1->offset(0);
is($t1->ical, '19700101Z', 'offset can be reset to zero seconds');

# The offset should not get set here because of the Z
my $t2 = DateTime->new(ical => '20020405T120000Z', offset => '-0400');

is($t2->offset(), '0', 'UTC in ical ending with Z overrides offset');

# TODO: write tests here that test date/time output of an 
# offset-valued time

undef $t2;
my $loctime = '20020405T120000';
my $utctime = '20020405T200000Z';
$t2 = DateTime->new(ical => $loctime, offset => '-0800');
ok(defined($t2), 
    "new object with localtime ical and an offset returns a defined value");

is($t2->offset(), '-0800', "offset() returns negative offsets correctly");

ok($t2->ical() =~ /Z$/, "Default ical() output is in UTC");
is($t2->ical(), $utctime, 
    "Default ical() output in UTC is correct when an object is initialized with an offset");

is($t2->ical( localtime => 1 ), $loctime,
    "Localtime ical( localtime => 1 ) output is correct");

is($t2->ical(), $utctime,    
    "Default ical() output in UTC is correct after localtime access made");           

undef $t2;
$t2 = DateTime->new(ical => '20020405T120000', offset => '+0800');
is($t2->offset(), '+0800', "offset() returns positive offsets correctly");
# TODO: test ical output on that object

undef $t2;
$t2 = DateTime->new(ical => '20020405T120000', offset => '+0545');
is($t2->offset(), '+0545', "offset() returns fractional-hour offsets correctly");
# TODO: test ical output from this object

# TODO: test the offset method's ways of being called: make sure it can
# tell the difference between being called like offset("+0100") and
# offset("3700").  
