use strict;

use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'DateTime',
               VERSION_FROM => 'lib/DateTime.pm',
               AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
               ABSTRACT     => 'DateTime base objects',

               PREREQ_PM    => { 'Time::Local' => 0,
                                 'Date::Leapyear' => 0,
                                 'Test::More'  => 0,
                               },
             );
