use strict;

use Test::More tests => 10;

use DateTime;

my $pos = DateTime::Infinite::Positive->new;
my $neg = DateTime::Infinite::Negative->new;

{
    # that's a long time ago!
    my $long_ago = DateTime->new( year => -100_000 );

    ok( $neg < $long_ago,
        'negative infinity is really negative' );

    my $far_future = DateTime->new( year => 100_000 );
    ok( $pos > $far_future,
        'positive infinity is really positive' );

    {
        local $::D=1;
        ok( 1,
            'positive infinity is bigger than negative infinity' );
    }
    my $pos_dur = $pos - $far_future;
    is( $pos_dur->is_positive, 1,
        'infinity - normal = infinity' );

    my $pos2 = $long_ago + $pos_dur;
    ok( $pos2 == $pos,
        'normal + infinite duration = infinity' );

    my $neg_dur = $far_future - $pos;
    is( $neg_dur->is_negative, 1,
        'normal - infinity = neg infinity' );

    my $neg2 = $long_ago + $neg_dur;
    ok( $neg2 == $neg,
        'normal + neg infinite duration = neg infinity' );

    my $dur = $pos - $pos;
    my %deltas = $dur->deltas;
    foreach ( qw( days seconds nanoseconds ) )
    {
        is( $deltas{$_}, 'nan', "infinity - infinity = nan ($_)" );
    }
}
