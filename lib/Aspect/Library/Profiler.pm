package Aspect::Library::Profiler;

use strict;
use warnings;
use Carp;
use Aspect;

use base 'Aspect::Modular';

my $Timer = Benchmark::Timer::ReportOnDestroy->new;

sub get_advice {
	my ($self, $pointcut) = @_;
	my $before = before { $Timer->start(shift->sub_name) } $pointcut;
	my $after  = after  { $Timer->stop (shift->sub_name) } $pointcut;
	return ($before, $after);
}

package Benchmark::Timer::ReportOnDestroy;
use base qw(Benchmark::Timer);
sub DESTROY { shift->report }

1;

__END__

=head1 NAME

Aspect::Library::Profiler - reusable method call profiling aspect

=head1 SYNOPSIS

  # profile all subs on SlowObject
  aspect Profiler => call qr/^SlowObject::/;

  # will be profiled
  SlowObject->foo;

  # will not
  FastObject->bar;

=head1 SUPER

L<Aspect::Modular>

=head1 DESCRIPTION

This class implements a reusable aspect that profiles subroutine calls.
It uses C<Benchmark::Timer> to profile elapsed times for your calls to
the affected methods. The profiling report will be printed to C<STDERR>
at the end of program execution.

The design comes from C<Attribute::Profiled> by Tatsuhiko Miyagawa.

=head1 WHY

  +-------------+
  |      A      |
  +-------------+
  | X -> Y <- Z |
  +-^-----------+

Suppose you want to profile some code, call it C<X>, part of a larger
program, called C<A>. So you run your program under a profiler, and
notice most of the time is spent not in C<X>, but in C<Y>. C<X> uses
C<Y>, but so does C<Z>. You only want to profile how C<X> uses C<Y>, not
how C<Z> uses C<Y>. This is where this aspect can help- you can install a
profiling aspect with a C<cflow()> pointcut, to profile only usage of
C<Y> by code in the call flow of C<X>.

=head1 SEE ALSO

See the L<Aspect|::Aspect> pods for a guide to the Aspect module.

You can find an example of using this aspect in the C<examples/> directory
of the distribution.

=cut

