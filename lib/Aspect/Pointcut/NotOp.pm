package Aspect::Pointcut::NotOp;

use strict;
use warnings;
use Carp;

use base 'Aspect::Pointcut';

sub init { shift->{op} = pop }

sub match_define {
	my ($self, $sub_name) = @_;
	return !$self->{op}->match_define($sub_name);
}

sub match_run {
	my ($self, $sub_name) = @_;
	return !$self->{op}->match_run($sub_name);
}

1;
