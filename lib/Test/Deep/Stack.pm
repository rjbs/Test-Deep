use strict;
use warnings;

package Test::Deep::Stack;
use Carp qw( confess );

use Test::Deep::MM qw( new init Stack Arrow );

sub init
{
	my $self = shift;

	$self->SUPER::init(@_);

	$self->setStack([]) unless $self->getStack;
}

sub push
{
	my $self = shift;

	push(@{$self->getStack}, @_);
}

sub pop
{
	my $self = shift;

	return pop @{$self->getStack};
}

sub render
{
	my $self = shift;
	my $var = shift;

	my $stack = $self->getStack;

	$self->setArrow(0);

	foreach my $data (@$stack)
	{
		my $type = $data->{type};
		if (UNIVERSAL::isa($type, "Test::Deep::Cmp"))
		{			
			$var = $type->render_stack($var, $data);

			$self->setArrow(0) if $data->{type}->reset_arrow;
		}
		else
		{
			confess "Don't know how to render '$data->{type}'";
		}
	}

	return $var;
}

sub getLast
{
	my $self = shift;

	return $self->getStack->[-1];
}

sub incArrow
{
	my $self = shift;

	my $a = $self->getArrow;
	$self->setArrow($a + 1);

	return $a;
}

1;
