package Aspect::Modular;

use Class::MethodMaker
    new_with_init => 'new',
    list          => 'handlers';

our $VERSION = '0.04';

sub init {
	my $self = shift;
	return unless @_;
	$self->define(@_);
}

# This is where you set up the advice.
# Implement this in subclasses.

sub define {}

sub enable {
	my $self = shift;
	$_->enable(@_) for $self->handlers;
}

sub disable {
	my $self = shift;
	$_->disable(@_) for $self->handlers;
}

1;

__END__

=head1 NAME

Aspect::Modular - Base class for modular aspects

=head1 SYNOPSIS

  use base 'Aspect::Modular';
  use Aspect qw(advice calls returns);

  sub define {
    my ($self, $spec) = @_;
    $self->handlers_push(
      advice(calls($spec),   sub { ... }),
      advice(returns($spec), sub { ... })
    );
    $self->enable;
  }

=head1 DESCRIPTION

This is the base class for modular aspects. Specific modular aspects
need to override the C<define()> method at least.

=head1 METHODS

This class implements the following methods:

=over 4

=item C<new([args])>

This is the constructor. It creates the object, then calls C<init()>
to handle any arguments that were passed to the constructor.

=item C<init([args])>

This method initializes newly constructed objects. Since a modular
aspect most likely, when instantiated, wants to create and enable
some advice, it calls the C<define()> method with the same arguments
as C<init()> got itself.

=item C<define(spec)>

This method should be overridden in subclasses and create and enable
the advice necessary to implement the modular aspect. All advice
should be pushed onto the object's handler array using C<handler_push()>.
See subclasses for examples.

=item C<enable([packages])>

=item C<disable([packages])>

=item C<handlers()>

Each aspect object stores lexical handlers created by installing
advice code on join points in an array called C<handlers>. For
example, call and return join points install advice by wrapping
the affected subroutine using C<Hook::LexWrap>. Those wrappers are
lexically bound, so if we want to disable them and restore the
subroutine to its original state, all we need to do is to let the
handlers go out of scope. See the C<Hook::LexWrap> manpage for
details. Obviously, if the modular aspect goes out of scope, so do
the handlers.

Access to these handlers is defined via a C<list> property created
by C<Class::MethodMaker>.

This accessor returns the handlers. In an array context it returns
them as an array and in scalar context as a reference to the array.

=item C<handlers_push(advice)>

Pushes a list of handlers onto the handlers array. Cf. C<push()>
in perlfunc.

=item C<handlers_pop()>

Pops an entry off the handlers array and returns it. Cf. C<pop()>
in perlfunc.

=item C<handlers_shift(advice)>

Shifts a list of handlers onto the handlers array. Cf. C<shift()>
in perlfunc.

=item C<handlers_unshift()>

Unshifts an entry off the handlers array and returns it. Cf.
C<unshift()> in perlfunc.

=item C<handlers_splice()>

Splices the handlers array. Cf. C<splice()> in perlfunc.

=item C<handlers_clear()>

Clears the handlers array.

=item C<handlers_count()>

Returns the number of elements in x.

=item C<handlers_index(indices)>

Takes a list of indices, returns a list of the corresponding values.

=item C<handlers_set(list)>

Takes a list, treated as pairs of index => value; each given index
is set to the corresponding value. No return value.

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
