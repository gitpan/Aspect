package Aspect::Pointcut::BinOp;

use strict;
use warnings;
use Carp;

use base 'Aspect::Pointcut';

sub init {
	my $self = shift;
	$self->{left_op}  = shift;
	$self->{right_op} = shift;
}

sub match_define {
	my ($self, $sub_name) = @_;
	return $self->binop(
		$self->{left_op}->match_define($sub_name),
		$self->{right_op}->match_define($sub_name)
	);
}

sub match_run {
	my ($self, $sub_name, $runtime_context) = @_;
	return $self->binop(
		$self->{left_op }->match_run($sub_name, $runtime_context),
		$self->{right_op}->match_run($sub_name, $runtime_context)
	);
}

# template method to be defined in subclasses
sub binop { die "Must be implemented by subclass" }

1;
