package MooseX::Storage::Traits::DisableCycleDetection;
# ABSTRACT: A custom trait to bypass cycle detection

our $VERSION = '0.53';

use Moose::Role;
use namespace::autoclean;

requires 'pack';
requires 'unpack';

around 'pack' => sub {
    my ($orig, $self, %args) = @_;
    $args{engine_traits} ||= [];
    push(@{$args{engine_traits}}, 'DisableCycleDetection');
    $self->$orig(%args);
};

around 'unpack' => sub {
    my ($orig, $self, $data, %args) = @_;
    $args{engine_traits} ||= [];
    push(@{$args{engine_traits}}, 'DisableCycleDetection');
    $self->$orig($data, %args);
};

no Moose::Role;

1;

__END__

=pod

=head1 SYNOPSIS


    package Double;
    use Moose;
    use MooseX::Storage;
    with Storage( traits => ['DisableCycleDetection'] );

    has 'x' => ( is => 'rw', isa => 'HashRef' );
    has 'y' => ( is => 'rw', isa => 'HashRef' );

    my $ref = {};

    my $double = Double->new( 'x' => $ref, 'y' => $ref );

    $double->pack;

=head1 DESCRIPTION

C<MooseX::Storage> implements a primitive check for circular references.
This check also triggers on simple cases as shown in the Synopsis.
Providing the C<DisableCycleDetection> traits disables checks for any cyclical
references, so if you know what you are doing, you can bypass this check.

This trait is applied to all objects that inherit from it. To use this
on a per-case basis, see C<disable_cycle_check> in L<MooseX::Storage::Basic>.

=for stopwords culted

See the SYNOPSIS for a nice example that can be easily cargo-culted.

=cut
