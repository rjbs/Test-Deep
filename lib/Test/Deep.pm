use strict;
use warnings;

package Test::Deep;
use Carp qw( confess );

use Test::Deep::Cache;
use Test::Deep::Stack;
require overload;
use Scalar::Util;

use Test::Builder;

my $Test = Test::Builder->new;

use Data::Dumper qw(Dumper);

use vars qw(
	$VERSION @EXPORT @EXPORT_OK @ISA
	$Stack %Compared $CompareCache
	$Snobby $Expects $DNE $DNE_ADDR $Shallow
);

$VERSION = '0.081';

require Exporter;
@ISA = qw( Exporter );

@EXPORT = qw( eq_deeply cmp_deeply cmp_set cmp_bag cmp_methods
	methods shallow useclass noclass ignore set bag re any all isa array_each
	hash_each str num bool scalref array hash regexpref reftype blessed
	arraylength hashkeys code
);

@EXPORT_OK = qw( descend render_stack deep_diag class_base );

$Snobby = 1; # should we compare classes?
$Expects = 0; # are we comparing got vs expect or expect vs expect

$DNE = \"";
$DNE_ADDR = Scalar::Util::refaddr($DNE);

my %WrapCache;

sub cmp_deeply
{
	my ($d1, $d2, $name) = @_;

	local $Stack = Test::Deep::Stack->new;
	local $CompareCache = Test::Deep::Cache->new;

	my $ok = descend($d1, $d2);

	if (not $Test->ok($ok, $name))
	{
		my $diag = deep_diag($Stack);
		$Test->diag($diag);
	}

	return $ok;
}

sub eq_deeply
{
	my ($d1, $d2, $name) = @_;

	local $Stack = Test::Deep::Stack->new;
	local $CompareCache = Test::Deep::Cache->new;

	my $ok = descend($d1, $d2);

	return $ok;
}

sub eq_deeply_cache
{
	# this is like cross between eq_deeply and descend(). It doesn't start
	# with a new $CompareCache but if the comparison fails it will leave
	# $CompareCache as if nothing happened. However, if the comparison
	# succeeds then $CompareCache retains all the new information

	# this allows Set and Bag to handle circular refs

	my ($d1, $d2, $name) = @_;

	local $Stack = Test::Deep::Stack->new;
	$CompareCache->local;

	my $ok = descend($d1, $d2);

	$CompareCache->finish($ok);

	return $ok;
}

sub deep_diag
{
	my $stack = shift;
	my $where = render_stack('$data', $stack);

	confess "No stack to diagnose" unless $stack;
	my $last = $stack->getLast;

	my $diag;
	my $message;
	my $got;
	my $expected;

	my $type = $last->{type};
	if (ref $type)
	{
		if ($type->can("diagnostics"))
		{
			$diag = $type->diagnostics($where, $last);
			$diag =~ s/\n+$/\n/;
		}
		else
		{
			if ($type->can("diag_message"))
			{
				$message = $type->diag_message($where);
			}
		}
	}

	if (not defined $diag)
	{
		my $vals = $last->{vals};
		$got = $type->renderGot($vals->[0]) unless defined $got;
		$expected = $type->renderExp($vals->[1]) unless defined $expected;
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
	 	$rendered = ref($val) ?
	 		(Scalar::Util::refaddr($val) eq $DNE_ADDR ?
	 			"Does not exist" :
	      overload::StrVal($val)
	    ) :
      qq('$val');
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

	if (! $Expects and ref($d1) and UNIVERSAL::isa($d1, "Test::Deep::Cmp"))
	{
		my $where = render_stack('$data', $Stack);
		confess "Found a special comparison in $where\nYou can only the specials in the expects structure";
	}

	if (ref $d1 and ref $d2)
	{
		if ($Expects and UNIVERSAL::isa($d1, "Test::Deep::Cmp"))
		{
			return 0 unless blessed(Scalar::Util::blessed($d2))->descend($d1);
			return $d1->compare($d2);
		}

		my $s1 = Scalar::Util::refaddr($d1);
		my $s2 = Scalar::Util::refaddr($d2);

		if ($s1 eq $s2)
		{
			return 1;
		}
		if ($CompareCache->cmp($d1, $d2))
		{
			# we've tried comparing these already so either they turned out to
			# be the same or we must be in a loop and we have to assume they're
			# the same

			return 1;
		}
		else
		{
			$CompareCache->add($d1, $d2)
		}
	}

	$d2 = wrap($d2);

	return $d2->descend($d1);
}

sub wrap
{
	my $data = shift;

	return $data if ref($data) and UNIVERSAL::isa($data, "Test::Deep::Cmp");

	my ($class, $base) = class_base($data);

	my $cmp;

	if($base eq '')
	{
		$cmp = shallow($data);
	}
	else
	{
		my $addr = Scalar::Util::refaddr($data);

		return $WrapCache{$addr} if $WrapCache{$addr};
		
		if($base eq 'ARRAY')
		{
			$cmp = array($data);
		}
		elsif($base eq 'HASH')
		{
			$cmp = hash($data);
		}
		elsif($base eq 'SCALAR' or $base eq 'REF')
		{
			$cmp = scalref($data);
		}
		elsif($base eq 'Regexp')
		{
			$cmp = regexpref($data);
		}
		else
		{
			confess "I don't know how to wrap '$base'";
		}

		$WrapCache{$addr} = $cmp;
	}
	return $cmp;
}

sub class_base
{
	my $val = shift;

	if (ref $val)
	{
		my $blessed = Scalar::Util::blessed($val);
		$blessed = defined($blessed) ? $blessed : "";
		my $reftype = Scalar::Util::reftype($val);

		if ($blessed eq "Regexp" and $reftype eq "SCALAR")
		{
			$reftype = "Regexp"
		}
#		print "$blessed, $reftype\n";
		return ($blessed, $reftype);
	}
	else
	{
		return ("", "");
	}
}

sub render_stack
{
	my ($var, $stack) = @_;

	return $stack->render($var);
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

	return Test::Deep::Number->new(@_);
}

sub bool
{
	require Test::Deep::Boolean;

	my $val = shift;

	return Test::Deep::Boolean->new($val);
}

sub scalref
{
	require Test::Deep::ScalarRef;

	my $val = shift;

	return Test::Deep::ScalarRef->new($val);
}

sub array
{
	require Test::Deep::Array;

	my $val = shift;

	return Test::Deep::Array->new($val);
}

sub hash
{
	require Test::Deep::Hash;

	my $val = shift;

	return Test::Deep::Hash->new($val);
}

sub regexpref
{
	require Test::Deep::RegexpRef;

	my $val = shift;

	return Test::Deep::RegexpRef->new($val);
}

sub reftype
{
	require Test::Deep::RefType;

	my $val = shift;
	my $regex = shift;
	return Test::Deep::RefType->new($val, $regex);
}

sub blessed
{
	require Test::Deep::Blessed;

	my $val = shift;

	return Test::Deep::Blessed->new($val);
}

sub arraylength
{
	require Test::Deep::ArrayLength;

	my $val = shift;

	return Test::Deep::ArrayLength->new($val);
}

sub hashkeys
{
	require Test::Deep::HashKeys;

	return Test::Deep::HashKeys->new(@_);
}

sub code
{
	require Test::Deep::Code;

	return Test::Deep::Code->new(@_);
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

