package Aspect::JoinPoint::Call;

use base 'Aspect::JoinPoint::Sub';
use Hook::LexWrap;

use overload '""' => \&as_string;

our $VERSION = '0.06';

sub as_string {
	my $self = shift;
	'call join point: ' . $self->sub;
}

# XXX: to implement match_run, don't install the code directly as a wrapper,
# XXX: but a sub that calls the pointcut expression's match_run with this
# XXX: join point to see whether it should actually call the advice code.

sub install {
	my ($self, $code) = @_;
	my $w1 = wrap $self->sub(), pre => $code;
	my $w2 = wrap $self->sub(), pre => sub { $::thisjp = $self };

	# return all handles so they can be lexically dealt with

	($w1, $w2);
}

1;

__END__

=head1 NAME

Aspect::JoinPoint::Call - Class representing a call join point

=head1 SYNOPSIS

There is no synopsis, as this class is only used within Aspects;
if you develop Aspect internals, you'll know how to use it. If not,
you don't need to. If you're curious, read the source.

=head1 DESCRIPTION

This class represents a call join point.

=head1 METHODS

This class inherits from C<Aspect::JoinPoint::Sub>. In addition,
it implements and/or overrides the following methods:

=over 4

=item C<as_string()>

This method, which is called automatically via overloading if a
reference to an object of this type is printed. It returns a string
saying that it is a call join point and also gives the name of the
subroutine this join point belongs to.

=item C<install(coderef)>

This method takes a coderef (to advice code) and installs it at a
location appropriate to this call join point, i.e. as a prewrapper
for the affected subroutine using C<Hook::LexWrap>. See that manpage
for what this means for the advice code, noting especially that
caller, wantarray and argument information are preserved and
execution of the wrapped subroutine can be short-circuited by
providing a return value.

The method returns handles to the installed advice code that can
be dealt with lexically as described for C<handlers()> in the
C<Aspect::Modular> manpage.

Note the potential use of the C<$::thisjp> variable in the advice
code as described in C<Aspect::JoinPoint>.

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
