package Aspect::PointCut::BinOp;

use strict;
use warnings;
use base 'Aspect::PointCut';
use Class::MethodMaker
    get_set => [ qw/leftop rightop/ ];

our $VERSION = '0.04';

sub init {
	my ($self, $leftop, $rightop) = @_;
	$self->leftop($leftop);
	$self->rightop($rightop);
}

# implement this in subclasses

sub binop {}

sub match_define {
	my ($self, $jp) = @_;
	return $self->binop(
	    $self->leftop->match_define($jp),
	    $self->rightop->match_define($jp));
}

1;
