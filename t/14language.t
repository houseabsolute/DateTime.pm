#!/usr/bin/perl -w

use strict;

use Test::More;

use DateTime;
use DateTime::Language;

my @langs = DateTime::Language->languages();
my @codes = DateTime::Language->iso_codes();
push @codes, 'en-us', 'en-uk';

plan tests => 4 + scalar @codes + ( scalar @langs * 2 );

foreach my $lang ( sort @langs, sort @codes )
{
    my $dt;
    eval { $dt = DateTime->new( year => 1900,
                                language => $lang,
                                time_zone => 'UTC',
                              ) };
    ok( ! $@, "Load language: $lang\n" );

    if ( $lang =~ /^[A-Z]/ )
    {
        is( $dt->language->name, $lang, "language name is $lang" );
    }
}

eval { DateTime->new( year => 1900, language => 'fo-ba' ) };
like( $@, qr/unsupported/i, "try loading invalid language via ISO code" );

{
    package Some::Language;
    use base 'DateTime::Language';

}

my $lang = eval { Some::Language->new };
ok( ! $@, 'Some::Language->new works' );
isa_ok( $lang, 'Some::Language', '$lang isa Some::Language' );
isa_ok( $lang, 'DateTime::Language', '$lang isa DateTime::Language' );
