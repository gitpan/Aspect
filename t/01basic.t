use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test::More tests => 14;

BEGIN { use_ok('Aspect', qw(advice calls returns)) }

sub get_foo { our $output .= "foo(@_):"; 1 }
sub set_bar { our $output .= "bar(@_):"; 2 }
sub baz     {
	our $output .= "baz(@_):";
	is(get_foo('foo'), 1, 'no aspect: get_foo() return value');
	is(set_bar('bar'), 2, 'no aspect: set_bar() return value');
	3;
}

my $spec = qr/^(.*::)?[gs]et_/;
my $aspect = advice(calls($spec) | returns($spec),
    sub { our $output .= 'advice:' });
isa_ok($aspect, 'Aspect::Advice');

our $output;

$output = '';
is(baz('baz'), 3, 'baz() return value');
is($output, 'baz(baz):foo(foo):bar(bar):', 'no aspect: cumulated output');

$aspect->enable('main');

$output = '';
is(baz('frob'), 3, 'with aspect: baz() return value');
is($output, 'baz(frob):advice:foo(foo):advice:advice:bar(bar):advice:',
    'with aspect: cumulated output');

$aspect->disable;

$output = '';
is(baz('nule'), 3, 'aspect disabled: baz() return value');
is($output, 'baz(nule):foo(foo):bar(bar):', 'aspect disabled: cumulated output');

