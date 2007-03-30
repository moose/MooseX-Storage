
package MooseX::Storage::IO::File;
use Moose::Role;

use MooseX::Storage::Engine::IO::File;

requires 'thaw';
requires 'freeze';

sub load {
    my ( $class, $filename ) = @_;
    $class->thaw( MooseX::Storage::Engine::IO::File->new( file => $filename )->load() );
}

sub store {
    my ( $self, $filename ) = @_;
    MooseX::Storage::Engine::IO::File->new( file => $filename )->store( $self->freeze() );
}

1;

__END__

=pod

=cut

