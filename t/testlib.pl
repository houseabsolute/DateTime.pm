use strict;

sub fake_ical
{
    my $dt = shift;

    my $ical = sprintf( '%04d%02d%02d', $dt->year, $dt->month, $dt->day);

    if ( $dt->hour || $dt->minute || $dt->second )
    {
        $ical .=
            sprintf ( 'T%02d%02d%02d',
                      $dt->hour, $dt->minute, $dt->second );
    }

    $ical .= 'Z';

    return $ical;
}

1;
