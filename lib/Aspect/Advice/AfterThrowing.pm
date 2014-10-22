package Aspect::Advice::AfterThrowing;

use strict;
use warnings;

# Added by eilara as hack around caller() core dump
# NOTE: Now we've switched to Sub::Uplevel can this be removed? --ADAMK
use Carp::Heavy                  (); 
use Carp                         ();
use Sub::Uplevel                 ();
use Aspect::Hook                 ();
use Aspect::Advice               ();
use Aspect::Point::AfterThrowing ();

our $VERSION = '0.97_03';
our @ISA     = 'Aspect::Advice';

# NOTE: To simplify debugging of the generated code, all injected string
# fragments will be defined in $UPPERCASE, and all lexical variables to be
# accessed via the closure will be in $lowercase.
sub _install {
	my $self     = shift;
	my $pointcut = $self->pointcut;
	my $code     = $self->code;
	my $lexical  = $self->lexical;

	# Get the curried version of the pointcut we will use for the
	# runtime checks instead of the original.
	# Because $MATCH_RUN is used in boolean conditionals, if there
	# is nothing to do the compiler will optimise away the code entirely.
	my $curried   = $pointcut->match_curry;
	my $compiled  = $curried ? $curried->compiled_runtime : undef;
	my $MATCH_RUN = $compiled ? '$compiled->()' : 1;

	# When an aspect falls out of scope, we don't attempt to remove
	# the generated hook code, because it might (for reasons potentially
	# outside our control) have been recursively hooked several times
	# by both Aspect and other modules.
	# Instead, we store an "out of scope" flag that is used to shortcut
	# past the hook as quickely as possible.
	# This flag is shared between all the generated hooks for each
	# installed Aspect.
	# If the advice is going to last lexical then we don't need to
	# check or use the $out_of_scope variable.
	my $out_of_scope   = undef;
	my $MATCH_DISABLED = $lexical ? '$out_of_scope' : '0';

	# Find all pointcuts that are statically matched
	# wrap the method with advice code and install the wrapper
	foreach my $name ( $pointcut->match_all ) {
		my $NAME = $name; # For completeness

		no strict 'refs';
		my $original = *$name{CODE};
		unless ( $original ) {
			Carp::croak("Can't wrap non-existent subroutine ", $name);
		}

		# Any way to set prototypes other than eval?
		my $PROTOTYPE = prototype($original);
		   $PROTOTYPE = defined($PROTOTYPE) ? "($PROTOTYPE)" : '';

		# Generate the new function
		no warnings 'redefine';
		eval <<"END_PERL"; die $@ if $@;
		package Aspect::Hook;

		*$NAME = sub $PROTOTYPE {
			# Is this a lexically scoped hook that has finished
			goto &\$original if $MATCH_DISABLED;

			my \$wantarray = wantarray;
			if ( \$wantarray ) {
				my \$return = eval { [
					Sub::Uplevel::uplevel(
						2, \$original, \@_,
					)
				] };
				return \@\$return unless \$\@;

				local \$_ = bless {
					sub_name     => \$name,
					wantarray    => \$wantarray,
					params       => \\\@_,
					return_value => \$return,
					exception    => \$\@,
					pointcut     => \$pointcut,
					original     => \$original,
				}, 'Aspect::Point::AfterThrowing';

				die \$_->{exception} unless $MATCH_RUN;

				# Execute the advice code
				() = &\$code(\$_);

				# Throw the same (or modified) exception
				my \$exception = \$_->exception;
				die \$exception if \$exception;

				# Get the (potentially) modified return value
				return \@{\$_->{return_value}};
			}

			if ( defined \$wantarray ) {
				my \$return = eval {
					Sub::Uplevel::uplevel(
						2, \$original, \@_,
					)
				};
				return \$return unless \$\@;

				local \$_ = bless {
					sub_name     => \$name,
					wantarray    => \$wantarray,
					params       => \\\@_,
					return_value => \$return,
					exception    => \$\@,
					pointcut     => \$pointcut,
					original     => \$original,
				}, 'Aspect::Point::AfterThrowing';

				die \$_->{exception} unless $MATCH_RUN;

				# Execute the advice code
				my \$dummy = &\$code(\$_);

				# Throw the same (or modified) exception
				my \$exception = \$_->exception;
				die \$exception if \$exception;

				# Return the potentially-modified value
				return \$_->{return_value};

			} else {
				eval {
					Sub::Uplevel::uplevel(
						2, \$original, \@_,
					)
				};
				return unless \$\@;

				local \$_ = bless {
					sub_name     => \$name,
					wantarray    => \$wantarray,
					params       => \\\@_,
					return_value => undef,
					exception    => \$\@,
					pointcut     => \$pointcut,
					original     => \$original,
				}, 'Aspect::Point::AfterThrowing';

				die \$_->{exception} unless $MATCH_RUN;

				# Execute the advice code
				&\$code(\$_);

				# Throw the same (or modified) exception
				my \$exception = \$_->exception;
				die \$exception if \$exception;

				return;
			}
		};
END_PERL
	}

	# If this will run lexical we don't need a descoping hook
	return unless $lexical;

	# Return the lexical descoping hook.
	# This MUST be stored and run at DESTROY-time by the
	# parent object calling _install. This is less bullet-proof
	# than the DESTROY-time self-executing blessed coderef
	return sub { $out_of_scope = 1 };
}

1;

__END__

=pod

=head1 NAME

Aspect::Advice::AfterThrowing - Execute code when a function throws an
exception

=head1 SYNOPSIS

  use Aspect;
  
  after_throwing {
      # Trace all function calls that throw an exception
      print STDERR "Called my function " . $_->sub_name . "\n";
  
      # Suppress stringwise "bar" errors from foo() and return true instead
      if (
          $_->short_sub_name eq 'foo'
          and
          ref $_->exception
          and
          $_->exception =~ /bar/
      ) {
          $_->return_value(1);
      }
  
  } call qr/^ MyModule::\w+ $/

=head1 DESCRIPTION

The C<after_throwing> advice type is used to execute code when calls to a
function result in it (or something within it) throwing an exception.

The C<after_throwing> advice type can be useful for catching and
suppressing exceptions like a kind of targetted try/catch mechanism,
to enhance the information recorded in a exception object, or to apply
additional logging or other side effects to the exception.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
