
package MooseX::Storage::IO::File;
use Moose::Role;

use MooseX::Storage::IO::File;

sub load {
    my ( $class, $filename ) = @_;
    $class->thaw( MooseX::Storage::IO::File->new( file => $filename )->load() );
}

sub store {
    my ( $self, $filename ) = @_;
    MooseX::Storage::IO::File->new( file => $filename )->store( $self->freeze() );
}

1;

__END__

=pod

=cut

