use strict;

use Test::More tests => 30;

use DateTime;

my %vals =
    ( year   => 50,
      month  => 3,
      day    => 15,
      hour   => 10,
      minute => 55,
      second => 17,
    );

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'minute' );
    foreach my $f ( qw( year month day hour minute ) )
    {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( second ) )
    {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'hour' );
    foreach my $f ( qw( year month day hour ) )
    {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( minute second ) )
    {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'day' );
    foreach my $f ( qw( year month day ) )
    {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'month' );
    foreach my $f ( qw( year month ) )
    {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( day ) )
    {
        is( $dt->$f(), 1, "$f should be 1" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}

{
    my $dt = DateTime->new(%vals);
    $dt->truncate( to => 'year' );
    foreach my $f ( qw( year ) )
    {
        is( $dt->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( month day ) )
    {
        is( $dt->$f(), 1, "$f should be 1" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $dt->$f(), 0, "$f should be 0" );
    }
}
