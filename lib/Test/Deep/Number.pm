use strict;
use warnings;

package Test::Deep::Number;

use Test::Deep::Cmp;

use Scalar::Util;

sub init
{
	my $self = shift;

	$self->{val} = shift(@_) + 0;
}

sub descend
{
	my $self = shift;
	my $got = shift;
	{
		no warnings 'numeric';
		$got += 0;
	}

	$self->data->{got} = $got;

	return $got == $self->{val};
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Comparing $where as a number";
}

1;
