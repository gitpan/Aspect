package Aspect::Pointcut;

use strict;
use warnings;
use Carp;
use Aspect::Pointcut::AndOp;
use Aspect::Pointcut::OrOp;
use Aspect::Pointcut::NotOp;
use Data::Dumper;

use overload
	'&'  => sub { Aspect::Pointcut::AndOp->new(@_) },
	'|'  => sub { Aspect::Pointcut::OrOp ->new(@_) },
	'!'  => sub { Aspect::Pointcut::NotOp->new(@_) },
	'""' => sub { Dumper [@_] };

sub new {
	my ($class, @spec) = @_;
	my $self = bless {}, $class;
	$self->init(@spec);
	return $self;
}

sub match {
	my ($self, $spec, $sub_name) = @_;
	return
		ref $spec eq 'Regexp'? $sub_name =~ $spec:
		ref $spec eq 'CODE'  ? $spec->($sub_name):
		$spec eq $sub_name;
}

sub init {}

# template methods ------------------------------------------------------------

sub match_define { 1 }
sub match_run    { 1 }

1;

=head1 NAME

Aspect::Pointcut - pointcut base class

=head1 DESCRIPTION

A running program can be seen as a collection of events. Events like a
sub returning from a call, or a package being used. These are called join
points. A pointcut defines a set of join points, taken from all the join
points in the program. Different pointcut classes allow you to define the
set in different ways, so you can target the exact join points you need.

Pointcuts are constructed as trees; logical operations on pointcuts with
one or two arguments (not, and, or) are themselves pointcut operators.
You can construct them explicitly using object syntax, or you can use the
convenience functions exported by Aspect and the overloaded operators
C<!>, C<&> and C<|>.

=head1 SEE ALSO

See the L<Aspect|::Aspect> pod for a guide to the Aspect module.

=cut
