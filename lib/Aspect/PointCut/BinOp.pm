package Aspect::PointCut::BinOp;

# $Id: BinOp.pm,v 1.2 2002/07/31 21:29:19 marcelgr Exp $
#
# $Log: BinOp.pm,v $
# Revision 1.2  2002/07/31 21:29:19  marcelgr
# changed version number to 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use strict;
use warnings;
use base 'Aspect::PointCut';
use Class::MethodMaker
    get_set => [ qw/leftop rightop/ ];

our $VERSION = '0.08';

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
