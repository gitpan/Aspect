#!perl

require 5.008;

use strict;
use warnings;
use Carp;
use FindBin;
use lib ("$FindBin::Bin/../lib", "$FindBin::Bin/lib");
use Test::Class;

$| = 1;
$ENV{TEST_VERBOSE} = 0;

sub runtime_use {
	my $package = shift;
	eval "use $package;";
	croak "Cannot use [$package]: $@" if $@;
}

my @test_class_names;

BEGIN {
	my @ALL_TESTS = qw(
 		Aspect::Pointcut::tests::Call
 		Aspect::Pointcut::tests::Cflow
 		Aspect::tests::Weaver
 		Aspect::tests::AdviceContext
		Aspect::tests::Advice
 		Aspect::Library::tests::Singleton
 		Aspect::Library::tests::Wormhole
		Aspect::Library::tests::Listenable
	);

	my $thing = 'Aspect::'. ($ARGV[0] || '');
	$thing =~ s/(::)?([^:]+)?$/${
		\( $1 || '')
	}tests::${
		\( $2 || '')
	}/;

	@test_class_names = $thing eq 'Aspect::tests::'? @ALL_TESTS: ($thing);

	runtime_use $_ for @test_class_names;
}

Test::Class->runtests(@test_class_names);

1;

=head1 NAME

run_tests.pl - run Aspect unit tests

=head1 SYNOPSIS

  # run all tests
  perl run_tests.pl

  # a specific test case, no need to prefix with Aspect:: or add the tests:: part
  perl run_tests.pl Weaver
  perl run_tests.pl Pointcut::Call

=cut
