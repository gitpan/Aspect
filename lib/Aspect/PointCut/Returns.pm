package Aspect::PointCut::Returns;

# $Id: Returns.pm,v 1.2 2002/07/31 21:29:20 marcelgr Exp $
#
# $Log: Returns.pm,v $
# Revision 1.2  2002/07/31 21:29:20  marcelgr
# changed version number to 0.08
#
# Revision 1.1.1.1  2002/06/13 07:17:54  marcelgr
# initial import
#

use strict;
use warnings;
use base 'Aspect::PointCut::Sub';

our $VERSION = '0.08';

sub join_point_type { 'Aspect::JoinPoint::Return' }

1;
