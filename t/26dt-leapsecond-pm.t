use strict;

use Test::More tests => 9;

use DateTime::LeapSecond;

is ( DateTime::LeapSecond::leap_seconds( 100 ), 9, 'before 1970'  );

# at the start of the table:

# 1971-12-31
my $day = 719892;
is ( DateTime::LeapSecond::leap_seconds( $day ), 9, 'before leap-second transition'  );

is ( DateTime::LeapSecond::extra_seconds( $day )+0, 1, 'leap day'  );

# 1972-01-01
$day = 719893;
is ( DateTime::LeapSecond::leap_seconds( $day ), 10, 'day after leap-second day'  );

is ( DateTime::LeapSecond::extra_seconds( $day ), 0, 'not a leap day'  );

# 1972-01-02
$day = 719894;
is ( DateTime::LeapSecond::leap_seconds( $day ), 10, 'after leap-second day'  );

# at the end of the table:
# 1998-12-31
$day = 729754;
is ( DateTime::LeapSecond::leap_seconds( $day ), 31, 'before leap-second day'  );

# 1999-01-01
$day = 729755;
is ( DateTime::LeapSecond::leap_seconds( $day ), 32, 'leap-second day'  );

# 1999-01-02
$day = 729756;
is ( DateTime::LeapSecond::leap_seconds( $day ), 32, 'after leap-second day'  );


# some leap second dates:
# 1972  Jan. 1
# 1972  Jul. 1
# 1973  Jan. 1
# ...
# 1997  Jul. 1
# 1999  Jan. 1
