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
		return 0 unless Test::Deep::blessed(blessed($exp))->descend($d1);
	}

	return 1;
}

1;
