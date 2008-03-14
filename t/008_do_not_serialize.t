#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
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


