package Aspect::tests::Advice;

use strict;
use warnings;
use Carp;
use Test::More;
use Aspect;

use base qw(Test::Class);

my $Demo_Class = 'Aspect_Advice_Foo';
my $Subject;

sub setup: Test(setup) { $Subject = $Demo_Class->new }

sub call_pointcut: Test(10) {
	my $self = shift;
	is $Subject->foo, 'foo', 'foo not yet installed';
	is $Subject->inc(2), 3, 'inc not yet installed';
	{
		my @advice;

		push @advice, before { shift->return_value('bar') }
			call "${Demo_Class}::foo";
		is $Subject->foo, 'bar', 'a before advice changing return_value';

		push @advice, after { my $c = shift; $c->return_value($c->self) }
			call sub { shift eq "${Demo_Class}::foo" };
		is $Subject->foo, $Subject, 'an after advice changing return_value';

		push @advice, before
			{ my $p = shift->params; splice @$p, 1, 1, $p->[1] + 1 }
				call qr/${Demo_Class}::inc/;
		is $Subject->inc(2), 4, 'a before advice changing params';

		push @advice, after
			{ my $c = shift; $c->return_value($c->return_value + 1) }
				call "${Demo_Class}::inc";
		is $Subject->inc(2), 5, 'a before and an after advice together';
	}
	{
		my @advice;

		push @advice, after
			{ my $c = shift; $c->return_value($c->params->[1]) }
				call 'Aspect_Advice_Foo::foo';
		is $Subject->foo('baz'), 'baz', 'an after advice accessing params';

		push @advice, before
			{ my $p = shift->params; splice @$p, 1, 1, $p->[1] x 2 }
				call 'Aspect_Advice_Foo::foo';
		is $Subject->foo('baz'), 'bazbaz', 'same but with a before advice';
	}
	is $Subject->foo, 'foo', 'foo uninstalled';
	is $Subject->inc(3), 4, 'inc uninstalled';
}

sub cflow_pointcut: Test(6) {
	my $self = shift;
	is $Subject->bar, 'foo', 'bar cflow not yet installed';
	is $Subject->foo, 'foo', 'foo cflow not yet installed';
	{
		my $advice = before
			{ my $c = shift; $c->return_value($c->my_key->self) }
				call "${Demo_Class}::foo" & cflow my_key => "${Demo_Class}::bar";
		is $Subject->bar, $Subject, 'foo cflow installed';
		is $Subject->foo, 'foo', 'foo called out of the cflow';
	}
	is $Subject->bar, 'foo', 'bar cflow uninstalled';
	is $Subject->foo, 'foo', 'foo cflow uninstalled';
}

# -----------------------------------------------------------------------------

package Aspect_Advice_Foo;

sub new { bless {}, shift }
sub foo { 'foo'           }
sub bar { shift->foo      }
sub inc { $_[1] + 1       }


1;
