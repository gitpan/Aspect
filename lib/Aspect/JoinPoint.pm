package Aspect::JoinPoint;

use Class::MethodMaker
    new_with_init => 'new';
use Aspect::JoinPoint::Call;
use Aspect::JoinPoint::Return;
use Aspect::Symbol::Enum qw(get_user_packages get_CODE);

our $VERSION = '0.07';

sub init {}    # might be useful in a subclass

# XXX: Make this an iterator.
# In Perl 6, this would be coroutine, yielding each join point in turn.

sub enum {
	# go through each sub, generating call join points
	# and return join points

	# unless given a list of package names as arguments, we will
	# iterate through all of the user's packages

	my @pkg = @_;
	@pkg = get_user_packages unless @_;

	my @jp;  # XXX: not needed in iterator

	for my $pkg (@pkg) {
		for my $sub (get_CODE($pkg)) {
			my $sym = $pkg . '::' . $sub;

			# subs that have been exported from Aspect.pm
			# don't provide join points; that's not the
			# expected default behavior. See Aspect::import().

			next if exists $Aspect::exp_syms{$sym};
			push @jp =>
			    Aspect::JoinPoint::Call->new($sym),
			    Aspect::JoinPoint::Return->new($sym);
		}
	}

	return \@jp;
}

# Install advice code on the particular join point corresponding
# to the object. Return a lexical handler that can be used to
# uninstall the advice, e.g., by going out of scope.

sub install {}

1;

__END__

=head1 NAME

Aspect::JoinPoint - Superclass for all types of join points

=head1 SYNOPSIS

  use Aspect::JoinPoint;
  print "$_\n" for @{ Aspect::JoinPoint::enum(@_) };

=head1 DESCRIPTION

This is the superclass for all types of join points.

=head1 METHODS

This class implements the following methods:

=over 4

=item C<new([args])>

This is the constructor. It creates the object, then calls C<init()> 
to handle any arguments that were passed to the constructor.w

=item C<init([args])>

This method initializes newly constructed objects. It doesn't do
anything in this class, but can be overridden in subclasses
representing specific types of join points to handle arguments
appropriate to that type of join point.

=item C<enum([packages])>

This is a class method that enumerates, as a list, all join points
in existence within the current program and returns a reference to
that list.

If no argument is given to this method, all join points from all
'user packages' will be enumerated. See the description
C<get_user_packages()> in the manpage of C<Aspect::Symbol::Enum>
for what that means.

If given a list of package names, only join points in those packages
will be enumerated, even if those packages are not user packages.

=item C<install(coderef)>

This method is used to install advice code on a join point. It
doesn't do anything in this class, but can be overridden in subclasses
representing specific types of join points to install the code as
appropriate for that type of join point.

The advice code can make use of the C<$::thisjp> variable, which
holds a reference to the object representing the current join point,
i.e. the join point that the advice code was invoked for. One
example use for that is that the advice can find out the name of
a call join point's subroutine (via the C<sub> method described in
C<Aspect::JoinPoint::Sub>), which is necessary for tracing the call
flow (also see C<Aspect::Trace>).

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel.gruenauer@chello.at>

=head1 COPYRIGHT

Copyright 2001 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm).

=cut
