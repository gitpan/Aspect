package Aspect::PointCut::AndOp;

use strict;
use warnings;
use base 'Aspect::PointCut::BinOp';

our $VERSION = '0.07';

sub binop { $_[1] && $_[2] }

1;
