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

	return 0 unless Test::Deep::hashkeys(keys %$h2)->descend($h1);

	return 0 unless $self->test_class($h1);


	my $ok = 1;

	my %data = (type => $self);

	push(@Test::Deep::Stack, \%data);

	my $bigger = keys %$h1 > keys %$h2 ? $h1 : $h2;

	foreach my $key (keys %$bigger)
	{
		$data{index} = $key;

		my $got = exists $h1->{$key} ? $h1->{$key} : $Test::Deep::DNE;
		my $expected = exists $h2->{$key} ? $h2->{$key} : $Test::Deep::DNE;

		$ok = Test::Deep::descend($got, $expected);

		if (! $ok)
		{
			$data{vals} = [$got, $expected];
			last;
		}
	}

	pop @Test::Deep::Stack if $ok;
	return $ok;
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;
	$var .= "->" unless $Test::Deep::DidArrow++;
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
