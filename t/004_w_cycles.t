#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 12;
use Test::Exception;

BEGIN {
    use_ok('MooseX::Storage');
}

=pod

This test demonstrates two things:

- cycles will not work in the default engine
- you can use a special metaclass to tell 
  MooseX::Storage to skip an attribute

=cut

{

    package Circular;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'cycle' => (is => 'rw', isa => 'Circular');
}

{
    my $circular = Circular->new;
    isa_ok($circular, 'Circular');
    
    $circular->cycle($circular);
    
    throws_ok {
        $circular->pack;
    } qr/^Basic Engine does not support cycles/, 
    '... cannot collapse a cycle with the basic engine';
}

{
    my $packed_circular = { __CLASS__ => 'Circular' };
    $packed_circular->{cycle} = $packed_circular;

    throws_ok {
        Circular->unpack($packed_circular);
    } qr/^Basic Engine does not support cycles/, 
    '... cannot expand a cycle with the basic engine';
}

{

    package Tree;
    use Moose;
    use MooseX::Storage;

    with Storage;

    has 'node' => (is => 'rw');
    
    has 'children' => (
        is      => 'ro', 
        isa     => 'ArrayRef', 
        default => sub {[]}
    );
    
    has 'parent' => (
        metaclass => 'DoNotSerialize',
        is        => 'rw', 
        isa       => 'Tree',
    );
    
    sub add_child {
        my ($self, $child) = @_;
        $child->parent($self);
        push @{$self->children} => $child;
    }
}

{
    my $t = Tree->new(node => 100);
    isa_ok($t, 'Tree');
    
    is_deeply(
        $t->pack, 
        {
            __CLASS__ => 'Tree',
            node      => 100,
            children  => [],
        },
    '... got the right packed version');
    
    my $t2 = Tree->new(node => 200);
    isa_ok($t2, 'Tree');    
    
    $t->add_child($t2);
    
    is_deeply($t->children, [ $t2 ], '... got the right children in $t');
    
    is($t2->parent, $t, '... created the cycle correctly');
    isa_ok($t2->parent, 'Tree');        
    
    is_deeply(
        $t->pack, 
        {
            __CLASS__ => 'Tree',
            node      => 100,
            children  => [
               {
                   __CLASS__ => 'Tree',
                   node      => 200,
                   children  => [],            
               } 
            ],
        },
    '... got the right packed version (with parent attribute skipped in child)');    
    
    is_deeply(
        $t2->pack, 
        {
            __CLASS__ => 'Tree',
            node      => 200,
            children  => [],            
        },
    '... got the right packed version (with parent attribute skipped)');
}


