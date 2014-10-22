package Aspect::Pointcut::Logic;

# A base class for logic pointcuts

use strict;
use warnings;
use Carp             ();
use Params::Util     ();
use Aspect::Pointcut ();

our $VERSION = '0.97_05';
our @ISA     = 'Aspect::Pointcut';

sub new {
	my $class = shift;
	foreach ( @_ ) {
		next if Params::Util::_INSTANCE($_, 'Aspect::Pointcut');
		Carp::croak("Attempted to apply pointcut logic to non-pointcut '$_'");
	}
	$class->SUPER::new(@_);
}

sub match_runtime {
	return 0;
}

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::Logic - Pointcut logic role

=head1 DESCRIPTION

A typical real world L<Aspect::Pointcut> object tree will contain a variety of
different conditions. To combine these together a family of logic pointcuts
are used.

All of these can be identified by calling
C<-E<gt>isa('Aspect::Pointcut::Logic')> on them.

This role is used primarily by the optimiser during the execution of various
strategies, and does not have a significant use directly.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2011 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
