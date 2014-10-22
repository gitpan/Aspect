package Aspect::AdviceContext;

use strict;
use warnings;
use Carp ();

our $VERSION = '0.29';





######################################################################
# Constructor and Built-In Accessors

sub new {
	my $class = shift;
	my $self  = bless { @_, proceed => 1 }, $class;
	unless ( $self->{sub_name} ) {
		Carp::croak("Cannot create Aspect::AdviceContext without sub_name");
	}
	return $self;
}

sub sub_name {
	$_[0]->{sub_name};
}

sub wantarray {
	$_[0]->{wantarray};
}

sub proceed {
	$_[0]->{proceed} = $_[1] if @_ > 1;
	$_[0]->{proceed};
}

sub params_ref {
	$_[0]->{params};
}

sub self {
	$_[0]->{params}->[0];
}

sub params {
	$_[0]->{params} = [ @_[1..$#_] ] if @_ > 1;
	return CORE::wantarray
		? @{$_[0]->{params}}
		: $_[0]->{params};
}

sub append_param {
	my $self = shift;
	push @{$self->{params}}, @_;
	return 1;
}

sub append_params {
	shift->append_param(@_);
}





######################################################################
# Higher Level Methods

sub package_name {
	my $self = shift;
	my $name = $self->{sub_name};
	return '' unless $name =~ /::/;
	$name =~ s/::[^:]+$//;
	return $name;
}

sub short_sub_name {
	my $self = shift;
	my $name = $self->{sub_name};
	return $name unless $name =~ /::/;
	$name =~ /::([^:]+)$/;
	return $1;
}

sub run_original {
	my $self     = shift;
	my $original = $self->original;
	my @params   = $self->params;
	my $return_value;
	if ( CORE::wantarray ) {
		$return_value = [ $original->(@params) ];
	} else {
		$return_value = $original->(@params);
	}
	return $self->return_value($return_value);
}

sub return_value {
	my ($self, $value) = @_;
	if ( @_ > 1 ) {
		$self->{return_value} = $value;
		$self->{proceed} = 0;
	}
	my $return_value = $self->get_value('return_value');
	return (CORE::wantarray && ref $return_value eq 'ARRAY')
		? @$return_value
		: $return_value;
}

sub get_value {
	my ($self, $key) = @_;
	Carp::croak "Key does not exist: [$key]" unless exists $self->{$key};
	my $value = $self->{$key};
	return (CORE::wantarray && ref $value eq 'ARRAY')
		? @$value
		: $value;
}

sub AUTOLOAD {
	my $self = shift;
	my $key  = our $AUTOLOAD;
	$key =~ s/^.*:://;
	return $self->get_value($key);
}

# Improves performance by not having to send DESTROY calls
# through AUTOLOAD, and not having to check for DESTROY in AUTOLOAD.
sub DESTROY () { }

1;

__END__

=pod

=head1 NAME

Aspect::AdviceContext - a pointcut context for advice code

=head1 SYNOPSIS

  $pointcut = call qr/^Person::[gs]et_/ & cflow company => qr/^Company::/;

  # using in 'before' advice code
  before {
     my $context = shift;             # context is only param to advice code
     print $context->type;            # 'before': advice type: before/after
     print $context->pointcut;        # $pointcut: the pointcut for this advice
     print $context->sub_name;        # package + sub name of matched sub
     print $context->package_name;    # 'Person': package name of matched sub
     print $context->short_sub_name;  # sub name of matched sub
     print $context->self;            # 1st parameter to matched sub
     print $context->params->[1];     # 2nd parameter to matched sub
     $context->append_param($rdbms);  # append param to matched sub
     $context->append_params($a, $b); # append params to matched sub
     $context->return_value(4)        # don't proceed to matched sub, return 4
     $context->original->(x => 3);    # call matched sub, don't proceed
     $context->proceed(1);            # do proceed to matched sub after all
     print $context->company->name;   # access cflow pointcut advice context
  } $pointcut;

=head1 DESCRIPTION

Advice code is called when the advice pointcut is matched. In this code,
there is always a need to access information about the context of the
advice. Information like: what is the actual sub name matched? What are
the parameters in this call that we matched? Sometimes you want to change
the context for the matched sub: append a parameter, or even stop the
matched sub from being called.

You do all these things through the C<AdviceContext>. It is the only
parameter provided to the advice code. It provides all the information
required about the match context, and allows you to change the behavior
of the matched sub.

Note that modifying parameters through the context, in the code of an
I<after> advice, will have no effect, since the matched sub has already
been called.

=head1 CFLOW CONTEXT

If the pointcut of an advice is composed of at least one
L<Aspect::Pointcut::Cflow>, advice code may require not only the context
of the advice, but also the context of the cflows. This is required if
you want to find out, for example, what is the name of the sub that
matched a cflow. E.g. for the synopsis example above, what method of
C<Company> started the chain of calls that eventually reached the get/set
on C<Person>?

You can access cflow context in the synopsis above, by calling:

  $context->company;

You get it from the main advice context, by calling a method named after
the context key used in the cflow spec. In the synopsis pointcut
definition, the cflow part was:

  cflow company => qr/^Company::/
        ^^^^^^^

An C<AdviceContext> will be created for the cflow, and you can access it
using the key C<company>.

=head1 EXAMPLES

Print parameters to matched sub:

  before { my $c = shift; print join(',', $c->params) } $pointcut;

Append a parameter:

  before { shift->append_param('extra-param') } $pointcut;

Don't proceed to matched sub, return 4 instead:

  before { shift->return_value(4) } $pointcut;

Call matched sub again, and again, until it returns something defined:

  after {
     my $context = shift;
     my $return  = $context->return_value;
     while (!defined $return)
        { $return = $context->original($context->params) }
     $context->return_value($return);
  } $pointcut;

Print the name of the C<Company> object that started the chain of calls
that eventually reached the get/set on C<Person>:

  before { print shift->company->name } $pointcut;

=head1 SEE ALSO

See the L<Aspect|::Aspect> pod for a guide to the Aspect module.

You can find examples of using the C<AdviceContext> in any advice code.
The aspect library for example (e.g. L<Aspect::Library::Wormhole>).

L<Aspect::Advice> creates the main C<AdviceContext>, and
C<Aspect::Pointcut::Cflow> creates contexts for each matched call flow.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Marcel GrE<uuml>nauer E<lt>marcel@cpan.orgE<gt>

Ran Eilam E<lt>eilara@cpan.orgE<gt>

=head1 SEE ALSO

You can find AOP examples in the C<examples/> directory of the
distribution.

=head1 COPYRIGHT AND LICENSE

Copyright 2001 by Marcel GrE<uuml>nauer

Some parts copyright 2009 - 2010 Adam Kennedy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
