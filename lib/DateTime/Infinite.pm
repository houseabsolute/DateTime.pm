package DateTime::Infinite;

use strict;

use DateTime;
use DateTime::TimeZone;

use base qw(DateTime);

foreach my $m ( qw( set set_time_zone truncate ) )
{
    no strict 'refs';
    *{"DateTime::$m"} = sub { die "Infinite datetime objects are not mutable" };
}

sub is_infinite { 1 }

sub _rd2ymd
{
    return $_[2] ? ($_[1]) x 7 : ($_[1]) x 3;
}

sub _seconds_as_components
{
    return ($_[1]) x 3;
}

package DateTime::Infinite::Future;

use base qw(DateTime::Infinite);

{
    my $Pos = bless { utc_rd_days => DateTime::INFINITY,
                      utc_rd_secs => DateTime::INFINITY,
                      local_rd_days => DateTime::INFINITY,
                      local_rd_secs => DateTime::INFINITY,
                      rd_nanosecs => DateTime::INFINITY,
                      tz          => DateTime::TimeZone->new( name => 'floating' ),
                    }, __PACKAGE__;

    $Pos->_calc_utc_rd;
    $Pos->_calc_local_rd;

    sub new { $Pos }
}

package DateTime::Infinite::Past;

use base qw(DateTime::Infinite);

{
    my $Neg = bless { utc_rd_days => DateTime::NEG_INFINITY,
                      utc_rd_secs => DateTime::NEG_INFINITY,
                      local_rd_days => DateTime::NEG_INFINITY,
                      local_rd_secs => DateTime::NEG_INFINITY,
                      rd_nanosecs => DateTime::NEG_INFINITY,
                      tz          => DateTime::TimeZone->new( name => 'floating' ),
                    }, __PACKAGE__;

    $Neg->_calc_utc_rd;
    $Neg->_calc_local_rd;

    sub new { $Neg }
}


1;

__END__

=head1 NAME

DateTime::Infinite - Infinite past and future DateTime objects

=head1 SYNOPSIS

  my $future = DateTime::Infinite::Future->new;
  my $past   = DateTime::Infinite::Past->new;

=head1 DESCRIPTION

???

=head1 METHODS

???

=cut
