package Aspect::PointCut::Returns;

use strict;
use warnings;
use base 'Aspect::PointCut::Sub';

our $VERSION = '0.06';

sub join_point_type { 'Aspect::JoinPoint::Return' }

1;
