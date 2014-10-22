package Aspect;

require 5.008002;

use strict;
use warnings;
use Carp;
use Aspect::Advice;
use Aspect::Pointcut::Call;
use Aspect::Pointcut::Cflow;

use base 'Exporter';

our $VERSION = '0.12';
our @EXPORT  = qw(aspect before after call cflow);

my (@Aspect_Store, @Advice_Store);

sub aspect {
	my ($name, @params) = @_;
	$name = "Aspect::Library::$name";
	runtime_use($name);
	my $aspect = $name->new(@params);
	# if called in void context, aspect is for life
	push @Aspect_Store, $aspect unless defined wantarray;
	return $aspect;
}

sub call   ($)  { Aspect::Pointcut::Call ->new(@_) }
sub cflow  ($$) { Aspect::Pointcut::Cflow->new(@_) }

sub before (&$) { advice(before => @_) }
sub after  (&$) { advice(after  => @_) }

sub advice {
	my $advice = Aspect::Advice->new(@_);
	# if called in void context, advice is for life
	push @Advice_Store, $advice unless defined wantarray;
	return $advice;
}

sub runtime_use {
	my $package = shift;
	eval "use $package;";
	croak "Cannot use [$package]: $@" if $@;
}

1;

=head1 NAME

Aspect - AOP for Perl

=head1 SYNOPSIS

  package Person;
  sub create      { ... }
  sub set_name    { ... }
  sub get_address { ... }

  package main;
  use Aspect;

  # using reusable aspects
  aspect Singleton => 'Person::create';        # let there be only one Person
  aspect Profiled  => call qr/^Person::set_/;  # profile calls to setters

  # append extra argument when Person::get_address is called:
  # the instance of the calling Company object, iff get_address
  # is in the call flow of Company::get_employee_addresses.
  # aspect will live as long as $wormhole reference is in scope
  $aspect = aspect Wormhole => 'Company::make_report', 'Person::get_address';

  # writing your own advice
  $pointcut = call qr/^Person::[gs]et_/; # defines a collection of events

  # advice will live as long as $before is in scope
  $before = before { print "g/set will soon be called"  } $pointcut;

  # advice will live forever, because it is created in void context 
  after { print "g/set has just been called" } $pointcut;

  before
     { print "get will soon be called, if in call flow of Tester::run_tests" }
     call qr/^Person::get_/ & cflow tester => 'Tester::run_tests';

=head1 DESCRIPTION

Aspect-oriented Programming (AOP) is a programming method developed by
Xerox PARC and others. The basic idea is that in complex class systems
there are certain aspects or behaviors that cannot normally be expressed
in a coherent, concise and precise way. One example of such aspects are
design patterns, which combine various kinds of classes to produce a
common type of behavior. Another is logging. See L<http://www.aosd.net>
for more info.

The Perl C<Aspect> module closely follows the terminology of the AspectJ
project (L<http://eclipse.org/aspectj>). However due to the dynamic
nature of the Perl language, several C<AspectJ> features are useless for
us: exception softening, mixin support, out-of-class method declarations,
and others.

The Perl C<Aspect> module is focused on subroutine matching and wrapping.
It allows you to select collections of subroutines using a flexible
pointcut language, and modify their behavior in any way you want.

=head1 TERMINOLOGY 

=over

=item Join Point

An event that occurs during the running of a program. Currently only
calls to subroutines are recognized as join points.

=item Pointcut

An expression that selects a collection of join points. For example: all
calls to the class C<Person>, that are in the call flow of some
C<Company>, but I<not> in the call flow of C<Company::make_report>.
C<Aspect> supports C<call()>, and C<cflow()> pointcuts, and logical
operators (C<&>, C<|>, C<!>) for constructing more complex pointcuts. See
the L<Aspect::Pointcut> documentation.

=item Advice

A pointcut, with code that will run when it matches. The code can be run
before or after the matched sub is run.

=item Advice Code

The code that is run before or after a pointcut is matched. It can modify
the way that the matched sub is run, and the value it returns.

=item Weave

The installation of advice code on subs that match a pointcut. Weaving
happens when you create the advice. Unweaving happens when the advice
goes out of scope.

=item The Aspect

An object that installs advice. A way to package advice and other Perl
code, so that it is reusable.

=back

=head1 FEATURES

=over

=item *

Create and remove pointcuts, advice, and aspects.

=item *

Flexible pointcut language: select subs to match using string equality,
regexp, or C<CODE> ref. Match currently running sub, or a sub in the call
flow. Build pointcuts composed of a logical expression of other
pointcuts, using conjunction, disjunction, and negation.

=item *

In advice code, you can: modify parameter list for matched sub, modify
return value, decide if to proceed to matched sub, access C<CODE> ref for
matched sub, and access the context of any call flow pointcuts that were
matched, if they exist.

=item *

Add/remove advice and entire aspects during run-time. Scope of advice and
aspect objects, is the scope of their effect.

=item *

A reusable aspect library. The L<Wormhole|Aspect::Library::Wormhole>,
aspect, for example. A base class makes it easy to create your own
reusable aspects. The L<Memoize|Aspect::Library::Memoize> aspect is an
example of how to interface with APOish modules from CPAN.

=back

=head1 WHY

Perl is a highly dynamic language, where everything this module does can
be done without too much difficulty. All this module does, is make it
even easier, and bring these features under one consistent interface. I
have found it useful in my work in several places:

=over

=item *

Saves me from typing an entire line of code for almost every
C<Test::Class> test method, because I use the
L<TestClass|Aspect::Library::TestClass> aspect.

=item *

I use the L<Wormhole|Aspect::Library::Wormhole> aspect, so that my
methods can aquire implicit context, and so I don't need to pass too many
parameters all over the place. Sure I could do it with C<caller()> and
C<Hook::LexWrap>, but this is much easier.

=item *

Using custom advice to modify class behavior: register objects when
constructors are called, save object state on changes to it, etc. All
this, while cleanly separating these concerns from the effected class.
They exist as an independant aspect, so the class remains unpoluted.

=back

The C<Aspect> module is different from C<Hook::Lexwrap> (which it uses
for the actual wrapping) in two respects:

=over

=item *

Select join points using flexible pointcut language instead of the sub
name. For example: select all calls to C<Account> objects that are in the
call flow of C<Company::make_report>.

=item *

More options when writing the advice code. You can, for example, run the
original sub, or append parameters to it.

=back

=head1 USING

This package is a facade on top of the Perl AOP framework. It allows you
to create pointcuts, advice, and aspects. You will be mostly working with
this package (C<Aspect>), and the L<advice
context|Aspect::AdviceContext> package.

When you use this package:

  use Aspect;

You will import five subs: C<call()>, C<cflow()>, C<before()>,
C<after()>, and C<aspect()>. These are all factories that allow you to
create pointcuts, advice, and aspects.

=head2 POINTCUTS

Poincuts select join points, so that an advice can run code when they
happen. The simplest pointcut is C<call()>. For example:

  $p = call 'Person::get_address';

Selects the calling of C<Person::get_address()>, as defined in the symbol
table during weave-time. The string is a pointcut spec, and can be
expressed in three ways:

=over

=item string

Select only the sub whose name is equal to the spec string.

=item regexp

Select only the subs whose name matches the regexp. The following will
match all the subs defined on the C<Person> class, but not on
the C<Person::Address> class.

  $p = call qr/^Person::\w+$/;

=item C<CODE> ref

Select only subs, where the supplied code, when run with the sub name as
only parameter, returns true. The following will match all calls to
subs whose name isa key in the hash C<%subs_to_match>:

  $p = call sub { exists $subs_to_match{shift()} }

=back

Pointcuts can be combined to form logical expressions, because they
overload C<&>, C<|>, and C<!>, with factories that create composite
pointcut objects. Be careful not to use the non-overloadable C<&&>, and
C<||> operators, because you will get no error message.

Select all calls to C<Person>, which are not calls to the constructor:

  $p = call qr/^Person::\w+$/ & !call 'Person::create';

The second pointcut you can use, is C<cflow()>. It selects only the subs
that are in call flow of its spec. Here we select all calls to C<Person>,
only if they are in the call flow of some method in C<Company>:

  $p = call qr/^Person::\w+$/ & cflow company => qr/^Company::\w+$/;

The C<cflow()> pointcut takes two parameters: a context key, and a
pointcut spec. The context key is used in advice code to access the
context (params, sub name, etc.) of the sub found in the call flow. In
the example above, the key can be used to access the name of the specific
sub on C<Company> that was found in the call flow of the C<Person>
method.The second parameter is a pointcut spec, that should match the sub
required from the call flow.

See the L<Aspect::Pointcut> docs for more info.

=head2 ADVICE

An advice is just some definition of code that will run on a match of
some pointcut. An advice can run before the pointcut matched sub is run,
or after. You create advice using C<before()>, and C<after()>. These take
a C<CODE> ref, and a pointcut, and install the code on the subs that
match the pointcut. For example:

  after { print "Person::get_address has returned!\n" }
     call 'Person::get_address';

The advice code is run with one parameter: the advice context. You use it
to learn how the matched sub was run, modify parameters, return value,
and if it is run at all. You also use the advice context to access any
context objects that were created by any matching C<cflow()> pointcuts.
This will print the name of the C<Company> that started the call flow
which evetually reached C<Person::get_address()>:

  before { print shift->company->name }
     call 'Person::get_address' & cflow company => qr/^Company::w+$/;

See the L<Aspect::AdviceContext> docs for some more examples of advice
code.

Advice code is applied to matching pointcuts (i.e. the advice is enabled)
as long as the advice object is in scope. This allows you to neatly
control enabling and disabling of advice:

  {
     my $advice = before { print "called!\n" } $pointcut;
     # do something while the device is enabled
  }
  # the advice is now disabled

If the advice is created in void context, it remains enabled until the
interperter dies, or the symbol table reloaded.

=head2 ASPECTS

Aspects are just plain old Perl objects, that install advice, and do
other AOPish things, like install methods on other classes, or mess
around with the inheritance hierarchy of other classes. A good base class
for them is L<Aspect::Modular>, but you can use any Perl object.

If the aspect class exists in the package C<Aspect::Library>, then it can
be easily created:

  aspect Singleton => 'Company::create';

Will create an L<Aspect::Library::Singleton> object. This reusable aspect
is included in the C<Aspect> distribution, and forces singleton behavior
on some constructor, in this case, C<Company::create()>.

Such aspects, like advice, are enabled as long as they are in scope.

=head1 INTERNALS

Due to the dynamic nature of Perl, and thanks to C<Hook::LexWrap>, there
is no need for processing of source or byte code, as required in the Java
and .NET worlds.

The implementation is very simple: when you create advice, its pointcut
is matched using C<match_define()>. Every sub defined in the symbol table
is matched against the pointcut. Those that match, will get a special
wrapper installed, using C<Hook::LexWrap>. The wrapper only runs if
during run-time, the C<match_run()> of the pointcut returns true.

The wrapper code creates an advice context, and gives it to the advice
code.

The C<call()> pointcut is static, so C<match_run()> always returns true,
and C<match_define()> returns true if the sub name matches the pointcut
spec.

The C<cflow()> pointcut is dynamic, so C<match_define()> always returns
true, but C<match_run()> return true only if some frame in the call flow
matches the pointcut spec.

=head1 LIMITATIONS

=over

=item Inheritance Support

Support for inheritance is lacking. Consider the following two classes:

  package Automobile;
  ...
  sub compute_mileage { ... }

  package Van;
  use base 'Automobile';

And the following two advice:

  before { print "Automobile!\n" } call 'Automobile::compute_mileage';
  before { print "Van!\n"        } call 'Van::compute_mileage';

Some join points one would expect to be matched by the call pointcuts
above, do not:

  $automobile = Automobile->new;
  $van = Van->new;
  $automobile->compute_mileage; # Automobile!
  $van->compute_mileage;        # Automobile!, should also print Van!

C<Van!> will never be printed. This happens because C<Aspect> installs
advice code on symbol table entries. C<Van::compute_mileage> does not
have one, so nothing happens. Until this is solved, you have to do the
thinking about inheritance yourself.

=item Performance

You may find it very easy to shoot yourself in the foot with this module.
Consider this advice:

  # do not do this!
  before { print shift->sub_name }
     cflow company => 'MyApp::Company::make_report';

The advice code will be installed on every sub loaded. The advice code
will only run when in the specified call flow, which is the correct
behavior, but it will be I<installed> on every sub in the system. This
can be slow. It happens because the C<cflow()> pointcut matches I<all>
subs during weave-time. It matches the correct sub during run-time. The
solution is to narrow the pointcut:

  # much better
  before { print shift->sub_name }
     call qr/^MyApp::/ & cflow company => 'MyApp::Company::make_report';

=back

See the C<TODO> file in the distribution for possible solutions.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
maintainer.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel@cpan.org>, Ran Eilam <eilara@cpan.org>.

=head1 COPYRIGHT

Copyright 2001-2002 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

You can find AOP examples in the C<examples/> directory of the
distribution.

=cut
