#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 11;
use Storable ();

BEGIN {
    use_ok('MooseX::Storage');
}

{
    package Foo;
    use Moose;
    use MooseX::Storage;
    
    with Storage(io => 'StorableFile');
    
    has 'number' => (is => 'ro', isa => 'Int');
    has 'string' => (is => 'rw', isa => 'Str');
    has 'float'  => (is => 'ro', isa => 'Num');        
    has 'array'  => (is => 'ro', isa => 'ArrayRef');
    has 'hash'   => (is => 'ro', isa => 'HashRef');    
	has 'object' => (is => 'ro', isa => 'Object');    
	
	## add some custom freeze/thaw hooks here ...
	
    sub thaw {
        my ( $class, $data ) = @_;
        my $self = $class->unpack( $data );
        $self->string("Hello World");
        $self;
    }

    sub freeze {
        my ( $self, @args ) = @_;
        my $data = $self->pack(@args);
        $data->{string} = "HELLO WORLD";
        $data;
    }

}

my $file = 'temp.storable';

{
    my $foo = Foo->new(
        number => 10,
        string => 'foo',
        float  => 10.5,
        array  => [ 1 .. 10 ],
        hash   => { map { $_ => undef } (1 .. 10) },
    	object => Foo->new( number => 2 ),
    );
    isa_ok($foo, 'Foo');

    $foo->store($file);
    
    # check our custom freeze hook fired ...
    my $data = Storable::retrieve($file);
    is_deeply(
        $data,
        {
            '__CLASS__' => 'Foo',
            'float'     => 10.5,
            'number'    => 10,
            'string'    => 'HELLO WORLD',           
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
    my $foo = Foo->load($file);
    isa_ok($foo, 'Foo');

    ## check our custom thaw hook fired
    is($foo->string, 'Hello World', '... got the right string');

    is($foo->number, 10, '... got the right number');
    is($foo->float, 10.5, '... got the right float');
    is_deeply($foo->array, [ 1 .. 10], '... got the right array');
    is_deeply($foo->hash, { map { $_ => undef } (1 .. 10) }, '... got the right hash');

    isa_ok($foo->object, 'Foo');
    is($foo->object->number, 2, '... got the right number (in the embedded object)');
}

unlink $file;
