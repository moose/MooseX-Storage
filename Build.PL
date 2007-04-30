use Module::Build;

use strict;

my $build = Module::Build->new(
    module_name => 'MooseX::Storage',
    license => 'perl',
    requires => {   
        'Moose'        => '0.20',
        # you should have at least one 
        # serialization format
        'JSON::Any'    => '0',
        'Best'         => '0', # << this if for loading YAML
        # and the ability to save the 
        # file to disk        
        'IO::File'     => '0',        
    },
    optional => {
        'IO::AtomicFile'    => '0',  
        # these are only used in the 
        # test, I recommend them, but 
        # there is no need to force 
        # them on people :)
        'Test::YAML::Valid' => '0',
        'Test::JSON'        => '0',        
    },
    build_requires => {
        'Test::More'       => '0.62',
        'Test::Exception'  => '0.21',
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;

