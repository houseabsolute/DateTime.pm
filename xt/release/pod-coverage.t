
use strict;
use warnings;

use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

my @modules = grep { !/PP/ && !/Helpers/ } all_modules();
plan tests => scalar @modules;

my %trustme = (
    'DateTime' => {
        trustme => [
            qr/0$/, qr/^STORABLE/, 'utc_year',
            'timegm',
            qw(
                day_of_month
                doq
                dow
                doy
                iso8601
                local_rd_as_seconds
                mday
                min
                mon
                sec
                wday
                ),
            # deprecated methods
            'DefaultLanguage', 'era', 'language',
        ]
    },
    'DateTime::Infinite' => {
        trustme => [
            qr/^STORABLE/, qr/^set/, qr/^is_(?:in)?finite/,
            'truncate'
        ]
    },
);

for my $mod ( sort @modules ) {
    pod_coverage_ok( $mod, $trustme{$mod} || {}, $mod );
}
