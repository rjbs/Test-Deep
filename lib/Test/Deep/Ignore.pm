use strict;
use warnings;

package Test::Deep::Ignore;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

my $Singleton = __PACKAGE__->SUPER::new;

sub new
{
	return $Singleton;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	return 1;
}

sub compare
{
	return 1;
}

1;
