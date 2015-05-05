package MooseX::Storage::Format::YAML;
# ABSTRACT: A YAML serialization role

our $VERSION = '0.51';

use Moose::Role;

# When I add YAML::LibYAML
# Tests break because tye YAML is invalid...?
# -dcp

use YAML::Any qw(Load Dump);
use namespace::autoclean;

requires 'pack';
requires 'unpack';

sub thaw {
    my ( $class, $yaml, @args ) = @_;
    $class->unpack( Load($yaml), @args );
}

sub freeze {
    my ( $self, @args ) = @_;
    Dump( $self->pack(@args) );
}

no Moose::Role;

1;

__END__

=pod

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

  with Storage('format' => 'YAML');

  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');

  1;

  my $p = Point->new(x => 10, y => 10);

  ## methods to freeze/thaw into
  ## a specified serialization format
  ## (in this case YAML)

  # pack the class into a YAML string
  $p->freeze();

  # ----
  # __CLASS__: "Point"
  # x: 10
  # y: 10

  # unpack the JSON string into a class
  my $p2 = Point->thaw(<<YAML);
  ----
  __CLASS__: "Point"
  x: 10
  y: 10
  YAML

=head1 METHODS

=over 4

=item B<freeze>

=item B<thaw ($yaml)>

=back

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please or add the bug to cpan-RT
at L<https://rt.cpan.org/Dist/Display.html?Queue=MooseX-Storage>.

=cut
