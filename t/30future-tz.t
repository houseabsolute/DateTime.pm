use strict;
use warnings;

use Test::More;

use DateTime;

#
# This test exercises a bug that occurred when date math did not
# always make sure to update the utc_year attribute of the given
# DateTime.  The sympton was that the time zone future span generation
# would fail because utc_year was less than the span's max_year, so
# span generation wouldn't actually do anything, and it would die with
# "Invalid local time".
#
{

    # Each iteration needs to use a different zone, because if it
    # works once, the generated spans are cached.
    for my $add (
        [ years   => 50, 1,               'America/New_York' ],
        [ days    => 50, 365,             'America/Chicago' ],
        [ minutes => 50, 365 * 1440,      'America/Denver', ],
        [ seconds => 50, 365 * 1440 * 60, 'America/Los_Angeles' ],
        [
            nanoseconds => 50, 365 * 1440 * 60 * 1_000_000_000,
            'America/North_Dakota/Center'
        ],

        [ years   => 750, 1,               'Europe/Paris' ],
        [ days    => 750, 365,             'Europe/London' ],
        [ minutes => 750, 365 * 1440,      'Europe/Brussels', ],
        [ seconds => 750, 365 * 1440 * 60, 'Europe/Vienna' ],
        [
            nanoseconds => 750, 365 * 1440 * 60 * 1_000_000_000,
            'Europe/Prague'
        ],
        ) {

        my $dt = DateTime->now( time_zone => $add->[3] );

        my $new
            = eval { $dt->clone->add( $add->[0], $add->[1] * $add->[2] ) };

        ok(
            !$@,
            "Make sure we can add $add->[1] years worth of $add->[0] in $add->[3] time zone"
        );
    }
}

done_testing();
