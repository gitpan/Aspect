#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;

BEGIN { plan tests => 14 }

use Aspect qw(advice calls returns);

sub get_foo { our $output .= "foo(@_):"; 1 }
sub set_bar { our $output .= "bar(@_):"; 2 }
sub baz     {
	our $output .= "baz(@_):";
	ok(get_foo('foo'), 1);
	ok(set_bar('bar'), 2);
	3;
}

ok(1);  # loaded ok

my $spec = qr/^(.*::)?[gs]et_/;
my $aspect = advice(calls($spec) | returns($spec),
    sub { our $output .= 'advice:' });
ok(ref $aspect, 'Aspect::Advice');

our $output;

$output = '';
ok(baz('baz'), 3);
ok($output, 'baz(baz):foo(foo):bar(bar):');

$aspect->enable('main');

$output = '';
ok(baz('frob'), 3);
ok($output, 'baz(frob):advice:foo(foo):advice:advice:bar(bar):advice:');

$aspect->disable;

$output = '';
ok(baz('nule'), 3);
ok($output, 'baz(nule):foo(foo):bar(bar):');

