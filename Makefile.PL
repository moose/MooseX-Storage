# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.75;
use Module::Install::AuthorRequires;
use Module::Install::AuthorTests;

# Define metadata
name 'MooseX-Storage';
all_from 'lib/MooseX/Storage.pm';

# Specific dependencies
requires 'Moose' => '0.99';
requires 'String::RewritePrefix';

author_requires 'Test::Without::Module';

# you should have at least one
# serialization format
auto_install; # Needed for features to work. RT#67170
feature 'JSON',
  -default     => 1,
  'JSON::Any'  => '1.15',
  'Test::JSON' => '0.06';

author_requires 'JSON::Any'  => '1.15';
author_requires 'Test::JSON' => '0.06';

feature 'YAML',
  -default            => 1,
  'YAML::Any'         => '0';
author_requires 'YAML::Any';

feature 'Storable',
  -default   => 1,
  'Storable' => '0';
author_requires 'Storable';

# and the ability to save the
# file to disk
feature 'File',
  -default   => 1,
  'IO::File' => '0.1';
author_requires 'IO::File' => '0.1';

author_tests 't/author';

build_requires 'Test::More'      => '0.88';
build_requires 'Test::Deep'      => '0';
build_requires 'Test::Fatal'     => '0';
build_requires 'Test::Requires'  => '0.05';

author_requires 'Digest::HMAC';
author_requires 'Digest::SHA';
author_requires 'Test::Pod' => '1.14';
author_requires 'Test::Pod::Coverage' => '1.08';

resources repository => 'git://git.moose.perl.org/MooseX-Storage.git';

WriteAll;

