#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test::More tests => 16;

BEGIN { use_ok('Aspect::Singleton') }

package Foo;

use Class::MethodMaker
    new => 'new',
    get_set => [ qw/bar baz/ ];

package Bar;

use Class::MethodMaker
    new => 'new',
    get_set => [ qw/bar baz/ ];

package main;

my $s = Aspect::Singleton->new('Foo');
isa_ok($s, 'Aspect::Singleton');

# show that Foo is affected...

my $f1 = new Foo;
$f1->bar(10);
$f1->baz('hello');

isa_ok($f1, 'Foo');
is($f1->bar, 10, "first Foo object's bar()");
is($f1->baz, 'hello', "first Foo object's baz()");

my $f2 = new Foo;

is($f1, $f2, "both Foo object's stringifications are equal");
isa_ok($f2, 'Foo');
is($f2->bar, $f1->bar, "both object's bar() are equal");
is($f2->baz, $f1->baz, "both objects' baz() are equal");

# ... now show that Bar is not affected

my $b1 = new Bar;
$b1->bar(10);
$b1->baz('hello');

isa_ok($b1, 'Bar');
is($b1->bar, 10, "first Bar object's bar()");
is($b1->baz, 'hello', "first Bar object's baz()");

my $b2 = new Bar;

isnt($b1, $b2, "both Bar objects' stringifications aren't equal");
isa_ok($b2, 'Bar');
ok(!defined $b2->bar, "second Bar object's bar() is undefined");
ok(!defined $b2->baz, "second Bar object's baz() is undefined");
