use strict;
use warnings;

package Test::Deep::HashEach;
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

	my $ok = 1;

	my %data = (type => $self);

	my %d2;

	@d2{keys %$d1} = ($self->{val}) x (keys %$d1);

	$Test::Deep::Stack->push(\%data);

	$ok = Test::Deep::descend($d1, \%d2);

	$Test::Deep::Stack->pop if $ok;

	return $ok;
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
