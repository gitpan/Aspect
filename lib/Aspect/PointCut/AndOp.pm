package Aspect::PointCut::AndOp;

# $Id: AndOp.pm,v 1.2 2002/07/31 21:29:19 marcelgr Exp $
#
# $Log: AndOp.pm,v $
# Revision 1.2  2002/07/31 21:29:19  marcelgr
# changed version number to 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use strict;
use warnings;
use base 'Aspect::PointCut::BinOp';

our $VERSION = '0.08';

sub binop { $_[1] && $_[2] }

1;
