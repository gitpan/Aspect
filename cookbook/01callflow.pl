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
});
my $adv2 = advice(returns(qr/^Foo::/), sub { $::indent-- });

$_->enable for $adv1, $adv2;

Foo::bar(9);

