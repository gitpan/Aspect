package Aspect::PointCut::NotOp;

use strict;
use warnings;
use base 'Aspect::PointCut';
use Class::MethodMaker
    get_set => 'op';

our $VERSION = '0.07';

sub init {
	my $self = shift;
	return unless @_;
	$self->op(+shift);
}

sub match_define {
	my ($self, $jp) = @_;
	return !$self->op->match_define($jp);
}

1;
