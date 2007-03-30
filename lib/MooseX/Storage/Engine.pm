
package MooseX::Storage::Engine;
use Moose;

has 'storage' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {{}}
);

has 'object' => (is => 'rw', isa => 'Object');
has 'class'  => (is => 'rw', isa => 'Str');

## this is the API used by other modules ...

sub collapse_object {
	my $self = shift;
    $self->map_attributes('collapse_attribute');
    $self->storage->{'__class__'} = $self->object->meta->name;    
	return $self->storage;
}

sub expand_object {
    my ($self, $data) = @_;
    $self->map_attributes('expand_attribute', $data);
	return $self->storage;    
}

## this is the internal API ...

sub collapse_attribute {
    my ($self, $attr)  = @_;
    $self->storage->{$attr->name} = $self->collapse_attribute_value($attr) || return;
}

sub expand_attribute {
    my ($self, $attr, $data)  = @_;
    $self->storage->{$attr->name} = $self->expand_attribute_value($attr, $data->{$attr->name}) || return;
}

sub collapse_attribute_value {
    my ($self, $attr)  = @_;
	my $value = $attr->get_value($self->object);
    if (defined $value && $attr->has_type_constraint) {
        my $type_converter = $self->match_type($attr->type_constraint);
        (defined $type_converter)
            || confess "Cannot convert " . $attr->type_constraint->name;
        $value = $type_converter->{collapse}->($value);
    }
	return $value;
}

sub expand_attribute_value {
    my ($self, $attr, $value)  = @_;
    if (defined $value && $attr->has_type_constraint) {
        my $type_converter = $self->match_type($attr->type_constraint);
        $value = $type_converter->{expand}->($value);
    }
	return $value;
}

# util methods ...

sub map_attributes {
    my ($self, $method_name, @args) = @_;
    map { 
        $self->$method_name($_, @args) 
    } ($self->object || $self->class)->meta->compute_all_applicable_attributes;
}

## ------------------------------------------------------------------
## Everything below here might need some re-thinking ...
## ------------------------------------------------------------------

# NOTE:
# these are needed by the 
# ArrayRef and HashRef handlers
# below, so I need easy access 
my %OBJECT_HANDLERS = (
    expand => sub {
        my $data = shift;   
        (exists $data->{'__class__'})
            || confess "Serialized item has no class marker";
        $data->{'__class__'}->unpack($data);
    },
    collapse => sub {
        my $obj = shift;
        ($obj->can('does') && $obj->does('MooseX::Storage::Basic'))
            || confess "Bad object ($obj) does not do MooseX::Storage::Basic role";
        $obj->pack();
    },
);


my %TYPES = (
    'Int'      => { expand => sub { shift }, collapse => sub { shift } },
    'Num'      => { expand => sub { shift }, collapse => sub { shift } },
    'Str'      => { expand => sub { shift }, collapse => sub { shift } },
    'ArrayRef' => { 
        # FIXME:
        # these should also probably be
        # recursive as well, so they 
        # can handle arbitrarily deep
        # arrays and such. Or perhaps
        # we force the user to handle 
        # the types in a custom way. 
        # This would require a more 
        # sophisticated way of handling
        # this %TYPES hash.
        expand => sub {
            my $array = shift;
            foreach my $i (0 .. $#{$array}) {
                next unless ref($array->[$i]) eq 'HASH' 
                         && exists $array->[$i]->{'__class__'};
                $array->[$i] = $OBJECT_HANDLERS{expand}->($array->[$i])
            }
            $array;
        }, 
        collapse => sub { 
            my $array = shift;   
            # NOTE:         
            # we need to make a copy cause
            # otherwise it will affect the 
            # other real version.
            [ map {
                blessed($_)
                    ? $OBJECT_HANDLERS{collapse}->($_)
                    : $_
            } @$array ] 
        } 
    },
    'HashRef'  => { 
        expand   => sub { shift }, 
        collapse => sub { shift } 
    },
    'Object'   => \%OBJECT_HANDLERS,
    # NOTE:
    # The sanity of enabling this feature by 
    # default is very questionable.
    # - SL
    #'CodeRef' => {
    #    expand   => sub {}, # use eval ...
    #    collapse => sub {}, # use B::Deparse ...        
    #}       
);

sub match_type {
    my ($self, $type_constraint) = @_;
    
    # this should handle most type usages
    # since they they are usually just 
    # the standard set of built-ins
    return $TYPES{$type_constraint->name} 
        if exists $TYPES{$type_constraint->name};
      
    # the next possibility is they are 
    # a subtype of the built-in types, 
    # in which case this will DWIM in 
    # most cases. It is probably not 
    # 100% ideal though, but until I 
    # come up with a decent test case 
    # it will do for now.
    foreach my $type (keys %TYPES) {
        return $TYPES{$type} 
            if $type_constraint->is_subtype_of($type);
    }
    
    # NOTE:
    # the reason the above will work has to 
    # do with the fact that custom subtypes
    # are mostly used for validation of 
    # the guts of a type, and not for some
    # weird structural thing which would 
    # need to be accomidated by the serializer.
    # Of course, mst or phaylon will probably  
    # do something to throw this assumption 
    # totally out the door ;)
    # - SL
    

	# To cover the last possibilities we 
	# need a way for people to extend this 
	# process. Which they can do by subclassing
	# this class and overriding the method 
	# below to handle things.
	my $match = $self->_custom_type_match($type_constraint);
	return $match if defined $match;

    # NOTE:
    # if this method hasnt returned by now
    # then we have no been able to find a 
    # type constraint handler to match 
    confess "Cannot handle type constraint (" . $type_constraint->name . ")";    
}

sub _custom_type_match {
    return;
    # my ($self, $type_constraint) = @_;
}

1;

__END__

=pod

=head1 NAME

MooseX::Storage::Engine

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 Accessors

=over 4

=item B<class>

=item B<object>

=item B<storage>

=back

=head2 API

=over 4

=item B<expand_object>

=item B<collapse_object>

=back

=head2 ...

=over 4

=item B<collapse_attribute>

=item B<collapse_attribute_value>

=item B<expand_attribute>

=item B<expand_attribute_value>

=item B<map_attributes>

=item B<match_type>

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



