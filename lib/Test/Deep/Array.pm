use strict;
use warnings;

package Test::Deep::Array;
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
	my $a1 = shift;

	my $a2 = $self->{val};

	return 0 unless Test::Deep::arraylength(scalar @$a2)->descend($a1);

	return 0 unless $self->test_class($a1);

	my $ok = 1;

	my %data = (type => $self);

	$Test::Deep::Stack->push(\%data);

	for my $i (0..$#{$a2})
	{
		$data{index} = $i;

		my $got = $a1->[$i];
		my $expected = $a2->[$i];

		$ok = Test::Deep::descend($got, $expected);

		if (! $ok)
		{
			$data{vals} = [$got, $expected];
			last;
		}
	}

	$Test::Deep::Stack->pop if $ok;

	return $ok;
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;
	$var .= "->" unless $Test::Deep::Stack->incArrow;
	$var .= "[$data->{index}]";

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
