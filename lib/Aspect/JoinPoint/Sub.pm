package Aspect::JoinPoint::Sub;

# $Id: Sub.pm,v 1.3 2002/07/31 21:29:18 marcelgr Exp $
#
# $Log: Sub.pm,v $
# Revision 1.3  2002/07/31 21:29:18  marcelgr
# changed version number to 0.08
#
# Revision 1.2  2002/07/31 21:03:20  marcelgr
# changed e-mail address; other changes for version 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use base 'Aspect::JoinPoint';
use Class::MethodMaker
    get_set => 'sub';

our $VERSION = '0.08';

sub init {
	my $self = shift;
	return unless @_;
	$self->sub(+shift);
}

sub signature {
	my $self = shift;

	# assume we're called from a wrapper where the last arg is
	# the return value and not part of the original args

	my $args = 
	    join ', ' =>
	    map { defined $_ ? $_ : 'undef' }
	    @_[0..$#_-1];
	$self->sub() . "($args)";
}

1;

__END__

=head1 NAME

Aspect::JoinPoint::Sub - Superclass for subroutine-based join points

=head1 SYNOPSIS

There is no synopsis, as this class is only used within Aspects;
if you develop Aspect internals, you'll know how to use it. If not,
you don't need to. If you're curious, read the source.

=head1 DESCRIPTION

This class is a superclass for subroutine-based join points, that is, call join points and return join points.

=head1 METHODS

This class inherits from C<Aspect::JoinPoint>. In addition, it implements
and/or overrides the following methods:

=over 4

=item C<init([STRING])>

This method initializes newly constructed objects. The optional
argument is handed to C<sub()>.

=item C<sub([STRING])>

Gets or sets (if called with an argument) the name of the subroutine
this join points belongs to.

=item C<signature(LIST)>

Returns a string describing a call to the subroutine given the
argument list. This list is expected to come from a C<Hook::LexWrap>
wrapper argument list, so the last list element is discarded as it
indicates the potential return value. See C<Hook::LexWrap> for
details.

This method is useful for tracing subroutine calls.

Example: If the join point's subroutine name is C<foo> and the
argument list is C<(1, 'hello')> then the signature would be C<foo(1,
hello)>.

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel@cpan.org>

=head1 COPYRIGHT

Copyright 2001-2002 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm).

=cut
