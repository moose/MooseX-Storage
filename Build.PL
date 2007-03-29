use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MooseX::Storage',
    license             => 'perl',
    dist_author         => 'Chris Prather <perigrin@cpan.org>',
    dist_version_from   => 'lib/MooseX/Storage.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'MooseX-Storage-JSON-*' ],
);

$builder->create_build_script();
