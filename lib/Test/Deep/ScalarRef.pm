use strict;
use warnings;

package Test::Deep::ScalarRef;
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
	my $r2 = $self->{val};

	return 0 unless $self->test_class($r1);
	return 0 unless $self->test_reftype($r1, Scalar::Util::reftype($r2));

	$self->push($$r1);

	return Test::Deep::descend($$r1, $$r2);
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;

	return "\${$var}";
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
