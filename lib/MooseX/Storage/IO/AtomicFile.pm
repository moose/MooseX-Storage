package MooseX::Storage::IO::AtomicFile;
# ABSTRACT: An Atomic File I/O role

our $VERSION = '0.54';

use Moose::Role;
use MooseX::Storage::Engine::IO::AtomicFile;
use namespace::autoclean;

with 'MooseX::Storage::IO::File';

sub store {
    my ( $self, $filename, @args ) = @_;
    MooseX::Storage::Engine::IO::AtomicFile->new( file => $filename )->store( $self->freeze(@args) );
}

1;

__END__

=pod

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

  with Storage('format' => 'JSON', 'io' => 'AtomicFile');

  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');

  1;

  my $p = Point->new(x => 10, y => 10);

  ## methods to load/store a class
  ## on the file system

  $p->store('my_point.json');

  my $p2 = Point->load('my_point.json');

=head1 METHODS

=over 4

=item B<load ($filename)>

=item B<store ($filename)>

=back

=cut
