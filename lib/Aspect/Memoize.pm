package Aspect::Memoize;

use base 'Aspect::Modular';
use Class::MethodMaker
    get_set => 'spec';
use Aspect qw(advice calls returns);

our $VERSION = '0.06';

sub define {
	my ($self, $spec) = @_;
	print "def memoize for <$spec>\n" if $::debug;
	$self->spec($spec);

	# see the INTERNALS section of the documentation below

	$self->handlers_push(
	    advice(calls($spec), sub {
		my $argcode = join $;,@_[0..$#_-1];
		my $sub = $::thisjp->sub;
		$_[-1] = $Aspect::Memoize::cache{$sub}{$argcode}
		    if defined $Aspect::Memoize::cache{$sub}{$argcode};
		push @{ $Aspect::Memoize::argstack{$sub} } => $argcode;
	    }),
	    advice(returns($spec), sub {
		my $sub = $::thisjp->sub;
		my $argcode = pop @{ $Aspect::Memoize::argstack{$sub} };
		$Aspect::Memoize::cache{$sub}{$argcode}
		    = wantarray ? @{$_[-1]} : $_[-1];
	    }),
	);
	$self->enable;
}

1;

__END__

=head1 NAME

Aspect::Memoize - Modular aspect to handle subroutine memoization

=head1 SYNOPSIS

  use Aspect::Memoize;

  sub fib {
    my $n = shift;
    return $n if $n < 2;
    fib($n-1) + fib($n-2);
  }

  my $memo_fib = Aspect::Memoize->new('main::fib');

  for my $i (0..9) {
    print fib($i), "\n";
  }

=head1 DESCRIPTION

This class implements a modular aspect that handles memoization,
that is, caching of subroutine results. With apologies to Mark
Jason Dominus, the following description is taken from the C<Memoize>
manpage:

Memoizing a function makes it faster by trading space for time.
It does this by caching the return values of the function in a
table.  If you call the function again with the same arguments,
C<memoize> jmups in and gives you the value out of the table,
instead of letting the function compute the value all over again.

Here is an extreme example.  Consider the Fibonacci sequence,
defined by the following function:

  # Compute Fibonacci numbers
  sub fib {
    my $n = shift;
    return $n if $n < 2;
    fib($n-1) + fib($n-2);
  }

This function is very slow.  Why?  To compute fib(14), it first
wants to compute fib(13) and fib(12), and add the results.  But to
compute fib(13), it first has to compute fib(12) and fib(11), and
then it comes back and computes fib(12) all over again even though
the answer is the same.  And both of the times that it wants to
compute fib(12), it has to compute fib(11) from scratch, and then
it has to do it again each time it wants to compute fib(13).  This
function does so much recomputing of old results that it takes a
really long time to run---fib(14) makes 1,200 extra recursive calls
to itself, to compute and recompute things that it already computed.

This function is a good candidate for memoization.  If you memoize
the C<fib()> function above, it will compute fib(14) exactly once,
the first time it needs to, and then save the result in a table.
Then if you ask for fib(14) again, it gives you the result out of
the table.  While computing fib(14), instead of computing fib(12)
twice, it does it once; the second time it needs the value it gets
it from the table.  It doesn't compute fib(11) four times; it
computes it once, getting it from the table the next three times.
Instead of making 1,200 recursive calls to `fib', it makes 15.
This makes the function about 150 times faster.

=head1 METHODS

This class inherits from C<Aspect::Modular>. In addition, it
implements and/or overrides the following methods:

=over 4

=item C<define(spec)>

Creates and enables advice that implements the memoization for
subroutines matching the specification given in the argument. The
specification can be a string, regular expression or a coderef, as
described in the C<PointCut> manpage.

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

When calling a memoized subroutine, check whether we hold a return
value for this particular subroutine and argument configuration in
the cache. If so, return it.

=item *

When exiting from the subroutine, remember the value in the cache.

=back

=head1 TODO

Extend this aspect with ideas from C<Memoize>, e.g. custom normalizers.
A C<normalizer()> method could take a coderef to a normalizer
function. The advice code will use the default normalizer unless
set.

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
