use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;
use overload;

my $dt = DateTime->now;

like(
    exception { $dt->set_formatter('Invalid::Formatter') },
    qr/\QValidation failed for type named Maybe[Formatter]/,
    'set_format is validated'
);

SKIP:
{
    ## no critic (BuiltinFunctions::ProhibitStringyEval)
    skip 'This test requires DateTime::Format::Strptime 1.2000+', 1
        unless eval 'use DateTime::Format::Strptime 1.2000; 1;';

    my $formatter = DateTime::Format::Strptime->new(
        pattern => '%Y%m%d %T',
    );

    is(
        $dt->set_formatter($formatter),
        $dt,
        'set_formatter returns the datetime object'
    );
}

done_testing();
