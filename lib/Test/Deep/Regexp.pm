use strict;
use warnings;

package Test::Deep::Regexp;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	my $val = shift;

	$val = ref $val ? $val : qr/$val/;

	$self->{val} = $val;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	$self->push($d1);

	return ($d1 =~ $self->{val}) ? 1 : 0;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Using Regexp on $where";
}

sub renderExp
{
	my $self = shift;

	return "$self->{val}";
}

1;
