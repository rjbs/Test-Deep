use strict;
use warnings;

package Test::Deep::Isa;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

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

	my %data = (type => $self, vals =>[$d1, $self->{val}]);

	$Test::Deep::Stack->push(\%data);

	my $ok = UNIVERSAL::isa($d1, $self->{val});

	$Test::Deep::Stack->pop if $ok;

	return $ok;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return $self->{val} eq $other->{val};
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Checking class of $where with isa()";
}

1;
