
package MooseX::Storage;

sub import {
    my $pkg = caller();
    $pkg->meta->alias_method('Storage' => sub {
        my $engine_name = 'MooseX::Storage::' . (shift);
        Class::MOP::load_class($engine_name) 
            || die "Could not load engine ($engine_name) for package ($pkg)";
        return $engine_name;
    });
}

package MooseX::Storage::Base;
use Moose::Role;

requires 'pack';
requires 'unpack';

requires 'freeze';
requires 'thaw';

requires 'load';
requires 'store';

1;

__END__

=pod

=cut
