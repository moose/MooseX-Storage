#!perl -T

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "set env var RELEASE_TESTING=1 to run these"
  unless $ENV{RELEASE_TESTING};
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
all_pod_coverage_ok();
