#!perl
use Test::More;

plan skip_all => "set env var RELEASE_TESTING=1 to run these"
  unless $ENV{RELEASE_TESTING};

eval "use Test::Pod::Coverage 1.08";
warn $@ if $@;
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

my @modules = grep { ! /::Traits?::/ } all_modules();

plan tests => scalar(@modules);

foreach my $module (@modules) {
    pod_coverage_ok($module);
}

