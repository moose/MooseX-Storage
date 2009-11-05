#!perl
use Test::More;

use Test::Pod::Coverage 1.08;

my @modules = grep { ! /::Traits?::/ } all_modules();

plan tests => scalar(@modules);

foreach my $module (@modules) {
    pod_coverage_ok($module);
}

