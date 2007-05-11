
package MooseX::Storage::Base::WithChecksum;
use Moose::Role;

use Digest ();
use Storable ();
use MooseX::Storage::Engine;

our $VERSION = '0.01';

our $DIGEST_MARKER = '__DIGEST__';

sub pack {
    my ($self, @args ) = @_;

    my $e = MooseX::Storage::Engine->new( object => $self );

    my $collapsed = $e->collapse_object;
    
    $collapsed->{$DIGEST_MARKER} = $self->_digest_packed($collapsed, @args);
    
    return $collapsed;
}

sub unpack {
    my ($class, $data, @args) = @_;

    # check checksum on data
    
    my $old_checksum = $data->{$DIGEST_MARKER};
    delete $data->{$DIGEST_MARKER};
    
    my $checksum = $class->_digest_packed($data, @args);

    ($checksum eq $old_checksum)
        || confess "Bad Checksum got=($checksum) expected=($old_checksum)";    

    my $e = MooseX::Storage::Engine->new(class => $class);
    $class->new($e->expand_object($data));
}


sub _digest_packed {
    my ( $self, $collapsed, @args ) = @_;

    my $d = shift @args;

    if ( ref $d ) {
        if ( $d->can("clone") ) {
            $d = $d->clone;
        } elsif ( $d->can("reset") ) {
            $d->reset;
        } else {
            die "Can't clone or reset digest object: $d";
        }
    } else {
        $d = Digest->new($d || "SHA1", @args);
    }

    {
        local $Storable::canonical = 1;
        $d->add( Storable::nfreeze($collapsed) );
    }

    return $d->hexdigest;
}


1;

__END__

=pod

=head1 NAME

MooseX::Storage::Base::WithChecksum

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<pack (?$salt)>

=item B<unpack ($data, ?$salt)>

=back

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
