# NAME

DateTime - A date and time object for Perl

# VERSION

version 1.50

# SYNOPSIS

    use DateTime;

    $dt = DateTime->new(
        year       => 1964,
        month      => 10,
        day        => 16,
        hour       => 16,
        minute     => 12,
        second     => 47,
        nanosecond => 500000000,
        time_zone  => 'Asia/Taipei',
    );

    $dt = DateTime->from_epoch( epoch => $epoch );
    $dt = DateTime->now; # same as ( epoch => time() )

    $year   = $dt->year;
    $month  = $dt->month;          # 1-12

    $day    = $dt->day;            # 1-31

    $dow    = $dt->day_of_week;    # 1-7 (Monday is 1)

    $hour   = $dt->hour;           # 0-23
    $minute = $dt->minute;         # 0-59

    $second = $dt->second;         # 0-61 (leap seconds!)

    $doy    = $dt->day_of_year;    # 1-366 (leap years)

    $doq    = $dt->day_of_quarter; # 1..

    $qtr    = $dt->quarter;        # 1-4

    # all of the start-at-1 methods above have corresponding start-at-0
    # methods, such as $dt->day_of_month_0, $dt->month_0 and so on

    $ymd    = $dt->ymd;           # 2002-12-06
    $ymd    = $dt->ymd('/');      # 2002/12/06

    $mdy    = $dt->mdy;           # 12-06-2002
    $mdy    = $dt->mdy('/');      # 12/06/2002

    $dmy    = $dt->dmy;           # 06-12-2002
    $dmy    = $dt->dmy('/');      # 06/12/2002

    $hms    = $dt->hms;           # 14:02:29
    $hms    = $dt->hms('!');      # 14!02!29

    $is_leap  = $dt->is_leap_year;

    # these are localizable, see Locales section
    $month_name  = $dt->month_name; # January, February, ...
    $month_abbr  = $dt->month_abbr; # Jan, Feb, ...
    $day_name    = $dt->day_name;   # Monday, Tuesday, ...
    $day_abbr    = $dt->day_abbr;   # Mon, Tue, ...

    # May not work for all possible datetime, see the docs on this
    # method for more details.
    $epoch_time  = $dt->epoch;

    $dt2 = $dt + $duration_object;

    $dt3 = $dt - $duration_object;

    $duration_object = $dt - $dt2;

    $dt->set( year => 1882 );

    $dt->set_time_zone( 'America/Chicago' );

    $dt->set_formatter( $formatter );

# DESCRIPTION

DateTime is a class for the representation of date/time combinations,
and is part of the Perl DateTime project. For details on this project
please see [http://datetime.perl.org/](http://datetime.perl.org/). The DateTime site has a FAQ
which may help answer many "how do I do X?" questions. The FAQ is at
[http://datetime.perl.org/wiki/datetime/page/FAQ](http://datetime.perl.org/wiki/datetime/page/FAQ).

It represents the Gregorian calendar, extended backwards in time
before its creation (in 1582). This is sometimes known as the
"proleptic Gregorian calendar". In this calendar, the first day of
the calendar (the epoch), is the first day of year 1, which
corresponds to the date which was (incorrectly) believed to be the
birth of Jesus Christ.

The calendar represented does have a year 0, and in that way differs
from how dates are often written using "BCE/CE" or "BC/AD".

For infinite datetimes, please see the
[DateTime::Infinite](https://metacpan.org/pod/DateTime::Infinite) module.

# USAGE

## 0-based Versus 1-based Numbers

The DateTime.pm module follows a simple logic for determining whether or not a
given number is 0-based or 1-based.

Month, day of month, day of week, and day of year are 1-based. Any
method that is 1-based also has an equivalent 0-based method ending in
"\_0". So for example, this class provides both `day_of_week()` and
`day_of_week_0()` methods.

The `day_of_week_0()` method still treats Monday as the first day of
the week.

All _time_-related numbers such as hour, minute, and second are
0-based.

Years are neither, as they can be both positive or negative, unlike
any other datetime component. There _is_ a year 0.

There is no `quarter_0()` method.

## Error Handling

Some errors may cause this module to die with an error string. This
can only happen when calling constructor methods, methods that change
the object, such as `set()`, or methods that take parameters.
Methods that retrieve information about the object, such as `year()`
or `epoch()`, will never die.

## Locales

All the object methods which return names or abbreviations return data based
on a locale. This is done by setting the locale when constructing a DateTime
object. If this is not set, then "en-US" is used.

## Floating DateTimes

The default time zone for new DateTime objects, except where stated
otherwise, is the "floating" time zone. This concept comes from the
iCal standard. A floating datetime is one which is not anchored to
any particular time zone. In addition, floating datetimes do not
include leap seconds, since we cannot apply them without knowing the
datetime's time zone.

The results of date math and comparison between a floating datetime
and one with a real time zone are not really valid, because one
includes leap seconds and the other does not. Similarly, the results
of datetime math between two floating datetimes and two datetimes with
time zones are not really comparable.

If you are planning to use any objects with a real time zone, it is
strongly recommended that you **do not** mix these with floating
datetimes.

## Math

If you are going to be doing date math, please read the section ["How DateTime
Math Works"](#how-datetime-math-works).

## Determining the Local Time Zone Can Be Slow

If `$ENV{TZ}` is not set, it may involve reading a number of files in `/etc`
or elsewhere. If you know that the local time zone won't change while your
code is running, and you need to make many objects for the local time zone, it
is strongly recommended that you retrieve the local time zone once and cache
it:

    our $App::LocalTZ = DateTime::TimeZone->new( name => 'local' );

    ... # then everywhere else

    my $dt = DateTime->new( ..., time_zone => $App::LocalTZ );

DateTime itself does not do this internally because local time zones can
change, and there's no good way to determine if it's changed without doing all
the work to look it up.

Do not try to use named time zones (like "America/Chicago") with dates
very far in the future (thousands of years). The current
implementation of `DateTime::TimeZone` will use a huge amount of
memory calculating all the DST changes from now until the future
date. Use UTC or the floating time zone and you will be safe.

## Globally Setting a Default Time Zone

**Warning: This is very dangerous. Do this at your own risk!**

By default, `DateTime` uses either the floating time zone or UTC for newly
created objects, depending on the constructor.

You can force `DateTime` to use a different time zone by setting the
`PERL_DATETIME_DEFAULT_TZ` environment variable.

As noted above, this is very dangerous, as it affects all code that creates a
`DateTime` object, including modules from CPAN. If those modules expect the
normal default, then setting this can cause confusing breakage or subtly
broken data. Before setting this variable, you are strongly encouraged to
audit your CPAN dependencies to see how they use `DateTime`. Try running the
test suite for each dependency with this environment variable set before using
this in production.

## Upper and Lower Bounds

Internally, dates are represented the number of days before or after
0001-01-01. This is stored as an integer, meaning that the upper and lower
bounds are based on your Perl's integer size (`$Config{ivsize}`).

The limit on 32-bit systems is around 2^29 days, which gets you to year
(+/-)1,469,903. On a 64-bit system you get 2^62 days,
(+/-)12,626,367,463,883,278 (12.626 quadrillion).

# METHODS

DateTime provide many methods. The documentation breaks them down into groups
based on what they do (constructor, accessors, modifiers, etc.).

## Constructors

All constructors can die when invalid parameters are given.

### Warnings

Currently, constructors will warn if you try to create a far future DateTime
(year >= 5000) with any time zone besides floating or UTC. This can be very
slow if the time zone has future DST transitions that need to be
calculated. If the date is sufficiently far in the future this can be
_really_ slow (minutes).

All warnings from DateTime use the `DateTime` category and can be suppressed
with:

    no warnings 'DateTime';

This warning may be removed in the future if [DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone) is made
much faster.

### DateTime->new( ... )

This class method accepts parameters for each date and time component:
"year", "month", "day", "hour", "minute", "second", "nanosecond".
It also accepts "locale", "time\_zone", and "formatter" parameters.

    my $dt = DateTime->new(
        year       => 1966,
        month      => 10,
        day        => 25,
        hour       => 7,
        minute     => 15,
        second     => 47,
        nanosecond => 500000000,
        time_zone  => 'America/Chicago',
    );

DateTime validates the "month", "day", "hour", "minute", and "second",
and "nanosecond" parameters. The valid values for these parameters are:

- month

    An integer from 1-12.

- day

    An integer from 1-31, and it must be within the valid range of days for the
    specified month.

- hour

    An integer from 0-23.

- minute

    An integer from 0-59.

- second

    An integer from 0-61 (to allow for leap seconds). Values of 60 or 61 are only
    allowed when they match actual leap seconds.

- nanosecond

    An integer >= 0. If this number is greater than 1 billion, it will be
    normalized into the second value for the DateTime object.

Invalid parameter types (like an array reference) will cause the
constructor to die.

The value for seconds may be from 0 to 61, to account for leap
seconds. If you give a value greater than 59, DateTime does check to
see that it really matches a valid leap second.

All of the parameters are optional except for "year". The "month" and
"day" parameters both default to 1, while the "hour", "minute",
"second", and "nanosecond" parameters all default to 0.

The "locale" parameter should be a string containing a locale code, like
"en-US" or "zh-Hant-TW", or an object returned by `DateTime::Locale->load`. See the [DateTime::Locale](https://metacpan.org/pod/DateTime::Locale) documentation for details.

The "time\_zone" parameter can be either a string or a `DateTime::TimeZone`
object. A string will simply be passed to the `DateTime::TimeZone->new`
method as its "name" parameter. This string may be an Olson DB time zone name
("America/Chicago"), an offset string ("+0630"), or the words "floating" or
"local". See the `DateTime::TimeZone` documentation for more details.

The default time zone is "floating".

The "formatter" can be either a scalar or an object, but the class
specified by the scalar or the object must implement a
`format_datetime()` method.

#### Parsing Dates

**This module does not parse dates!** That means there is no
constructor to which you can pass things like "March 3, 1970 12:34".

Instead, take a look at the various `DateTime::Format::*` modules on
CPAN. These parse all sorts of different date formats, and you're
bound to find something that can handle your particular needs.

#### Ambiguous Local Times

Because of Daylight Saving Time, it is possible to specify a local
time that is ambiguous. For example, in the US in 2003, the
transition from to saving to standard time occurred on October 26, at
02:00:00 local time. The local clock changed from 01:59:59 (saving
time) to 01:00:00 (standard time). This means that the hour from
01:00:00 through 01:59:59 actually occurs twice, though the UTC time
continues to move forward.

If you specify an ambiguous time, then the latest UTC time is always
used, in effect always choosing standard time. In this case, you can
simply subtract an hour to the object in order to move to saving time,
for example:

    # This object represent 01:30:00 standard time
    my $dt = DateTime->new(
        year      => 2003,
        month     => 10,
        day       => 26,
        hour      => 1,
        minute    => 30,
        second    => 0,
        time_zone => 'America/Chicago',
    );

    print $dt->hms;  # prints 01:30:00

    # Now the object represent 01:30:00 saving time
    $dt->subtract( hours => 1 );

    print $dt->hms;  # still prints 01:30:00

Alternately, you could create the object with the UTC time zone, and
then call the `set_time_zone()` method to change the time zone. This
is a good way to ensure that the time is not ambiguous.

#### Invalid Local Times

Another problem introduced by Daylight Saving Time is that certain
local times just do not exist. For example, in the US in 2003, the
transition from standard to saving time occurred on April 6, at the
change to 2:00:00 local time. The local clock changes from 01:59:59
(standard time) to 03:00:00 (saving time). This means that there is
no 02:00:00 through 02:59:59 on April 6!

Attempting to create an invalid time currently causes a fatal error.
This may change in future version of this module.

### DateTime->from\_epoch( epoch => $epoch, ... )

This class method can be used to construct a new DateTime object from
an epoch time instead of components. Just as with the `new()`
method, it accepts "time\_zone", "locale", and "formatter" parameters.

If the epoch value is a floating-point value, it will be rounded to
nearest microsecond.

By default, the returned object will be in the UTC time zone.

### DateTime->now( ... )

This class method is equivalent to calling `from_epoch()` with the
value returned from Perl's `time()` function. Just as with the
`new()` method, it accepts "time\_zone" and "locale" parameters.

By default, the returned object will be in the UTC time zone.

### DateTime->today( ... )

This class method is equivalent to:

    DateTime->now(@_)->truncate( to => 'day' );

### DateTime->from\_object( object => $object, ... )

This class method can be used to construct a new DateTime object from
any object that implements the `utc_rd_values()` method. All
`DateTime::Calendar` modules must implement this method in order to
provide cross-calendar compatibility. This method accepts a
"locale" and "formatter" parameter

If the object passed to this method has a `time_zone()` method, that
is used to set the time zone of the newly created `DateTime.pm`
object.

Otherwise, the returned object will be in the floating time zone.

### DateTime->last\_day\_of\_month( ... )

This constructor takes the same arguments as can be given to the
`new()` method, except for "day". Additionally, both "year" and
"month" are required.

### DateTime->from\_day\_of\_year( ... )

This constructor takes the same arguments as can be given to the
`new()` method, except that it does not accept a "month" or "day"
argument. Instead, it requires both "year" and "day\_of\_year". The
day of year must be between 1 and 366, and 366 is only allowed for
leap years.

### $dt->clone()

This object method returns a new object that is replica of the object
upon which the method is called.

## "Get" Methods

This class has many methods for retrieving information about an
object.

### $dt->year()

Returns the year.

### $dt->ce\_year()

Returns the year according to the BCE/CE numbering system. The year
before year 1 in this system is year -1, aka "1 BCE".

### $dt->era\_name()

Returns the long name of the current era, something like "Before
Christ". See the [Locales](#locales) section for more details.

### $dt->era\_abbr()

Returns the abbreviated name of the current era, something like "BC".
See the [Locales](#locales) section for more details.

### $dt->christian\_era()

Returns a string, either "BC" or "AD", according to the year.

### $dt->secular\_era()

Returns a string, either "BCE" or "CE", according to the year.

### $dt->year\_with\_era()

Returns a string containing the year immediately followed by its era
abbreviation. The year is the absolute value of `ce_year()`, so that
year 1 is "1AD" and year 0 is "1BC".

### $dt->year\_with\_christian\_era()

Like `year_with_era()`, but uses the christian\_era() method to get the era
name.

### $dt->year\_with\_secular\_era()

Like `year_with_era()`, but uses the secular\_era() method to get the
era name.

### $dt->month()

Returns the month of the year, from 1..12.

Also available as `$dt->mon()`.

### $dt->month\_name()

Returns the name of the current month. See the
[Locales](#locales) section for more details.

### $dt->month\_abbr()

Returns the abbreviated name of the current month. See the
[Locales](#locales) section for more details.

### $dt->day()

Returns the day of the month, from 1..31.

Also available as `$dt->mday()` and `$dt->day_of_month()`.

### $dt->day\_of\_week()

Returns the day of the week as a number, from 1..7, with 1 being
Monday and 7 being Sunday.

Also available as `$dt->wday()` and `$dt->dow()`.

### $dt->local\_day\_of\_week()

Returns the day of the week as a number, from 1..7. The day
corresponding to 1 will vary based on the locale.

### $dt->day\_name()

Returns the name of the current day of the week. See the
[Locales](#locales) section for more details.

### $dt->day\_abbr()

Returns the abbreviated name of the current day of the week. See the
[Locales](#locales) section for more details.

### $dt->day\_of\_year()

Returns the day of the year.

Also available as `$dt->doy()`.

### $dt->quarter()

Returns the quarter of the year, from 1..4.

### $dt->quarter\_name()

Returns the name of the current quarter. See the
[Locales](#locales) section for more details.

### $dt->quarter\_abbr()

Returns the abbreviated name of the current quarter. See the
[Locales](#locales) section for more details.

### $dt->day\_of\_quarter()

Returns the day of the quarter.

Also available as `$dt->doq()`.

### $dt->weekday\_of\_month()

Returns a number from 1..5 indicating which week day of the month this
is. For example, June 9, 2003 is the second Monday of the month, and
so this method returns 2 for that day.

### $dt->ymd( $optional\_separator ), $dt->mdy(...), $dt->dmy(...)

Each method returns the year, month, and day, in the order indicated
by the method name. Years are zero-padded to four digits. Months and
days are 0-padded to two digits.

By default, the values are separated by a dash (-), but this can be
overridden by passing a value to the method.

The `$dt->ymd()` method is also available as `$dt->date()`.

### $dt->hour()

Returns the hour of the day, from 0..23.

### $dt->hour\_1()

Returns the hour of the day, from 1..24.

### $dt->hour\_12()

Returns the hour of the day, from 1..12.

### $dt->hour\_12\_0()

Returns the hour of the day, from 0..11.

### $dt->am\_or\_pm()

Returns the appropriate localized abbreviation, depending on the
current hour.

### $dt->minute()

Returns the minute of the hour, from 0..59.

Also available as `$dt->min()`.

### $dt->second()

Returns the second, from 0..61. The values 60 and 61 are used for
leap seconds.

Also available as `$dt->sec()`.

### $dt->fractional\_second()

Returns the second, as a real number from 0.0 until 61.999999999

The values 60 and 61 are used for leap seconds.

### $dt->millisecond()

Returns the fractional part of the second as milliseconds (1E-3 seconds).

Half a second is 500 milliseconds.

This value will always be rounded down to the nearest integer.

### $dt->microsecond()

Returns the fractional part of the second as microseconds (1E-6
seconds).

Half a second is 500\_000 microseconds.

This value will always be rounded down to the nearest integer.

### $dt->nanosecond()

Returns the fractional part of the second as nanoseconds (1E-9 seconds).

Half a second is 500\_000\_000 nanoseconds.

### $dt->hms( $optional\_separator )

Returns the hour, minute, and second, all zero-padded to two digits.
If no separator is specified, a colon (:) is used by default.

Also available as `$dt->time()`.

### $dt->datetime( $optional\_separator )

This method is equivalent to:

    $dt->ymd('-') . 'T' . $dt->hms(':')

The `$optional_separator` parameter allows you to override the separator
between the date and time, for e.g. `$dt->datetime(q{ })`.

This method is also available as `$dt->iso8601()`, but it's not really a
very good ISO8601 format, as it lacks a time zone.  If called as
`$dt->iso8601()` you cannot change the separator, as ISO8601 specifies
that "T" must be used to separate them.

### $dt->stringify()

This method returns a stringified version of the object. It is how
stringification overloading is implemented. If the object has a formatter,
then its `format_datetime()` method is used to produce a string. Otherwise,
this method calls `$dt->iso8601()` to produce a string. See ["Formatters
And Stringification"](#formatters-and-stringification) for details.

### $dt->is\_leap\_year()

This method returns a true or false value indicating whether or not the
datetime object is in a leap year.

### $dt->is\_last\_day\_of\_month()

This method returns a true or false value indicating whether or not the
datetime object is the last day of the month.

### $dt->is\_last\_day\_of\_quarter()

This method returns a true or false value indicating whether or not the
datetime object is the last day of the quarter.

### $dt->is\_last\_day\_of\_year()

This method returns a true or false value indicating whether or not the
datetime object is the last day of the year.

### $dt->month\_length()

This method returns the number of days in the current month.

### $dt->quarter\_length()

This method returns the number of days in the current quarter.

### $dt->year\_length()

This method returns the number of days in the current year.

### $dt->week()

    ($week_year, $week_number) = $dt->week;

Returns information about the calendar week which contains this
datetime object. The values returned by this method are also available
separately through the week\_year and week\_number methods.

The first week of the year is defined by ISO as the one which contains
the fourth day of January, which is equivalent to saying that it's the
first week to overlap the new year by at least four days.

Typically the week year will be the same as the year that the object
is in, but dates at the very beginning of a calendar year often end up
in the last week of the prior year, and similarly, the final few days
of the year may be placed in the first week of the next year.

### $dt->week\_year()

Returns the year of the week. See `$dt->week()` for details.

### $dt->week\_number()

Returns the week of the year, from 1..53. See `$dt->week()` for details.

### $dt->week\_of\_month()

The week of the month, from 0..5. The first week of the month is the
first week that contains a Thursday. This is based on the ICU
definition of week of month, and correlates to the ISO8601 week of
year definition. A day in the week _before_ the week with the first
Thursday will be week 0.

### $dt->jd(), $dt->mjd()

These return the Julian Day and Modified Julian Day, respectively.
The value returned is a floating point number. The fractional portion
of the number represents the time portion of the datetime.

### $dt->time\_zone()

This returns the `DateTime::TimeZone` object for the datetime object.

### $dt->offset()

This returns the offset from UTC, in seconds, of the datetime object
according to the time zone.

### $dt->is\_dst()

Returns a boolean indicating whether or not the datetime object is
currently in Daylight Saving Time or not.

### $dt->time\_zone\_long\_name()

This is a shortcut for `$dt->time_zone->name`. It's provided so
that one can use "%{time\_zone\_long\_name}" as a strftime format
specifier.

### $dt->time\_zone\_short\_name()

This method returns the time zone abbreviation for the current time
zone, such as "PST" or "GMT". These names are **not** definitive, and
should not be used in any application intended for general use by
users around the world.

### $dt->strftime( $format, ... )

This method implements functionality similar to the `strftime()`
method in C. However, if given multiple format strings, then it will
return multiple scalars, one for each format string.

See the ["strftime Patterns"](#strftime-patterns) section for a list of all possible
strftime patterns.

If you give a pattern that doesn't exist, then it is simply treated as
text.

Note that any deviation from the POSIX standard is probably a bug. DateTime
should match the output of `POSIX::strftime` for any given pattern.

### $dt->format\_cldr( $format, ... )

This method implements formatting based on the CLDR date patterns. If
given multiple format strings, then it will return multiple scalars,
one for each format string.

See the ["CLDR Patterns"](#cldr-patterns) section for a list of all possible CLDR
patterns.

If you give a pattern that doesn't exist, then it is simply treated as
text.

### $dt->epoch()

Return the UTC epoch value for the datetime object. Datetimes before the start
of the epoch will be returned as a negative number.

The return value from this method is always an integer.

Since the epoch does not account for leap seconds, the epoch time for
1972-12-31T23:59:60 (UTC) is exactly the same as that for
1973-01-01T00:00:00.

### $dt->hires\_epoch()

Returns the epoch as a floating point number. The floating point
portion of the value represents the nanosecond value of the object.
This method is provided for compatibility with the `Time::HiRes`
module.

Note that this method suffers from the imprecision of floating point numbers,
and the result may end up rounded to an arbitrary degree depending on your
platform.

    my $dt = DateTime->new( year => 2012, nanosecond => 4 );
    say $dt->hires_epoch();

On my system, this simply prints `1325376000` because adding `0.000000004`
to `1325376000` returns `1325376000`.

### $dt->is\_finite(), $dt->is\_infinite()

These methods allow you to distinguish normal datetime objects from
infinite ones. Infinite datetime objects are documented in
[DateTime::Infinite](https://metacpan.org/pod/DateTime::Infinite).

### $dt->utc\_rd\_values()

Returns the current UTC Rata Die days, seconds, and nanoseconds as a
three element list. This exists primarily to allow other calendar
modules to create objects based on the values provided by this object.

### $dt->local\_rd\_values()

Returns the current local Rata Die days, seconds, and nanoseconds as a
three element list. This exists for the benefit of other modules
which might want to use this information for date math, such as
`DateTime::Event::Recurrence`.

### $dt->leap\_seconds()

Returns the number of leap seconds that have happened up to the
datetime represented by the object. For floating datetimes, this
always returns 0.

### $dt->utc\_rd\_as\_seconds()

Returns the current UTC Rata Die days and seconds purely as seconds.
This number ignores any fractional seconds stored in the object,
as well as leap seconds.

### $dt->locale()

Returns the current locale object.

### $dt->formatter()

Returns current formatter object or class. See ["Formatters And
Stringification"](#formatters-and-stringification) for details.

## "Set" Methods

The remaining methods provided by `DateTime.pm`, except where otherwise
specified, return the object itself, thus making method chaining
possible. For example:

    my $dt = DateTime->now->set_time_zone( 'Australia/Sydney' );

    my $first = DateTime
                  ->last_day_of_month( year => 2003, month => 3 )
                  ->add( days => 1 )
                  ->subtract( seconds => 1 );

### $dt->set( .. )

This method can be used to change the local components of a date time. This
method accepts any parameter allowed by the `new()` method except for
"locale" or "time\_zone". Use `set_locale()` and `set_time_zone()` for those
instead.

This method performs parameter validation just like the `new()` method.

**Do not use this method to do date math. Use the `add()` and `subtract()`
methods instead.**

### $dt->set\_year(), $dt->set\_month(), etc.

DateTime has a `set_*` method for every item that can be passed to the
constructor:

- $dt->set\_year()
- $dt->set\_month()
- $dt->set\_day()
- $dt->set\_hour()
- $dt->set\_minute()
- $dt->set\_second()
- $dt->set\_nanosecond()

These are shortcuts to calling `set()` with a single key. They all
take a single parameter.

### $dt->truncate( to => ... )

This method allows you to reset some of the local time components in the
object to their "zero" values. The "to" parameter is used to specify which
values to truncate, and it may be one of "year", "quarter", "month", "week",
"local\_week", "day", "hour", "minute", or "second".

For example, if "month" is specified, then the local day becomes 1, and the
hour, minute, and second all become 0.

If "week" is given, then the datetime is set to the Monday of the week in
which it occurs, and the time components are all set to 0. If you truncate to
"local\_week", then the first day of the week is locale-dependent. For example,
in the `en-US` locale, the first day of the week is Sunday.

### $dt->set\_locale( $locale )

Sets the object's locale. You can provide either a locale code like "en-US" or
an object returned by `DateTime::Locale->load`.

### $dt->set\_time\_zone( $tz )

This method accepts either a time zone object or a string that can be
passed as the "name" parameter to `DateTime::TimeZone->new()`.
If the new time zone's offset is different from the old time zone,
then the _local_ time is adjusted accordingly.

For example:

    my $dt = DateTime->new(
        year      => 2000,
        month     => 5,
        day       => 10,
        hour      => 15,
        minute    => 15,
        time_zone => 'America/Los_Angeles',
    );

    print $dt->hour; # prints 15

    $dt->set_time_zone( 'America/Chicago' );

    print $dt->hour; # prints 17

If the old time zone was a floating time zone, then no adjustments to
the local time are made, except to account for leap seconds. If the
new time zone is floating, then the _UTC_ time is adjusted in order
to leave the local time untouched.

Fans of Tsai Ming-Liang's films will be happy to know that this does
work:

    my $dt = DateTime->now( time_zone => 'Asia/Taipei' );

    $dt->set_time_zone( 'Europe/Paris' );

Yes, now we can know "ni3 na4 bian1 ji2dian3?"

### $dt->set\_formatter( $formatter )

Set the formatter for the object. See ["Formatters And
Stringification"](#formatters-and-stringification) for details.

You can set this to `undef` to revert to the default formatter.

## Math Methods

Like the set methods, math related methods always return the object
itself, to allow for chaining:

    $dt->add( days => 1 )->subtract( seconds => 1 );

### $dt->duration\_class()

This returns `DateTime::Duration`, but exists so that a subclass of
`DateTime.pm` can provide a different value.

### $dt->add\_duration( $duration\_object )

This method adds a `DateTime::Duration` to the current datetime. See
the [DateTime::Duration](https://metacpan.org/pod/DateTime::Duration) docs for more details.

### $dt->add( parameters for DateTime::Duration )

This method is syntactic sugar around the `add_duration()` method. It
simply creates a new `DateTime::Duration` object using the parameters
given, and then calls the `add_duration()` method.

### $dt->add( $duration\_object )

A synonym of `$dt->add_duration( $duration_object )`.

### $dt->subtract\_duration( $duration\_object )

When given a `DateTime::Duration` object, this method simply calls
`invert()` on that object and passes that new duration to the
`add_duration` method.

### $dt->subtract( DateTime::Duration->new parameters )

Like `add()`, this is syntactic sugar for the `subtract_duration()`
method.

### $dt->subtract( $duration\_object )

A synonym of `$dt->subtract_duration( $duration_object )`.

### $dt->subtract\_datetime( $datetime )

This method returns a new `DateTime::Duration` object representing
the difference between the two dates. The duration is **relative** to
the object from which `$datetime` is subtracted. For example:

       2003-03-15 00:00:00.00000000
    -  2003-02-15 00:00:00.00000000
    -------------------------------
    = 1 month

Note that this duration is not an absolute measure of the amount of
time between the two datetimes, because the length of a month varies,
as well as due to the presence of leap seconds.

The returned duration may have deltas for months, days, minutes,
seconds, and nanoseconds.

### $dt->delta\_md( $datetime )

### $dt->delta\_days( $datetime )

Each of these methods returns a new `DateTime::Duration` object
representing some portion of the difference between two datetimes.
The `delta_md()` method returns a duration which contains only the
month and day portions of the duration is represented. The
`delta_days()` method returns a duration which contains only days.

The `delta_md` and `delta_days` methods truncate the duration so
that any fractional portion of a day is ignored. Both of these
methods operate on the date portion of a datetime only, and so
effectively ignore the time zone.

Unlike the subtraction methods, **these methods always return a
positive (or zero) duration**.

### $dt->delta\_ms( $datetime )

Returns a duration which contains only minutes and seconds. Any day
and month differences to minutes are converted to minutes and
seconds. This method also **always return a positive (or zero)
duration**.

### $dt->subtract\_datetime\_absolute( $datetime )

This method returns a new `DateTime::Duration` object representing
the difference between the two dates in seconds and nanoseconds. This
is the only way to accurately measure the absolute amount of time
between two datetimes, since units larger than a second do not
represent a fixed number of seconds.

Note that because of leap seconds, this may not return the same result as
doing this math based on the value returned by `$dt->epoch()`.

## Class Methods

### DateTime->DefaultLocale( $locale )

This can be used to specify the default locale to be used when
creating DateTime objects. If unset, then "en-US" is used.

### DateTime->compare( $dt1, $dt2 ), DateTime->compare\_ignore\_floating( $dt1, $dt2 )

    $cmp = DateTime->compare( $dt1, $dt2 );

    $cmp = DateTime->compare_ignore_floating( $dt1, $dt2 );

Compare two DateTime objects. The semantics are compatible with Perl's
`sort()` function; it returns -1 if $dt1 < $dt2, 0 if $dt1 == $dt2, 1 if $dt1
\> $dt2.

If one of the two DateTime objects has a floating time zone, it will
first be converted to the time zone of the other object. This is what
you want most of the time, but it can lead to inconsistent results
when you compare a number of DateTime objects, some of which are
floating, and some of which are in other time zones.

If you want to have consistent results (because you want to sort a
number of objects, for example), you can use the
`compare_ignore_floating()` method:

    @dates = sort { DateTime->compare_ignore_floating($a, $b) } @dates;

In this case, objects with a floating time zone will be sorted as if
they were UTC times.

Since DateTime objects overload comparison operators, this:

    @dates = sort @dates;

is equivalent to this:

    @dates = sort { DateTime->compare($a, $b) } @dates;

DateTime objects can be compared to any other calendar class that
implements the `utc_rd_values()` method.

## Testing Code That Uses DateTime

If you are trying to test code that calls uses DateTime, you may want to be
able to explicitly set the value returned by Perl's `time()` builtin. This
builtin is called by `DateTime->now()` and `DateTime->today()`.

You can  override `CORE::GLOBAL::time()`, but this  will only work if  you do
this **before** loading  DateTime. If doing this is inconvenient,  you can also
override `DateTime::_core_time()`:

    no warnings 'redefine';
    local *DateTime::_core_time = sub { return 42 };

DateTime is guaranteed to call this subroutine to get the current `time()`
value. You can also override the `_core_time()` sub in a subclass of DateTime
and use that.

## How DateTime Math Works

It's important to have some understanding of how datetime math is
implemented in order to effectively use this module and
`DateTime::Duration`.

### Making Things Simple

If you want to simplify your life and not have to think too hard about
the nitty-gritty of datetime math, I have several recommendations:

- use the floating time zone

    If you do not care about time zones or leap seconds, use the
    "floating" timezone:

        my $dt = DateTime->now( time_zone => 'floating' );

    Math done on two objects in the floating time zone produces very
    predictable results.

    Note that in most cases you will want to start by creating an object in a
    specific zone and _then_ convert it to the floating time zone. When an object
    goes from a real zone to the floating zone, the time for the object remains
    the same.

    This means that passing the floating zone to a constructor may not do what you
    want.

        my $dt = DateTime->now( time_zone => 'floating' );

    is equivalent to

        my $dt = DateTime->now( time_zone => 'UTC' )->set_time_zone('floating');

    This might not be what you wanted. Instead, you may prefer to do this:

        my $dt = DateTime->now( time_zone => 'local' )->set_time_zone('floating');

- use UTC for all calculations

    If you do care about time zones (particularly DST) or leap seconds,
    try to use non-UTC time zones for presentation and user input only.
    Convert to UTC immediately and convert back to the local time zone for
    presentation:

        my $dt = DateTime->new( %user_input, time_zone => $user_tz );
        $dt->set_time_zone('UTC');

        # do various operations - store it, retrieve it, add, subtract, etc.

        $dt->set_time_zone($user_tz);
        print $dt->datetime;

- math on non-UTC time zones

    If you need to do date math on objects with non-UTC time zones, please
    read the caveats below carefully. The results `DateTime.pm` produces are
    predictable and correct, and mostly intuitive, but datetime math gets
    very ugly when time zones are involved, and there are a few strange
    corner cases involving subtraction of two datetimes across a DST
    change.

    If you can always use the floating or UTC time zones, you can skip
    ahead to ["Leap Seconds and Date Math"](#leap-seconds-and-date-math)

- date vs datetime math

    If you only care about the date (calendar) portion of a datetime, you
    should use either `delta_md()` or `delta_days()`, not
    `subtract_datetime()`. This will give predictable, unsurprising
    results, free from DST-related complications.

- subtract\_datetime() and add\_duration()

    You must convert your datetime objects to the UTC time zone before
    doing date math if you want to make sure that the following formulas
    are always true:

        $dt2 - $dt1 = $dur
        $dt1 + $dur = $dt2
        $dt2 - $dur = $dt1

    Note that using `delta_days` ensures that this formula always works,
    regardless of the timezone of the objects involved, as does using
    `subtract_datetime_absolute()`. Other methods of subtraction are not
    always reversible.

- never do math on two objects where only one is in the floating time zone

    The date math code accounts for leap seconds whenever the `DateTime` object
    is not in the floating time zone. If you try to do math where one object is in
    the floating zone and the other isn't, the results will be confusing and
    wrong.

### Adding a Duration to a Datetime

The parts of a duration can be broken down into five parts. These are
months, days, minutes, seconds, and nanoseconds. Adding one month to
a date is different than adding 4 weeks or 28, 29, 30, or 31 days.
Similarly, due to DST and leap seconds, adding a day can be different
than adding 86,400 seconds, and adding a minute is not exactly the
same as 60 seconds.

We cannot convert between these units, except for seconds and
nanoseconds, because there is no fixed conversion between the two
units, because of things like leap seconds, DST changes, etc.

`DateTime.pm` always adds (or subtracts) days, then months, minutes, and then
seconds and nanoseconds. If there are any boundary overflows, these are
normalized at each step. For the days and months the local (not UTC) values
are used. For minutes and seconds, the local values are used. This generally
just works.

This means that adding one month and one day to February 28, 2003 will
produce the date April 1, 2003, not March 29, 2003.

    my $dt = DateTime->new( year => 2003, month => 2, day => 28 );

    $dt->add( months => 1, days => 1 );

    # 2003-04-01 - the result

On the other hand, if we add months first, and then separately add
days, we end up with March 29, 2003:

    $dt->add( months => 1 )->add( days => 1 );

    # 2003-03-29

We see similar strangeness when math crosses a DST boundary:

    my $dt = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 1,
        minute    => 58,
        time_zone => "America/Chicago",
    );

    $dt->add( days => 1, minutes => 3 );
    # 2003-04-06 02:01:00

    $dt->add( minutes => 3 )->add( days => 1 );
    # 2003-04-06 03:01:00

Note that if you converted the datetime object to UTC first you would
get predictable results.

If you want to know how many seconds a duration object represents, you
have to add it to a datetime to find out, so you could do:

    my $now = DateTime->now( time_zone => 'UTC' );
    my $later = $now->clone->add_duration($duration);

    my $seconds_dur = $later->subtract_datetime_absolute($now);

This returns a duration which only contains seconds and nanoseconds.

If we were add the duration to a different datetime object we might
get a different number of seconds.

[DateTime::Duration](https://metacpan.org/pod/DateTime::Duration) supports three different end-of-month algorithms for
adding months. This comes into play when an addition results in a day past the
end of the month (for example, adding one month to January 30).

    # 2010-08-31 + 1 month = 2010-10-01
    $dt->add( months => 1, end_of_month => 'wrap' );

    # 2010-01-30 + 1 month = 2010-02-28
    $dt->add( months => 1, end_of_month => 'limit' );

    # 2010-04-30 + 1 month = 2010-05-31
    $dt->add( months => 1, end_of_month => 'preserve' );

By default, it uses "wrap" for positive durations and "preserve" for negative
durations. See [DateTime::Duration](https://metacpan.org/pod/DateTime::Duration) for a detailed explanation of these
algorithms.

If you need to do lots of work with durations, take a look at Rick
Measham's `DateTime::Format::Duration` module, which lets you present
information from durations in many useful ways.

There are other subtract/delta methods in DateTime.pm to generate
different types of durations. These methods are
`subtract_datetime()`, `subtract_datetime_absolute()`,
`delta_md()`, `delta_days()`, and `delta_ms()`.

### Datetime Subtraction

Date subtraction is done solely based on the two object's local
datetimes, with one exception to handle DST changes. Also, if the two
datetime objects are in different time zones, one of them is converted
to the other's time zone first before subtraction. This is best
explained through examples:

The first of these probably makes the most sense:

    my $dt1 = DateTime->new(
        year      => 2003,
        month     => 5,
        day       => 6,
        time_zone => 'America/Chicago',
    );

    # not DST

    my $dt2 = DateTime->new(
        year      => 2003,
        month     => 11,
        day       => 6,
        time_zone => 'America/Chicago',
    );

    # is DST

    my $dur = $dt2->subtract_datetime($dt1);
    # 6 months

Nice and simple.

This one is a little trickier, but still fairly logical:

    my $dt1 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 1,
        minute    => 58,
        time_zone => "America/Chicago",
    );

    # is DST

    my $dt2 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 7,
        hour      => 2,
        minute    => 1,
        time_zone => "America/Chicago",
    );

    # not DST

    my $dur = $dt2->subtract_datetime($dt1);

    # 2 days and 3 minutes

Which contradicts the result this one gives, even though they both
make sense:

    my $dt1 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 1,
        minute    => 58,
        time_zone => "America/Chicago",
    );

    # is DST

    my $dt2 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 6,
        hour      => 3,
        minute    => 1,
        time_zone => "America/Chicago",
    );

    # not DST

    my $dur = $dt2->subtract_datetime($dt1);

    # 1 day and 3 minutes

This last example illustrates the "DST" exception mentioned earlier.
The exception accounts for the fact 2003-04-06 only lasts 23 hours.

And finally:

    my $dt2 = DateTime->new(
        year      => 2003,
        month     => 10,
        day       => 26,
        hour      => 1,
        time_zone => 'America/Chicago',
    );

    my $dt1 = $dt2->clone->subtract( hours => 1 );

    my $dur = $dt2->subtract_datetime($dt1);
    # 60 minutes

This seems obvious until you realize that subtracting 60 minutes from
`$dt2` in the above example still leaves the clock time at
"01:00:00". This time we are accounting for a 25 hour day.

### Reversibility

Date math operations are not always reversible. This is because of
the way that addition operations are ordered. As was discussed
earlier, adding 1 day and 3 minutes in one call to `add()` is not the
same as first adding 3 minutes and 1 day in two separate calls.

If we take a duration returned from `subtract_datetime()` and then
try to add or subtract that duration from one of the datetimes we just
used, we sometimes get interesting results:

    my $dt1 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 1,
        minute    => 58,
        time_zone => "America/Chicago",
    );

    my $dt2 = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 6,
        hour      => 3,
        minute    => 1,
        time_zone => "America/Chicago",
    );

    my $dur = $dt2->subtract_datetime($dt1);
    # 1 day and 3 minutes

    $dt1->add_duration($dur);
    # gives us $dt2

    $dt2->subtract_duration($dur);
    # gives us 2003-04-05 02:58:00 - 1 hour later than $dt1

The `subtract_duration()` operation gives us a (perhaps) unexpected
answer because it first subtracts one day to get 2003-04-05T03:01:00
and then subtracts 3 minutes to get the final result.

If we explicitly reverse the order we can get the original value of
`$dt1`. This can be facilitated by `DateTime::Duration`'s
`calendar_duration()` and `clock_duration()` methods:

    $dt2->subtract_duration( $dur->clock_duration )
        ->subtract_duration( $dur->calendar_duration );

### Leap Seconds and Date Math

The presence of leap seconds can cause even more anomalies in date
math. For example, the following is a legal datetime:

    my $dt = DateTime->new(
        year      => 1972,
        month     => 12,
        day       => 31,
        hour      => 23,
        minute    => 59,
        second    => 60,
        time_zone => 'UTC'
    );

If we do the following:

    $dt->add( months => 1 );

Then the datetime is now "1973-02-01 00:00:00", because there is no
23:59:60 on 1973-01-31.

Leap seconds also force us to distinguish between minutes and seconds
during date math. Given the following datetime:

    my $dt = DateTime->new(
        year      => 1972,
        month     => 12,
        day       => 31,
        hour      => 23,
        minute    => 59,
        second    => 30,
        time_zone => 'UTC'
    );

we will get different results when adding 1 minute than we get if we
add 60 seconds. This is because in this case, the last minute of the
day, beginning at 23:59:00, actually contains 61 seconds.

Here are the results we get:

    # 1972-12-31 23:59:30 - our starting datetime

    $dt->clone->add( minutes => 1 );
    # 1973-01-01 00:00:30 - one minute later

    $dt->clone->add( seconds => 60 );
    # 1973-01-01 00:00:29 - 60 seconds later

    $dt->clone->add( seconds => 61 );
    # 1973-01-01 00:00:30 - 61 seconds later

### Local vs. UTC and 24 hours vs. 1 day

When math crosses a daylight saving boundary, a single day may have
more or less than 24 hours.

For example, if you do this:

    my $dt = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 2,
        time_zone => 'America/Chicago',
    );

    $dt->add( days => 1 );

then you will produce an _invalid_ local time, and therefore an
exception will be thrown.

However, this works:

    my $dt = DateTime->new(
        year      => 2003,
        month     => 4,
        day       => 5,
        hour      => 2,
        time_zone => 'America/Chicago',
    );

    $dt->add( hours => 24 );

and produces a datetime with the local time of "03:00".

If all this makes your head hurt, there is a simple alternative. Just
convert your datetime object to the "UTC" time zone before doing date
math on it, and switch it back to the local time zone afterwards.
This avoids the possibility of having date math throw an exception,
and makes sure that 1 day equals 24 hours. Of course, this may not
always be desirable, so caveat user!

## Overloading

This module explicitly overloads the addition (+), subtraction (-),
string and numeric comparison operators. This means that the
following all do sensible things:

    my $new_dt = $dt + $duration_obj;

    my $new_dt = $dt - $duration_obj;

    my $duration_obj = $dt - $new_dt;

    foreach my $dt ( sort @dts ) { ... }

Additionally, the fallback parameter is set to true, so other
derivable operators (+=, -=, etc.) will work properly. Do not expect
increment (++) or decrement (--) to do anything useful.

The string comparison operators, `eq` or `ne`, will use the string
value to compare with non-DateTime objects.

DateTime objects do not have a numeric value, using `==` or `<=>` to compare a DateTime object with a non-DateTime object will result
in an exception. To safely sort mixed DateTime and non-DateTime
objects, use `sort { $a cmp $b } @dates`.

The module also overloads stringification using the object's
formatter, defaulting to `iso8601()` method. See ["Formatters And
Stringification"](#formatters-and-stringification) for details.

## Formatters And Stringification

You can optionally specify a "formatter", which is usually a
DateTime::Format::\* object/class, to control the stringification of
the DateTime object.

Any of the constructor methods can accept a formatter argument:

    my $formatter = DateTime::Format::Strptime->new(...);
    my $dt = DateTime->new(year => 2004, formatter => $formatter);

Or, you can set it afterwards:

    $dt->set_formatter($formatter);
    $formatter = $dt->formatter();

Once you set the formatter, the overloaded stringification method will
use the formatter. If unspecified, the `iso8601()` method is used.

A formatter can be handy when you know that in your application you
want to stringify your DateTime objects into a special format all the
time, for example to a different language.

If you provide a formatter class name or object, it must implement a
`format_datetime` method. This method will be called with just the
DateTime object as its argument.

## CLDR Patterns

The CLDR pattern language is both more powerful and more complex than
strftime. Unlike strftime patterns, you often have to explicitly
escape text that you do not want formatted, as the patterns are simply
letters without any prefix.

For example, "yyyy-MM-dd" is a valid CLDR pattern. If you want to
include any lower or upper case ASCII characters as-is, you can
surround them with single quotes ('). If you want to include a single
quote, you must escape it as two single quotes ('').

    'Today is ' EEEE
    'It is now' h 'o''clock' a

Spaces and any non-letter text will always be passed through as-is.

Many CLDR patterns which produce numbers will pad the number with
leading zeroes depending on the length of the format specifier. For
example, "h" represents the current hour from 1-12. If you specify
"hh" then the 1-9 will have a leading zero prepended.

However, CLDR often uses five of a letter to represent the narrow form
of a pattern. This inconsistency is necessary for backwards
compatibility.

CLDR often distinguishes between the "format" and "stand-alone" forms
of a pattern. The format pattern is used when the thing in question is
being placed into a larger string. The stand-alone form is used when
displaying that item by itself, for example in a calendar.

It also often provides three sizes for each item, wide (the full
name), abbreviated, and narrow. The narrow form is often just a single
character, for example "T" for "Tuesday", and may not be unique.

CLDR provides a fairly complex system for localizing time zones that
we ignore entirely. The time zone patterns just use the information
provided by `DateTime::TimeZone`, and _do not follow the CLDR spec_.

The output of a CLDR pattern is always localized, when applicable.

CLDR provides the following patterns:

- G{1,3}

    The abbreviated era (BC, AD).

- GGGG

    The wide era (Before Christ, Anno Domini).

- GGGGG

    The narrow era, if it exists (and it mostly doesn't).

- y and y{3,}

    The year, zero-prefixed as needed. Negative years will start with a "-",
    and this will be included in the length calculation.

    In other, words the "yyyyy" pattern will format year -1234 as "-1234", not
    "-01234".

- yy

    This is a special case. It always produces a two-digit year, so "1976" becomes
    "76". Negative years will start with a "-", making them one character longer.

- Y{1,}

    The year in "week of the year" calendars, from `$dt->week_year()`.

- u{1,}

    Same as "y" except that "uu" is not a special case.

- Q{1,2}

    The quarter as a number (1..4).

- QQQ

    The abbreviated format form for the quarter.

- QQQQ

    The wide format form for the quarter.

- q{1,2}

    The quarter as a number (1..4).

- qqq

    The abbreviated stand-alone form for the quarter.

- qqqq

    The wide stand-alone form for the quarter.

- M{1,2\]

    The numerical month.

- MMM

    The abbreviated format form for the month.

- MMMM

    The wide format form for the month.

- MMMMM

    The narrow format form for the month.

- L{1,2\]

    The numerical month.

- LLL

    The abbreviated stand-alone form for the month.

- LLLL

    The wide stand-alone form for the month.

- LLLLL

    The narrow stand-alone form for the month.

- w{1,2}

    The week of the year, from `$dt->week_number()`.

- W

    The week of the month, from `$dt->week_of_month()`.

- d{1,2}

    The numeric day of the month.

- D{1,3}

    The numeric day of the year.

- F

    The day of the week in the month, from `$dt->weekday_of_month()`.

- g{1,}

    The modified Julian day, from `$dt->mjd()`.

- E{1,3} and eee

    The abbreviated format form for the day of the week.

- EEEE and eeee

    The wide format form for the day of the week.

- EEEEE and eeeee

    The narrow format form for the day of the week.

- e{1,2}

    The _local_ numeric day of the week, from 1 to 7. This number depends
    on what day is considered the first day of the week, which varies by
    locale. For example, in the US, Sunday is the first day of the week,
    so this returns 2 for Monday.

- c

    The numeric day of the week from 1 to 7, treating Monday as the first
    of the week, regardless of locale.

- ccc

    The abbreviated stand-alone form for the day of the week.

- cccc

    The wide stand-alone form for the day of the week.

- ccccc

    The narrow format form for the day of the week.

- a

    The localized form of AM or PM for the time.

- h{1,2}

    The hour from 1-12.

- H{1,2}

    The hour from 0-23.

- K{1,2}

    The hour from 0-11.

- k{1,2}

    The hour from 1-24.

- j{1,2}

    The hour, in 12 or 24 hour form, based on the preferred form for the
    locale. In other words, this is equivalent to either "h{1,2}" or
    "H{1,2}".

- m{1,2}

    The minute.

- s{1,2}

    The second.

- S{1,}

    The fractional portion of the seconds, rounded based on the length of
    the specifier. This returned _without_ a leading decimal point, but
    may have leading or trailing zeroes.

- A{1,}

    The millisecond of the day, based on the current time. In other words,
    if it is 12:00:00.00, this returns 43200000.

- z{1,3}

    The time zone short name.

- zzzz

    The time zone long name.

- Z{1,3}

    The time zone offset.

- ZZZZ

    The time zone short name and the offset as one string, so something
    like "CDT-0500".

- ZZZZZ

    The time zone offset as a sexagesimal number, so something like "-05:00".
    (This is useful for W3C format.)

- v{1,3}

    The time zone short name.

- vvvv

    The time zone long name.

- V{1,3}

    The time zone short name.

- VVVV

    The time zone long name.

### CLDR "Available Formats"

The CLDR data includes pre-defined formats for various patterns such as "month
and day" or "time of day". Using these formats lets you render information
about a datetime in the most natural way for users from a given locale.

These formats are indexed by a key that is itself a CLDR pattern. When you
look these up, you get back a different CLDR pattern suitable for the locale.

Let's look at some example We'll use `2008-02-05T18:30:30` as our example
datetime value, and see how this is rendered for the `en-US` and `fr-FR`
locales.

- `MMMd`

    The abbreviated month and day as number. For `en-US`, we get the pattern
    `MMM d`, which renders as `Feb 5`. For `fr-FR`, we get the pattern
    `d MMM`, which renders as `5 févr.`.

- `yQQQ`

    The year and abbreviated quarter of year. For `en-US`, we get the pattern
    `QQQ y`, which renders as `Q1 2008`. For `fr-FR`, we get the same pattern,
    `QQQ y`, which renders as `T1 2008`.

- `hm`

    The 12-hour time of day without seconds.  For `en-US`, we get the pattern
    `h:mm a`, which renders as `6:30 PM`. For `fr-FR`, we get the exact same
    pattern and rendering.

The available formats for each locale are documented in the POD for that
locale. To get back the format, you use the `$locale->format_for`
method. For example:

    say $dt->format_cldr( $dt->locale->format_for('MMMd') );

## strftime Patterns

The following patterns are allowed in the format string given to the
`$dt->strftime()` method:

- %a

    The abbreviated weekday name.

- %A

    The full weekday name.

- %b

    The abbreviated month name.

- %B

    The full month name.

- %c

    The default datetime format for the object's locale.

- %C

    The century number (year/100) as a 2-digit integer.

- %d

    The day of the month as a decimal number (range 01 to 31).

- %D

    Equivalent to %m/%d/%y. This is not a good standard format if you
    want folks from both the United States and the rest of the world to
    understand the date!

- %e

    Like %d, the day of the month as a decimal number, but a leading zero
    is replaced by a space.

- %F

    Equivalent to %Y-%m-%d (the ISO 8601 date format)

- %G

    The ISO 8601 year with century as a decimal number. The 4-digit year
    corresponding to the ISO week number (see %V). This has the same
    format and value as %Y, except that if the ISO week number belongs to
    the previous or next year, that year is used instead. (TZ)

- %g

    Like %G, but without century, i.e., with a 2-digit year (00-99).

- %h

    Equivalent to %b.

- %H

    The hour as a decimal number using a 24-hour clock (range 00 to 23).

- %I

    The hour as a decimal number using a 12-hour clock (range 01 to 12).

- %j

    The day of the year as a decimal number (range 001 to 366).

- %k

    The hour (24-hour clock) as a decimal number (range 0 to 23); single
    digits are preceded by a blank. (See also %H.)

- %l

    The hour (12-hour clock) as a decimal number (range 1 to 12); single
    digits are preceded by a blank. (See also %I.)

- %m

    The month as a decimal number (range 01 to 12).

- %M

    The minute as a decimal number (range 00 to 59).

- %n

    A newline character.

- %N

    The fractional seconds digits. Default is 9 digits (nanoseconds).

        %3N   milliseconds (3 digits)
        %6N   microseconds (6 digits)
        %9N   nanoseconds  (9 digits)

    This value will always be rounded down to the nearest integer.

- %p

    Either \`AM' or \`PM' according to the given time value, or the
    corresponding strings for the current locale. Noon is treated as \`pm'
    and midnight as \`am'.

- %P

    Like %p but in lowercase: \`am' or \`pm' or a corresponding string for
    the current locale.

- %r

    The time in a.m. or p.m. notation. In the POSIX locale this is
    equivalent to \`%I:%M:%S %p'.

- %R

    The time in 24-hour notation (%H:%M). (SU) For a version including the
    seconds, see %T below.

- %s

    The number of seconds since the epoch.

- %S

    The second as a decimal number (range 00 to 61).

- %t

    A tab character.

- %T

    The time in 24-hour notation (%H:%M:%S).

- %u

    The day of the week as a decimal, range 1 to 7, Monday being 1. See
    also %w.

- %U

    The week number of the current year as a decimal number, range 00 to
    53, starting with the first Sunday as the first day of week 01. See
    also %V and %W.

- %V

    The ISO 8601:1988 week number of the current year as a decimal number,
    range 01 to 53, where week 1 is the first week that has at least 4
    days in the current year, and with Monday as the first day of the
    week. See also %U and %W.

- %w

    The day of the week as a decimal, range 0 to 6, Sunday being 0. See
    also %u.

- %W

    The week number of the current year as a decimal number, range 00 to
    53, starting with the first Monday as the first day of week 01.

- %x

    The default date format for the object's locale.

- %X

    The default time format for the object's locale.

- %y

    The year as a decimal number without a century (range 00 to 99).

- %Y

    The year as a decimal number including the century.

- %z

    The time-zone as hour offset from UTC. Required to emit
    RFC822-conformant dates (using "%a, %d %b %Y %H:%M:%S %z").

- %Z

    The time zone or name or abbreviation.

- %%

    A literal \`%' character.

- %{method}

    Any method name may be specified using the format `%{method}` name
    where "method" is a valid `DateTime.pm` object method.

## DateTime.pm and Storable

DateTime implements Storable hooks in order to reduce the size of a
serialized DateTime object.

# THE DATETIME PROJECT ECOSYSTEM

This module is part of a larger ecosystem of modules in the DateTime
family.

## [DateTime::Set](https://metacpan.org/pod/DateTime::Set)

The [DateTime::Set](https://metacpan.org/pod/DateTime::Set) module represents sets (including recurrences) of
datetimes. Many modules return sets or recurrences.

## Format Modules

The various format modules exist to parse and format datetimes. For example,
[DateTime::Format::HTTP](https://metacpan.org/pod/DateTime::Format::HTTP) parses dates according to the RFC 1123 format:

    my $datetime
        = DateTime::Format::HTTP->parse_datetime('Thu Feb  3 17:03:55 GMT 1994');

    print DateTime::Format::HTTP->format_datetime($datetime);

Most format modules are suitable for use as a `formatter` with a DateTime
object.

All format modules start with `DateTime::Format::`.

## Calendar Modules

There are a number of modules on CPAN that implement non-Gregorian calendars,
such as the Chinese, Mayan, and Julian calendars.

All calendar modules start with `DateTime::Calendar::`.

## Event Modules

There are a number of modules that calculate the dates for events, such as
Easter, Sunrise, etc.

All event modules start with `DateTime::Event::`.

## Others

There are many other modules that work with DateTime, including modules in the
`DateTimeX` namespace, as well as others.

See the [datetime wiki](http://datetime.perl.org) and
[search.cpan.org](http://search.cpan.org/search?query=datetime&mode=dist) for
more details.

# KNOWN BUGS

The tests in `20infinite.t` seem to fail on some machines,
particularly on Win32. This appears to be related to Perl's internal
handling of IEEE infinity and NaN, and seems to be highly
platform/compiler/phase of moon dependent.

If you don't plan to use infinite datetimes you can probably ignore
this. This will be fixed (perhaps) in future versions.

# SEE ALSO

[A Date with
Perl](http://www.houseabsolute.com/presentations/a-date-with-perl/) - a talk
I've given at a few YAPCs.

[datetime@perl.org mailing list](http://lists.perl.org/list/datetime.html)

[http://datetime.perl.org/](http://datetime.perl.org/)

# SUPPORT

Bugs may be submitted at [https://github.com/houseabsolute/DateTime.pm/issues](https://github.com/houseabsolute/DateTime.pm/issues).

There is a mailing list available for users of this distribution,
[mailto:datetime@perl.org](mailto:datetime@perl.org).

I am also usually active on IRC as 'autarch' on `irc://irc.perl.org`.

# SOURCE

The source code repository for DateTime can be found at [https://github.com/houseabsolute/DateTime.pm](https://github.com/houseabsolute/DateTime.pm).

# DONATIONS

If you'd like to thank me for the work I've done on this module, please
consider making a "donation" to me via PayPal. I spend a lot of free time
creating free software, and would appreciate any support you'd care to offer.

Please note that **I am not suggesting that you must do this** in order for me
to continue working on this particular software. I will continue to do so,
inasmuch as I have in the past, for as long as it interests me.

Similarly, a donation made in this way will probably not make me work on this
software much more, unless I get so many donations that I can consider working
on free software full time (let's all have a chuckle at that together).

To donate, log into PayPal and send money to autarch@urth.org, or use the
button at [http://www.urth.org/~autarch/fs-donation.html](http://www.urth.org/~autarch/fs-donation.html).

# AUTHOR

Dave Rolsky <autarch@urth.org>

# CONTRIBUTORS

- Ben Bennett <fiji@limey.net>
- Christian Hansen <chansen@cpan.org>
- Daisuke Maki <dmaki@cpan.org>
- Dan Book <grinnz@gmail.com>
- Dan Stewart <danielandrewstewart@gmail.com>
- David E. Wheeler <david@justatheory.com>
- David Precious <davidp@preshweb.co.uk>
- Doug Bell <madcityzen@gmail.com>
- Flávio Soibelmann Glock <fglock@gmail.com>
- Gianni Ceccarelli <gianni.ceccarelli@broadbean.com>
- Gregory Oschwald <oschwald@gmail.com>
- Hauke D <haukex@zero-g.net>
- Iain Truskett &lt;deceased>
- Jason McIntosh <jmac@jmac.org>
- Joshua Hoblitt <jhoblitt@cpan.org>
- Karen Etheridge <ether@cpan.org>
- Michael Conrad <mike@nrdvana.net>
- Michael R. Davis <mrdvt92@users.noreply.github.com>
- M Somerville <dracos@users.noreply.github.com>
- Nick Tonkin <1nickt@users.noreply.github.com>
- Olaf Alders <olaf@wundersolutions.com>
- Ovid &lt;curtis\_ovid\_poe@yahoo.com>
- Paul Howarth <paul@city-fan.org>
- Philippe Bruhat (BooK) <book@cpan.org>
- Ricardo Signes <rjbs@cpan.org>
- Richard Bowen <bowen@cpan.org>
- Ron Hill <rkhill@cpan.org>
- Sam Kington <github@illuminated.co.uk>
- viviparous &lt;viviparous@prc>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2003 - 2018 by Dave Rolsky.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)

The full text of the license can be found in the
`LICENSE` file included with this distribution.
