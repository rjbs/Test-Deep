use strict;
use warnings;

package Test::Deep::String;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	$self->{val} = shift;
}

sub descend
{
	my $self = shift;
	my $d1 = shift()."";

	$self->push($d1);

	return $d1 eq $self->{val};
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return 1 if $self->{val} eq $other->{val};
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Comparing $where as a string";
}

1;
