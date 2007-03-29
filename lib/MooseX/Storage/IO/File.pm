
package MooseX::Storage::IO::File;
use Moose;

has file => (
	isa => 'Str',
	is  => 'ro',
	required => 1,
);

sub load { 
	my ($self) = @_;
	my $fh = IO::File->new($self->file, 'r');
	return do { local $/; <$fh>; };
}

sub store {
	my ($self, $data) = @_;
	my $fh = IO::File->new($self->file, 'w');
	print $fh $data;
}