#!/usr/bin/perl

use warnings;
use strict;
use Aspect::Attribute;

package Foo;

sub frobnicate { $_[0] }
sub baz { return 5 + frobnicate(10 + shift) }
sub bar { baz(17) + baz(23) - shift }

package main;

sub adv1 : Before(qr/^Foo::/) {
	$::indent++;
	print ' ' x ($::indent - 1), $::thisjp->signature(@_), "\n"
}

sub adv2 : After(qr/^Foo::/) { $::indent-- }

Foo::bar(9);

