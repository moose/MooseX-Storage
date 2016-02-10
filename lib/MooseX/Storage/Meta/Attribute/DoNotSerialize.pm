package MooseX::Storage::Meta::Attribute::DoNotSerialize;
# ABSTRACT: A custom meta-attribute to bypass serialization

our $VERSION = '0.51';

use Moose;
use namespace::autoclean;
extends 'Moose::Meta::Attribute';
   with 'MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize';

# register this alias ...
package # hide from PAUSE
    Moose::Meta::Attribute::Custom::DoNotSerialize;

sub register_implementation { 'MooseX::Storage::Meta::Attribute::DoNotSerialize' }

1;

__END__

=pod

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

  with Storage('format' => 'JSON', 'io' => 'File');

  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');

  has 'foo' => (
      metaclass => 'DoNotSerialize',
      is        => 'rw',
      isa       => 'CodeRef',
  );

  1;

=head1 DESCRIPTION

=for stopwords culted

Sometimes you don't want a particular attribute to be part of the
serialization, in this case, you want to make sure that attribute
uses this custom meta-attribute. See the SYNOPSIS for a nice example
that can be easily cargo-culted.

=head1 METHODS

=head2 Introspection

=over 4

=item B<meta>

=back

=cut
