package Aspect::PointCut::OrOp;

use strict;
use warnings;
use base 'Aspect::PointCut::BinOp';

our $VERSION = '0.06';

sub binop { $_[1] || $_[2] }

1;
