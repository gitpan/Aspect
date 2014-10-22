package Aspect::Pointcut::Highest::Cleanup;

use strict;
use warnings;

our $VERSION = '0.97_03';

sub new {
	bless $_[1], $_[0];
}

sub DESTROY {
	$_[0]->();
}

1;
