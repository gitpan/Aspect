#!/usr/bin/perl

=pod

Here's an idea. Aspects can be used to explicitly, in a declarative
way, specify relationships between objects. In a way, that's what
design patterns do.

So we're looking at a fictitious set of user interface widgets;
there's a Widget class from which all widgets derive. We have a
Listbox class that can hold a list of options, one of which is
selected. We also have a Textbox class. And there's a Dialog class
that holds both a textbox and a listbox.

So far so good. If you look at the implementation of all those
classes you'll notice that they don't know anything about each
other.

How these classes interact with each other is specified explicitly
using an aspect. This particular aspect consists of three pieces
of advice:

(a1) When a listbox or textbox is assigned to a dialog, said box
is told who its parent is.

(a2) When an option on the listbox is selected, its dialog's
associated textbox is told about that text as well.

(a3) When a textbox's text is set, it is told to redraw or update
itself, which in this simple example just prints a line to STDOUT.

So the basic ideas here is that aspects can specify interrelationships
between objects in a declarative way.

Ideas? Comments?

=cut

use warnings;
use strict;
use Aspect::Attribute;

package Widget;
use Class::MethodMaker
    new_with_init => 'new',
    get_set => [ -eiffel => 'parent' ];

sub init {
	my $self = shift;
	while (my ($prop, $value) = splice(@_, 0, 2)) {
		$prop = "set_$prop" if $self->can("set_$prop");
		$self->$prop(ref $value eq 'ARRAY' ? @$value : $value);
	}
	
}

sub update {}


package Dialog;
use base 'Widget';
use Class::MethodMaker
    get_set => [ -eiffel => qw/listbox textbox/ ];

sub update {
	my $self = shift;
	$self->listbox->update;
	$self->textbox->update;
}


package Listbox;
use base 'Widget';
use Class::MethodMaker
    list    => 'options',
    get_set => [ -eiffel => 'select' ];


package Textbox;
use base 'Widget';
use Class::MethodMaker
    get_set => [ -eiffel => 'text' ];

sub update { printf "Text [ %20s ]\n", $_[0]->text }


package main;

sub a1 : Before(qr/^Dialog::set_(list|box)box$/) { $_[1]->set_parent($_[0]) }
sub a2 : Before('Listbox::set_select') {
	$_[0]->parent->textbox->set_text($_[0]->options_index($_[1])) }
sub a3 : After('Textbox::set_text') { $_[0]->update }

# Now the test...

my $listbox = Listbox->new(options => [ qw/Courier Helvetica Monaco/ ]);

my $font_dialog = Dialog->new(
    listbox => $listbox,
    textbox => Textbox->new,
);

for (0..2) {
	print "selecting option $_\n";
	$listbox->set_select($_);
}

__END__

output:

selecting option 0
Text [              Courier ]
selecting option 1
Text [            Helvetica ]
selecting option 2
Text [               Monaco ]

