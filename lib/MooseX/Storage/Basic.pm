
package MooseX::Storage::Basic;
use Moose::Role;

use MooseX::Storage::Engine;

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

1;

__END__

=pod

=head1 NAME

MooseX::Storage::Basic

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<pack>

=item B<unpack ($data)>

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

Chris Prather E<lt>chris.prather@iinteractive.comE<gt>

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
