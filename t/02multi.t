#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;
use Aspect 'advice';

BEGIN { plan tests => 6 }

ok(1);  # loaded ok

sub foo { our $output .= 'foo:' }
sub bar { our $output .= 'bar:' }

our $output;

$output = '';
foo();
bar();
ok($output, 'foo:bar:');

my $aspect = advice('main::foo', sub { our $output .= 'adv1:' });
$aspect->enable;

$output = '';
foo();
bar();
ok($output, 'adv1:foo:bar:');

my $aspect2 = advice('main::foo', sub { our $output .= 'adv2:' });
$aspect2->enable;

$output = '';
foo();
bar();
ok($output, 'adv2:adv1:foo:bar:');

$aspect->disable;

$output = '';
foo();
bar();
ok($output, 'adv2:foo:bar:');

$aspect2->disable;

$output = '';
foo();
bar();
ok($output, 'foo:bar:');

