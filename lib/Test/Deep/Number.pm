use strict;
use warnings;

package Test::Deep::Number;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

use Scalar::Util;

sub init
{
	my $self = shift;

	$self->{val} = shift(@_) + 0;

	my $mode = shift;

	$mode = "loose" unless defined $mode;

	if($mode !~ /^(strict|loose)$/)
	{
		die "'$mode' is not a valid mode";
	}

	if ($mode eq "strict" and $Scalar::Util::VERSION < 1.10)
	{
		die "You need Scalar::Util 1.10 or greater to use number's strict mode";
	}

	$self->{mode} = $mode;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my %data = (type => $self, vals => [$d1, $self->{val}]);

	push(@Test::Deep::Stack, \%data);

	if ($self->{mode} eq "strict")
	{
		if (! Scalar::Util::looks_like_number($d1))
		{
			# if we're being strict, fail because $d1 doesn't look like a number
			return 0 if $self->{"mode"} eq "strict";
		}
	}

	my $ok;
	{
		no warnings 'numeric';

		$ok = $d1 == $self->{val};
	}

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

	return $self->{val} == $other->{val};
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
Comparing $where as a number (==)
got      : $got
expected : $expect
EOM

	$diag =~ s/\n+$/\n/;
	return $diag;
}

1;
