use strict;
use warnings;

package Test::Deep::All;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

use overload
	'&' => \&add,
;

sub init
{
	my $self = shift;

	my @list = map {Test::Deep::wrap($_)} @_;

	$self->{val} = \@list;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my $data = $self->push($d1);

	my $ok = 1;

	my $index = 1;

	foreach my $cmp (@{$self->{val}})
	{
		$data->{index} = $index;
		$index++;

		next if Test::Deep::descend($d1, $cmp);
		return 0
	}

	return 1;
}

sub render_stack
{
	my $self = shift;
	my $var = shift;
	my $data = shift;

	my $max = @{$self->{val}};

	return "(Part $data->{index} of $max in $var)";
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

sub add
{
	my $self = shift;
	my $expect = shift;

	push(@{$self->{val}}, Test::Deep::wrap($expect));

	return $self;
}

1;
