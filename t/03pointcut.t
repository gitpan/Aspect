#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test::More tests => 8;;

BEGIN { use_ok('Aspect', ':all') }

my $spec = qr/main::.*/;
my $p1 = calls('main::y1') | calls('main::z1');
isa_ok($p1, 'Aspect::PointCut::OrOp');

my $l = $p1->leftop;
isa_ok($l, 'Aspect::PointCut::Calls');
is($l->spec, 'main::y1', "leftop's spec");

my $r = $p1->rightop;
isa_ok($r, 'Aspect::PointCut::Calls');
is($r->spec, 'main::z1', "rightop's spec");

my $p2 = returns($spec);
isa_ok($p2, 'Aspect::PointCut::Returns');
is($p2->spec, $spec, 'returns() spec');
