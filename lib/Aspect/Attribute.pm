package Aspect::Attribute;

use Attribute::Handlers;
use Aspect qw(advice calls returns around);

our $VERSION = '0.06';

sub make_advice {
	my ($cutter, $cuttype, $pkg, $sym, $ref, $data) = @_[0..4,6];
	no warnings 'once';
	$::advice{ $pkg . '::' . *{$sym}{NAME} }{$data}{$cuttype} =
	    advice($cutter->($data), $ref)->enable;
}

sub UNIVERSAL::Before : ATTR(CODE) { make_advice(\&calls,   'calls',   @_) }
sub UNIVERSAL::After  : ATTR(CODE) { make_advice(\&returns, 'returns', @_) }
sub UNIVERSAL::Around : ATTR(CODE) { make_advice(\&around,  'around',  @_) }

1;

__END__

=head1 NAME

Aspect::Attribute - attribute interface to creating advice

=head1 SYNOPSIS

  use Aspect::Attribute;
  sub report : Around(qr/^Foo::/) { print "$::thisjp\n" }

=head1 DESCRIPTION

This module defines an attribute interface for creating advice. It
is just another interface to aspects; you can just as well construct
pointcuts and advice directly, or using the convenience functions
provided by C<Aspect>.

The universally accessible attributes defined by this module are:

=over 4

=item C<:Before>

This code attribute (i.e., it can only be used on subroutines)
defines the subroutine as a call join point handler for the pointcut
given in the attribute's argument. The argument can be a string,
pointcut or coderef, just as C<calls()> (from the C<Aspect> module)
accepts.

=item C<:After>

This code attribute is like C<:Before>, except that it defines the
subroutine as a return join point handler.

=item C<:Around>

This code attribute is like C<:Before>, except that it defines the
subroutine as both a calls and return join point handler.

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel Grunauer, <marcel@codewerk.com>

=head1 COPYRIGHT

Copyright 2001 Marcel Grunauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm).

=cut
