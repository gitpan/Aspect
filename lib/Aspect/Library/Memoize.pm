package Aspect::Library::Memoize;

use strict;
use warnings;
use Carp;
use Memoize;
use Aspect;

use base 'Aspect::Modular';

sub get_advice {
	my ($self, $pointcut) = @_;
	my %wrappers;
	before {
		my $context  = shift;
		my $sub_name = $context->sub_name;
		# would be difficult if Memoize did not have INSTALL => undef option
		$wrappers{$sub_name} ||= memoize($context->original, INSTALL => undef);
		my $wrapper = $wrappers{$sub_name};
		my @params  = $context->params;
		$context->return_value
			(wantarray? [$wrapper->(@params)]: $wrapper->(@params));
	} $pointcut; 
}

1;

=head1 NAME

Aspect::Library::Memoize - cross-cutting memoization

=head1 SYNOPSIS

  # memoize all subs that have '_slow_' in their name, under package MyApp
  aspect Memoize => call qr/^MyApp::.*_slow_/;

=head1 SUPER

L<Aspect::Modular>

=head1 DESCRIPTION

An aspect interface on the Memoize module. Only difference from Memoize
module is that you can specify subs to be memoized using pointcuts.

Works by memoizing on the 1st call, and calling the memoized version on
subsequent calls.

=head1 SEE ALSO

See the L<Aspect|::Aspect> pods for a guide to the Aspect module.

You can find an example of using this aspect in the C<examples/> directory
of the distribution.

=cut