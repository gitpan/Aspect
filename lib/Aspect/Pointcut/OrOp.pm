package Aspect::Pointcut::OrOp;

use strict;
use warnings;
use Carp;

use base 'Aspect::Pointcut::BinOp';

sub binop { $_[1] || $_[2] }

1;
