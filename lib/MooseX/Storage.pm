

package MooseX::Storage;

sub import {
    my $pkg = caller();
    $pkg->meta->alias_method('Storage' => sub {
        my $engine = shift;
        return 'MooseX::Storage::' . $engine;
    });
}

package MooseX::Storage::Base;
use Moose::Role;

requires 'load';
requires 'store';

requires 'freeze';
requires 'thaw';

1;

__END__