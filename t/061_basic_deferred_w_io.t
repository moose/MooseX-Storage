use strict;
use warnings;

use Test::More;
use Test::Deep;
use File::Temp qw(tempdir);
use File::Spec::Functions;

my $dir = tempdir;

use Test::Needs qw(
    IO::AtomicFile
    JSON::MaybeXS
);
diag 'using JSON backend: ', JSON::MaybeXS->JSON;

plan tests => 23;

{
    package Foo;
    use Moose;
    use MooseX::Storage;

    with 'MooseX::Storage::Deferred';

    has 'unset'  => ( is => 'ro', isa => 'Any' );
    has 'undef'  => ( is => 'ro', isa => 'Any' );
    has 'number' => (is => 'ro', isa => 'Int');
    has 'string' => (is => 'ro', isa => 'Str');
    has 'float'  => (is => 'ro', isa => 'Num');
    has 'array'  => (is => 'ro', isa => 'ArrayRef');
    has 'hash'   => (is => 'ro', isa => 'HashRef');
    has 'object' => (is => 'ro', isa => 'Object');
}

my $file = catfile($dir, 'temp.json');

{
    my $foo = Foo->new(
        undef  => undef,
        number => 10,
        string => 'foo',
        float  => 10.5,
        array  => [ 1 .. 10 ],
        hash   => { map { $_ => undef } (1 .. 10) },
        object => Foo->new( number => 2 ),
    );
    isa_ok($foo, 'Foo');

    $foo->store($file, { format => 'JSON', io => 'File' });
}

{
    my $foo = Foo->load($file, { format => 'JSON', io => 'File' });
    isa_ok($foo, 'Foo');

    is($foo->number, 10, '... got the right number');
    is($foo->string, 'foo', '... got the right string');
    is($foo->float, 10.5, '... got the right float');
    cmp_deeply($foo->array, [ 1 .. 10], '... got the right array');
    cmp_deeply($foo->hash, { map { $_ => undef } (1 .. 10) }, '... got the right hash');

    isa_ok($foo->object, 'Foo');
    is($foo->object->number, 2, '... got the right number (in the embedded object)');
}

unlink $file;
ok(!(-e $file), '... the file has been deleted');

{
    my $foo = Foo->new(
        undef  => undef,
        number => 10,
        string => 'foo',
        float  => 10.5,
        array  => [ 1 .. 10 ],
        hash   => { map { $_ => undef } (1 .. 10) },
        object => Foo->new( number => 2 ),
    );
    isa_ok($foo, 'Foo');

    $foo->store($file, { format => 'JSON', io => 'AtomicFile' });
}

{
    my $foo = Foo->load($file, { format => 'JSON', io => 'AtomicFile' });
    isa_ok($foo, 'Foo');

    is( $foo->unset, undef,  '... got the right unset value');
    ok(!$foo->meta->get_attribute('unset')->has_value($foo), 'unset attribute has no value');
    is( $foo->undef, undef,  '... got the right undef value');
    ok( $foo->meta->get_attribute('undef')->has_value($foo), 'undef attribute has a value');
    is($foo->number, 10, '... got the right number');
    is($foo->string, 'foo', '... got the right string');
    is($foo->float, 10.5, '... got the right float');
    cmp_deeply($foo->array, [ 1 .. 10], '... got the right array');
    cmp_deeply($foo->hash, { map { $_ => undef } (1 .. 10) }, '... got the right hash');

    isa_ok($foo->object, 'Foo');
    is($foo->object->number, 2, '... got the right number (in the embedded object)');
}
