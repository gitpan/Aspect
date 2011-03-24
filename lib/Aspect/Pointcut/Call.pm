package Aspect::Pointcut::Call;

use strict;
use warnings;
use Carp             ();
use Params::Util     ();
use Aspect::Pointcut ();

our $VERSION = '0.97_01';
our @ISA     = 'Aspect::Pointcut';

use constant ORIGINAL     => 0;
use constant COMPILE_CODE => 1;
use constant RUNTIME_CODE => 2;
use constant COMPILE_EVAL => 3;
use constant RUNTIME_EVAL => 4;





######################################################################
# Constructor Methods

# The constructor stores three values.
# $self->[0] is the original specification provided to the constructor
# $self->[1] is a function form of the condition that has a sub name passed
#            in and returns true if matching or false if not.
# $self->[2] is a either a string that is a fragment of Perl that can be eval'ed
#            with $_ set to a join point object, or a function in the style of
#            the $self->[1] param above and taking the sub name param. Returns
#            true if matching or false if not.
sub new {
	my $class = shift;
	my $spec  = shift;
	if ( Params::Util::_STRING($spec) ) {
		my $string = '"' . quotemeta($spec) . '"';
		return bless [
			$spec,
			eval "sub () { \$_[0] eq $string }",
			eval "sub () { \$_ eq $string }",
			eval "sub () { \$_->{sub_name} eq $string }",
			"\$_ eq $string",
			"\$_->{sub_name} eq $string",
		], $class;
	}
	if ( Params::Util::_CODELIKE($spec) ) {
		return bless [
			$spec,
			$spec,
			sub { $spec->($_) },
			sub { $spec->($_->{sub_name}) },
			sub { $spec->($_) },
			sub { $spec->($_->{sub_name}) },
		], $class;
	}
	if ( Params::Util::_REGEX($spec) ) {
		# Special case serialisation of regexs
		# In Perl 5.13.6 the format of a serialised regex changed
		# incompatibly. Worse, the optimisation trick that worked
		# before no longer works after, as there are now modifiers
		# that are ONLY value inside and can't be moved to the end.
		# So we first serialise to a form that will be valid code
		# under the new system, and then do the replace that will
		# only match (and only be valid) under the old system.
		my $regex = "/$spec/";
		$regex =~ s|^/\(\?([xism]*)-[xism]*:(.*)\)/\z|/$2/$1|s;
		return bless [
			$spec,
			eval "sub () { \$_[0] =~ $regex }",
			eval "sub () { $regex }",
			eval "sub () { \$_->{sub_name} =~ $regex }",
			$regex,
			"\$_->{sub_name} =~ $regex",
		], $class;
	}
	Carp::croak("Invalid function call specification");
}





######################################################################
# Weaving Methods

sub match_runtime {
	return 0;
}

# Call pointcuts curry away to null, because they are the basis
# for which methods to hook in the first place. Any method called
# at run-time has already been checked.
sub match_curry {
	return;
}

# Compiled string form of the pointcut
sub compile_weave {
	$_[0]->[4];
}

# Compiled string form of the pointcut
sub compile_runtime {
	$_[0]->[5];
}

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::Call - Call pointcut

=head1 SYNOPSIS

  use Aspect;
  
  # High-level creation
  my $pointcut1 = call 'one';
  
  # Manual creation
  my $pointcut2 = Aspect::Pointcut::Call->new('one');

=head1 DESCRIPTION

None yet.

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
