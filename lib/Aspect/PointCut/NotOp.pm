package Aspect::PointCut::NotOp;

# $Id: NotOp.pm,v 1.2 2002/07/31 21:29:20 marcelgr Exp $
#
# $Log: NotOp.pm,v $
# Revision 1.2  2002/07/31 21:29:20  marcelgr
# changed version number to 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use strict;
use warnings;
use base 'Aspect::PointCut';
use Class::MethodMaker
    get_set => 'op';

our $VERSION = '0.08';

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
