package Aspect::PointCut::Sub;

# $Id: Sub.pm,v 1.2 2002/07/31 21:29:20 marcelgr Exp $
#
# $Log: Sub.pm,v $
# Revision 1.2  2002/07/31 21:29:20  marcelgr
# changed version number to 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use strict;
use warnings;
use base 'Aspect::PointCut';

our $VERSION = '0.08';

sub init {
	my $self = shift;
	return unless @_;
	$self->spec(+shift);
}

# A calls pointcut operator (i.e., this class) matches only
# call join points at define time. And then only those call join points
# that match the pointcut op's spec.
# There is no run-time match test;  once the advice is installed, it runs.

sub match_define {
	my ($self, $jp) = @_;
	return unless ref $jp eq $self->join_point_type;
	return $self->match($jp->sub);
}

# implement this in subclasses; return the package name of the join
# point this pointcut operator matches

sub join_point_type {}

1;
