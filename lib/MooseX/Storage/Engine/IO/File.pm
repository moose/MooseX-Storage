package MooseX::Storage::Engine::IO::File;
# ABSTRACT: The actual file storage mechanism.

our $VERSION = '0.51';

use Moose;
use IO::File;
use Carp 'confess';
use namespace::autoclean;

has 'file' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub load {
    my ($self) = @_;
    my $fh = IO::File->new($self->file, 'r')
        || confess "Unable to open file (" . $self->file . ") for loading : $!";
    return do { local $/; <$fh>; };
}

sub store {
    my ($self, $data) = @_;
    my $fh = IO::File->new($self->file, 'w')
        || confess "Unable to open file (" . $self->file . ") for storing : $!";

    # TODO ugh! this is surely wrong and should be fixed.
    $fh->binmode(':utf8') if utf8::is_utf8($data);
    print $fh $data;
}

1;

__END__

=pod

=head1 DESCRIPTION

This provides the actual means to store data to a file.

=head1 METHODS

=over 4

=item B<file>

=item B<load>

=item B<store ($data)>

=back

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
