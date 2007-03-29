
package MooseX::Storage::JSON;
use Moose::Role;

with 'MooseX::Storage::Base';

use JSON::Syck ();
use MooseX::Storage::Engine;
use MooseX::Storage::IO::File;

sub pack {
    my $self = shift;
    my $e = MooseX::Storage::Engine->new( object => $self );
    $e->collapse_object;
}

sub unpack {
    my ( $class, $data ) = @_;
    my $e = MooseX::Storage::Engine->new( class => $class );
    $class->new( $e->expand_object($data) );
}

sub load {
    my ( $class, $filename ) = @_;
    $class->unpack(
        $class->thaw( MooseX::Storage::IO->new( file => $filename )->load() )
    );
}

sub store {
    my ( $self, $filename ) = @_;
    MooseX::Storage::IO->new( file => $filename )->store( $self->freeze() );
}

sub thaw {
    my ( $class, $json ) = @_;
    $class->unpack( JSON::Syck::Load($json) );
}

sub freeze {
    my $self = shift;
    JSON::Syck::Dump( $self->pack() );
}

1;

__END__

=pod

=cut

