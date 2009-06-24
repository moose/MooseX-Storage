package MooseX::Storage::Engine::Trait::OnlyWhenBuilt;
use Moose::Role;

# we should
# only serialize the attribute if it's already built. So, go ahead
# and check if the attribute has a predicate. If so, check if it's 
# set  and then go ahead and look it up.
around 'collapse_attribute' => sub {
    my ($orig, $self, $attr, @args) = @_;

    my $pred = $attr->predicate if $attr->has_predicate;
    if ($pred) {
        return () unless $self->object->$pred();
    }

    return $self->$orig($attr, @args);
};

1;

