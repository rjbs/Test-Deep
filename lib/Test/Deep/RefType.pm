use strict;
use warnings;

package Test::Deep::RefType;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

use Scalar::Util qw( reftype );

sub init
{
	my $self = shift;

	$self->{val} = shift;
}

sub descend
{
	my $self = shift;

	my $d1 = shift;

	my $exp = $self->{val};
	my $reftype = reftype($d1);

	$self->push($reftype);

	my $cmp = Test::Deep::shallow($exp);
	return Test::Deep::descend($reftype, $cmp);
}

sub render_stack
{
	my $self = shift;
	my $var = shift;

	return "reftype($var)";
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return $self->descend($other->{val});
}

1;
