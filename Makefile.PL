# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'MooseX-Storage';
all_from 'lib/MooseX/Storage.pm';

# Specific dependencies
requires 'Moose' => '0.39';

# you should have at least one
# serialization format
feature 'JSON',
  -default     => 1,
  'JSON::Any'  => '1.15',
  'Test::JSON' => '0.06';

feature 'YAML',
  -default            => 1,
  'Best'              => '0.1',
  'Test::YAML::Valid' => '0';

feature 'Storable',
  -default   => 1,
  'Storable' => '0';

# and the ability to save the
# file to disk
feature 'File',
  -default   => 1,
  'IO::File' => '0.1';

build_requires 'Test::More'      => '0.42';
build_requires 'Test::Deep'      => '0';
build_requires 'Test::Exception' => '0';

no_index 'directory' => 'ex';

auto_install;
WriteAll;
