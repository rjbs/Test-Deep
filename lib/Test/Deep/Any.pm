use strict;

package Test::Deep::Any;
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

	my $ok = 0;

	foreach my $cmp (@{$self->{val}})
	{
		if (Test::Deep::eq_deeply_cache($d1, $cmp))
		{
			$ok = 1;
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

	return $var;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

sub diagnostics
{
	my $self = shift;
	my ($where, $last) = @_;

	my $vals = $last->{vals};
	my ($got, $expect) = @$vals;

	$got = Test::Deep::render_val($got);
	my $things = join(", ", map {Test::Deep::render_val($_)} @$expect);

	my $diag = <<EOM;
Comparing $where with Any
got      : $got
expected : Any of ( $things )
EOM

	$diag =~ s/\n+$/\n/;
	return $diag;
}

sub add
{
	my $self = shift;
	my $expect = shift;

	push(@{$self->{val}}, $expect);

	return $self;
}

1;
