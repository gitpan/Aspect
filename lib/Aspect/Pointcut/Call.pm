package Aspect::Pointcut::Call;

use strict;
use warnings;
use Carp;

use base 'Aspect::Pointcut';

sub init { shift->{spec} = pop }

sub match_define {
	my ($self, $sub_name) = @_;
	return $self->match($self->{spec}, $sub_name);
}

1;
