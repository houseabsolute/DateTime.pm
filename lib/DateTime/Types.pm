package DateTime::Types;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '1.44';

use parent 'Specio::Exporter';

use Specio 0.18;
use Specio::Declare;
use Specio::Library::Builtins -reexport;
use Specio::Library::Numeric -reexport;
use Specio::Library::String;

any_can_type(
    'ConvertibleObject',
    methods => ['utc_rd_values'],
);

declare(
    'DayOfMonth',
    parent => t('Int'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 1 && $_[1] <= 31";
    },
);

declare(
    'DayOfYear',
    parent => t('Int'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 1 && $_[1] <= 366";
    },
);

object_isa_type(
    'Duration',
    class => 'DateTime::Duration',
);

enum(
    'EndOfMonthMode',
    values => [qw( wrap limit preserve )],
);

any_can_type(
    'Formatter',
    methods => ['format_datetime'],
);

my $locale_object = declare(
    'LocaleObject',
    parent => t('Object'),
    inline => sub {

        # Can't use $_[1] directly because 5.8 gives very weird errors
        my $var = $_[1];
        <<"EOF";
(
    $var->isa('DateTime::Locale::FromData')
    || $var->isa('DateTime::Locale::Base')
)
EOF
    },
);

union(
    'Locale',
    of => [ t('NonEmptySimpleStr'), $locale_object ],
);

my $time_zone_object = object_can_type(
    'TZObject',
    methods => [
        qw(
            is_floating
            is_utc
            name
            offset_for_datetime
            short_name_for_datetime
            )
    ],
);

declare(
    'TimeZone',
    of => [ t('NonEmptySimpleStr'), $time_zone_object ],
);

declare(
    'Hour',
    parent => t('PositiveOrZeroInt'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 0 && $_[1] <= 23";
    },
);

declare(
    'Minute',
    parent => t('PositiveOrZeroInt'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 0 && $_[1] <= 59";
    },
);

declare(
    'Month',
    parent => t('PositiveInt'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 1 && $_[1] <= 12";
    },
);

declare(
    'Nanosecond',
    parent => t('PositiveOrZeroInt'),
);

declare(
    'Second',
    parent => t('PositiveOrZeroInt'),
    inline => sub {
        $_[0]->parent->inline_check( $_[1] )
            . " && $_[1] >= 0 && $_[1] <= 61";
    },
);

enum(
    'TruncationLevel',
    values => [
        qw(
            year
            quarter
            month
            day hour
            minute
            second
            nanosecond
            week
            local_week
            )
    ],
);

declare(
    'Year',
    parent => t('Int'),
);

1;

# ABSTRACT: Types used for parameter checking in DateTime

__END__

=pod

=for Pod::Coverage .*

=head1 DESCRIPTION

This module has no user-facing parts.

=cut
