package Aspect::Singleton;

use base 'Aspect::Modular';
use Class::MethodMaker
    get_set => 'class';
use Aspect qw(advice calls returns);

our $VERSION = '0.06';

sub define {
	my ($self, $class) = @_;
	print "def singleton for $class\n" if $::debug;
	$self->class($class);

	# see the INTERNALS section of the documentation below

	my $cons = $class . '::new';   # constructor name
	$self->handlers_push(
	    advice(calls($cons), sub {
	    	my $class = ref $_[0] || $_[0];
		$_[-1] = $Aspect::Singleton::cache{$class}
		    if $Aspect::Singleton::cache{$class}
	    }),
	    advice(returns($cons), sub {
	    	my $class = ref $_[0] || $_[0];
		$Aspect::Singleton::cache{$class} = $_[-1]
	    }),
	);
	$self->enable;
}

sub enable {
	my $self = shift;
	$self->SUPER::enable($self->class);
}

sub disable {
	my $self = shift;
	$self->SUPER::disable($self->class);
}

1;

__END__

=head1 NAME

Aspect::Singleton - Modular aspect to force singleton behavior on a class

=head1 SYNOPSIS

  use Aspect::Singleton;

  my $s = Aspect::Singleton->new('Foo');

  my $f1 = Foo->new;
  my $f2 = Foo->new;

  # now $f1 and $f2 refer to the same object

=head1 DESCRIPTION

This class implements a modular aspect that forces singleton behavior
on a class.

=head1 METHODS

This class inherits from C<Aspect::Modular>. In addition, it
implements and/or overrides the following methods:

=over 4

=item C<define(STRING)>

Creates and enables advice that implements the singleton behavior for
the given class. The class can only be specified as a string.

=item C<class([class])>

Gets, if called without an argument, or sets, if called with an
argument, the package name of the class to be affected. It is set
automatically by C<define()>; setting it afterwards has no effect.

=item C<enable()>

Calls the superclass's C<enable()> method with the class name as
an argument, which in effect restricts the search for possible join
points to that class only, thereby saving time.

=item C<disable()>

Calls the superclass's C<disable()> method with the class name as
an argument, which in effect restricts the search for possible join
points to that class only, thereby saving time.

=back

=head1 INTERNALS

This aspect consists of two pieces of advice for each affected
class:

=over 4

=item *

When calling the constructor, check whether we hold its object in
cache. If so, return it. If not, let it go ahead and construct one.

=item *

When exiting from the constructor, which can only happen once when
the singleton object is created, take the newly created object and
put it into the cache.

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
