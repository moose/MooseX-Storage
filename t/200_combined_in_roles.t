#/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;
use Test::Exception;

{
    package ClassOne;
    use Moose::Role;
    use MooseX::Storage;
}
{
    package ClassTwo;
    use Moose::Role;
    use MooseX::Storage;
}

lives_ok {
    package CombineClasses;
    use Moose;
    with qw/ClassOne ClassTwo/;
} 'Can include two roles which both use MooseX::Storage';

