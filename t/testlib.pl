use strict;

sub fake_ical
{
    my $dt = shift;

    my $ical = $dt->ymd('');

    if ( $dt->hour || $dt->minute || $dt->second )
    {
        $ical .= 'T' . $dt->hms('');
    }

    $ical .= 'Z';

    return $ical;
}

1;
