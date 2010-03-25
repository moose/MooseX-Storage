use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN {
    eval { require JSON::Any } or do {
        plan skip_all => "JSON::Any is required for this test";
        exit 0;
    }
}

{
    package Thing;
    use Moose;
    use MooseX::Storage;

    use overload
        q{""}    => 'as_string',
        fallback => 1;

    with Storage('format' => 'JSON');

    has foo => ( is => 'ro' );

    sub as_string { shift->freeze }

    no Moose;
}

my $i = Thing->new(foo => "bar");

lives_ok {
    $i . "";
} 'Can stringify without deep recursion';

done_testing;

