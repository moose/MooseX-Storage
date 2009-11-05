#!/usr/bin/perl
$|++;
use strict;
use warnings;

use Test::More tests => 11;
use Storable;

BEGIN {
    use_ok('MooseX::Storage');
}

{

    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage( 'format' => 'Storable' );

    has 'number' => ( is => 'ro', isa => 'Int' );
    has 'string' => ( is => 'ro', isa => 'Str' );
    has 'float'  => ( is => 'ro', isa => 'Num' );
    has 'array'  => ( is => 'ro', isa => 'ArrayRef' );
    has 'hash'   => ( is => 'ro', isa => 'HashRef' );
    has 'object' => ( is => 'ro', isa => 'Object' );
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

    my $stored = $foo->freeze;

    my $struct = Storable::thaw($stored);
    is_deeply(
        $struct,
        {
            '__CLASS__' => 'Foo',
            'float'     => 10.5,
            'number'    => 10,
            'string'    => 'foo',
            'array'     => [ 1 .. 10],
            'hash'      => { map { $_ => undef } 1 .. 10 },
            'object'    => {
                '__CLASS__' => 'Foo',
                'number' => 2
            },
        },
        '... got the data struct we expected'
    );
}

{
    my $stored = Storable::nfreeze({
        '__CLASS__' => 'Foo',
        'float'     => 10.5,
        'number'    => 10,
        'string'    => 'foo',
        'array'     => [ 1 .. 10],
        'hash'      => { map { $_ => undef } 1 .. 10 },
        'object'    => {
            '__CLASS__' => 'Foo',
            'number' => 2
        },
    });

    my $foo = Foo->thaw($stored);
    isa_ok( $foo, 'Foo' );

    is( $foo->number, 10,    '... got the right number' );
    is( $foo->string, 'foo', '... got the right string' );
    is( $foo->float,  10.5,  '... got the right float' );
    is_deeply( $foo->array, [ 1 .. 10 ], '... got the right array' );
    is_deeply(
        $foo->hash,
        { map { $_ => undef } ( 1 .. 10 ) },
        '... got the right hash'
    );

    isa_ok( $foo->object, 'Foo' );
    is( $foo->object->number, 2,
        '... got the right number (in the embedded object)' );
}

