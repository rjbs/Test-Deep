use strict;
use warnings;

package Test::Deep::Number;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

use Scalar::Util;

sub init
{
	my $self = shift;

	$self->{val} = shift(@_) + 0;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;
	{
		no warnings 'numeric';
		$d1 += 0;
	}
	my %data = (type => $self, vals => [$d1, $self->{val}]);

	$Test::Deep::Stack->push(\%data);

	my $ok = $d1 == $self->{val};

	$Test::Deep::Stack->pop if $ok;

	return $ok;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return $self->{val} == $other->{val};
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Comparing $where as a number";
}

1;
