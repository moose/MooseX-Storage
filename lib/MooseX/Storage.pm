
package MooseX::Storage;

sub import {
    my $pkg = caller();
    $pkg->meta->alias_method('Storage' => sub {
        my %params = @_;
        
        my @roles = (
            'MooseX::Storage::Basic'
        );
        
        push @roles => 'MooseX::Storage::Format::' . $params{'format'};
        Class::MOP::load_class($roles[-1]) 
            || die "Could not load format role (" . $roles[-1] . ") for package ($pkg)";
           
        if (exists $params{'io'}) {
            push @roles => 'MooseX::Storage::IO::' . $params{'io'};
            Class::MOP::load_class($roles[-1]) 
                || die "Could not load IO role (" . $roles[-1] . ") for package ($pkg)";            
        }
        
        return @roles;
    });
}

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

=cut
