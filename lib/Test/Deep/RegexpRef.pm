use strict;
use warnings;

package Test::Deep::RegexpRef;
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

	my $r1 = shift;

	return 0 unless $self->test_class($r1, "Regexp");
	return 0 unless $self->test_reftype($r1, "SCALAR");

	my $r2 = $self->{val};

	$self->push($r1);

	return $r1 eq $r2;
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

sub renderGot
{
	my $self = shift;

	return shift()."";
}

1;
