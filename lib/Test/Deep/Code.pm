use strict;
use warnings;

package Test::Deep::Code;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	my $code = shift || die "No coderef supplied";

	$self->{code} = $code;
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my %data = (type => $self);

	push(@Test::Deep::Stack, \%data);

	my ($ok, $diag) = &{$self->{code}}($d1);

	if ($ok)
	{
		pop @Test::Deep::Stack;
	}
	else
	{
		$data{diag} = $diag;
		$data{data} = $d1;
	}

	return $ok;
}

sub diagnostics
{
	my $self = shift;
	my ($where, $last) = @_;

	my $type = $self->{IgnoreDupes} ? "Set" : "Bag";

	my $error = $last->{diag};
	my $data = Test::Deep::render_val($last->{data});
	my $diag = <<EOM;
Ran coderef at $where on

$data

and it said
$error
EOM

	return $diag;
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

	return Test::Deep::descend($self->{code}, shallow($other->{code}));
}

1;
