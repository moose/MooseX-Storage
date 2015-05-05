package MooseX::Storage::Engine::Trait::DisableCycleDetection;
# ABSTRACT: A custom trait to bypass cycle detection

our $VERSION = '0.51';

use Moose::Role;
use namespace::autoclean;

around 'check_for_cycle_in_collapse' => sub {
    my ($orig, $self, $attr, $value) = @_;
    # See NOTE in MX::Storage::Engine
    return $value;
};

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

This trait is applied to an instance of L<MooseX::Storage::Engine>, for the
user-visible version shown in the SYNOPSIS, see L<MooseX::Storage::Traits::DisableCycleDetection>

=head1 METHODS

=head2 Introspection

=over 4

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
