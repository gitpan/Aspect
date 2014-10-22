package Aspect::Pointcut::Call;

use strict;
use warnings;
use Carp             ();
use Params::Util     ();
use Aspect::Pointcut ();

our $VERSION = '0.45';
our @ISA     = 'Aspect::Pointcut';





######################################################################
# Constructor Methods

sub new {
	my $class = shift;
	my $spec  = shift;
	if ( Params::Util::_STRING($spec) ) {
		my $perl = '$_->{sub_name} eq "' . quotemeta($spec) . '"';
		return bless [ $spec, sub { $_[0] eq $spec }, $perl ], $class;
	}
	if ( Params::Util::_CODELIKE($spec) ) {
		return bless [ $spec, $spec, $spec ], $class;
	}
	unless ( Params::Util::_REGEX($spec) ) {
		Carp::croak("Invalid function call specification");
	}

	# Special case serialisation of regexs
	my $perl = "$spec";
	$perl =~ s|^\(\?([xism]*)-[xism]*:(.*)\)\z|\$_->{sub_name} =~ m/$2/$1|s;
	return bless [ $spec, sub { $_[0] =~ $spec }, $perl ], $class;
}





######################################################################
# Weaving Methods

sub match_define {
	$_[0]->[1]->($_[1]);
}

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
sub match_compile {
	$_[0]->[2];
}





######################################################################
# Runtime Methods

# Because we now curry away this pointcut, theoretically we should just
# return true. But if it is ever run inside a negation it returns false
# results. So since this should never be run due to currying leave the
# method resolving to the parent class die'ing stub.
# Having this method die will allow us to more easily catch places where
# this method is being called incorrectly.
sub match_run {
	$_[0]->[1]->( $_[1]->{sub_name} );
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

Some parts copyright 2009 - 2010 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
