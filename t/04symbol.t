#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;
use Aspect::Symbol::Enum ':all';

BEGIN { plan tests => 10 }

sub foo {}
sub bar {}
sub baz {}

ok(1);  # loaded ok
my @u = get_user_packages;
ok(grep /^$_$/ => @u) for qw/main Test Test::Harness/;

my @c = get_CODE('main');
ok(grep /^$_$/ => @c)
    for qw/foo bar baz get_CODE get_code get_user_packages/;
