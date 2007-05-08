
package MooseX::Storage::Base::WithChecksum;
use Moose::Role;

use Digest::MD5  ('md5_hex');
use Data::Dumper ();
use MooseX::Storage::Engine;

our $VERSION = '0.01';

sub pack {
    my ($self, $salt) = @_;
    my $e = MooseX::Storage::Engine->new( object => $self );
    my $collapsed = $e->collapse_object;
    
    # create checksum
    
    local $Data::Dumper::Sortkeys = 1;
    my $dumped = Data::Dumper::Dumper($collapsed);

    #warn $dumped;
    
    $salt ||= $dumped;
    
    $collapsed->{checksum} = md5_hex($dumped, $salt);
    
    return $collapsed;
}

sub unpack {
    my ($class, $data, $salt) = @_;

    # check checksum on data
    
    my $old_checksum = $data->{checksum};
    delete $data->{checksum};
    
    local $Data::Dumper::Sortkeys = 1;
    my $dumped = Data::Dumper::Dumper($data);
    
    #warn $dumped;
    
    $salt ||= $dumped;
    
    my $checksum = md5_hex($dumped, $salt);
    
    ($checksum eq $old_checksum)
        || confess "Bad Checksum got=($checksum) expected=($data->{checksum})";    

    my $e = MooseX::Storage::Engine->new(class => $class);
    $class->new($e->expand_object($data));
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
