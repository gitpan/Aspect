#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;

BEGIN { plan tests => 16 }

use Aspect::Singleton;

package Foo;

use Class::MethodMaker
    new => 'new',
    get_set => [ qw/bar baz/ ];

package Bar;

use Class::MethodMaker
    new => 'new',
    get_set => [ qw/bar baz/ ];

package main;

ok(1);  # loaded ok

my $s = Aspect::Singleton->new('Foo');
ok(ref $s, 'Aspect::Singleton');

# show that Foo is affected...

my $f1 = new Foo;
$f1->bar(10);
$f1->baz('hello');

ok(ref $f1, 'Foo');
ok($f1->bar, 10);
ok($f1->baz, 'hello');

my $f2 = new Foo;

ok($f1 eq $f2);      # string representations
ok(ref $f2, 'Foo');
ok($f2->bar == $f1->bar);
ok($f2->baz eq $f1->baz);

# ... now show that Bar is not affected

my $b1 = new Bar;
$b1->bar(10);
$b1->baz('hello');

ok(ref $b1, 'Bar');
ok($b1->bar, 10);
ok($b1->baz, 'hello');

my $b2 = new Bar;

ok($b1 ne $b2);      # string representations
ok(ref $b2, 'Bar');
ok(!defined $b2->bar);
ok(!defined $b2->baz);

