package Aspect::Profiled;

# $Id: Profiled.pm,v 1.3 2002/07/31 21:29:16 marcelgr Exp $
#
# $Log: Profiled.pm,v $
# Revision 1.3  2002/07/31 21:29:16  marcelgr
# changed version number to 0.08
#
# Revision 1.2  2002/07/31 21:03:13  marcelgr
# changed e-mail address; other changes for version 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use base 'Aspect::Modular';
use Class::MethodMaker
    get_set => [ qw/spec/ ];
use Aspect qw(advice calls returns);

our $VERSION = '0.08';

sub define {
	my ($self, $spec) = @_;
	print "def profile for <$spec>\n" if $::debug;
	$self->spec($spec);

	# see the INTERNALS section of the documentation below

	$self->handlers_push(
	    advice(calls($spec), sub {
	    	$Aspect::Profiled::Profiler ||=
		    Benchmark::Timer::ReportOnDestroy->new;
		$Aspect::Profiled::Profiler->start("$spec");
	    }),
	    advice(returns($spec), sub {
		$Aspect::Profiled::Profiler->stop("$spec");
	    }),
	);
	$self->enable;
}

package Benchmark::Timer::ReportOnDestroy;
use base qw(Benchmark::Timer);

sub DESTROY {
	my $self = shift;
	$self->report;
}

1;

__END__

=head1 NAME

Aspect::Profiled - Modular aspect to profile subroutine calls

=head1 SYNOPSIS

  use Aspect::Profiled;
  my $prof = Aspect::Profiled->new(qr/^main::(foo|bar)$/);
  foo(7);

=head1 DESCRIPTION

This class implements a modular aspect that profiles subroutine
calls. It uses Benchmark::Timer to profile elapsed times for your
calls to the affected methods. The profiling report will be printed
to STDERR at the end of program execution.

It uses an idea first implemented by Tatsuhiko Miyagawa in
C<Attribute::Profiled>.

=head1 METHODS

This class inherits from C<Aspect::Modular>. In addition, it
implements and/or overrides the following methods:

=over 4

=item C<define(STRING)>

Creates and enables advice that implements the profiling behavior
for the given subroutines. The specification can be a string,
regular expression or a coderef, as described in the C<PointCut>
manpage.

=item C<spec([spec])>

Gets, if called without an argument, or sets, if called with an
argument, the aspect's pointcut specification. It is set automatically
by C<define()>; setting it afterwards has no effect.

=back

=head1 INTERNALS

This aspect consists of two pieces of advice for each affected
subroutine:

=over 4

=item *

When calling a subroutine affected by the aspect's pointcut, the
a timer associated with the aspect's specifier is started.

=item *

When returning from the subroutine the associated timer is stopped.

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel@cpan.org>

=head1 COPYRIGHT

Copyright 2001-2002 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm), Benchmark::Timer(3pm).

=cut
