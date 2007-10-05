
package MooseX::Storage;
use Moose qw(confess);

use MooseX::Storage::Meta::Attribute::DoNotSerialize;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

sub import {
    my $pkg = caller();
    
    return if $pkg eq 'main';
    
    ($pkg->can('meta'))
        || confess "This package can only be used in Moose based classes";
    
    $pkg->meta->alias_method('Storage' => sub {
        my %params = @_;
        
        if (exists $params{'base'}) {
            $params{'base'} = ('Base::' . $params{'base'});        
        }
        else {
            $params{'base'} = 'Basic';        
        }
        
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
        # many IO roles don't make sense unless 
        # you have also have a format role chosen
        # too, the exception being StorableFile
        if (exists $params{'io'}) {
            # NOTE:
            # we dont need this code anymore, cause 
            # the role composition will catch it for 
            # us. This allows the StorableFile to work
            #(exists $params{'format'})
            #    || confess "You must specify a format role in order to use an IO role";
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

  package Point;
  use Moose;
  use MooseX::Storage;
  
  our $VERSION = '0.01';
  
  with Storage('format' => 'JSON', 'io' => 'File');
  
  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');
  
  1;
  
  my $p = Point->new(x => 10, y => 10);
  
  ## methods to pack/unpack an 
  ## object in perl data structures
  
  # pack the class into a hash
  $p->pack(); # { __CLASS__ => 'Point-0.01', x => 10, y => 10 }
  
  # unpack the hash into a class
  my $p2 = Point->unpack({ __CLASS__ => 'Point-0.01', x => 10, y => 10 });

  ## methods to freeze/thaw into 
  ## a specified serialization format
  ## (in this case JSON)
  
  # pack the class into a JSON string
  $p->freeze(); # { "__CLASS__" : "Point-0.01", "x" : 10, "y" : 10 }
  
  # unpack the JSON string into a class
  my $p2 = Point->thaw('{ "__CLASS__" : "Point-0.01", "x" : 10, "y" : 10 }');  

  ## methods to load/store a class 
  ## on the file system
  
  $p->store('my_point.json');
  
  my $p2 = Point->load('my_point.json');

=head1 DESCRIPTION

MooseX::Storage is a serialization framework for Moose, it provides 
a very flexible and highly pluggable way to serialize Moose classes
to a number of different formats and styles.

=head2 Important Note

This is still an early release of this module, so use with caution. 
It's outward facing serialization API should be considered stable, 
but I still reserve the right to make tweaks if I need too. Anything
beyond the basic pack/unpack, freeze/thaw and load/store should not 
be relied on.

=head2 Levels of Serialization

There are 3 levels to the serialization, each of which builds upon 
the other and each of which can be customized to the specific needs
of your class.

=over 4

=item B<base>

The first (base) level is C<pack> and C<unpack>. In this level the 
class is serialized into a Perl HASH reference, it is tagged with the  
class name and each instance attribute is stored. Very simple.

This level is not optional, it is the bare minumum that 
MooseX::Storage provides and all other levels build on top of this.

=item B<format>

The second (format) level is C<freeze> and C<thaw>. In this level the 
output of C<pack> is sent to C<freeze> or the output of C<thaw> is sent 
to C<unpack>. This levels primary role is to convert to and from the 
specific serialization format and Perl land. 

This level is optional, if you don't want/need it, you don't have to 
have it. You can just use C<pack>/C<unpack> instead.

=item B<io>

The third (io) level is C<load> and C<store>. In this level we are reading 
and writing data to file/network/database/etc. 

This level is also optional, in most cases it does require a C<format> role
to also be used, the expection being the C<StorableFile> role.

=back

=head2 How we serialize

There are always limits to any serialization framework, there are just 
some things which are really difficult to serialize properly and some 
things which cannot be serialized at all.

=head2 What can be serialized?

Currently only numbers, string, ARRAY refs, HASH refs and other 
MooseX::Storage enabled objects are supported. 

With Array and Hash references the first level down is inspected and 
any objects found are serialized/deserialized for you. We do not do 
this recusively by default, however this feature may become an 
option eventually.

The specific serialize/deserialize routine is determined by the 
Moose type constraint a specific attribute has. In most cases subtypes 
of the supported types are handled correctly, and there is a facility 
for adding handlers for custom types as well. This will get documented
eventually, but it is currently still in development.

=head2 What can not be serialized?

We do not support CODE references yet, but this support might be added 
in using B::Deparse or some other deep magic. 

Scalar refs are not supported, mostly because there is no way to know 
if the value being referenced will be there when the object is inflated. 
I highly doubt will be ever support this in a general sense, but it 
would be possible to add this yourself for a small specific case.

Circular references are specifically disallowed, however if you break 
the cycles yourself then re-assemble them later you can get around this.
The reason we disallow circular refs is because they are not always supported 
in all formats we use, and they tend to be very tricky to do for all 
possible cases. It is almost always something you want to have tight control 
over anyway.

=head1 CAVEAT

This is B<not> a persistence framework, changes to your object after
you load or store it will not be reflected in the stored class.  

=head1 EXPORTS

=over 4

=item B<Storage (%options)>

This module will export the C<Storage> method will can be used to 
load a specific set of MooseX::Storage roles to implement a specific 
combination of features. It is meant to make things easier, but it 
is by no means the only way. You can still compose your roles by 
hand if you like.

=back

=head1 METHODS

=over 4

=item B<import>

=back

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 TODO

This module needs docs and probably a Cookbook of some kind as well. 
This is an early release, so that is my excuse for now :)

For the time being, please read the tests and feel free to email me 
if you have any questions. This module can also be discussed on IRC 
in the #moose channel on irc.perl.org.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Chris Prather E<lt>chris.prather@iinteractive.comE<gt>

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

Yuval Kogman E<lt>yuval.kogman@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
