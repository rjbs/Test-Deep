use strict;
use warnings;

package Test::Deep::Class;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	my $snobby = shift;
	my $val = shift;

	$self->{snobby} = $snobby;
	$self->{val} = $val;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	local $Test::Deep::Snobby = $self->{snobby};

	Test::Deep::wrap($self->{val})->descend($d1);
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return 0 if $self->{snobby} != $other->{snobby};

	local $Test::Deep::Snobby = $self->{snobby};

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
