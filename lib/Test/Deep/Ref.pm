use strict;
use warnings;

package Test::Deep::Ref;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Scalar::Util qw( blessed );

sub test_class
{
	my $self = shift;
	my $d1 = shift;

	my $exp = $self->{val};
	
	if ($Test::Deep::Snobby)
	{
		return Test::Deep::descend($d1, Test::Deep::blessed(blessed($exp)));
	}
	else
	{
		return 1;
	}
}

sub test_reftype
{
	my $self = shift;
	my $ref = shift;
	my $reftype = shift;

	return Test::Deep::descend($ref, Test::Deep::reftype($reftype));
}

1;
