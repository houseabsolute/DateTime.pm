use strict;

use Test::More;

use DateTime;
use DateTime::Language;

my @langs = DateTime::Language->languages();
my @codes = DateTime::Language->iso_codes();
push @codes, 'en-us', 'en-uk';

plan tests => scalar @langs + scalar @codes + 1;

foreach my $lang ( sort @langs, sort @codes )
{
    eval { DateTime->new( year => 1900,
                          language => $lang,
                          time_zone => 'UTC',
                        ) };
    ok( ! $@, "Load language: $lang\n" );
}

eval { DateTime->new( year => 1900, language => 'fo-ba' ) };
like( $@, qr/unsupported/i, "try loading invalid language via ISO code" );
