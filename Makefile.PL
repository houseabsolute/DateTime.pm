use strict;

use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'DateTime',
               VERSION_FROM => 'lib/DateTime.pm',
               AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
               ABSTRACT     => 'DateTime base objects',

               PREREQ_PM    => { 'Class::Factory::Util' => 1.2,
                                 'Date::Leapyear' => 0,
                                 'DateTime::TimeZone' => 0.05,
                                 'Params::Validate' => 0,
                                 'Test::More'  => 0,
                                 'Time::Local' => 0,
                               },
             );
