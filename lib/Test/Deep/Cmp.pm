use strict;
use warnings;

package Test::Deep::Cmp;
use Carp qw( confess );

use overload
	'&' => \&make_all,
	'|' => \&make_any,
	'""' => \&string,
	fallback => 1,
;

sub new
{
	my $pkg = shift;

	my $self = bless {}, $pkg;

	$self->init(@_);
	return $self;
}

sub init
{
}

sub make_all
{
	my ($e1, $e2) = @_;

	if (UNIVERSAL::isa($e1, "Test::Deep::All"))
	{
		$e1->add($e2);
		return $e1;
	}
	elsif(UNIVERSAL::isa($e2, "Test::Deep::All"))
	{
		$e2->add($e1);
		return $e2;
	}
	else
	{
		return Test::Deep::all($e1, $e2);
	}
}

sub make_any
{
	my ($e1, $e2) = @_;

	if (UNIVERSAL::isa($e1, "Test::Deep::Any"))
	{
		$e1->add($e2);
		return $e1;
	}
	elsif(UNIVERSAL::isa($e2, "Test::Deep::Any"))
	{
		$e2->add($e1);
		return $e2;
	}
	else
	{
		return Test::Deep::any($e1, $e2);
	}
}

sub cmp
{
	my ($a1, $a2, $rev) = @_;

	($a1, $a2) = ($a2, $a1) if $rev;

	return (overload::StrVal($a1) cmp overload::StrVal($a2));
}

sub string
{
	my $self = shift;

	return overload::StrVal($self);
}

sub reset_arrow
{
	return 1;
}

1;
