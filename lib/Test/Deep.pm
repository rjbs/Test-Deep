use strict;

package Test::Deep;
use Carp qw( confess );

use Test::Deep::Cache;
require overload;
use Scalar::Util;

use Test::Builder;

my $Test = Test::Builder->new;

use Data::Dumper qw(Dumper);

use vars qw(
	$VERSION @EXPORT @EXPORT_OK @ISA
	@Stack %Compared $CompareCache
	$Snobby $Expects $DNE $Shallow
);

$VERSION = '0.04';

require Exporter;
@ISA = qw( Exporter );

@EXPORT = qw( eq_deeply cmp_deeply cmp_set cmp_bag cmp_methods
	methods shallow useclass noclass ignore set bag re any all isa array_each
	hash_each str num bool
);
@EXPORT_OK = qw( descend render_stack deep_diag class_base );

$Snobby = 1; # should we compare classes?
$Expects = 0; # are we comparing got vs expect or expect vs expect
$Shallow = 0;

$DNE = \"";

sub cmp_deeply
{
	my ($d1, $d2, $name) = @_;

	local @Stack = ();
	local $CompareCache = Test::Deep::Cache->new;

	my $ok = descend($d1, $d2);

	if (not $Test->ok($ok, $name))
	{
		my $diag = deep_diag(@Stack);
		$Test->diag($diag);
	}

	return $ok;
}

sub eq_deeply
{
	my ($d1, $d2, $name) = @_;

	local @Stack = ();
	local $CompareCache = Test::Deep::Cache->new;

	my $ok = descend($d1, $d2);

	return $ok;
}

sub eq_deeply_cache
{
	# this is like cross between eq_deeply and descend(). It doesn't with a
	# new $CompareCache but if the comparison fails it will leave
	# $CompareCache as if nothing happened. However, if the comparison
	# succeeds then $CompareCache retain all the new information

	# this allows Set and Bag to handle circular refs

	my ($d1, $d2, $name) = @_;

	local @Stack = ();
	$CompareCache->local;

	my $ok = descend($d1, $d2);

	$CompareCache->finish($ok);

	return $ok;
}

sub deep_diag
{
	my @stack = @_;
	my $where = render_stack('$data', @stack);

	confess "No stack to diagnose" unless @Stack;
	my $last = $stack[-1];

	my $diag;
	my $message;
	my $got;
	my $expected;

	if (ref $last->{type})
	{
		if ($last->{type}->can("diagnostics"))
		{
			$diag = $last->{type}->diagnostics($where, $last);
			$diag =~ s/\n+$/\n/;
		}
		else
		{
			if ($last->{type}->can("diag_message"))
			{
				$message = $last->{type}->diag_message($where);
			}
		}
	}

	if (not defined $diag)
	{
		my $vals = $last->{vals};
		$got = render_val($vals->[0]) unless defined $got;
		$expected = render_val($vals->[1]) unless defined $expected;
		$message = "Compared $where" unless defined $message;

		$diag = <<EOM
$message
   got : $got
expect : $expected
EOM
	}

	return $diag;
}

sub render_val
{
	# add in Data::Dumper stuff
	my $val = shift;

	my $rendered;
	if (defined $val)
	{
	 	$rendered = ref($val) ? overload::StrVal($val) eq $DNE ? "Does not exist"
	                                                         : $val
                          : qq('$val');
	}
	else
	{
	  $rendered = "undef";
	}

	return $rendered;
}

sub descend
{
	my ($d1, $d2) = @_;

	if (!defined $d1 and !defined $d2)
	{
		return 1;
	}

	if (! $Expects and UNIVERSAL::isa($d1, "Test::Deep::Cmp"))
	{
		my $where = render_stack('$data', @Stack);
		confess "Found a special comparison in $where\nYou can only the specials in the expects structure";
	}

	my $ok;

	if (! ref $d2 or $Shallow)
	{
		# $d2 is a scalar or we're doing shallow comparison

		if (defined $d1 xor defined $d2)
		{
			$ok = 0;
		}
		elsif (ref $d1 xor ref $d2)
		{
			$ok = 0;
		}
		else
		{
			$ok = $d1 eq $d2;
		}

		if (not $ok)
		{
			my %data = (type => 'scalar', vals => [$d1, $d2]);

			push(@Stack, \%data);
		}
	} 
	else
	{
		# d2 is a reference, the fun starts

		if (ref $d1)
		{
			my $s1 = overload::StrVal($d1);
			my $s2 = overload::StrVal($d2);

			if ($s1 eq $s2)
			{
				return 1;
			}
			if ($CompareCache->cmp($s1, $s2))
			{
				# we've tried comparing these already so either they turned out to
				# be the same or we must be in a loop and we have to assume they're
				# the same

				$ok = 1;
			}
			else
			{
				$CompareCache->add($s1, $s2)
			}
		}

		goto break_out if $ok; # avoid yet more indenting

		# find out the class and the base type of each
		my ($class1, $base1) = class_base($d1);
		my ($class2, $base2) = class_base($d2);

		if(UNIVERSAL::isa($d2, "Test::Deep::Cmp"))
		{
			if ($Expects)
			{
				# we are comparing special 2 expects, this is special and only the
				# expects know how to compare themselves

				if ($class1 ne $class2 or $base1 ne $base2)
				{
					$ok = 0;
				}
				else
				{
					$ok = $d1->compare($d2);
				}
			}
			else
			{
				# special stuff
				$ok = $d2->descend($d1);
			}
		}
		elsif($base1 ne $base2 or ($Snobby and $class1 ne $class2))
		{
			my %data = (type => 'scalar', vals => [$d1, $d2]);

			push(@Stack, \%data);

			$ok = 0;
		}
		elsif($base2 eq 'ARRAY')
		{
			$ok = descend_array($d1, $d2);
		}
		elsif($base2 eq 'HASH')
		{
			$ok = descend_hash($d1, $d2);
		}
		elsif($base2 eq 'SCALAR' or $base2 eq 'REF')
		{
			$ok = descend_ref($d1, $d2);
		}
		elsif($base2 eq 'Regexp')
		{
			$ok = descend_regexp($d1, $d2);
		}
		else
		{
			confess "I have no idea how to compare '$d1' and '$d2'";
		}
	}

	break_out:

	confess "ok was not set for '$d1' and '$d2'" unless defined($ok);

	return $ok;
}

sub descend_regexp
{
	my ($r1, $r2) = @_;

	my %data = (type => 'regexp', vals => [$r1, $r2]);

	push(@Stack, \%data);

	my $ok = $r1 eq $r2;

	pop @Stack if $ok;

	return $ok;
}

sub descend_array
{
	my ($a1, $a2) = @_;

	my $ok = 1;
	my $max = $#$a1 < $#$a2 ? $#$a2 : $#$a1;

	my %data = (type => 'array');

	push(@Stack, \%data);

	for my $i (0..$max)
	{
		$data{index} = $i;

		my $got = $i > $#$a1 ? $DNE : $a1->[$i];
		my $expected = $i > $#$a2 ? $DNE : $a2->[$i];

		$ok = descend($got, $expected);

		if (! $ok)
		{
			$data{vals} = [$got, $expected];
			last;
		}
	}

	pop @Stack if $ok;
	return $ok;
}

sub descend_hash
{
	my ($h1, $h2) = @_;

	my $ok = 1;

	my %data = (type => 'hash');

	push(@Stack, \%data);

	my $bigger = keys %$h1 > keys %$h2 ? $h1 : $h2;

	foreach my $key (keys %$bigger)
	{
		$data{index} = $key;

		my $got = exists $h1->{$key} ? $h1->{$key} : $DNE;
		my $expected = exists $h2->{$key} ? $h2->{$key} : $DNE;

		$ok = descend($got, $expected);

		if (! $ok)
		{
			$data{vals} = [$got, $expected];
			last;
		}
	}

	pop @Stack if $ok;
	return $ok;
}

sub descend_ref
{
	my ($r1, $r2) = @_;

	my %data = (type => 'ref', vals => [$$r1, $$r2]);

	push(@Stack, \%data);

	my $ok = descend($$r1, $$r2);

	pop @Stack if $ok;

	return $ok;
}

sub class_base
{
	my $val = shift;

	my $blessed = Scalar::Util::blessed($val);
	my $reftype = Scalar::Util::reftype($val);
	if (defined($blessed) and $blessed eq "Regexp" and $reftype eq "SCALAR")
	{
		$reftype = "Regexp"
	}
	return ($blessed, $reftype);
}

sub render_stack
{
	my ($var, @stack) = @_;

	my $did_arrow = 0;

	for my $i (0..$#Stack)
	{
		my $data = $Stack[$i];

		if (ref $data->{type})
		{
			$var = $data->{type}->render_stack($var, $data);

			# we could end up with anything after this so have to make sure with
			# start using arrows again

			$did_arrow = 0;
		}
		elsif ($data->{type} eq 'array')
		{
			$var .= "->" unless $did_arrow++;
			$var .= "[$data->{index}]";
		}
		elsif ($data->{type} eq 'hash')
		{
			$var .= "->" unless $did_arrow++;
			$var .= '{"'.quotemeta($data->{index}).'"}';
		}
		elsif ($data->{type} eq 'ref')
		{
			$var = "\${$var}";
		}
		elsif ($data->{type} eq 'regexp')
		{
			$var = "m/$var/";
		}
		elsif ($data->{type} eq 'scalar')
		{
			# don't do anything for a plain scalar
		}
		else
		{
			confess "Don't know how to render '$data->{type}'";
		}
	}

	return $var;
}

sub methods
{
	require Test::Deep::Methods;

	return Test::Deep::Methods->new(@_);
}

sub cmp_methods
{
	return cmp_deeply(shift, methods(@{shift()}));
}

sub shallow
{
	require Test::Deep::Shallow;

	my $val = shift;
	return Test::Deep::Shallow->new($val);
}

sub requireclass
{
	require Test::Deep::Class;

	my $val = shift;

	return Test::Deep::Class->new(1, $val);
}

sub noclass
{
	require Test::Deep::Class;

	my $val = shift;

	return Test::Deep::Class->new(0, $val);
}

sub ignore
{
	require Test::Deep::Ignore;

	return Test::Deep::Ignore->new;
}

sub set
{
	require Test::Deep::Set;

	return Test::Deep::Set->new(1, @_);
}

sub cmp_set
{
	return cmp_deeply(shift, set(@{shift()}));
}

sub bag
{
	require Test::Deep::Set;

	return Test::Deep::Set->new(0, @_);
}

sub cmp_bag
{
	return cmp_deeply(shift, bag(@{shift()}));
}

sub re
{
	require Test::Deep::Regexp;

	my $re = shift;

	return Test::Deep::Regexp->new($re);
}

sub any
{
	require Test::Deep::Any;

	return Test::Deep::Any->new(@_);
}

sub all
{
	require Test::Deep::All;

	return Test::Deep::All->new(@_);
}

sub isa
{
	require Test::Deep::Isa;

	my $class = shift;

	return Test::Deep::Isa->new($class);
}

sub array_each
{
	require Test::Deep::ArrayEach;

	my $val = shift;

	return Test::Deep::ArrayEach->new($val);
}

sub hash_each
{
	require Test::Deep::HashEach;

	my $val = shift;

	return Test::Deep::HashEach->new($val);
}

sub str
{
	require Test::Deep::String;

	my $val = shift;

	return Test::Deep::String->new($val);
}

sub num
{
	require Test::Deep::Number;

	my $val = shift;

	return Test::Deep::Number->new($val);
}

sub bool
{
	require Test::Deep::Boolean;

	my $val = shift;

	return Test::Deep::Boolean->new($val);
}

sub builder
{
	if (@_)
	{
		$Test = shift;
	}
	return $Test;
}

1;

