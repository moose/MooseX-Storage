#!perl

use Test::More;
eval "use Test::Pod 1.14";
plan skip_all => "set env var RELEASE_TESTING=1 to run these"
  unless $ENV{RELEASE_TESTING};
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
