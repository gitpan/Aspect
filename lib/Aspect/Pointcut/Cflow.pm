package Aspect::Pointcut::Cflow;

use strict;
use warnings;
use Carp                   ();
use Params::Util           ();
use Aspect::Pointcut       ();
use Aspect::Pointcut::Call ();
use Aspect::AdviceContext  ();

our $VERSION = '0.94';
our @ISA     = 'Aspect::Pointcut';

use constant KEY  => 0;
use constant SPEC => 2;





######################################################################
# Constructor Methods

sub new {
	my $class = shift;
	unless ( Params::Util::_IDENTIFIER($_[0]) ) {
		Carp::croak('Invalid runtime context key');
	}

	# Generate it via call
	my $call = Aspect::Pointcut::Call->new($_[1]);
	return bless [ $_[0], @$call ], $class;
}





######################################################################
# Weaving Methods

# The cflow pointcuts do not curry at all.
# So they don't need to clone, and can be used directly.
sub match_curry {
	return $_[0];
}





######################################################################
# Runtime Methods

sub compile_runtime {
	my $self = shift;
	return sub {
		my $level   = 2;
		my $caller  = undef;
		while ( my $cc = caller_info($level++) ) {
			next unless $self->[SPEC]->( $cc->{sub_name} );
			$caller = $cc;
			last;
		}
		return 0 unless $caller;
		my $class   = (ref $_ or 'Aspect::AdviceContext');
		my $context = $class->new(
			sub_name => $caller->{sub_name},
			pointcut => $_->{pointcut},
			params   => $caller->{params},
		);
		$_->{$self->[KEY]} = $context;
		return 1;
	};
}

sub caller_info {
	my $level = shift;

	package DB;

	my %call_info;
	@call_info{qw(
		calling_package
		sub_name
		has_params
	)} = (CORE::caller($level))[0, 3, 4];

	return defined $call_info{calling_package}
		? {
			%call_info,
			params => [
				$call_info{has_params} ? @DB::args : ()
			],
		} : 0;
}

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::Cflow - Cflow pointcut

=head1 SYNOPSIS

  Aspect::Pointcut::Cflow->new;

=head1 DESCRIPTION

None yet.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2010 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
