package MooseX::Storage::Deferred;
use Moose::Role;

our $VERSION   = '0.03';
our $AUTHORITY = 'cpan:STEVAN';

with 'MooseX::Storage::Basic';

sub thaw {
    my ( $class, $packed, $type, @args ) = @_;

    (exists $type->{format})
        || confess "You must specify a format type to thaw from";

    my $class_to_load = 'MooseX::Storage::Format::' . $type->{format};
    Class::MOP::load_class($class_to_load);

    my $method_to_call = $class_to_load . '::thaw';

    $class->$method_to_call($packed, @args);
}

sub freeze {
    my ( $self, $type, @args ) = @_;

    (exists $type->{format})
        || confess "You must specify a format type to freeze into";

    my $class_to_load = 'MooseX::Storage::Format::' . $type->{format};
    Class::MOP::load_class($class_to_load);

    my $method_to_call = $class_to_load . '::freeze';

    $self->$method_to_call(@args);
}

sub load {
    my ( $class, $filename, $type, @args ) = @_;

    (exists $type->{io})
        || confess "You must specify an I/O type to load with";

    my $class_to_load = 'MooseX::Storage::IO::' . $type->{io};
    Class::MOP::load_class($class_to_load);

    my $method_to_call = $class_to_load . '::load';

    $class->$method_to_call($filename, $type, @args);
}

sub store {
    my ( $self, $filename, $type, @args ) = @_;

    (exists $type->{io})
        || confess "You must specify an I/O type to store with";

    my $class_to_load = 'MooseX::Storage::IO::' . $type->{io};
    Class::MOP::load_class($class_to_load);

    my $method_to_call = $class_to_load . '::store';

    $self->$method_to_call($filename, $type, @args);
}

1;

__END__

=pod

=head1 NAME

MooseX::Storage::Deferred - A role for undecisive programmers

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

  our $VERSION = '0.01';

  with 'MooseX::Storage::Deferred';

  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');

  1;

  my $p = Point->new(x => 10, y => 10);

  ## methods to freeze/thaw into
  ## a specified serialization format
  ## (in this case JSON)

  # pack the class into a JSON string
  $p->freeze({ format => 'JSON' }); # { "__CLASS__" : "Point", "x" : 10, "y" : 10 }

  # unpack the JSON string into a class
  my $p2 = Point->thaw(
      '{ "__CLASS__" : "Point", "x" : 10, "y" : 10 }',
      { format => 'JSON' }
  );

=head1 DESCRIPTION

This role is designed for those times when you need to
serialize into many different formats or I/O options.

It basically allows you to choose the format and IO
options only when you actually use them (see the
SYNOPSIS for more info)

=head1 SUPPORTED FORMATS

=over 4

=item I<JSON>

=item I<YAML>

=item I<Storable>

=back

=head1 SUPPORTED I/O

=over 4

=item I<File>

=item I<AtomicFile>

=back

B<NOTE:> The B<StorableFile> I/O option is not supported, 
this is because it does not mix well with options who also 
have a C<thaw> and C<freeze> methods like this. It is possible
to probably work around this issue, but I don't currently 
have the need for it. If you need this supported, talk to me
and I will see what I can do. 

=head1 METHODS

=over 4

=item B<freeze ($type_desc)>

=item B<thaw ($data, $type_desc)>

=item B<load ($filename, $type_desc)>

=item B<store ($filename, $type_desc)>

=back

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
