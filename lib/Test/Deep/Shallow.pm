use strict;

package Test::Deep::Shallow;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

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
	my $d1 = shift;

	my %data = (type => $self);

	push(@Test::Deep::Stack, \%data);

	local $Test::Deep::Shallow = 1;

	my $ok = Test::Deep::descend($d1, $self->{val});

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

	return $self->{val} eq $other->{val};
}

1;
