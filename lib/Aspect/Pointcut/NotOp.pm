package Aspect::Pointcut::NotOp;

use strict;
use warnings;
use Aspect::Pointcut ();

our $VERSION = '0.27';
our @ISA     = 'Aspect::Pointcut';

sub new {
	bless [ $_[1] ], $_[0];
}

sub match_define {
	return ! shift->[0]->match_define(@_);
}

sub match_run {
	return ! shift->[0]->match_run(@_);
}

1;

__END__

=pod

=head1 NAME

Aspect::Pointcut::NotOp - Logical 'not' operation pointcut

=head1 SYNOPSIS

    Aspect::Pointcut::NotOp->new;

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
