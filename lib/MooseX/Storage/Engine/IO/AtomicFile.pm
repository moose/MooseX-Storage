package MooseX::Storage::Engine::IO::AtomicFile;
# ABSTRACT: The actually atomic file storage mechanism.
use Moose;

use IO::AtomicFile;

extends 'MooseX::Storage::Engine::IO::File';

sub store {
    my ($self, $data) = @_;
    my $fh = IO::AtomicFile->new($self->file, 'w')
        || confess "Unable to open file (" . $self->file . ") for storing : $!";
    $fh->binmode(':utf8') if utf8::is_utf8($data);
    print $fh $data;
    $fh->close()
        || confess "Could not write atomic file (" . $self->file . ") because: $!";
}

1;

__END__

=pod

=head1 DESCRIPTION

This provides the actual means to store data to a file atomically.

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
