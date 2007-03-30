#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('MooseX::Storage');
}

{
    package Bar;
    use Moose;
    use MooseX::Storage;

    with Storage;
    
    has 'baz' => (is => 'ro', isa => 'Int');
    
    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage;    

    has 'bars' => ( 
        is  => 'ro', 
        isa => 'ArrayRef' 
    );
}

{
    my $foo = Foo->new(
        bars => [ map { Bar->new(baz => $_) } (1 .. 10) ]
    );
    isa_ok( $foo, 'Foo' );
    
    is_deeply(
        $foo->pack,
        {
            __class__ => 'Foo',
            bars      => [ 
                map {
                  {
                      __class__ => 'Bar',
                      baz       => $_,
                  }  
                } (1 .. 10)
            ],           
        },
        '... got the right frozen class'
    );
}

{
    my $foo = Foo->unpack(
        {
            __class__ => 'Foo',
            bars      => [ 
                map {
                  {
                      __class__ => 'Bar',
                      baz       => $_,
                  }  
                } (1 .. 10)
            ],           
        }      
    );
    isa_ok( $foo, 'Foo' );

    foreach my $i (1 .. scalar @{$foo->bars}) {
        isa_ok($foo->bars->[$i - 1], 'Bar');
        is($foo->bars->[$i - 1]->baz, $i, "... got the right baz ($i) in the Bar in Foo");
    }
}
