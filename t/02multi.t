#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test::More tests => 6;

BEGIN { use_ok('Aspect', 'advice') }

sub foo { our $output .= 'foo:' }
sub bar { our $output .= 'bar:' }

our $output;

$output = '';
foo();
bar();
is($output, 'foo:bar:', 'no aspect: cumulative output');

my $aspect = advice('main::foo', sub { our $output .= 'adv1:' });
$aspect->enable;

$output = '';
foo();
bar();
is($output, 'adv1:foo:bar:', 'aspect 1: cumulative output');

my $aspect2 = advice('main::foo', sub { our $output .= 'adv2:' });
$aspect2->enable;

$output = '';
foo();
bar();
is($output, 'adv2:adv1:foo:bar:', 'aspects 1+2: cumulative output');

$aspect->disable;

$output = '';
foo();
bar();
is($output, 'adv2:foo:bar:', 'aspect 2: cumulative output');

$aspect2->disable;

$output = '';
foo();
bar();
is($output, 'foo:bar:', 'aspects disabled: cumulative output');

