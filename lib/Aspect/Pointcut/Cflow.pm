package Aspect::Pointcut::Cflow;

use strict;
use warnings;
use Carp;
use Aspect::AdviceContext;

use base 'Aspect::Pointcut';

sub init {
	my $self = shift;
	carp 'Cflow must be created with 2 parameters' unless @_ == 2;
	$self->{runtime_context_key} = shift;
	$self->{spec} = shift;
}

sub match_run {
	my ($self, $sub_name, $runtime_context) = @_;
	my $caller_info = $self->find_caller;
	return 0 unless $caller_info;
	
	my $advice_context = Aspect::AdviceContext->new(
		sub_name => $caller_info->{sub_name},
		pointcut => $self,
		params   => $caller_info->{params},
	);
	$runtime_context->{$self->{runtime_context_key}} = $advice_context;
	return 1;
}

sub find_caller {
	my $self  = shift;
	my $level = 2;
	my $caller_info;
	while (1) {
		$caller_info = $self->caller_info($level++);
		last if
			!$caller_info ||
			$self->match($self->{spec}, $caller_info->{sub_name});
	}
	return $caller_info;
}

sub caller_info {
	my ($self, $level) = @_;
	package DB;
	my %call_info;
	@call_info {qw(calling_package sub_name has_params)} =
		(CORE::caller($level))[0, 3, 4];
	return defined $call_info{calling_package}?
		{%call_info, params => [$call_info{has_params}? @DB::args: ()]}: 0;
}

1;
