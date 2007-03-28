#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

{
    package Foo;
    use Moose;
    use MooseX::Storage;
    
    with Storage('JSON');
    
    has 'number' => (is => 'ro', isa => 'Int');
    has 'string' => (is => 'ro', isa => 'Str');
    has 'float' => (is => 'ro', isa => 'Num');        
    has 'array' => (is => 'ro', isa => 'ArrayRef');
	has 'object' => (is => 'ro', isa => 'Object');    
}

my $foo = Foo->new(
    number => 10,
    string => 'foo',
    float  => 10.5,
    array => [ 1 .. 10 ],
	object => Foo->new( number => 2 ),
);

diag $foo->freeze;

