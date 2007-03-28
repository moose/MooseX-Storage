
package MooseX::Storage::JSON;
use Moose::Role;

with 'MooseX::Storage::Base';

use JSON::Syck;
use MooseX::Storage::Engine;

has '_storage' => (
	is => 'ro',
	isa => 'MooseX::Storage::Engine',
	default => sub {
		my $self = shift;
		warn "Building Storage Engine\n";
		MooseX::Storage::Engine->new(object => $self);
	},
	handles => {
		'pack' => 'collapse_object',
		# unpack here ...
	}
);

sub load {}
sub store {}
sub thaw {}

sub freeze {
    my $self = shift;
    JSON::Syck::Dump($self->pack());    
}


1;
__END__