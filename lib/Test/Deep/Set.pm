use strict;
use warnings;

package Test::Deep::Set;
use Carp qw( confess );

use Test::Deep::Cmp;

use vars qw( @ISA );
@ISA = qw( Test::Deep::Cmp );

use Data::Dumper qw(Dumper);

sub init
{
	my $self = shift;

	my $dupes = shift;

	$self->{IgnoreDupes} = $dupes;
	$self->{val} = [];

	$self->add(@_);
}

sub descend
{
	my $self = shift;
	my $d1 = shift;

	my $d2 = $self->{val};

	my $IgnoreDupes = $self->{IgnoreDupes};

	my $type = $IgnoreDupes ? "Set" : "Bag";

	my %data = (type => $self);

	push(@Test::Deep::Stack, \%data);

	my $diag;

	if (ref $d1 ne 'ARRAY')
	{
		my $got = Test::Deep::render_val($d1);
		$diag = <<EOM;
got    : $got
expect : An array to use as a $type
EOM
	}

	if (not $diag)
	{
		my @got = @$d1;
		my @missing;
		foreach my $expect (@$d2)
		{
			my $found = 0;

			for (my $i = $#got; $i >= 0; $i--)
			{
				if (Test::Deep::eq_deeply_cache($got[$i], $expect))
				{
					$found = 1;
					splice(@got, $i, 1);

					last unless $IgnoreDupes;
				}
			}

			push(@missing, $expect) unless $found;
		}

		my $got = __PACKAGE__->new($IgnoreDupes, @got);

		my @diags;
		if (@missing)
		{
			push(@diags, "Missing: ".nice_list(\@missing));
		}

		if (@got)
		{
			push(@diags, "Extra: ".nice_list($got->{val}));
		}

		$diag = join("\n", @diags);
	}

	my $ok;
	if ($diag)
	{
		$ok = 0;

		$data{diag} = $diag;
	}
	else
	{
		$ok = 1;
	}

	pop @Test::Deep::Stack if $ok;

	return $ok;
}

sub diagnostics
{
	my $self = shift;
	my ($where, $last) = @_;

	my $type = $self->{IgnoreDupes} ? "Set" : "Bag";

	my $error = $last->{diag};
	my $diag = <<EOM;
Comparing $where as a $type
$error
EOM

	return $diag;
}

sub add
{
	# this takes an array.

	# For each element A of the array, it looks for an element, B, already in
	# the set which are deeply equal to A. If no matching B is found then A is
	# added to the set. If a B is found and IgnoreDupes is true, then A will
	# be discarded, if IgnoreDupes is false, then B will be added to the set
	# again.
	
	my $self = shift;

	my @array = @_;

	my $IgnoreDupes = $self->{IgnoreDupes};

	my $already = $self->{val};

	local $Test::Deep::Expects = 1;
	foreach my $new_elem (@array)
	{
		my $want_push = 1;
		my $push_this = $new_elem;
		foreach my $old_elem (@$already)
		{
			if (Test::Deep::eq_deeply($new_elem, $old_elem))
			{
				$push_this = $old_elem;
				$want_push = ! $IgnoreDupes;
				last;
			}
		}
		push(@$already, $push_this) if $want_push;
	}

	# so we can compare 2 Test::Deep::Set objects using array comparison

	@$already = sort @$already;
}

sub nice_list
{
	my $list = shift;

	my @scalars = grep ! ref $_, @$list;
	my $refs = grep ref $_, @$list;

	my @ref_string = "$refs reference" if $refs;
	$ref_string[0] .= "s" if $refs > 1;

	# sort them so we can predict the diagnostic output

	return join(", ",
		(map {"'$_'"} sort @scalars),
		@ref_string
	);
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

	return 0 if $self->{IgnoreDupes} != $other->{IgnoreDupes};

	# this works (kind of) because the the arrays are sorted

	return Test::Deep::descend($self->{val}, $other->{val});
}

1;
