use strict;

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

	my %data = (type => $self, vals => [$d1, $self->{val}]);

	push(@Test::Deep::Stack, \%data);

	local $Test::Deep::Shallow = 1;

	my $ok = ($d1 =~ $self->{val}) ? 1 : 0;

	pop @Test::Deep::Stack if $ok;

	return $ok;
	scalar ($d1 =~ $self->{val});
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

	return Test::Deep::descend($self->{val}, $other->{val});
}

sub diag_message
{
	my $self = shift;

	my $where = shift;

	return "Using Regexp on $where";
}

1;
