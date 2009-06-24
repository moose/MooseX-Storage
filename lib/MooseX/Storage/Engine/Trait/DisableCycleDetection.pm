package MooseX::Storage::Engine::Trait::DisableCycleDetection;
use Moose::Role;

around 'check_for_cycle_in_collapse' => sub {
    my ($orig, $self, $attr, $value) = @_;
    # See NOTE in MX::Storage::Engine
    return $value;
};

1;

