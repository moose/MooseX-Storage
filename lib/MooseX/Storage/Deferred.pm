package MooseX::Storage::Deferred;
# ABSTRACT: A role for indecisive programmers

our $VERSION = '0.53';

use Moose::Role;
with 'MooseX::Storage::Basic';
use Carp 'confess';
use namespace::autoclean;

sub __get_method {
    my ( $self, $basename, $value, $method_name ) = @_;

    my $role   = MooseX::Storage->_expand_role($basename => $value)->meta;
    my $method = $role->get_method($method_name)->body;
}

sub thaw {
    my ( $class, $packed, $type, @args ) = @_;

    (exists $type->{format})
        || confess "You must specify a format type to thaw from";

    my $code = $class->__get_method(Format => $type->{format} => 'thaw');

    $class->$code($packed, @args);
}

sub freeze {
    my ( $self, $type, @args ) = @_;

    (exists $type->{format})
        || confess "You must specify a format type to freeze into";

    my $code = $self->__get_method(Format => $type->{format} => 'freeze');

    $self->$code(@args);
}

sub load {
    my ( $class, $filename, $type, @args ) = @_;

    (exists $type->{io})
        || confess "You must specify an I/O type to load with";

    my $code = $class->__get_method(IO => $type->{io} => 'load');

    $class->$code($filename, $type, @args);
}

sub store {
    my ( $self, $filename, $type, @args ) = @_;

    (exists $type->{io})
        || confess "You must specify an I/O type to store with";

    my $code = $self->__get_method(IO => $type->{io} => 'store');

    $self->$code($filename, $type, @args);
}

1;

__END__

=pod

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

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

  # pack the class into a JSON string using parameterized JSONpm role
  $p->freeze({ format => [ JSONpm => { json_opts => { pretty => 1 } } ] });

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

=for stopwords JSONpm

=item I<JSONpm>

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

=cut
