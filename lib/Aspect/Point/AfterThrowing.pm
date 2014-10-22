package Aspect::Point::AfterThrowing;

use strict;
use warnings;
use Aspect::Point ();

our $VERSION = '0.96';
our @ISA     = 'Aspect::Point';

sub type { 'after_throwing' }

sub exception {
	my $self = shift;
	if ( @_ ) {
		$self->{exception} = shift;
		$self->{proceed}   = 0;
	}
	$self->{exception};
}

1;
