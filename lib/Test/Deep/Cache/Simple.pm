use strict;
use warnings;

package Test::Deep::Cache::Simple;
use Carp qw( confess );

sub new
{
	my $pkg = shift;

	my $self = bless {}, $pkg;

	return $self;
}

sub add
{
	my $self = shift;

	my ($d1, $d2) = @_;
	$self->{$d1}->{$d2} = 1;
	$self->{$d2}->{$d1} = 1;
}

sub cmp
{
	my $self = shift;

	my ($d1, $d2) = @_;
	return $self->{$d1}->{$d2};
}

sub absorb
{
	my $self = shift;

	my $other = shift;

	while (my ($d1, $d2s) = each %$other)
	{
		@{$self->{$d1}}{keys %$d2s} = values %$d2s;
	}
}

1;
