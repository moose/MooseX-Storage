
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
	# TODO:
	# we want to explicitly disallow 
	# cycles here, because the base
	# storage engine does not support 
	# them
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
    # TODO:
    # we need to check $value here to 
    # make sure that we do not have
    # a cycle here.
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

my %TYPES = (
    'Int'      => { expand => sub { shift }, collapse => sub { shift } },
    'Num'      => { expand => sub { shift }, collapse => sub { shift } },
    'Str'      => { expand => sub { shift }, collapse => sub { shift } },
    'ArrayRef' => { expand => sub { shift }, collapse => sub { shift } },
    'HashRef'  => { expand => sub { shift }, collapse => sub { shift } },
    'Object'   => {
        expand => sub {
            my $data = shift;   
            (exists $data->{'__class__'})
                || confess "Serialized item has no class marker";
            $data->{'__class__'}->unpack($data);
        },
        collapse => sub {
            my $obj = shift;
            ($obj->can('does') && $obj->does('MooseX::Storage::Basic'))
                || confess "Bad object ($obj) does not do MooseX::Storage::Base role";
            $obj->pack();
        },
    }       
);

sub match_type {
    my ($self, $type_constraint) = @_;
    return $TYPES{$type_constraint->name} if exists $TYPES{$type_constraint->name};
    foreach my $type (keys %TYPES) {
        return $TYPES{$type} 
            if $type_constraint->is_subtype_of($type);
    }
    # TODO:
    # from here we can expand this to support the following:
    # - if it is subtype of Ref
    # -- if it is a subtype of Object
    # --- treat it like an object
    # -- else 
    # --- treat it like any other Ref
    # - else
    # -- if it is a subtype of Num or Str
    # --- treat it like Num or Str
    # -- else
    # --- pass it on
    # this should cover 80% of all use cases

	# CHRIS: To cover the last 20% we need a way 
	# for people to extend this process.

    # NOTE:
    # if this method hasnt returned by now
    # then we have no been able to find a 
    # type constraint handler to match 
    confess "Cannot handle type constraint (" . $type_constraint->name . ")";    
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



