package Aspect::Advice;

use Class::MethodMaker
    new_with_init => 'new',
    get_set       => [ qw/pointcut code/ ];
use Aspect::JoinPoint;

our $VERSION = '0.06';

sub init {
	my $self = shift;
	return unless @_;
	$self->pointcut(+shift);
	$self->code(+shift);
};

# enable() asks the aspect's pointcut to install the aspect on all
# define-time matching join points. Takes a list of package names
# as optional arguments, which limits the packages on which the advice
# may be installed.

sub enable {
	my $self = shift;

	# Iterate over all join points, generating appropriate objects.
	# Pass each join point to the pointcut expression. If there is a
	# define-time match, ask the join point to install the advice code.

	for my $jp (@{ Aspect::JoinPoint::enum(@_) }) {
		print "testing <$jp>\n" if $::debug;
		next unless $self->pointcut->match_define($jp);
		print "match, installing code\n" if $::debug;

		# a join point can return more than one handle, e.g.
		# see call and return join points

		push @{ $self->{handles} } => $jp->install($self->code);
	}

	$self;
}

sub disable {
	my $self = shift;
	undef $self->{handles};
	$self;
}

1;

__END__

=head1 NAME

Aspect::Advice - Object representing a pointcut and associated advice

=head1 SYNOPSIS

  use Aspect qw(advice calls returns);
  
  sub get_foo { print "in foo\n" }
  sub set_bar { print "in bar\n" }
  sub baz     { print "in baz\n" }
  
  my $aspect = advice(calls(qr/^(.*::)?[gs]et_/), 
      sub { printf "entering %s\n", $::thisjp->sub });
  
  $aspect->enable;
  
  get_foo();
  set_bar();
  baz();

=head1 DESCRIPTION

An aspect consists of one or more advice, which each consists of
a pointcut and a coderef. The coderef is executed whenever the
pointcut matches a given point in execution.

=head1 METHODS

This class implements the following methods:

=over 4

=item C<new([pointcut, code])>

This is the constructor. It takes as optional arguments the advice's
pointcut and the coderef, which are passed to C<pointcut()> and
C<code()>, respectively.

=item C<enable()>

Enables, or activates, the advice. Each join point in the program
is tested against the pointcut designator. If there is a define-time
match, the join point is asked to install the advice code. Note
that depending on the type of join point, a define-time match may
not be sufficient to have the advice code run; there may be a
run-time match. However, in the case of call join points or return
join points, once an advice is installed, it will run.

Returns the advice object.

=item C<disable()>

Disables, or disactivates, the advice from all affected join points.
Returns the advice object.

=item C<pointcut([pointcut])>

Sets (with arguments), or gets (without arguments), the advice's
pointcut designator. This needs to be an object of the type
C<Aspect::PointCut>.

=item C<code([coderef])>

Sets (with arguments), or gets (without arguments), the advice
code. When the code is run, it can examine the current join point
using the variable C<$::thisjp>. Depending on the type of join
point, the advice code can then obtain certain context information.

For example, for a call join point it may be interesting to know
which subroutine has been called. A call join point is of the type
C<Aspect::JoinPoint::Call>, so you can call methods as explained
on its manpage. This is what the sample code in the Synopsis above
does.

=back

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
