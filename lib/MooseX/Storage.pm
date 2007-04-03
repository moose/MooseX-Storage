
package MooseX::Storage;
use Moose qw(confess);

sub import {
    my $pkg = caller();
    
    return if $pkg eq 'main';
    
    ($pkg->can('meta'))
        || confess "This package can only be used in Moose based classes";
    
    $pkg->meta->alias_method('Storage' => sub {
        my %params = @_;
        
        $params{'base'} ||= 'Basic';
        
        my @roles = (
            ('MooseX::Storage::' . $params{'base'}),
        );
        
        # NOTE:
        # you don't have to have a format 
        # role, this just means you dont 
        # get anything other than pack/unpack
        push @roles => 'MooseX::Storage::Format::' . $params{'format'}
            if exists $params{'format'};
            
        # NOTE:
        # if you do choose an IO role, then 
        # you *must* have a format role chosen
        # since load/store require freeze/thaw
        if (exists $params{'io'}) {
            (exists $params{'format'})
                || confess "You must specify a format role in order to use an IO role";
            push @roles => 'MooseX::Storage::IO::' . $params{'io'};
        }
        
        Class::MOP::load_class($_) 
            || die "Could not load role (" . $_ . ") for package ($pkg)"
                foreach @roles;        
        
        return @roles;
    });
}

1;

__END__

=pod

=head1 NAME

MooseX::Storage - An serialization framework for Moose classes

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<import>

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
