
package MooseX::Storage::Engine;
use Moose;

has 'storage' => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub {{}}
);

has 'object' => (
    is  => 'rw',
    isa => 'Object',    
);

sub BUILD  { 
	(shift)->collapse_object;
}

sub collapse_object {
	my $self = shift;
    $self->process_attributes;
	return $self->storage;
}

sub extract_attributes {
    my $self = shift;
    return $self->object->meta->compute_all_applicable_attributes;
}

sub process_attributes {
    my $self = shift;
    foreach my $attr ($self->extract_attributes) {
		next if $attr->name eq '_storage';
        $self->process_attribute($attr);
    }
}

sub process_attribute {
    my ($self, $attr)  = @_;
    $self->storage->{$attr->name} = $self->collapse_attribute($attr);
}

my %TYPES = (
    'Int'      => sub { shift },
    'Num'      => sub { shift },
    'Str'      => sub { shift },
    'ArrayRef' => sub { shift },
    'HashRef'  => sub { shift },
    'GlobRef' => sub { confess "FOO" },
    'CodeRef' => sub { confess "This should use B::Deparse" },
    'Object'  => sub {
        my $obj = shift;
		$obj || confess("Object Not Defined");
        ($obj->does('MooseX::Storage::Base'))
            || confess "Bad object";
        $obj->pack();
    }                    
);

sub match_type {
    my ($self, $type_constraint) = @_;
    return $TYPES{$type_constraint->name} if exists $TYPES{$type_constraint->name};
    foreach my $type (keys %TYPES) {
        return $TYPES{$type} 
            if $type_constraint->is_subtype_of($type);
    }
}

sub collapse_attribute {
    my ($self, $attr)  = @_;
	my $value = $attr->get_value($self->object);
    if (defined $value && $attr->has_type_constraint) {
        my $type_converter = $self->match_type($attr->type_constraint);
        (defined $type_converter)
            || confess "Cannot convert " . $attr->type_constraint->name;
        $value = $type_converter->($value);
    }
	return $value;
}

1;
__END__