use strict;

use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'DateTime',
               VERSION_FROM => 'lib/DateTime.pm',
               AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
               ABSTRACT     => 'DateTime base objects',

               PREREQ_PM    => { 'Class::Factory::Util' => 1.3,
                                 'Date::Leapyear' => 0,
                                 'DateTime::TimeZone' => 0.06,
                                 'Params::Validate' => 0,
                                 'Test::More'  => 0,
                                 'Time::Local' => 0,
                               },
             );
