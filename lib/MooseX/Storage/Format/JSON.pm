
package MooseX::Storage::Format::JSON;
use Moose::Role;

use JSON::Syck ();

requires 'pack';
requires 'unpack';

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

