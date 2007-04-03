#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('MooseX::Storage');
}

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



