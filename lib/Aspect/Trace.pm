package Aspect::Trace;

use base 'Aspect::Modular';
use Class::MethodMaker
    get_set => [ qw/spec fh/ ];
use Aspect qw(advice calls returns);

our $VERSION = '0.04';

sub define {
	my ($self, $spec) = @_;
	print "def trace for <$spec>\n" if $::debug;
	$self->spec($spec);

	# see the INTERNALS section of the documentation below

	$self->handlers_push(
	    advice(calls($spec), sub {
		my $context = defined wantarray
		    ?  wantarray ? 'array' : 'scalar'
		    : 'void';
		no warnings 'once';
		printf { $self->fh || STDOUT }
		    "call %s in %s context\n",
		    $::thisjp->signature(@_), $context;
	    }),
	    advice(returns($spec), sub {
		no warnings 'once';
		if (defined wantarray) {
			my $retval;
			if (ref $_[-1] eq 'ARRAY') {
				$retval =
				    join ', ',
				    map { defined $_ ? $_ : 'undef' }
				    @{$_[-1]};
				$retval = "($retval)";
			} else {
				$retval = defined $_[-1] ? $_[-1] : 'undef';
			}
			printf { $self->fh || STDOUT }
			    "retval from %s = %s\n", $::thisjp->sub(), $retval;
		} else {
			printf { $self->fh || STDOUT }
			    "return from %s\n", $::thisjp->sub();
		}
	    }),
	);
	$self->enable;
}

1;

__END__

=head1 NAME

Aspect::Trace - Modular aspect to trace subroutine calls

=head1 SYNOPSIS

  use Aspect::Trace;
  my $trace = Aspect::Trace->new(qr/^main::(foo|bar)$/);
  $trace->enable;
  foo(7);

=head1 DESCRIPTION

This class implements a modular aspect that traces subroutine calls.

=head1 METHODS

This class inherits from C<Aspect::Modular>. In addition, it
implements and/or overrides the following methods:

=over 4

=item C<define(STRING)>

Creates and enables advice that implements the tracing behavior
for the given subroutines. The specification can be a string,
regular expression or a coderef, as described in the C<PointCut>
manpage.

=item C<spec([spec])>

Gets, if called without an argument, or sets, if called with an
argument, the aspect's pointcut specification. It is set automatically
by C<define()>; setting it afterwards has no effect.

=item C<fh([fh])>

Gets, if called without an argument, or sets, if called with an
argument, the filehandle onto which the trace messages are printed.
Unless set, messages are printed to C<STDOUT> and getting the
filehandle will return C<undef>. This accessor can be called at
any time with an open filehandle; all messages printed afterwards
will be directed to the new filehandle.

=back

=head1 INTERNALS

This aspect consists of two pieces of advice for each affected
class:

=over 4

=item *

When calling an subroutine affected by the aspect's pointcut, the
subroutine name and arguments are printed along with the context
(scalar, array, void).

=item *

When returning from the subroutine, a message with the subroutine
name and return value (or C<undef> if there is none) is printed.

=back

=head1 TODO

The constructor could be made to take named arguments specifying
formats, along the lines of C<printf>, for the trace messages.
Placeholders could include the subroutine name, arguments, context,
return value, file name, package name etc.

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
