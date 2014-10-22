package Aspect::Pointcut::Throwing;

use strict;
use warnings;
use Carp             ();
use Params::Util     ();
use Aspect::Pointcut ();

our $VERSION = '0.93_01';
our @ISA     = 'Aspect::Pointcut';





######################################################################
# Constructor

sub new {
	my $class = shift;
	my $spec  = shift;
	if ( Params::Util::_STRING($spec) ) {
		return bless [
			$spec,
			"Params::Util::_INSTANCE(\$_->{exception}, '$spec')",
		], $class;
	}
	if ( Params::Util::_REGEX($spec) ) {
		my $regex = "$spec";
		$regex =~ s|^\(\?([xism]*)-[xism]*:(.*)\)\z|/$2/$1|s;
		return bless [
			$spec,
			"defined \$_->{exception} and not ref \$_->{exception} and \$_->{exception} =~ $regex",
		], $class;
	}
	Carp::croak("Invalid throwing pointcut specification");
}





######################################################################
# Weaving Methods

# Throwing pointcuts do not curry.
# (But maybe they should, when used with say a before {} block)
sub match_curry {
	return $_[0];
}

sub compile_runtime {
	$_[0]->[1];
}

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::Throwing - Exception typing pointcut

  use Aspect;
  
  # Catch a Foo::Exception object exception
  after {
      $_->return_value(1)
  } throwing 'Foo::Exception';
  
=head1 DESCRIPTION

The B<Aspect::Pointcut::Throwing> pointcut is used to match situations
in which an after() or after_throwing() advice block wishes to intercept
the throwing of a specific exception string or object.

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
