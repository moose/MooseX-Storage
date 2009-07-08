#!perl

use Test::More;
eval "use Test::Pod::Coverage 1.08";
warn $@ if $@;
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

my @modules = grep { ! /::Traits?::/ } all_modules();

plan tests => scalar(@modules);

foreach my $module (@modules) {
    pod_coverage_ok($module);
}

