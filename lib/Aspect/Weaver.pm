package Aspect::Weaver;

use strict;
use warnings;
use Carp;
use Aspect::Hook::LexWrap;
use Devel::Symdump;

my %UNTOUCHABLES = map { $_ => 1 } qw(
	attributes base fields lib strict warnings Carp Carp::Heavy Config CORE
	CORE::GLOBAL DB DynaLoader Exporter Exporter::Heavy IO IO::Handle UNIVERSAL
);

sub new { bless {}, shift }

sub get_sub_names {
	# TODO: need to filter Aspect exportable functions!
	map  { Devel::Symdump->new($_)->functions }
	grep { !/^Aspect::/ }
	grep { !$UNTOUCHABLES{$_} }
	Devel::Symdump->rnew->packages;
}

sub install {
	my ($self, $type, $sub_name, $code) = @_;
	return wrap
		$sub_name,
		($type eq 'before'? 'pre': 'post'),
		$code;
}

1;

=head1 NAME

Aspect::Weaver - aspect weaving functionality

=head1 SYNOPSIS

  $weaver = Aspect::Weaver->new;
  print join(',', $weaver->get_sub_names); # all wrappable subs
  $weaver->install(before => 'Employee::get_name', $wrapper_code);
  $weaver->install(after  => 'Employee::set_name', $wrapper_code);

=head1 DESCRIPTION

Used by L<Aspect::Advice> to get all wrappable subs, and to install a
before/after hook on a sub. Uses L<Aspect::Hook::LexWrap> for the
wrapping itself, and C<Devel::Symdump> for accessing symbol table info.

=head1 SEE ALSO

See the L<Aspect|::Aspect> pod for a guide to the Aspect module.

=cut
