package Aspect::PointCut::Sub;

use strict;
use warnings;
use base 'Aspect::PointCut';

our $VERSION = '0.07';

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
