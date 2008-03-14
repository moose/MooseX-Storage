#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 6;
use Test::Exception;

BEGIN {
    use_ok('MooseX::Storage');
}

{
    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'bar' => (
        metaclass => 'DoNotSerialize',
        is        => 'rw',
        default   => sub { 'BAR' }        
    );
    
    has 'baz' => (
        traits  => [ 'DoNotSerialize' ],
        is      => 'rw',
        default => sub { 'BAZ' }        
    );    
    
    has 'gorch' => (
        is      => 'rw', 
        default => sub { 'GORCH' }
    );    

    1;
}

my $foo = Foo->new;
isa_ok($foo, 'Foo');

is($foo->bar, 'BAR', '... got the value we expected');
is($foo->baz, 'BAZ', '... got the value we expected');
is($foo->gorch, 'GORCH', '... got the value we expected');

is_deeply(
    $foo->pack,
    {
        __CLASS__ => 'Foo',
        gorch     => 'GORCH'
    },
    '... got the right packed class data'
);




