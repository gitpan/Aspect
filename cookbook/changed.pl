#!/usr/bin/perl

use warnings;
use strict;
use Test;
use Aspect::Attribute;

package Foo;
use Class::MethodMaker
    new     => 'new',
    get_set => [ -java => qw/X Y Z/ ];

sub changed1 : After(qr/^Foo::set[XYZ]/) { $_[0]->{changed} = 1 }

sub test_and_clear {
	my $self = shift;
	my $c = $self->{changed};
	$self->{changed} = 0;
	$c || 0
}

package main;

BEGIN { plan tests => 8 }

my $foo = Foo->new;

ok($foo->test_and_clear, 0);

$foo->setX(3);
ok($foo->getX,3);

ok($foo->test_and_clear, 1);
ok($foo->test_and_clear, 0);

$foo->setY(15);
ok($foo->getY,15);

$foo->setZ(27);
ok($foo->getZ,27);

ok($foo->test_and_clear, 1);
ok($foo->test_and_clear, 0);
