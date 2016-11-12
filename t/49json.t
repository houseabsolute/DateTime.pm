use strict;
use warnings;

use DateTime;

is(
    DateTime->new( year => 2016, time_zone => 'floating' )->TO_JSON,
    '2016-01-01T00:00:00',
    'TO_JSON for floating time zone'
);

is(
    DateTime->new( year => 2016, time_zone => 'UTC' )->TO_JSON,
    '2016-01-01T00:00:00Z',
    'TO_JSON for UTC time zone'
);

is(
    DateTime->new( year => 2016, time_zone => 'America/Chicago' )->TO_JSON,
    '2016-01-01T00:00:00-0500',
    'TO_JSON for UTC time zone'
);

done_testing();
