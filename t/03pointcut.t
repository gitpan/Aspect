#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;
use Aspect ':all';

BEGIN { plan tests => 8 }

ok(1);  # loaded ok

my $spec = qr/main::.*/;
my $p1 = calls('main::y1') | calls('main::z1');
ok(ref $p1, 'Aspect::PointCut::OrOp');

my $l = $p1->leftop;
ok(ref $l, 'Aspect::PointCut::Calls');
ok($l->spec, 'main::y1');

my $r = $p1->rightop;
ok(ref $r, 'Aspect::PointCut::Calls');
ok($r->spec, 'main::z1');

my $p2 = returns($spec);
ok(ref $p2, 'Aspect::PointCut::Returns');
ok($p2->spec eq $spec);
