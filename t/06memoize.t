#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;

BEGIN { plan tests => 95 }

use Aspect::Memoize;

sub fib {
	our $in_fib++;
	my $n = shift;
	return $n if $n < 2;
	fib($n-1) + fib($n-2);
}

sub g {
	# just trying to throw off the cache...
	my $m = shift;
	my $n = $_[0];
	our $in_g++;

	return 1 if $m < 1;
	return 1 if $n < 1;
	return g($m, $n-1) + g($m-1, $n);
}

ok(1);  # loaded ok


# Test fib() efficiency and results before memoization

our $in_fib;
my @fib = ();
for my $i (0..9) {
	$in_fib = 0;
	push @fib, fib($i);
	# ok if we need at least $i recursive calls to fib()
	ok($in_fib >= $i);
}

my @fib_expect = (0, 1, 1, 2, 3, 5, 8, 13, 21, 34);
ok($fib[$_], $fib_expect[$_]) for 0..9;

# Test fib() efficiency and results after memoization

my $memo_fib = Aspect::Memoize->new('main::fib');
ok(ref $memo_fib, 'Aspect::Memoize');

@fib = ();
for my $i (0..9) {
	$in_fib = 0;
	push @fib, fib($i);
	# ok if we only need one call to fib, that is, precisely fib($i)
	ok($in_fib = 1);
}

ok($fib[$_], $fib_expect[$_]) for 0..9;


# Test g() efficiency and results before memoization

our $in_g;
my @g = ();
for my $m (0..3) {
	for my $n (0..3) {
		$in_g = 0;
		push @g, g($m, $n);
		# ok if we need at least min($m,$n) recursive calls to g()
		my $min = $m < $n ? $m : $n;
		ok($in_g >= $min);
	}
}

my @g_expect = (1, 1, 1, 1, 1, 2, 3, 4, 1, 3, 6, 10, 1, 4, 10, 20);
ok($g[$_], $g_expect[$_]) for 0..9;

# Test g() efficiency and results after memoization

my $memo_g = Aspect::Memoize->new('main::g');
ok(ref $memo_g, 'Aspect::Memoize');

@g = ();
for my $m (0..3) {
	for my $n (0..3) {
		$in_g = 0;
		push @g, g($m, $n);
		# ok if we only need one call to g, that is, precisely g($m, $n)
		ok($in_g = 1);
	}
}

ok($g[$_], $g_expect[$_]) for 0..9;
