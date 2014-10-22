package Aspect::Pointcut::Call;

use strict;
use warnings;
use Carp             ();
use Params::Util     ();
use Aspect::Pointcut ();

our $VERSION = '0.42';
our @ISA     = 'Aspect::Pointcut';





######################################################################
# Constructor Methods

sub new {
	bless [ $_[0]->spec($_[1]) ], $_[0];
}

# Generate a match specification
sub spec {
	my $it = $_[1];
	Params::Util::_STRING($it)   and return sub { $_[0] eq $it };
	Params::Util::_REGEX($it)    and return sub { $_[0] =~ $it };
	Params::Util::_CODELIKE($it) and return $it;
	Carp::croak("Invalid function call specification");
}





######################################################################
# Weaving Methods

sub match_define {
	$_[0]->[0]->($_[1]);
}

# Call pointcuts curry away to null, because they are the basis
# for which methods to hook in the first place. Any method called
# at run-time has already been checked.
sub curry_run {
	return;
}





######################################################################
# Runtime Methods

# Because we now curry away this pointcut, theoretically we should just
# return true. But if it is ever run inside a negation it returns false
# results. So since this should never be run due to currying leave the
# method resolving to the parent class die'ing stub.
# Having this method die will allow us to more easily catch places where
# this method is being called incorrectly.
# sub match_run { 1 }

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::Call - Call pointcut

=head1 SYNOPSIS

    Aspect::Pointcut::Call->new;

=head1 DESCRIPTION

None yet.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 SEE ALSO

You can find AOP examples in the C<examples/> directory of the
distribution.

=head1 COPYRIGHT AND LICENSE

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2010 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
