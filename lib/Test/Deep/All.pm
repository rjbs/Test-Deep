use strict;

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

	my @list = @_;

	$self->{val} = \@list;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my %data = (type => $self, vals => [$d1, $self->{val}]);

	push(@Test::Deep::Stack, \%data);

	my $ok = 1;

	my $index = 1;

	foreach my $cmp (@{$self->{val}})
	{
		$data{index} = $index;
		$index++;
		if (! Test::Deep::descend($d1, $cmp))
		{
			$ok = 0;
			last;
		}
	}

	pop @Test::Deep::Stack if $ok;

	return $ok;
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

	push(@{$self->{val}}, $expect);

	return $self;
}

1;
