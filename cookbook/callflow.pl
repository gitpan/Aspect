#!/usr/bin/perl

use warnings;
use strict;
use Aspect qw(advice calls returns);

package Foo;

sub frobnicate { $_[0] }
sub baz { return 5 + frobnicate(10 + shift) }
sub bar { baz(17) + baz(23) - shift }

package main;

my $adv1 = advice(calls(qr/^Foo::/), sub {
	$::indent++;
	print ' ' x ($::indent - 1), $::thisjp->signature(@_), "\n"
})->enable;
my $adv2 = advice(returns(qr/^Foo::/), sub { $::indent-- })->enable;

Foo::bar(9);

