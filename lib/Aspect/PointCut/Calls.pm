package Aspect::PointCut::Calls;

use strict;
use warnings;
use base 'Aspect::PointCut::Sub';

our $VERSION = '0.06';

sub join_point_type { 'Aspect::JoinPoint::Call' }

1;

__END__

=head1 NAME

Aspect::PointCut::Calls - Represents a calls() pointcut operator

=head1 SYNOPSIS

There is no synopsis, as this class is only used within Aspects;
if you develop Aspect internals, you'll know how to use it. If not,
you don't need to. If you're curious, read the source.

=head1 DESCRIPTION

This class represents a pointcut of call join points whose subroutine
name matches a given criteria. An object of this type is most
commonly constructed using the C<calls()> function, or pointcut
operator, that is provided by the C<Aspect> module.

The match criteria can be given as an argument to the constructor
or set explicitly with the C<spec> method.

=head1 METHODS

This class inherits from C<Aspect::PointCut::Sub>. In addition, it
implements and/or overrides the following methods:

=over 4

=item C<new([STRING|REGEX|CODEREF])>

This is the constructor. It can optionally be given a pointcut
specification, which will be passed to the C<spec> method.

=item C<spec(STRING|REGEX|CODEREF)>

This method sets or returns (if called without arguments) the
pointcut's specifier. This pointcut matches call join points at
which the called sub's name matches the argument. "Matches" here
means that if the argument is a literal string, then the condition
must be exactly the same to match. If the argument is a regex, then
the condition is matched against it. And if the argument is a
coderef, it is executed with the condition as an argument and the
return value is taken as a boolean value of whether there was a
match or not.

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
