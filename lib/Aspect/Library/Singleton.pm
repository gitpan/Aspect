package Aspect::Library::Singleton;

use strict;
use warnings;
use Carp;
use Aspect;

use base 'Aspect::Modular';

my %Cache;

sub get_advice {
	my ($self, $constructor_matcher) = @_;
	return before {
		my $context = shift;
		my $class   = $context->self;
		$class      = ref $class || $class;

		if (exists $Cache{$class})
			{ $context->return_value($Cache{$class}) }
		else
			{ $Cache{$class} = $context->run_original }

	} call $constructor_matcher;
}

1;

=head1 NAME

Aspect::Library::Singleton - A singleton aspect

=head1 SYNOPSIS

  use Aspect::Singleton;

  aspect Singleton => 'Foo::new';

  my $f1 = Foo->new;
  my $f2 = Foo->new;

  # now $f1 and $f2 refer to the same object

=head1 SUPER

L<Aspect::Modular>

=head1 DESCRIPTION

A reusable aspect that forces singleton behavior on a constructor. The
constructor is defined by a pointcut spec: a string. regexp, or code ref.

It is slightly different from C<Class::Singleton>
(L<http://search.cpan.org/~abw/Class-Singleton/Singleton.pm>):

=over

=item *

No specific name requirement on the constructor for the external
interface, or for the implementation (C<Class::Singleton> requires
clients use C<instance()>, and that subclasses override
C<_new_instance()>). With aspects, you can change the cardinality of
your objects without changing the clients, or the objects themselves.

=item *

No need to inherit from anything- use pointcuts to specify the
constructors you want to memoize. Instead of I<pulling> singleton
behavior from a base class, you are I<pushing> it in, using the aspect.

=item *

No package variable or method is added to the callers namespace

=back

Note that this is just a special case of memoizing.

=head1 SEE ALSO

See the L<Aspect|::Aspect> pods for a guide to the Aspect module.

You can find an example comparing the OO and AOP solutions in the
C<examples/> directory of the distribution.

=cut

