use strict;
use warnings;

package Test::Deep::RegexpRef;
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

	my $r1 = shift;

	my $r2 = $self->{val};

	my %data = (type => $self, vals => [$r1, $r2]);

	push(@Test::Deep::Stack, \%data);

	my $ok = $r1 eq $r2;

	pop @Test::Deep::Stack if $ok;

	return $ok;
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;

	return "m/$var/";
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
