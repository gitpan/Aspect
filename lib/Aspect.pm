package Aspect;

=pod

=head1 NAME

Aspect - Aspect-Oriented Programming (AOP) for Perl

=head1 SYNOPSIS

  use Aspect;
  
  # Run some code "Advice" before a particular function
  before {
      print "About to call create\n";
  } call 'Person::create';
  
  # Run Advice after several methods and hijack their return values
  after {
      print "Called getter/setter " . $_->sub_name . "\n";
      $_->return_value(undef);
  } call qr/^Person::[gs]et_/;
  
  # Run Advice conditionally based on multiple factors
  before {
      print "Calling a get method in void context within Tester::run_tests";
  } wantvoid
  & ( call qr/^Person::get_/ & ! call 'Person::get_not_trapped' )
  & cflow 'Tester::run_tests';
  
  # Context-aware runtime hijacking of a method if certain condition is true
  around {
      if ( $_->self->customer_name eq 'Adam Kennedy' ) {
          # Ensure I always have cash
          $_->return_value('One meeeelion dollars');
      } else {
          # Take a dollar off everyone else
          $_->proceed;
          $_->return_value( $_->return_value - 1 );
      }
  } call 'Bank::Account::balance';
  
  # Catch and handle unexpected exceptions in a function into a formal object
  after {
      $_->exception(
          Exception::Unexpected->new($_->exception)
      );
  } throwing()
  & ! throwing('Exception::Expected')
  & ! throwing('Exception::Unexpected');
  
  # Run Advice only on the outmost of a recursive series of calls
  around {
    print "Starting recursive child search\n";
    $_->proceed;
    print "Finished recursive child search\n";
  } call 'Person::find_child' & highest;
  
  # Run Advice only during the current lexical scope
  SCOPE: {
      my $hook = before {
          print "About to call create\n";
      } call 'Person::create';
      Person->create('Bob'); # Advice will run
  }
  Person->create('Tom'); # Advice won't run
  
  # Use a pre-packaged collection "Aspect" of Advice rules to change a class
  aspect Singleton => 'Foo::new';
  
  # Define debugger breakpoints with high precision and conditionality
  aspect Breakpoint => call qr/^Foo::.+::Bar::when_/ & wantscalar & highest;

=head1 DESCRIPTION

=head2 What is Aspect-Oriented Programming?

Aspect-Oriented Programming (AOP) is a programming paradigm which aims to
increase modularity by allowing the separation of "cross-cutting "concerns.

It includes programming methods and tools that support the modularization of
concerns at the level of the source code, while "aspect-oriented software
development" refers to a whole engineering discipline.

Aspect-Oriented Programming (AOP) allows you to modularise code for issues that
would otherwise be spread across many parts of a program and be problematic to
both implement and maintain.

Logging exemplifies a crosscutting concern because a logging strategy
necessarily affects every logged part of the system. Logging thereby "crosscuts"
all logged classes and methods.

Typically, an aspect is scattered or tangled as code, making it harder to
understand and maintain. It is scattered by virtue of the function (such as
logging) being spread over a number of unrelated functions that might use its
function, possibly in entirely unrelated systems

That means to change logging can require modifying all affected modules. Aspects
become tangled not only with the mainline function of the systems in which they
are expressed but also with each other. That means changing one concern entails
understanding all the tangled concerns or having some means by which the effect
of changes can be inferred.

Because Aspect-Oritented Programming moves this scattered code into a single
module which is loaded as a single unit, another major benefit of this method
is conditional compilation.

Features implemented via Aspects can be compiled and added to you program only
in certain situations, and because of this Aspects are useful when debugging
or testing large or complex programs.

Aspects can implement features necessary for correctness of programs such as
reactivity or synchronisation, and can be used to add checking assertions
to your or other people's modules.

They can cause code to emit useful side effects not considered by the original
author of a module, without changing the original function of the module.

And, if necessary (although not recommended), they can do various types of
"Monkey Patching", hijacking the functionality of some other module in an
unexpected (by the original author) way so that the module acts differently
when used in your program, when those changes might otherwise be dangerous or
if encountered by other programs.

Aspects can be used to implement space or time optimisations. One popular use
case of AOP is to add caching to a module or function that does not natively
implement caching itself.

For more details on Aspect-Oriented Programming in general,
L<http://en.wikipedia.org/wiki/Aspect-oriented_programming> and
L<http://www.aosd.net>.

=head2 About This Implementation

The Perl B<Aspect> module tries to closely follow the terminology of the basic
Java AspectJ project wherever possible and reasonable
(L<http://eclipse.org/aspectj>).

However due to the dynamic nature of the Perl language, several C<AspectJ>
features are useless for us: exception softening, mixin support, out-of-class
method declarations, annotations, and others.

Currently the Perl B<Aspect> module is focused exclusively on subroutine
matching and wrapping.

It allows you to select collections of subroutines and conditions using a
flexible pointcut language, and modify their behavior in any way you want.

In this regard it provides a similar set of functionality to the venerable
L<Hook::LexWrap>, but with much more precision and with much more control and
maintainability as the complexity of the problems you are solving increases.

In addition, where the Java implementation of Aspect-Oriented Programming is
limited to concepts expressable at compile time, the more fluid nature of Perl
means that the B<Aspect> module can weave in aspect code at run-time. Pointcuts
in Perl can also take advantage of run-time information and Perl-specific
features like closures to implement more sophisticated pointcuts than are
possible in Java.

This allows the Perl implementation of Aspect-Oriented Programming to be
stateful and adaptive in a way that Java cannot (although the added power can
come with a significant speed cost if not used carefully).

=head2 Terminology

One of the more opaque aspects (no pun intended) of Aspect-Oriented programming
is that it has an entire unique set of terms that can be confusing for people
learning to use the B<Aspect> module.

In this section, we will attempt to define all the major terms in a way that
will hopefully make sense to Perl programmers.

=head3 What is an Aspect?

An I<Aspect> is a modular unit of cross-cutting implementation, consisting of
"Advice" on "Pointcuts" (we'll define those two shortly, don't worry if they
don't make sense for now).

In Perl, this would typically mean a package or module containing declarations
of where to inject code, the code to run at these points, and any variables or
support functions needed by the injected functionality.

The most critical point here is that the Aspect represents a collection of
many different injection points which collectively implement a single function
or feature and which should be enabled on an all or nothing basis.

For example, you might implement the Aspect B<My::SecurityMonitor> as a module
which will inject hooks into a dozen different strategic places in your
program to watch for valid-but-suspicious values and report these values to
an external network server.

Aspects can often written to be highly reusable, and be released via the CPAN.
When these generic aspects are written in the special namespace
L<Aspect::Library> they can be called using the following special shorthand.

  use Aspect;
  
  # Load and enable the Aspect::Library::NYTProf aspect to constrain profiling
  # to only the object constructors for each class in your program.
  aspect NYTProf => call qr/^MyProgram\b.*::new$/;

=head3 What is a Pointcut?

A I<Join Point> is a well-defined location at a point in the execution of a
program at which Perl can inject functionality, in effect joining two different
bits of code together.

In the Perl B<Aspect> implementation, this consists only of the execution of
named subroutines on the symbol table such as C<Foo::Bar::function_name>.

In other languages, additional join points can exist such as the instantiation
or destruction of an object or the static initialisation of a class.

A I<Pointcut> is a well-defined set of join points, and any conditions that
must be true when at these join points.

Example include "All public methods in class C<Foo::Bar>" or "Any non-recursive
call to the function C<Some::recursive_search>".

We will discuss each of the available pointcut types later in this document.

In addition to the default pointcut types it is possible to write your own
specialised pointcut types, although this is challenging due to the complex
API they follow to allow aggressive multi-pass optimisation.

See L<Aspect::Pointcut> for more information.

=head3 What is Advice?

I<Advice> is code designed to run automatically at all of the join points in
a particular pointcut. Advice comes in several types, instructing that the
code be run C<before>, C<after> or C<around> (in place of) the different join
points in the pointcut.

Advice code is introduced lexically to the target join points. That is, the
new functionality is injected in place to the existing program rather the
class being extended into some new version.

For example, function C<Foo::expensive_calculation> may not support caching
because it is unsafe to do so in the general case. But you know that in the
case of your program, the reasons it is unsafe in the general case don't apply.

So for your program you might use the L<Aspect::Library::Memoise> aspect to
"Weave" Advice code into the C<Foo> class which adds caching to the function
by integrating it with L<Memoise>.

Each of the different advice types needs to be used slightly differently, and
are best employed for different types of jobs. We will discuss the use of each
of the different advice types later in this document.

But in general, the more specific advice type you use, the more optimisation
can be applied to your advice declaration, and the less impact the advice will
have on the speed of your program.

In addition to the default pointcut types, it is (theoretically) possible to
write your own specialised Advice types, although this would be extremely
difficult and probably involve some form of XS programming.

For the brave, see L<Aspect::Advice> and the source for the different advice
classes for more information.

=head3 What is Weaving?

I<Weaving> is the installation of advice code to the subs that match a pointcut,
or might potentially match depending on certain run-time conditions.

In the Perl B<Aspect> module, weaving happens on the declaration of each
advice block. Unweaving happens when a lexically-created advice variable goes
out of scope.

Unfortunately, due to the nature of the mechanism B<Aspect> uses to hook into
function calls, unweaving can never be guarenteed to be round-trip clean.

While the pointcut matching logic and advice code will never be run for unwoven
advice, it may be necessary to leave the underlying hooking artifact in place on
the join point indefinitely (imposing a small performance penalty and preventing
clean up of the relevant advice closure from memory).

Programs that repeatedly weave and unweave during execution will thus gradually
slow down and leak memory, and so is discouraged despite being permitted.

If advice needs to be repeatedly enabled and disabled you should instead
consider using the C<true> pointcut and a variable in the aspect package or
a closure to introduce a remote "on/off" switch for the aspect.

into the advice code.

  package My::Aspect;
  
  my $switch = 1;
  
  before {
      print "Calling Foo::bar\n";
  } call 'Foo::bar' & true { $switch };
  
  sub enable {
      $switch = 1;
  }
  
  sub disable {
      $switch = 0;
  }
  
  1;

Under the covers weaving is done using a mechanism that is very similar to
the venerable L<Hook::LexWrap>, although in some areas B<Aspect> will try to
make use of faster mechanisms if it knows these are safe.

=head2 Feature Summary

=over

=item *

Create permanent pointcuts, advice, and aspects at compile time or run-time.

=item *

Flexible pointcut language: select subs to match using string equality,
regexp, or C<CODE> ref. Match currently running sub, a sub in the call
flow, calls in particular void, scalar, or array contexts, or only the highest
call in a set of recursive calls.

=item *

Build pointcuts composed of a logical expression of other pointcuts,
using conjunction, disjunction, and negation.

=item *

In advice code, you can modify parameter list for matched sub, modify return
value, throw or supress exceptions, decide whether or not to proceed to matched
sub, access a C<CODE> ref for matched sub, and access the context of any call
flow pointcuts that were matched, if they exist.

=item *

Add/remove advice and entire aspects lexically during run-time. The scope of
advice and aspect objects, is the scope of their effect (This does, however,
come with some caveats).

=item *

A basic library of reusable aspects. A base class makes it easy to create your
own reusable aspects. The L<Aspect::Library::Memoize> aspect is an
example of how to interface with AOP-like modules from CPAN.

=back

=head2 Using Aspect.pm

The B<Aspect> package allows you to create pointcuts, advice, and aspects in a
simple declarative fashion. This declarative form is a simple facade on top of
the Perl AOP framework, which you can also use directly if you need the
increased level of control or you feel the declarative form is not clear enough.

For example, the following two examples are equivalent.

  use Aspect;
  
  # Declarative advice creation
  before {
      print "Calling " . $_->sub_name . "\n";
  } call 'Function::one'
  | call 'Function::two';
  
  # Longhand advice creation
  Aspect::Advice::Before->new(
      Aspect::Pointcut::Or->new(
          Aspect::Pointcut::Call->new('Function::one'),
          Aspect::Pointcut::Call->new('Function::two'),
      ),
      sub {
          print "Calling " . $_->sub_name . "\n";
      },
  );

You will be mostly working with this package (B<Aspect>) and the
L<Aspect::Point> package, which provides the methods for getting information
about the call to the join point within advice code.

When you C<use Aspect;> you will import a family of around fifteen
functions. These are all factories that allow you to create pointcuts,
advice, and aspects.

=head2 Back Compatibility

The various APIs in B<Aspect> have changed a few times between older versions
and the current implementation.

By default, none of these changes are available in the current version of the
B<Aspect> module. They can, however, be accessed by providing one of two flags
when loading B<Aspect>.

  # Support for pre-1.00 Aspect usage
  use Aspect ':deprecated';

The C<:deprecated> flag loads in all alternative and deprecated function and
method names, and exports the deprecated C<after_returning>, C<after_throwing>
advice constructors, and the deprecated C<if_true> alias for the C<true>
pointcut.

  # Support for pre-2010 Aspect usage (both usages are equivalent)
  use Aspect ':legacy';
  use Aspect::Legacy;

The C<:legacy> flag loads in all alternative and deprecated functions as per
the C<:deprecated> flag.

Instead of exporting all available functions and pointcut declarators it exports
C<only> the set of functions that were available in B<Aspect> 0.12.

Finally, it changes the behaviour of the exported version of C<after> to add an
implicit C<& returning> to all pointcuts, as the original implementation did not
trap exceptions.

=head1 FUNCTIONS

The following functions are exported by default (and are documented as such)
but are also available directly in Aspect:: namespace as well if needed.

They are documented in order from the simplest and and most common pointcut
declarator to the highest level declarator for enabling complete aspect classes.

=cut

use 5.008002;
use strict;

# Added by eilara as hack around caller() core dump
# NOTE: Now we've switched to Sub::Uplevel can this be removed?
# -- ADAMK
use Carp::Heavy                 ();
use Carp                        ();
use Params::Util           1.00 ();
use Sub::Install           0.92 ();
use Sub::Uplevel         0.2002 ();
use Aspect::Pointcut            ();
use Aspect::Pointcut::Or        ();
use Aspect::Pointcut::And       ();
use Aspect::Pointcut::Not       ();
use Aspect::Pointcut::True      ();
use Aspect::Pointcut::Call      ();
use Aspect::Pointcut::Cflow     ();
use Aspect::Pointcut::Highest   ();
use Aspect::Pointcut::Throwing  ();
use Aspect::Pointcut::Returning ();
use Aspect::Pointcut::Wantarray ();
use Aspect::Advice              ();
use Aspect::Advice::After       ();
use Aspect::Advice::Around      ();
use Aspect::Advice::Before      ();
use Aspect::Point               ();
use Aspect::Point::Static       ();

our $VERSION = '1.03';
our %FLAGS   = ();

# Track the location of exported functions so that pointcuts
# can avoid accidentally binding them.
our %EXPORTED = ();

sub install {
	Sub::Install::install_sub( {
		into => $_[1],
		code => $_[2],
		as   => $_[3] || $_[2],
	} );
	$EXPORTED{"$_[1]::$_[2]"} = 1;
}

sub import {
	my $class  = shift;
	my $into   = caller();
	my %flag   = ();
	my @export = ();

	# Handle import params
	while ( @_ ) {
		my $value = shift;
		if ( $value =~ /^:(\w+)$/ ) {
			$flag{$1} = 1;
		} else {
			push @export, $_;
		}
	}

	# Legacy API and deprecation support
	if ( $flag{legacy} or $flag{deprecated} ) {
		require Aspect::Legacy;
		if ( $flag{legacy} ) {
			return Aspect::Legacy->import;
		}
	}

	# Custom method export list
	if ( @export ) {
		$class->install( $into => $_ ) foreach @export;
		return 1;
	}

	# Install the modern API
	$class->install( $into => $_ ) foreach qw{
		aspect
		before
		after
		around
		call
		cflow
		throwing
		returning
		wantlist
		wantscalar
		wantvoid
		highest
		true
	};

	# Install deprecated API elements
	if ( $flag{deprecated} ) {
		$class->install( $into => $_ ) foreach qw{
			after_returning
			after_throwing
			if_true
		};
	}

	return 1;
}





######################################################################
# Public (Exported) Functions

=pod

=head2 call

  my $single   = call 'Person::get_address';
  my $multiple = call qr/^Person::get_/;
  my $complex  = call sub { lc($_[0]) eq 'person::get_address' };
  my $object   = Aspect::Pointcut::Call->new('Person::get_address');

The most common pointcut is C<call>. All three of the examples will match the
calling of C<Person::get_address()> as defined in the symbol table at the
time an advice is declared.

The C<call> declarator takes a single parameter which is the pointcut spec,
and can be provided in three different forms.

B<string>

Select only the specific full resolved subroutine whose name is equal to the
specification string. 

For example C<call 'Person::get'> will only match the plain C<get> method
and will not match the longer C<get_address> method.

B<regexp>

Select all subroutines whose name matches the regular expression.

The following will match all the subs defined on the C<Person> class, but not
on the C<Person::Address> or any other child classes.

  $p = call qr/^Person::\w+$/;

B<CODE>

Select all subroutines where the supplied code returns true when passed a
full resolved subroutine name as the only parameter.

The following will match all calls to subroutines whose names are a key in the
hash C<%subs_to_match>:

  $p = call sub {
      exists $subs_to_match{$_[0]};
  }

For more information on the C<call> pointcut see L<Aspect::Pointcut::Call>.

=cut

sub call ($) {
	Aspect::Pointcut::Call->new(@_);
}

=pod

=head2 cflow

  before {
     print "Called My::foo somewhere within My::bar\n";
  } call 'My::foo'
  & cflow 'My::bar';

The C<cflow> declarator is used to specify that the join point must be somewhere
within the control flow of the C<My::bar> function. That is, at the time
C<My::foo> is being called somewhere up the call stack is C<My::bar>.

The parameters to C<cflow> are identical to the parameters to C<call>.

Due to an idiosyncracy in the way C<cflow> is implemented, they do not always
parse properly well when joined with an operator. In general, you should use
any C<cflow> operator last in your pointcut specification, or use explicit
braces for it.

  # This works fine
  my $x = call 'My::foo' & cflow 'My::bar';
  
  # This will error
  my $y = cflow 'My::bar' & call 'My::foo';
  
  # Use explicit braces if you can't have the flow last
  my $z = cflow('My::bar') & call 'My::foo';

For more information on the C<cflow> pointcut, see L<Aspect::Pointcut::Cflow>.

=cut

sub cflow ($;$) {
	Aspect::Pointcut::Cflow->new(@_);
}

=pod

=head2 wantlist

  my $pointcut = call 'Foo::bar' & wantlist;

The C<wantlist> pointcut traps a condition based on Perl C<wantarray> context,
when a function is called in list context. When used with C<call>, this
pointcut can be used to trap list-context calls to one or more functions, while
letting void or scalar context calls continue as normal.

For more information on the C<wantlist> pointcut see
L<Aspect::Pointcut::Wantarray>.

=cut

sub wantlist () {
	Aspect::Pointcut::Wantarray->new(1);
}

=pod

=head2 wantscalar

  my $pointcut = call 'Foo::bar' & wantscalar;

The C<wantscalar> pointcut traps a condition based on Perl C<wantarray> context,
when a function is called in scalar context. When used with C<call>, this
pointcut can be used to trap scalar-context calls to one or more functions,
while letting void or list context calls continue as normal.

For more information on the C<wantscalar> pointcut see
L<Aspect::Pointcut::Wantarray>.

=cut

sub wantscalar () {
	Aspect::Pointcut::Wantarray->new('');
}

=pod

=head2 wantvoid

  my $bug = call 'Foo::get_value' & wantvoid;

The C<wantvoid> pointcut traps a condition based on Perl C<wantarray> context,
when a function is called in void context. When used with C<call>, this pointcut
can be used to trap void-context calls to one or more functions, while letting
scalar or list context calls continue as normal.

This is particularly useful for methods which make no sense to call in void
context, such as getters or other methods calculating and returning a useful
result.

For more information on the C<wantvoid> pointcut see
L<Aspect::Pointcut::Wantarray>.

=cut

sub wantvoid () {
	Aspect::Pointcut::Wantarray->new(undef);
}

=pod

=head2 highest

  my $entry = call 'Foo::recurse' & highest;

The C<highest> pointcut is used to trap the first time a particular function
is encountered, while ignoring any subsequent recursive calls into the same
pointcut.

It is unusual in that unlike all other types of pointcuts it is stateful, and
so some detailed explaination is needed to understand how it will behave.

Pointcut declarators follow normal Perl precedence and shortcutting in the same
way that a typical set of C<foo() and bar()> might do for regular code.

When the C<highest> is evaluated for the first time it returns true and a
counter is to track the depth of the call stack. This counter is bound to the
join point itself, and will decrement back again once we exit the advice code.

If we encounter another function that is potentially contained in the same
pointcut, then C<highest> will always return false.

In this manner, you can trigger functionality to run only at the outermost
call into a recursive series of functions, or you can negate the pointcut 
with C<! highest> and look for recursive calls into a function when there
shouldn't be any recursion.

In the current implementation, the semantics and behaviour of pointcuts
containing multiple highest declarators is not defined (and the current
implementation is also not amenable to supporting it).

For these reasons, the usage of multiple highest declarators such as in the
following example is not support, and so the following will throw an exception.

  before {
      print "This advice will not compile\n";
  } wantscalar & (
      (call 'My::foo' & highest)
      |
      (call 'My::bar' & highest)
  );

This limitation may change in future releases. Feedback welcome.

For more information on the C<highest> pointcut see
L<Aspect::Pointcut::Highest>.

=cut

sub highest () {
	Aspect::Pointcut::Highest->new;
}

=pod

=head2 throwing

  my $string = throwing qr/does not exist/;
  my $object = throwing 'Exception::Class';

The C<throwing> pointcut is used with the C<after> to restrict the pointcut so
advice code is only fired for a specific die message or a particular exception
class (or subclass).

The C<throwing> declarator takes a single parameter which is the pointcut spec,
and can be provided in two different forms.

B<regexp>

If a regular expression is passed to C<throwing> it will be matched against
the exception if and only if the exception is a plain string.

Thus, the regexp form can be used to trap unstructured errors emitted by C<die>
or C<croak> while B<NOT> trapping any formal exception objects of any kind.

B<string>

If a string is passed to C<throwing> it will be treated as a class name and
will be matched against the exception via an C<isa> method call if and only
if the exception is an object.

Thus, the string form can be used to trap and handle specific types of
exceptions while allowing other types of exceptions or raw string errors to
pass through.

For more information on the C<throwing> pointcut see
L<Aspect::Pointcut::Throwing>.

=cut

sub throwing (;$) {
	Aspect::Pointcut::Throwing->new(@_);
}

=pod

=head2 returning

  after {
      print "No exception\n";
  } call 'Foo::bar' & returning;

The C<returning> pointcut is used with C<after> advice types to indicate the
join point should only occur when a function is returning B<without> throwing
an exception.

=cut

sub returning () {
	Aspect::Pointcut::Returning->new;
}

=pod

=head2 true

  # Intercept an adjustable random percentage of calls to a function
  our $RATE = 0.01;
  
  before {
      print "The few, the brave, the 1%\n";
  } call 'My::foo'
  & true {
      rand() < $RATE
  };

Because of the lengths that B<Aspect> goes to internally to optimise the
selection and interception of calls, writing your own custom pointcuts can
be very difficult.

When a custom or unusual pattern of interception is needed, often all that is
desired is to extend a relatively normal pointcut with an extra caveat.

To allow for this scenario, B<Aspect> provides the C<true> pointcut.

This pointcut allows you to specify any arbitrary code to match on. This code
will be executed at run-time if the join point matches all previous conditions.

The join point matches if the function or closure returns true, and does not
match if the code returns false or nothing at all.

=cut

sub true (&) {
	Aspect::Pointcut::True->new(@_);
}

=pod

=head2 before

  before {
      # Don't call the function, return instead
      $_->return_value(1);
  } call 'My::foo';

The B<before> advice declaration is used to defined advice code that will be
run instead of the code originally at the join points, but continuing on to the
real function if no action is taken to say otherwise.

When called in void context, as shown above, C<before> will install the advice
permanently into your program.

When called in scalar context, as shown below, C<before> will return a guard
object and enable the advice for as long as that guard object continues to
remain in scope or otherwise avoid being destroyed.

  SCOPE: {
      my $guard = before {
          print "Hello World!\n";
      } call 'My::foo';
  
      # This will print
      My::foo(); 
  }
  
  # This will NOT print
  My::foo();

Because the end result of the code at the join points is irrelevant to this
type of advice and the Aspect system does not need to hang around and maintain
control during the join point, the underlying implementation is done in a way
that is by far the fastest and with the least impact (essentially none) on the
execution of your program.

You are B<strongly> encouraged to use C<before> advice wherever possible for the
current implementation, resorting to the other advice types when you truly need
to be there are the end of the join point execution (or on both sides of it).

For more information, see L<Aspect::Advice::Before>.

=cut

sub before (&$) {
	Aspect::Advice::Before->new(
		lexical  => defined wantarray,
		code     => $_[0],
		pointcut => $_[1],
	);
}

=pod

=head2 after

  # Confuse a program by bizarely swapping return values and exceptions
  after {
      if ( $_->exception ) {
          $_->return_value($_->exception);
      } else {
          $_->exception($_->return_value);
      }
  } call 'My::foo' & wantscalar;

The C<after> declarator is used to create advice in which the advice code will
be run after the join point has run, regardless of whether the function return
correctly or throws an exception.

For more information, see L<Aspect::Advice::After>.

=cut

sub after (&$) {
	Aspect::Advice::After->new(
		lexical  => defined wantarray,
		code     => $_[0],
		pointcut => $_[1],
	);
}

=pod

=head2 around

  # Trace execution time for a function
  around {
      my @start   = Time::HiRes::gettimeofday();
      $_->proceed;
      my @stop    = Time::HiRes::gettimeofday();
      my $elapsed = Time::HiRes::tv_interval( \@start, \@stop );
      print "My::foo executed in $elapsed seconds\n";
  } call 'My::foo';

The C<around> declarator is used to create the most general form of advice,
and can be used to implement the most high level functionality.

It allows you to make changes to the calling parameters, to change the result
of the function, to subvert or prevent the calling altogether, and to do so
while storing extra lexical state of your own across the join point.

For example, the code shown above tracks the time at which a single function
is called and returned, and then uses the two pieces of information to track
the execution time of the call.

Similar functionality to the above is used to implement the CPAN modules
L<Aspect::Library::Timer> and the more complex L<Aspect::Library::ZoneTimer>.

Within the C<around> advice code, the C<$_-E<gt>proceed> method is used to call
the original function with whatever the current parameter context is, storing
the result (whether return values or an exception) in the context as well.

Alternatively, you can use the C<original> method to get access to a reference
to the original function and call it directly without using context
parameters and without storing the function results.

  around {
      $_->original->('alternative param');
      $_->return_value('fake result');
  } call 'My::foo';

The above example calls the original function directly with an alternative
parameter in void context (regardless of the original C<wantarray> context)
ignoring any return values. It then sets an entirely made up return value of
it's own.

Although it is the most powerful advice type, C<around> is also the slowest
advice type with the highest memory cost per join point. Where possible, you
should try to use a more specific advice type.

For more information, see L<Aspect::Advice::Around>.

=cut

sub around (&$) {
	Aspect::Advice::Around->new(
		lexical  => defined wantarray,
		code     => $_[0],
		pointcut => $_[1],
	);
}

=pod

=head2 aspect

  aspect Singleton => 'Foo::new';

The C<aspect> declarator is used to enable complete reusable aspects.

The first parameter to C<aspect> identifies the aspect library class. If the
parameter is a fully resolved class name (i.e. it contains double colons like
Foo::Bar) the value it will be used directly. If it is a simple C<Identifier>
without colons then it will be interpreted as C<Aspect::Library::Identifier>.

If the aspect class is not loaded, it will be loaded for you and validated as
being a subclass of C<Aspect::Library>.

And further parameters will be passed on to the constructor for that class. See
the documentation for each class for more information on the appropriate
parameters for that class.

As with each individual advice type complete aspects can be defined globally
by using C<aspect> in void context, or lexically via a guard object by calling
C<aspect> in scalar context.

  # Break on the topmost call to function for a limited time
  SCOPE: {
      my $break = aspect Breakpoint => call 'My::foo' & highest;
      
      do_something();
  }

For more information on writing reusable aspects, see L<Aspect::Library>.

=cut

sub aspect {
	my $class = _LIBRARY(shift);
	return $class->new(
		lexical => defined wantarray,
		args    => [ @_ ],
	);
}





######################################################################
# Private Functions

# Run-time use call
# NOTE: Do we REALLY need to do this as a use?
#       If the ->import method isn't important, change to native require.
sub _LIBRARY {
	my $package = shift;
	if ( Params::Util::_IDENTIFIER($package) ) {
		$package = "Aspect::Library::$package";
	}
	Params::Util::_DRIVER($package, 'Aspect::Library');
}

1;

=pod

=head1 OPERATORS

=head2 &

Overloading of bitwise C<&> for pointcut declarations allows a natural looking
boolean "and" logic for pointcuts. When using the C<&> operator the combined
pointcut expression will match if all pointcut subexpressions match.

In the original Java AspectJ framework, the subexpressions are considered to
be a union without an inherent order at all. In Perl you may treat them as
ordered since they are ordered internally, but since all subexpressions run 
anyway you should probably not do anything that relies on this order. The
optimiser may do interesting things with order in future, or we may move to an
unordered implementation.

For more information, see L<Aspect::Pointcut::And>.

=head2 |

Overloading of bitwise C<|> for pointcut declarations allows a natural looking
boolean "or" logic for pointcuts. When using the C<|> operator the combined
pointcut expression will match if either pointcut subexpressions match.

The subexpressions are ostensibly considered without any inherent order, and
you should treat them that way when you can. However, they are internally
ordered and shortcutting will be applied as per normal Perl expressions. So for
speed reasons, you may with to put cheap pointcut declarators before expensive
ones where you can.

The optimiser may do interesting things with order in future, or we may move to
an unordered implementation. So as a general rule, avoid things that require
order while using order to optimise where you can.

For more information, see L<Aspect::Pointcut::Or>.

=head2 !

Overload of negation C<!> for pointcut declarations allows a natural looking
boolean "not" logic for pointcuts. When using the C<!> operator the resulting
pointcut expression will match if the single subexpression does B<not> match.

For more information, see L<Aspect::Pointcut::Not>.

=head1 METHODS

A range of different methods are available within each type of advice code.

The are summarised below, and described in more detail in L<Aspect::Point>.

=head2 type

The C<type> method is a convenience provided in the situation advice code is
used in more than one type of advice, and wants to know the advice declarator
is was made form.

Returns C<"before">, C<"after"> or C<"around">.

=head2 pointcut

  my $pointcut = $_->pointcut;

The C<pointcut> method provides access to the original join point specification
(as a tree of L<Aspect::Pointcut> objects) that the current join point matched
against.

=head2 original

  $_->original->( 1, 2, 3 );

In a pointcut, the C<original> method returns a C<CODE> reference to the
original function before it was hooked by the L<Aspect> weaving process.

  # Prints "Full::Function::name"
  before {
      print $_->sub_name . "\n";
  } call 'Full::Function::name';

The C<sub_name> method returns a string with the full resolved function name
at the join point the advice code is running at.

=head2 package_name

  # Prints "Just::Package"
  before {
      print $_->package_name . "\n";
  } call 'Just::Package::name';

The C<package_name> parameter is a convenience wrapper around the C<sub_name>
method. Where C<sub_name> will return the fully resolved function name, the
C<package_name> method will return just the namespace of the package of the
join point.

=head2 short_name

  # Prints "name"
  before {
      print $_->short_name . "\n";
  } call 'Just::Package::name';

The C<short_name> parameter is a convenience wrapper around the C<sub_name>
method. Where C<sub_name> will return the fully resolved function name, the
C<short_name> method will return just the name of the function.

=head2 args

  # Get the parameters as a list
  my @list = $_->args;
  
  # Set the parameters
  $_->args( 1, 2, 3 );
  
  # Append a parameter
  $_->args( $_->args, 'more' );

The C<args> method allows you to get or set the list of parameters to a
function. It is the method equivalent of manipulating the C<@_> array.

=head2 self

  after {
      $_->self->save;
  } My::Foo::set;

The C<self> method is a convenience provided for when you are writing advice
that will be working with object-oriented Perl code. It returns the first
parameter to the method (which should be object), which you can then call
methods on.

=head2 wantarray

  # Return differently depending on the calling context
  if ( $_->wantarray ) {
      $_->return_value(5);
  } else {
      $_->return_value(1, 2, 3, 4, 5);
  }

The C<wantarray> method returns the L<perlfunc/wantarray> context of the
call to the function for the current join point.

As with the core Perl C<wantarray> function, returns true if the function is
being called in list context, false if the function is being called in scalar
context, or C<undef> if the function is being called in void context.

=head2 exception

  unless ( $_->exception ) {
      $_->exception('Kaboom');
  }

The C<exception> method is used to get the current die message or exception
object, or to set the die message or exception object.

=head2 return_value

  # Add an extra value to the returned list
  $_->return_value( $_->return_value, 'thing' );
  
  # Return null (equivalent to "return;")
  $_->return_value;

The C<return_value> method is used to get or set the return value for the
join point function, in a similar way to the normal Perl C<return> keyword.

=head2 proceed

  around {
      my $before = time;
      $_->proceed;
      my $elapsed = time - $before;
      print "Call to " . $_->sub_name . " took $elapsed seconds\n";
  } call 'My::function';

Available only in C<around> advice, the C<proceed> method is used to run the
join point function with the current join point context (parameters, scalar vs
list call, etc) and store the result of the original call in the join point
context (return values, exceptions etc).

=head1 LIBRARY

The main L<Aspect> distribution ships with the following set of libraries. These
are not necesarily recommended or the best on offer. The are shipped with
B<Aspect> for convenience, because they have no additional CPAN dependencies.

Their purpose is summarised below, but see their own documentation for more
information.

=head2 Aspect::Library::Singleton

L<Aspect::Library::Singleton> can be used to convert an existing class to
function as a singleton and return the same object for every constructor call.

=head2 Aspect::Library::Breakpoint

L<Aspect::Library::Breakpoint> allows you to inject debugging breakpoints into
a program using the full power and complexity of the C<Aspect> pointcuts.

=head2 Aspect::Library::Wormhole

L<Aspect::Library::Wormhole> is a tool for passing objects down a call flow,
without adding extra arguments to the frames between the source and the target,
letting a function implicit context.

=head2 Aspect::Library::Listenable

L<Aspect::Library::Listenable> assysts in the implementation of the "Listenable"
design pattern. It lets you define a function as emitting events that can be
registed for by subscribers, and then add/remove subscribers for these events
over time.

When the functions that are listenable are called, registered subscribers will
be notified. This lets you build a general event subscription system for your
program. This could be as part of a plugin API or just for your own convenience.

=head1 INTERNALS

Due to the dynamic nature of Perl, there is no need for processing of source
or byte code, as required in the Java and .NET worlds.

The implementation is conceptually very simple: when you create advice, its
pointcut is matched to find every sub defined in the symbol table that might
match against the pointcut (potentially subject to further runtime conditions).

Those that match, will get a special wrapper installed. The wrapper only
executes if, during run-time, a compiled context test for the pointcut
returns true.

The wrapper code creates an advice context, and gives it to the advice code.

Most of the complexity comes from the extensive optimisation that is used to
reduce the impact of both weaving of the advice and the run-time costs of the
wrappers added to your code.

Some pointcuts like C<call> are static and their full effect is known at
weave time, so the compiled run-time function can be optimised away entirely.

Some pointcuts like C<cflow> are dynamic, so they are not used to select
the functions to hook, but impose a run-time cost to determine whether or not
they match.

To make this process faster, when the advice is installed, the pointcut
will not use itself directly for the compiled run-time function but will
additionally generate a "curried" (optimised) version of itself.

This curried version uses the fact that the run-time check will only be
called if it matches the C<call> pointcut pattern, and so no C<call>
pointcuts needed to be tested at run-time unless they are in deep and
complex nested coolean logic. It also handles collapsing any boolean logic
impacted by the safe removal of the C<call> pointcuts.

Further, where possible the pointcuts will be expressed as Perl source
(including logic operators) and compiled into a single Perl expression. This
not only massively reduces the number of functions to be called, but allows
further optimisation of the pointcut by the opcode optimiser in perl itself.

If you use only C<call> pointcuts (alone or in boolean combinations)
the currying results in a null test (the pointcut is optimised away
entirely) and so the need to make a run-time point test will be removed
altogether from the generated advice hooks, reducing call overheads
significantly.

If your pointcut does not have any static conditions (i.e. C<call>) then
the wrapper code will need to be installed into every function on the symbol
table. This is highly discouraged and liable to result in hooks on unusual
functions and unwanted side effects, potentially breaking your program.

=head1 LIMITATIONS

=head2 Inheritance Support

Support for inheritance is lacking. Consider the following two classes:

  package Automobile;
  
  sub compute_mileage {
      # ...
  }
  
  package Van;
  
  use base 'Automobile';

And the following two advice:

  before {
      print "Automobile!\n";
  } call 'Automobile::compute_mileage';
  
  before {
      print "Van!\n";
  } call 'Van::compute_mileage';

Some join points one would expect to be matched by the call pointcuts
above, do not:

  $automobile = Automobile->new;
  $van = Van->new;
  $automobile->compute_mileage; # Automobile!
  $van->compute_mileage;        # Automobile!, should also print Van!

C<Van!> will never be printed. This happens because B<Aspect> installs
advice code on symbol table entries. C<Van::compute_mileage> does not
have one, so nothing happens. Until this is solved, you have to do the
thinking about inheritance yourself.

=head2 Performance

You may find it very easy to shoot yourself in the foot with this module.
Consider this advice:

  # Do not do this!
  before {
      print $_->sub_name;
  } cflow 'MyApp::Company::make_report';

The advice code will be installed on B<every> sub loaded. The advice code
will only run when in the specified call flow, which is the correct
behavior, but it will be I<installed> on every sub in the system. This
can be extremely slow because the run-time cost of checking C<cflow> will
occur on every single function called in your program.

It happens because the C<cflow> pointcut matches I<all> subs during weave-time.
It matches the correct sub during run-time. The solution is to narrow the
pointcut:

  # Much better
  before {
      print $_->sub_name;
  } call qr/^MyApp::/
  & cflow 'MyApp::Company::make_report';

=head1 TO DO

There are a many things that could be added, if people have an interest
in contributing to the project.

=head2 Documentation

* cookbook

* tutorial

* example of refactoring a useful CPAN module using aspects

=head2 Pointcuts

* New pointcuts: execution, cflowbelow, within, advice, calledby. Sure
  you can implement them today with Perl treachery, but it is too much
  work.

* We need a way to match subs with an attribute, attributes::get()
  will currently not work.

* isa() support for method pointcuts as Gaal Yahas suggested: match
  methods on class hierarchies without callbacks

* Perl join points: phasic- BEGIN/INIT/CHECK/END 

=head2 Weaving

* The current optimation has gone as far as it can, next we need to look into
  XS acceleration and byte code manipulation with B:: modules.

* A debug flag to print out subs that were matched during weaving

* Warnings when over 1000 methods wrapped

* Allow finer control of advice execution order

* Centralised hooking in wrappers so that each successive advice won't need
  to wrap around the previous one.

* Allow lexical aspects to be safely removed completely, rather than being left
  in place and disabled as in the current implementation.

=head1 SUPPORT

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Aspect>.

=head1 INSTALLATION

See L<perlmodinstall> for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see L<http://search.cpan.org/perldoc?Aspect>.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 SEE ALSO

You can find AOP examples in the C<examples/> directory of the
distribution.

L<Aspect::Library::Memoize>

L<Aspect::Library::Profiler>

L<Aspect::Library::Trace>

=head1 COPYRIGHT

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2012 Adam Kennedy.

Parts of the initial introduction courtesy Wikipedia.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
