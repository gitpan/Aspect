#!/usr/bin/perl

use warnings;
use strict;

use Aspect::Attribute;
use Test;
use Carp;

BEGIN { plan tests => 6 }

my %bounds = (
    x => { min =>  1, max =>  9 },
    y => { min => 11, max => 19 }
);

sub bounds1 : Before(qr/^main::set_/) {
	(my $prop = $::thisjp->sub) =~ s/^main::set_//;
	return unless exists $bounds{$prop};
	return if $_[0] >= $bounds{$prop}{min} && $_[0] <= $bounds{$prop}{max};
	croak sprintf "%s is out of bounds: min = %s, max = %s, given = %s",
	    $prop, $bounds{$prop}{min}, $bounds{$prop}{max}, $_[0];
}

sub set_x { our $x = shift }
sub get_x { our $x }

sub set_y { our $y = shift }
sub get_y { our $y }

sub set_z { our $y = shift }
sub get_z { our $y }

sub foo { 'foo' }

ok(foo, 'foo');
set_x(3);
ok(get_x,3);

set_y(15);
ok(get_y,15);

set_z(27);
ok(get_z,27);

eval { set_x(99) };
ok($@ =~ /x is out of bounds: min = 1, max = 9, given = 99/);
ok(get_x, 3);
