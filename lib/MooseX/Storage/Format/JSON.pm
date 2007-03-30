
package MooseX::Storage::Format::JSON;
use Moose::Role;

use JSON::Any;

requires 'pack';
requires 'unpack';

sub thaw {
    my ( $class, $json ) = @_;
    $class->unpack( JSON::Any->jsonToObj($json) );
}

sub freeze {
    my $self = shift;
    JSON::Any->objToJson( $self->pack() );
}

1;

__END__

=pod

=cut

