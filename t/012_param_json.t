#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {        
    local $@;
    plan skip_all => "MooseX::Storage::Format::JSONpm required for this test"
        unless eval "require MooseX::Storage::Format::JSONpm; 1";
}

plan tests => 3;
use_ok('MooseX::Storage');

{

    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage(format => [ JSONpm => { json_opts => { pretty => 1 } } ] );
    # with Storage(format => 'JSONpm');

    has 'string' => ( is => 'ro', isa => 'Str' );
    has 'float'  => ( is => 'ro', isa => 'Num' );
}

{
    my $foo = Foo->new(
        string => 'foo',
        float  => 10.5,
    );
    isa_ok( $foo, 'Foo' );

    my $json = $foo->freeze;

    isnt(
        index($json, "\n"),
        -1,
        "there are newlines in our JSON, because it is pretty",
    ) or diag $json;

}

