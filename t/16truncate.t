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

my $dt = DateTime->new(%vals);

{
    my $c = $dt->clone;
    $c->truncate( to => 'second' );
    foreach my $f ( qw( year month day hour minute ) )
    {
        is( $c->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( second ) )
    {
        is( $c->$f(), 0, "$f should be 0" );
    }
}

{
    my $c = $dt->clone;
    $c->truncate( to => 'minute' );
    foreach my $f ( qw( year month day hour ) )
    {
        is( $c->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( minute second ) )
    {
        is( $c->$f(), 0, "$f should be 0" );
    }
}

{
    my $c = $dt->clone;
    $c->truncate( to => 'hour' );
    foreach my $f ( qw( year month day ) )
    {
        is( $c->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $c->$f(), 0, "$f should be 0" );
    }
}

{
    my $c = $dt->clone;
    $c->truncate( to => 'day' );
    foreach my $f ( qw( year month ) )
    {
        is( $c->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( day ) )
    {
        is( $c->$f(), 1, "$f should be 1" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $c->$f(), 0, "$f should be 0" );
    }
}

{
    my $c = $dt->clone;
    $c->truncate( to => 'month' );
    foreach my $f ( qw( year ) )
    {
        is( $c->$f(), $vals{$f}, "$f should be $vals{$f}" );
    }

    foreach my $f ( qw( month day ) )
    {
        is( $c->$f(), 1, "$f should be 1" );
    }

    foreach my $f ( qw( hour minute second ) )
    {
        is( $c->$f(), 0, "$f should be 0" );
    }
}
