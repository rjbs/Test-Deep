use strict;

package Test::Deep::Methods;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	# get them all into [$name,@args] => $value format
	my @methods;
	while (@_)
	{
		my $name = shift;
		my $value = shift;
		push(@methods,
			[
				ref($name) ? $name : [ $name ],
				$value
			]
		);
	}
	$self->{methods} = \@methods;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my $ok = 1;

	my %data = (type => $self);

	push(@Test::Deep::Stack, \%data);

	foreach my $method (@{$self->{methods}})
	{
		$data{method} = $method;

		my ($call, $expected) = @$method;
		my ($name, @args) = @$call;

		my $got = UNIVERSAL::can($d1, $name) ? $d1->$name(@args) : $Test::Deep::DNE;

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

	my $method = $data->{method};
	my ($call, $expect) = @$method;
	my ($name, @args) = @$call;

	my $args = @args ? "(".join(", ", @args).")" : "";
	$var .= "->$name$args";

	return $var;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{methods}, $other->{methods});
}

1;
