use strict;
use warnings;

package Test::Deep::Shallow;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

use Scalar::Util qw( refaddr );

sub init
{
	my $self = shift;

	my $val = shift;
	$self->{val} = $val;
}

sub descend
{
	my $self = shift;

	my $d1 = shift;
	my $d2 = $self->{val};

	$self->push($d1);

	my $ok;

	if (!defined $d1 and !defined $d2)
	{
		$ok = 1;
	}
	elsif (defined $d1 xor defined $d2)
	{
		$ok = 0;
	}
	elsif (ref $d1 and ref $d2)
	{
		$ok = refaddr($d1) == refaddr($d2);
	}
	elsif (ref $d1 xor ref $d2)
	{
		$ok = 0;
	}
	else
	{
		$ok = $d1 eq $d2;
	}

	return $ok;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return $self->descend($other->{val});
}

1;
