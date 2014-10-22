package Aspect::Library::TestClass;

use strict;
use warnings;
use Carp;
use Test::Class;
use Aspect;

use base 'Aspect::Modular';

sub Test::Class::make_subject { shift->subject_class->new(@_) }

sub get_advice {
	my ($self, $pointcut) = @_;
	before {
		my $context = shift;
		my $self    = $context->self; # the Test::Class object
		return unless is_test_method_with_subject($context);
		my $subject = $self->make_subject;
		$self->init_subject_state($subject) if $self->can('init_subject_state');
		$context->append_param($subject);
	} call qr/::[a-z][^:]*$/ & $pointcut;
}

# true if we are in a test class, in a test method, and we can get a
# subject_class from the test class
# would be nice if we could somehow check for existence of test attribute
# on method
sub is_test_method_with_subject {
	my $context = shift;
	my $self    = $context->self; # the Test::Class object
	my @method  = ($context->package_name, $context->short_sub_name);
	return
		UNIVERSAL::isa($self, 'Test::Class') &&
		$self->_method_info(@method) &&
		$self->can('subject_class');
}

1;

=head1 NAME

Aspect::Library::TestClass - give Test::Class test methods an IUT
(implementation under test)

=head1 SYNOPSIS

  # append IUT to params of all test methods in matching packages
  # place this in your test script
  aspect TestClass => call qr/::tests::/;

=head1 SUPER

L<Aspect::Modular>

=head1 DESCRIPTION

Frequently my C<Test::Class> test methods look like this:

  sub some_test: Test {
     my $self = shift;
     my $subject = IUT->new;
     # send $subject messages and verify expected results
     ...
  }

After installing this aspect, they look like this:

  sub some_test: Test {
     my ($self, $subject) = @_;
     # send $subject messages and verify expected results
     ...
  }

In the test class you must add one I<template method> to provide the
class of the IUT:

  sub subject_class { 'MyApp::Person' }

=head1 SEE ALSO

See the L<Aspect|::Aspect> pods for a guide to the Aspect module.

C<XUL-Node> tests use this aspect extensively.

=cut
