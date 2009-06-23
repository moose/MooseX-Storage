#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 11;
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

{   my $foo = Foo->new;
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
}

### more involved test; required attribute that's not serialized
{   package Bar;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has foo => (
        metaclass   => 'DoNotSerialize',
        required    => 1,
        is          => 'rw',
    );
    
    has zot => (
        default     => sub { $$ },
        is          => 'rw',
    );        
}

{   my $bar = Bar->new( foo => $$ );
    
    ok( $bar,                   "New object created" );
    is( $bar->foo, $$,          "   ->foo => $$" );
    is( $bar->zot, $$,          "   ->zot => $$" );
    
    my $bpack = $bar->pack;
    is_deeply(
        $bpack,
        {   __CLASS__   => 'Bar',
            zot         => $$,
        },                      "   Packed correctly" );
        
    my $bar2 = Bar->unpack({ %$bpack, foo => $$ });
    ok( $bar2,                  "   Unpacked correctly by supplying foo => $$"); 
}        
            
        
        
    

