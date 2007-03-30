use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'MooseX::Storage',
    AUTHOR        => 'Chris Prather <perigrin@cpan.org>, Stevan Little <stevan@iinteractive.com>',
    VERSION_FROM  => 'lib/MooseX/Storage.pm',
    ABSTRACT_FROM => 'lib/MooseX/Storage.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More' => 0,
        'Moose'      => 0,
        'JSON::Any'  => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'MooseX-Storage-*' },
);
