use strict;
use warnings;

package Test::Deep::Boolean;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	$self->{val} = shift;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	$self->push($d1);

	return !( $d1 xor $self->{val} );
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return !( $self->{val} xor $other->{val} );
}

sub diag_message
{
	my $self = shift;
	my $where = shift;
	return "Comparing $where as a boolean";
}

sub renderExp
{
	my $self = shift;

	$self->renderGot($self->{val});
}

sub renderGot
{
	my $self = shift;

	my $val = shift;

	return ($val ? "true" : "false")." (".Test::Deep::render_val($val).")";
}

1;
