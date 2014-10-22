#!/usr/bin/perl

# Miscellaneous tests for pointcuts

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 47;
use Test::NoWarnings;
use Aspect;





######################################################################
# Validate that simple nested calls curry out to null

SCOPE: {
	my $nul1 = call 'Foo::foo' & call 'Foo::bar' & call 'Foo::baz';
	isa_ok( $nul1, 'Aspect::Pointcut::And' );
	is( scalar($nul1->curry_runtime), undef, 'Multi-level nested calls curry to null' );

	my $nul2 = wantlist & call 'Foo::bar' & call 'Foo::baz';
	isa_ok( $nul2, 'Aspect::Pointcut::And' );
	isa_ok( $nul2->curry_runtime, 'Aspect::Pointcut::Wantarray' );

	my $nul3 = call 'Foo::foo' & wantlist & call 'Foo::baz';
	isa_ok( $nul3, 'Aspect::Pointcut::And' );
	isa_ok( $nul3->curry_runtime, 'Aspect::Pointcut::Wantarray' );

	my $nul4 = call 'Foo::foo' & call 'Foo::baz' & highest;
	isa_ok( $nul4, 'Aspect::Pointcut::And' );
	isa_ok( $nul4->curry_runtime, 'Aspect::Pointcut::Highest' );
}

SCOPE: {
	my $nul1 = call 'Foo::foo' | call 'Foo::bar' | call 'Foo::baz';
	isa_ok( $nul1, 'Aspect::Pointcut::Or' );
	is( scalar($nul1->curry_runtime), undef, 'Multi-level nested calls curry to null' );

	my $nul2 = wantlist | call 'Foo::bar' | call 'Foo::baz';
	isa_ok( $nul2, 'Aspect::Pointcut::Or' );
	isa_ok( $nul2->curry_runtime, 'Aspect::Pointcut::Wantarray' );

	my $nul3 = call 'Foo::foo' | wantlist | call 'Foo::baz';
	isa_ok( $nul3, 'Aspect::Pointcut::Or' );
	isa_ok( $nul3->curry_runtime, 'Aspect::Pointcut::Wantarray' );

	my $nul4 = call 'Foo::foo' | call 'Foo::baz' | highest;
	isa_ok( $nul4, 'Aspect::Pointcut::Or' );
	isa_ok( $nul4->curry_runtime, 'Aspect::Pointcut::Highest' );
}





######################################################################
# Validate that nested And pointcuts curry out to a single depth

SCOPE: {
	# Create the normal nested pointcut
	my $raw = call 'Foo::bar' & wantlist & wantscalar & wantvoid;
	isa_ok( $raw,                'Aspect::Pointcut::And'       );
	isa_ok( $raw->[0],           'Aspect::Pointcut::And'       );
	isa_ok( $raw->[0]->[0],      'Aspect::Pointcut::And'       );
	isa_ok( $raw->[0]->[0]->[0], 'Aspect::Pointcut::Call'      );
	isa_ok( $raw->[0]->[0]->[1], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $raw->[0]->[1],      'Aspect::Pointcut::Wantarray' );
	isa_ok( $raw->[1],           'Aspect::Pointcut::Wantarray' );

	# Curry the pointcut to the final form
	my $run = $raw->curry_runtime;
	isa_ok( $run, 'Aspect::Pointcut::And' );
	is( scalar(@$run), 3, '3 elements in the top level And pointcut' );
	isa_ok( $run->[0], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $run->[1], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $run->[2], 'Aspect::Pointcut::Wantarray' );
	is( $run->[0]->[0], 3, 'wantlist is first'    );
	is( $run->[1]->[0], 2, 'wantscalar is second' );
	is( $run->[2]->[0], 1, 'wantvoid is third'    );
}

SCOPE: {
	# Create the normal nested pointcut
	my $raw = call 'Foo::bar' | wantlist | wantscalar | wantvoid;
	isa_ok( $raw,                'Aspect::Pointcut::Or'       );
	isa_ok( $raw->[0],           'Aspect::Pointcut::Or'       );
	isa_ok( $raw->[0]->[0],      'Aspect::Pointcut::Or'       );
	isa_ok( $raw->[0]->[0]->[0], 'Aspect::Pointcut::Call'      );
	isa_ok( $raw->[0]->[0]->[1], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $raw->[0]->[1],      'Aspect::Pointcut::Wantarray' );
	isa_ok( $raw->[1],           'Aspect::Pointcut::Wantarray' );

	# Curry the pointcut to the final form
	my $run = $raw->curry_runtime;
	isa_ok( $run, 'Aspect::Pointcut::Or' );
	is( scalar(@$run), 3, '3 elements in the top level Or pointcut' );
	isa_ok( $run->[0], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $run->[1], 'Aspect::Pointcut::Wantarray' );
	isa_ok( $run->[2], 'Aspect::Pointcut::Wantarray' );
	is( $run->[0]->[0], 3, 'wantlist is first'    );
	is( $run->[1]->[0], 2, 'wantscalar is second' );
	is( $run->[2]->[0], 1, 'wantvoid is third'    );
}
