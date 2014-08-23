use strict;
use warnings;

use Test::More;

# NOTE:
# this is because JSON::XS (and Cpanel::JSON::XS) is
# the only one which really gets utf8 correct
# - SL
BEGIN {
    $ENV{JSON_ANY_ORDER}  = 'XS CPANEL';
    $ENV{JSON_ANY_CONFIG} = "utf8=0,canonical=1";
}

use Test::Requires qw(
    Encode
    JSON::Any
);
diag 'using JSON backend: ', JSON::Any->handlerType;

binmode $_, ':utf8' foreach map { Test::Builder->new->$_ } qw(output failure_output todo_output);
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

plan tests => 16;
use_ok('MooseX::Storage');

{
    package Foo;
    use Moose;
    use MooseX::Storage;

    with Storage( 'format' => 'JSON' );

    has 'utf8_string' => (
        is      => 'rw',
        isa     => 'Str',
        default => sub { "ネットスーパー (Internet Shopping)" }
    );
}

{
    my $foo = Foo->new;
    isa_ok( $foo, 'Foo' );

    my $json = $foo->freeze;

    is($json,
       '{"__CLASS__":"Foo","utf8_string":"ネットスーパー (Internet Shopping)"}',
       '... got the right JSON');

    my $foo2 = Foo->thaw($json);
    isa_ok( $foo, 'Foo' );

    is($foo2->utf8_string,
      "ネットスーパー (Internet Shopping)",
      '... got the string we expected');

    is($foo2->freeze,
       '{"__CLASS__":"Foo","utf8_string":"ネットスーパー (Internet Shopping)"}',
       '... got the right JSON');
}

{
    my $test_string;
    {
        use utf8;
        $test_string = "ネットスーパー (Internet Shopping)";
        no utf8;
    }

    ok(utf8::is_utf8($test_string), '... got a utf8 string');
    ok(utf8::valid($test_string), '... got a valid utf8 string');

    Encode::_utf8_off($test_string);

    ok(!utf8::is_utf8($test_string), '... no longer is utf8 string');
    ok(utf8::valid($test_string), '... got a valid utf8 string');

    my $foo = Foo->new(
        utf8_string => $test_string
    );
    isa_ok( $foo, 'Foo' );

    ok(!utf8::is_utf8($foo->utf8_string), '... not a utf8 string');
    ok(utf8::valid($foo->utf8_string), '... but is a valid utf8 string');

    my $json = $foo->freeze;

    ok(utf8::is_utf8($json), '... is a utf8 string now');
    ok(utf8::valid($json), '... got a valid utf8 string');

    is($json,
       '{"__CLASS__":"Foo","utf8_string":"ネットスーパー (Internet Shopping)"}',
       '... got the right JSON');
}
