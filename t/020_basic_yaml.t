#!/usr/bin/perl
$|++;
use strict;
use warnings;

use Test::More;

BEGIN {
    eval "use Test::YAML::Valid";
    plan skip_all => "Test::YAML::Valid is required for this test" if $@;            
    eval "use Best [[qw(YAML::Syck YAML)]]";
    plan skip_all => "YAML or YAML::syck and Best are required for this test" if $@;            
    plan tests => 12;
    use_ok('MooseX::Storage');
}

{

    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage( 'format' => 'YAML' );

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

    my $yaml = $foo->freeze;

    yaml_string_ok( $yaml, '... we got valid YAML out of it' );

    is(
        $yaml,
        q{--- 
__CLASS__: Foo
array: 
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
  - 10
float: 10.5
hash: 
  1: ~
  10: ~
  2: ~
  3: ~
  4: ~
  5: ~
  6: ~
  7: ~
  8: ~
  9: ~
number: 10
object: 
  __CLASS__: Foo
  number: 2
string: foo
},
        '... got the same YAML'
    );

}

{
    my $foo = Foo->thaw(
        q{--- 
__CLASS__: Foo
array: 
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
  - 10
float: 10.5
hash: 
  1: ~
  10: ~
  2: ~
  3: ~
  4: ~
  5: ~
  6: ~
  7: ~
  8: ~
  9: ~
number: 10
object: 
  __CLASS__: Foo
  number: 2
string: foo
}
    );
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

