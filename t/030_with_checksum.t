#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;
use Test::Deep;

BEGIN {
    use_ok('MooseX::Storage');
}

{

    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage(base => 'WithChecksum');

    has 'number' => ( is => 'ro', isa => 'Int' );
    has 'string' => ( is => 'ro', isa => 'Str' );
    has 'float'  => ( is => 'ro', isa => 'Num' );
    has 'array'  => ( is => 'ro', isa => 'ArrayRef' );
    has 'hash'   => ( is => 'ro', isa => 'HashRef' );
    has 'object' => ( is => 'ro', isa => 'Foo' );
}

{
    my $foo = Foo->new(
        number => 10,
        string => 'foo',
        float  => 10.5,
        array  => [ 1 .. 10 ],
        hash   => { map { $_ => undef } ( 1 .. 10 ) },
        object => Foo->new( number => 2 ),
    );
    isa_ok( $foo, 'Foo' );
    
    my $packed = $foo->pack;
    
    cmp_deeply(
        $packed,
        {
            __CLASS__ => 'Foo',
            checksum  => re('[0-9a-f]+'),
            number    => 10,
            string    => 'foo',
            float     => 10.5,
            array     => [ 1 .. 10 ],
            hash      => { map { $_ => undef } ( 1 .. 10 ) },
            object    => { 
                            __CLASS__ => 'Foo', 
                            checksum  => re('[0-9a-f]+'),               
                            number    => 2 
                         },            
        },
        '... got the right frozen class'
    );

    my $foo2;
    lives_ok {
        $foo2 = Foo->unpack($packed);
    } '... unpacked okay';
    isa_ok($foo2, 'Foo');
    
    cmp_deeply(
        $foo2->pack,
        {
            __CLASS__ => 'Foo',
            checksum  => re('[0-9a-f]+'),
            number    => 10,
            string    => 'foo',
            float     => 10.5,
            array     => [ 1 .. 10 ],
            hash      => { map { $_ => undef } ( 1 .. 10 ) },
            object    => { 
                            __CLASS__ => 'Foo', 
                            checksum  => re('[0-9a-f]+'),               
                            number    => 2 
                         },            
        },
        '... got the right frozen class'
    );    
    
}

