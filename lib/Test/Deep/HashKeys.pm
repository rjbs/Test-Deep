use strict;
use warnings;

package Test::Deep::HashKeys;
use Carp qw( confess );

use Test::Deep::Ref;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Ref );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	my %keys;
	@keys{@_} = ();
	$self->{val} = \%keys;
	$self->{keys} = [sort @_];
}

sub descend
{
	my $self = shift;
	my $hash = shift;

	return 0 unless Test::Deep::reftype("HASH")->descend($hash);

	my $exp = $self->{val};
	my %got;
	@got{keys %$hash} = ();

	my @missing;
	my @extra;

	while (my ($key, $value) = each %$exp)
	{
		if (exists $got{$key})
		{
			delete $got{$key};
		}
		else
		{
			push(@missing, $key);
		}
	}

	my @diags;
	if (@missing)
	{
		push(@diags, "Missing: ".nice_list(\@missing));
	}

	if (%got)
	{
		push(@diags, "Extra: ".nice_list([keys %got]));
	}

	if (@diags)
	{
		my $diag = join("\n", @diags);
		push(@Test::Deep::Stack, {type => $self, diag => $diag});
		return 0;
	}

	return 1;
}

sub render_stack
{
	my $self = shift;
	my ($var, $data) = @_;

	return "hash keys of $var";
}

sub compare
{
	my $self = shift;

	my $other = shift;

	return Test::Deep::descend($self->{keys}, $other->{keys});
}

sub diagnostics
{
	my $self = shift;
	my ($where, $last) = @_;

	my $type = $self->{IgnoreDupes} ? "Set" : "Bag";

	my $error = $last->{diag};
	my $diag = <<EOM;
Comparing hash keys of $where
$error
EOM

	return $diag;
}

sub nice_list
{
	my $list = shift;

	return join(", ",
		(map {"'$_'"} sort @$list),
	);
}

1;
