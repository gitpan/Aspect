package Aspect::Symbol::Enum;

use base 'Exporter';

our $VERSION = '0.04';

our %EXPORT_TAGS = ( all => [ qw(
	get_packages get_user_packages get_symbols
) ] );

{
	no strict 'refs';
	for my $slot (qw/CODE SCALAR ARRAY HASH/) {
		*{"get_$slot"} = *{ 'get_' . lc($slot) } =
		    sub { get_symbols(shift, $slot) };
		push @{ $EXPORT_TAGS{all} } => "get_$slot", 'get_' . lc($slot);
	}
}

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub get_packages {
	my $base = shift || '';
	my $seen = shift || {};

	# Get all package names (with this base) we haven't seen
	# yet. Take only those that look like a valid identifier
	# followed by '::'

	my @pkg =
	    grep !exists($seen->{$_}) =>
	    grep /(\w+::)+$/ =>
	    eval "keys(%$base\::)";
	$seen->{$_} = 1 for @pkg;

	# end recursion if no more packages; otherwise munge string,
	# do proper prefixing and include recursively determined
	# packages

	return unless @pkg;
	return
	    map { $_, get_packages($_, $seen) }
	    map { length $base ? "$base\::$_" : $_ }
	    map { (/(.*)::$/) } @pkg;
}

sub get_user_packages {
	our $reserved ||= { map { $_ => 1 } qw(
	    attributes
	    base
	    fields
	    lib
	    Config
	    DB
	    UNIVERSAL
	    DynaLoader
	    Exporter
	    Exporter::Heavy
	    warnings
	    IO
	    IO::Handle
	    strict
	    Carp
	    CORE
	    CORE::GLOBAL
	) };

	return grep { !$reserved->{$_} && !/^Aspect(::.*)?$/ } get_packages;
}

sub get_symbols {
	my ($pkg, $globslot) = @_;
	no strict 'refs';
	return
	    grep { defined *{"$pkg\::$_"}{$globslot} }
	    grep !/::$/ => # these indicate a package
	    eval "keys(%$pkg\::)";
}

1;

__END__

=head1 NAME

Aspect::Symbol::Enum - Functions to extract symbol table information

=head1 SYNOPSIS

  use Aspect::Symbol::Enum ':all';
  for my $pkg (get_user_packages) {
    print "$pkg\::$_()\n" for get_CODE($pkg);
  }

=head1 DESCRIPTION

This module exports functions that extract information about
available packages and symbols of certain types (scalars, arrays,
hashes, subroutines) in those packages.

=head2 EXPORT

None by default.

=head2 EXPORT_OK

=over 4

=item C<get_packages([STRING, HASHREF])>

Returns a list of the names of all packages in existence in the
program at the time. If no arguments are given, the search starts
from the base symbol table, C<%::>, otherwise the search starts
from symbol table indicated by the string argument. The optional
second parameter is a reference to a hash whose keys indicate
package names we're not interested in. This argument is for internal
use.

=item C<get_user_packages()>

Returns those package names from C<get_packages> that aren't in
existence when starting even the most minimal of Perl programs.
This should leave all packages loaded (e.g., via C<use()>) or
otherwise declared by the main program. The following packages are
not considered to be user packages; in the list there are packages
likes C<UNIVERSAL> that are available in every program by default
as well as packages like C<Exporter> that are loaded by
C<Aspect::Symbol::Enum>.

  attributes
  base
  fields
  lib
  Config
  DB
  UNIVERSAL
  DynaLoader
  Exporter
  Exporter::Heavy
  warnings
  IO
  IO::Handle
  strict
  Carp
  CORE
  CORE::GLOBAL
  
=item C<get_symbols(STRING, STRING)>

Returns a list of glob names within the symbol table of the package
denoted by the first argument (without the package name) that have
a slot of thetype indicated by the second argument. The second
argument can be one of C<CODE>, C<SCALAR>, C<ARRAY> or C<HASH>.

This module can export certain convenience functions based on
C<get_symbols>:

=item C<get_CODE(STRING)>, C<get_code(STRING)>

Returns a list of glob names within the symbol table of the package
denoted by the argument (without the package name) that have a
C<CODE> slot. Effectively, a list of all subroutine names in the
given package.

=item C<get_SCALAR(STRING)>, C<get_scalar(STRING)>

Returns a list of glob names within the symbol table of the package
denoted by the argument (without the package name) that have a
C<SCALAR> slot. Effectively, a list of all scalar variables in the
given package.

=item C<get_ARRAY(STRING)>, C<get_array(STRING)>

Returns a list of glob names within the symbol table of the package
denoted by the argument (without the package name) that have a
C<ARRAY> slot. Effectively, a list of all array variables in the
given package.

=item C<get_HASH(STRING)>, C<get_hash(STRING)>

Returns a list of glob names within the symbol table of the package
denoted by the argument (without the package name) that have a
C<HASH> slot. Effectively, a list of all hash variables in the
given package.

=back

=head2 EXPORT_TAGS

Using C<:all> you can import all of the above functions.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel Grunauer, <marcel@codewerk.com>

=head1 COPYRIGHT

Copyright 2001 Marcel Grunauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Aspect::Intro(3pm), Aspect::Overview(3pm).

=cut
