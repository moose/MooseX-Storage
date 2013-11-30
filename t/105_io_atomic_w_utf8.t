use strict;
use warnings;

use Test::More;
use File::Temp qw(tempdir);
use File::Spec::Functions;
my $dir = tempdir;

# NOTE:
# this is because JSON::XS (and Cpanel::JSON::XS) is
# the only one which really gets utf8 correct
# - SL
BEGIN {
    $ENV{JSON_ANY_ORDER}  = 'XS CPANEL';
    $ENV{JSON_ANY_CONFIG} = "utf8=0,canonical=1";
}

use Test::Requires qw(
    JSON::Any
    IO::AtomicFile
);

plan tests => 8;
use_ok('MooseX::Storage');

use utf8;

{
    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage( 'format' => 'JSON', 'io' => 'AtomicFile' );

    has 'utf8_string' => (
        is      => 'rw',
        isa     => 'Str',
        default => sub { "ネットスーパー (Internet Shopping)" }
    );
}

my $file = catfile($dir, 'temp.json');

{
    my $foo = Foo->new;
    isa_ok( $foo, 'Foo' );

    $foo->store($file);
}

{
    my $foo = Foo->load($file);
    isa_ok($foo, 'Foo');

    is($foo->utf8_string,
      "ネットスーパー (Internet Shopping)",
      '... got the string we expected');
}

no utf8;

unlink $file;

{
    my $foo = Foo->new(
        utf8_string => 'Escritório'
    );
    isa_ok( $foo, 'Foo' );

    $foo->store($file);
}

{
    my $foo = Foo->load($file);
    isa_ok($foo, 'Foo');

    ok(utf8::is_utf8($foo->utf8_string), '... the string is still utf8');

    is($foo->utf8_string,
      "Escritório",
      '... got the string we expected');
}

