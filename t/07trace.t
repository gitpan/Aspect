#!/usr/bin/perl

use warnings;
use strict;
use lib qw(lib ./t/testlib);
use Test;
use IO::Scalar;
use Aspect qw(advice calls returns);
use Aspect::Trace;

BEGIN { plan tests => 2 }

sub foo { 1 }
sub bar { (2, 3) }
sub baz { 5 }

ok(1);  # loaded ok

my $bar = foo(6);
() = bar(7,8);
foo(9);
baz(10);

my $trace = Aspect::Trace->new(qr/^main::(foo|bar)$/);

# redirect output to a string

my $result;
tie *OUT, 'IO::Scalar', \$result;
$trace->fh(\*OUT);

$bar = foo(6);
() = bar(7,8);
foo(9);
baz(10);

$trace->disable;

$bar = foo(6);
() = bar(7,8);
foo(9);
baz(10);

my $expected = do { local $/; <DATA> };
ok($result eq $expected);

__END__
call main::foo(6) in scalar context
retval from main::foo = 1
call main::bar(7, 8) in array context
retval from main::bar = (2, 3)
call main::foo(9) in void context
return from main::foo
