# NAME

MooseX::Storage - A serialization framework for Moose classes

# VERSION

version 0.46

# SYNOPSIS

    package Point;
    use Moose;
    use MooseX::Storage;

    with Storage('format' => 'JSON', 'io' => 'File');

    has 'x' => (is => 'rw', isa => 'Int');
    has 'y' => (is => 'rw', isa => 'Int');

    1;

    my $p = Point->new(x => 10, y => 10);

    ## methods to pack/unpack an
    ## object in perl data structures

    # pack the class into a hash
    $p->pack(); # { __CLASS__ => 'Point-0.01', x => 10, y => 10 }

    # unpack the hash into a class
    my $p2 = Point->unpack({ __CLASS__ => 'Point-0.01', x => 10, y => 10 });

    ## methods to freeze/thaw into
    ## a specified serialization format
    ## (in this case JSON)

    # pack the class into a JSON string
    $p->freeze(); # { "__CLASS__" : "Point-0.01", "x" : 10, "y" : 10 }

    # unpack the JSON string into a class
    my $p2 = Point->thaw('{ "__CLASS__" : "Point-0.01", "x" : 10, "y" : 10 }');

    ## methods to load/store a class
    ## on the file system

    $p->store('my_point.json');

    my $p2 = Point->load('my_point.json');

# DESCRIPTION

MooseX::Storage is a serialization framework for Moose, it provides
a very flexible and highly pluggable way to serialize Moose classes
to a number of different formats and styles.

## Levels of Serialization

There are 3 levels to the serialization, each of which builds upon
the other and each of which can be customized to the specific needs
of your class.

- __base__

    The first (base) level is `pack` and `unpack`. In this level the
    class is serialized into a Perl HASH reference, it is tagged with the
    class name and each instance attribute is stored. Very simple.

    This level is not optional, it is the bare minimum that
    MooseX::Storage provides and all other levels build on top of this.

    See [MooseX::Storage::Basic](https://metacpan.org/pod/MooseX::Storage::Basic) for the fundamental implementation and
    options to `pack` and `unpack`

- __format__

    The second (format) level is `freeze` and `thaw`. In this level the
    output of `pack` is sent to `freeze` or the output of `thaw` is sent
    to `unpack`. This levels primary role is to convert to and from the
    specific serialization format and Perl land.

    This level is optional, if you don't want/need it, you don't have to
    have it. You can just use `pack`/`unpack` instead.

- __io__

    The third (io) level is `load` and `store`. In this level we are reading
    and writing data to file/network/database/etc.

    This level is also optional, in most cases it does require a `format` role
    to also be used, the exception being the `StorableFile` role.

## Behaviour modifiers

The serialization behaviour can be changed by supplying `traits` to either
the class or an individual attribute.

This can be done as follows:

    use MooseX::Storage;

    # adjust behaviour for the entire class
    with Storage( traits => [Trait1, Trait2,...] );

    # adjust behaviour for an attribute
    has my_attr => (
      traits => [Trait1, Trait2, ...],
      ...
    );

The following __class traits__ are currently bundled with [MooseX::Storage](https://metacpan.org/pod/MooseX::Storage):

- OnlyWhenBuilt

    Only attributes that have been built (i.e., where the predicate returns
    'true') will be serialized. This avoids any potentially expensive computations.

    See [MooseX::Storage::Traits::OnlyWhenBuilt](https://metacpan.org/pod/MooseX::Storage::Traits::OnlyWhenBuilt) for details.

- DisableCycleDetection

    Disables the default checks for circular references, which is necessary if you
    use such references in your serialisable objects.

    See [MooseX::Storage::Traits::DisableCycleDetection](https://metacpan.org/pod/MooseX::Storage::Traits::DisableCycleDetection) for details.

The following __attribute traits__ are currently bundled with [MooseX::Storage](https://metacpan.org/pod/MooseX::Storage):

- DoNotSerialize

    Skip serialization entirely for this attribute.

    See [MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize](https://metacpan.org/pod/MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize) for details.

## How we serialize

There are always limits to any serialization framework, there are just
some things which are really difficult to serialize properly and some
things which cannot be serialized at all.

## What can be serialized?

Currently only numbers, string, ARRAY refs, HASH refs and other
MooseX::Storage enabled objects are supported.

With Array and Hash references the first level down is inspected and
any objects found are serialized/deserialized for you. We do not do
this recursively by default, however this feature may become an
option eventually.

The specific serialize/deserialize routine is determined by the
Moose type constraint a specific attribute has. In most cases subtypes
of the supported types are handled correctly, and there is a facility
for adding handlers for custom types as well. This will get documented
eventually, but it is currently still in development.

## What can not be serialized?

We do not support CODE references yet, but this support might be added
in using B::Deparse or some other deep magic.

Scalar refs are not supported, mostly because there is no way to know
if the value being referenced will be there when the object is inflated.
I highly doubt will be ever support this in a general sense, but it
would be possible to add this yourself for a small specific case.

Circular references are specifically disallowed, however if you break
the cycles yourself then re-assemble them later you can get around this.
The reason we disallow circular refs is because they are not always supported
in all formats we use, and they tend to be very tricky to do for all
possible cases. It is almost always something you want to have tight control
over anyway.

# CAVEAT

This is __not__ a persistence framework; changes to your object after
you load or store it will not be reflected in the stored class.

# EXPORTS

- __Storage (%options)__

    This module will export the `Storage` method and can be used to
    load a specific set of MooseX::Storage roles to implement a specific
    combination of features. It is meant to make things easier, but it
    is by no means the only way. You can still compose your roles by
    hand if you like.

    By default, options are assumed to be short forms.  For example, this:

        Storage(format => 'JSON');

    ...will result in looking for MooseX::Storage::Format::JSON.  To use a role
    that is not under the default namespace prefix, start with an equal sign:

        Storage(format => '=My::Private::JSONFormat');

    To use a parameterized role (for which, see [MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized)) you
    can pass an arrayref of the role name (in short or long form, as above) and its
    parameters:

        Storage(format => [ JSONpm => { json_opts => { pretty => 1 } } ]);

# METHODS

- __import__

## Introspection

- __meta__

# TODO

This module needs docs and probably a Cookbook of some kind as well.
This is an early release, so that is my excuse for now :)

For the time being, please read the tests and feel free to email me
if you have any questions. This module can also be discussed on IRC
in the #moose channel on irc.perl.org.

# BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

# AUTHORS

- Chris Prather <chris.prather@iinteractive.com>
- Stevan Little <stevan.little@iinteractive.com>
- יובל קוג'מן (Yuval Kogman) <nothingmuch@woobling.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2007 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Chris Prather <chris@prather.org>
- Cory Watson <gphat@Crankwizzah.local>
- Dagfinn Ilmari Mannsåker <ilmari@ilmari.org>
- Dan Brook <dan@broquaint.com>
- David Golden <dagolden@cpan.org>
- David Steinbrunner <dsteinbrunner@pobox.com>
- Florian Ragwitz <rafl@debian.org>
- Johannes Plunien <plu@pqpq.de>
- Jonathan Rockway <jon@jrock.us>
- Jonathan Yu <frequency@cpan.org>
- Jos Boumans <jos@dwim.org>
- Karen Etheridge <ether@cpan.org>
- Ricardo Signes <rjbs@cpan.org>
- Robert Boone <robo4288@gmail.com>
- Shawn M Moore <sartak@gmail.com>
- Tomas Doran <bobtfish@bobtfish.net>
- Yuval Kogman <nothingmuch@woobling.org>
