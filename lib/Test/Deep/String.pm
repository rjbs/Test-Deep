use strict;

package Test::Deep::String;
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

	my %data = (type => $self, vals => [$d1, $self->{val}]);

	push(@Test::Deep::Stack, \%data);

	my $ok = $d1 eq $self->{val};

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

	return 1 if $self->{val} eq $other->{val};
}

sub diagnostics
{
	my $self = shift;
	my ($where, $last) = @_;

	my $vals = $last->{vals};
	my ($got, $expect) = @$vals;

	$got = Test::Deep::render_val($got);
	$expect = Test::Deep::render_val($expect);

	my $diag = <<EOM;
Comparing $where as a string (eq)
got      : $got
expected : $expect
EOM

	$diag =~ s/\n+$/\n/;
	return $diag;
}

1;
