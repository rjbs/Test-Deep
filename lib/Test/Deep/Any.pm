use strict;
use warnings;

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

	my @list = map {Test::Deep::wrap($_)} @_;

	$self->{val} = \@list;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	$self->push($d1);

	foreach my $cmp (@{$self->{val}})
	{
		return 1 if Test::Deep::eq_deeply_cache($d1, $cmp);
	}

	return 0;
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

	my $expect = $self->{val};

	my $got = $self->renderGot($last->{got});
	my $things = join(", ", map {$_->renderExp} @$expect);

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

	push(@{$self->{val}}, Test::Deep::wrap($expect));

	return $self;
}

1;
