package Aspect::PointCut;

use strict;
use warnings;
use Aspect::PointCut::AndOp;
use Aspect::PointCut::OrOp;
use Aspect::PointCut::NotOp;
use overload
    '&' => sub { Aspect::PointCut::AndOp->new(@_) },
    '|' => sub { Aspect::PointCut::OrOp->new(@_)  },
    '!' => sub { Aspect::PointCut::NotOp->new(@_) };

use Class::MethodMaker
    new_with_init => 'new',
    get_set       => 'spec';

our $VERSION = '0.04';

sub init {}   # might be useful in subclasses

sub match_define { 1 }

sub match {
        # test this specific pointcut's condition against a parameter
        # of the current join point's context.

        my ($self, $param) = @_;
        return unless defined $param;

	printf "testing pointcut: <%s> vs <%s>\n", $self->spec, $param
	    if $::debug;

	my $spec = $self->spec;
        if (ref($spec) eq 'Regexp') {
                return $param =~ $spec;
        } elsif (ref($spec) eq 'CODE') {
                return $spec->($param);
        } else {
                # assume literal string
                return $param eq $spec;
        }

}

1;

__END__

=head1 NAME

Aspect::PointCut - Superclass for all types of pointcuts

=head1 SYNOPSIS

There is no synopsis, as this class is only used within Aspects;
if you develop Aspect internals, you'll know how to use it. If not,
you don't need to. If you're curious, read the source.

=head1 DESCRIPTION

This is the superclass for all types of pointcuts. See specific
pointcuts' manpages (C<Aspect::PointCut::*>) for more information.

=head1 METHODS

This class inherits from C<Aspect::x>. In addition, it implements
and/or overrides the following methods:

=over 4

=item C<new([args])>

This is the constructor. It creates the object, then calls C<init()>
to handle any arguments that were passed to the constructor.

=item C<init([args])>

This method initializes newly constructed objects. It doesn't do
anything in this class but can be overridden in subclasses representing
specific pointcuts.

=item C<spec([spec])>

Gets, if called without an argument, or sets, if called with an
argument, the pointcut specifier. See C<match_define()> and C<match()>
for the meaning of this specifier.

=item C<match_define(joinpoint)>

This method is called for each potential join point when enabling
advice to find out whether to install the advice on that join point.
Whether a join point matches at define time depends on the kind of
operators a pointcut designator uses and their relationships to
the type of join point in question. For example, C<calls()>, which
constructs a pointcut of the type C<Aspect::PointCut::Calls> matches
call join points on subroutines whose name matches the pointcut
specifier. For more on matching see C<match()>.

This method doesn't do anything in this class but should be overridden
in subclasses.

=item C<match(arg)>

This method can be called to find out whether the pointcut specifier
matches the argument. If the specifier is a string, the argument
must be equal to the string to match. If the specifier is a regular
expression (constructed with C<qr//>), it must match the argument.
If the specifier is a coderef, the code is executed and given the
argument; the argument matches if the code returns a true value.

For example, the string or regular expression or coderef a C<calls()>
pointcut designator is constructed with is tested against the name
of each call join point's subroutine to see whether to install
advice code on that pointcut.

=back

Pointcuts are constructed as trees; logical operations on pointcuts
with one or two arguments (C<not>, C<and>, C<or>) are themselves
pointcut operators. You can construct them explicitly using object
syntax, or you can use the convenience functions exported by
C<Aspect> and the overloaded operators C<!>, C<&> and C<|>. See
the C<Aspect> manpage for more information.

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
