use strict;
use warnings;

package Test::Deep::Hash;
use Carp qw( confess );

use Test::Deep::Ref;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Ref );

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

	my $h1 = shift;

	my $h2 = $self->{val};

	return 0 unless Test::Deep::descend($h1, Test::Deep::hashkeys(keys %$h2));

	return 0 unless $self->test_class($h1);

	my $data = $self->push;

	my $bigger = keys %$h1 > keys %$h2 ? $h1 : $h2;

	foreach my $key (keys %$bigger)
	{
		$data->{index} = $key;

		my $got = exists $h1->{$key} ? $h1->{$key} : $Test::Deep::DNE;
		my $expected = exists $h2->{$key} ? $h2->{$key} : $Test::Deep::DNE;

		next if Test::Deep::descend($got, $expected);

		return 0;
	}

	return 1;
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;
	$var .= "->" unless $Test::Deep::Stack->incArrow;
	$var .= '{"'.quotemeta($data->{index}).'"}';

	return $var;
}

sub reset_arrow
{
	return 0;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
