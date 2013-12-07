use strict;
use warnings;

use Test::Fatal;
use Test::More;

use DateTime;
use overload;

my $dt = DateTime->now;

like(
    exception { $dt->set_formatter('Invalid::Formatter') },
    qr/can format_datetime/,
    'set_format is validated'
);

SKIP:
{
    skip 'This test requires DateTime::Format::Strptime 1.2000+', 1
        unless eval "use DateTime::Format::Strptime 1.2000";

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
