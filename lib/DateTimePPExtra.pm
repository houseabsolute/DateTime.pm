package DateTime;

use strict;

sub _normalize_seconds
{
    return if grep { $_ == INFINITY() || $_ == NEG_INFINITY() } @_[1,2];

    my $adj;

    if ($_[2] < 0)
    {
        $adj = int( ($_[2] - 86399) / 86400 );
    }
    else
    {
        $adj = int( $_[2] / 86400 );
    }

    ($_[1] += $adj), ($_[2] -= $adj*86400);
}


1;
