#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test::More tests => 10;
BEGIN { use_ok('Aspect::Symbol::Enum', ':all') }

sub foo {}
sub bar {}
sub baz {}

my @u = get_user_packages;
ok(grep(/^$_$/ => @u), "$_ is a user package") for qw/main Test Test::Harness/;

my @c = get_CODE('main');
ok(grep(/^$_$/ => @c), "$_ is a main:: CODE symbol")
    for qw/foo bar baz get_CODE get_code get_user_packages/;
