package Aspect;

use strict;
use warnings;
use base 'Exporter';

use Aspect::Advice;
use Aspect::PointCut::Calls;
use Aspect::PointCut::Returns;
use Aspect::PointCut::OrOp;
use Aspect::PointCut::AndOp;
use Aspect::PointCut::NotOp;

our %EXPORT_TAGS = ( all => [ qw(
	advice calls returns or_op and_op not_op
	around
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.06';

# if the first argument isn't a pointcut object, make it a calls()
# pointcut, the most common one

sub advice  {
	my ($ptcut, $code) = @_;
	$ptcut = calls($ptcut) unless $ptcut->isa('Aspect::PointCut');
	Aspect::Advice->new($ptcut, $code);
}

sub calls   { Aspect::PointCut::Calls->new(@_)   }
sub returns { Aspect::PointCut::Returns->new(@_) }
sub or_op   { Aspect::PointCut::OrOp->new(@_)    }
sub and_op  { Aspect::PointCut::AndOp->new(@_)   }
sub not_op  { Aspect::PointCut::NotOp->new(@_)   }

sub around  { calls(@_) | returns(@_) }

1;

__END__

=head1 NAME

Aspect - Convenience functions to set up aspects

=head1 SYNOPSIS

  use Aspect qw(advice calls returns);

  sub get_foo { ... }
  sub set_bar { ... }

  my $spec = qr/^(.*::)?[gs]et_/;
  $aspect = advice(calls($spec) | returns($spec), sub { ... });
  $aspect->enable;

=head1 DESCRIPTION

For general information on aspect-oriented programming in Perl,
read C<Aspect::Intro>, C<Aspect::Overview>, C<Aspect::Cookbook>
and C<Aspect::Ideas>.

This module exports convenience functions that make setting up
aspects easier. It is perfectly possible to create pointcuts and
aspects without these functions, but you would have to call the
relevant constructors and methods manually.

=head2 EXPORT

None by default.

=head2 EXPORT_OK

=over 4

=item C<advice(pointcut, code)>

This function takes two arguments and creates an C<Aspect::Advice>
object. The first argument is a pointcut expression, which can be
an object of the type C<Aspect::PointCut> (or a subclass thereof).
If the first argument is no such object, it will be passed to
C<calls()>, which is the most common type of pointcut.

The second parameter is the advice code. This is a coderef that
will be installed on join points matching the pointcut expression.

For example,

  my $pointcut = calls('main::foo');
  my $aspect = advice($pointcut, sub { print "called foo()\n" });

first creates a pointcut that matches the call join point on the
sub C<foo()> in the package C<main>. It then sets up advice on that
join point that prints a short nice every time the C<foo()> function
is called.

The same effect can be achieved with

  my $aspect = advice('main::foo', sub { print "called foo()\n" });

Note that this function creates the aspect, but does not enable
it. To do so, you have to call C<enable()> on the returned object.
See the C<Aspect::Advice> manpage for details.

=item C<calls(specifier)>

This function, or rather, pointcut operator, constructs an object
of the type C<Aspect::PointCut::Calls>. This pointcut matches all
call join points whose subroutine name correspond to the specifier
given as the argument. The specifier can be a plain string, in
which case only that specific subroutine matches, or a regular
expression (probably constructed with C<qr//>) that is used to
match the subroutine name, or a code reference that is given each
potential subroutine name in turn and is expected to return a true
value if the corresponding call join point is supposed to match.
The subroutine names are fully qualified with their package names
when comparing them with the specifier.

Examples:

=over 4

=item C<calls('main::y1')>

constructs a pointcut that matches the call join point of sub C<y1>
in package C<main> only.

=item C<calls(qr/^(.*::)?[gs]et_/)>

constructs a pointcut that matches the call join point of all
subroutines whose name starts with C<get_> or C<set_>, in any
package.

=item C<calls(sub { local $_ = shift; /^Foo/ && /bar$/ })>

constructs a pointcut that matches the call join point of all
subroutines whose fully qualified name starts with C<Foo> and ends
with C<bar>.

=back

=item C<returns(specifier)>

This function, or pointcut operator, is just like C<calls()>, except
that it applies to return join points instead of call join points.
The object it constructs is of the type C<Aspect::PointCut::Returns>.

=item C<around(specifier)>

This function creates a pointcut that applies to call join points
as well as return join points. It is equivalent to C<calls(specifier)
| returns(specifier)>.

=item C<or_op(leftexpr, rightexpr)>

This function constructs an object of the type C<Aspect::PointCut::OrOp>
and takes two pointcut expressions as arguments. When checking to
see whether a particular join point matches (e.g., when enabling
an aspect), the results of both left and right expressions are
combined using logical C<or>. That is, the whole pointcut expression
matches if the left expression or the right expression matches.

Example:

  or_op(calls(qr/./), returns(qr/./))

matches both the call join point and the return join point of every
subroutine in every package.

This function is overloaded so you can use the C<|> operator instead.
So the above example could be rewritten as

  calls(qr/./) | returns(qr/./)

=item C<and_op(leftexpr, rightexpr)>

This function is like C<or_op>, except that the two subexpressions
are combined in a logical C<and>. You can use the overloaded operator
C<&> instead. So the whole pointcut expression match a join point
only if both subexpression match. The constructed object is of the
type C<Aspect::PointCut::AndOp>.

=item C<not_op(expr)>

This function constructs an object of the type C<Aspect::PointCut::NotOp>.
This pointcut matches a join point only if the argument's pointcut
expression does not match it. You can use the overloaded operator
C<!> instead. For example, C<calls(qr/./) & !calls(qr/^Foo::/)>
matches every call join point whose corresponding subroutine is
not in the C<Foo> package or any other package that starts with
C<Foo::>.

=back

=head2 EXPORT_TAGS

Using C<:all> you can import all of the above functions.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel Grunauer, <marcel@codewerk.com>

=head1 COPYRIGHT

Copyright 2001 Marcel Grunauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm).

=cut
