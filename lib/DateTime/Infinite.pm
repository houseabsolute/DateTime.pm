package DateTime::Infinite;

use strict;

use DateTime;
use DateTime::TimeZone;

my $infinity = 100 ** 100 ** 100;

package DateTime::Infinite::Positive;

{
    my $Pos = bless { utc_rd_days => $infinity,
                      utc_rd_secs => $infinity,
                      local_rd_days => $infinity,
                      local_rd_secs => $infinity,
                      rd_nanosecs => $infinity,
                      tz          => DateTime::TimeZone->new( name => 'UTC' ),
                    }, 'DateTime';

    sub new { $Pos }
}

package DateTime::Infinite::Negative;

{
    my $Neg = bless { utc_rd_days => -1 * $infinity,
                      utc_rd_secs => -1 * $infinity,
                      local_rd_days => -1 * $infinity,
                      local_rd_secs => -1 * $infinity,
                      rd_nanosecs => -1 * $infinity,
                      tz          => DateTime::TimeZone->new( name => 'UTC' ),
                    }, 'DateTime';

    sub new { $Neg }
}


1;

__END__
