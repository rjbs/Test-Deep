use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Test::NoWarnings;

{
	check_test(
		sub {
			cmp_deeply(1, num(1));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"number eq"
	);

	check_test(
		sub {
			cmp_deeply(1, num(2))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data as a number (==)
got      : '1'
expected : '2'
EOM
		},
		"number not eq"
	);

	check_test(
		sub {
			cmp_deeply("1a", num("1"))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"funny number eq"
	);

	SKIP:{
		skip("Scalar::Util < 1.10", 2) unless $Scalar::Util::VERSION >= 1.10;
	   	check_test(
   			sub {
   				cmp_deeply("1a", num("1", "strict"))
	   		},
   			{
   				actual_ok => 0,
	   		},
   			"funny number eq strict"
	   	);
	}

}

{
	require "t/over.pm";

	my $o = Over->new(1);

	check_test(
		sub {
			cmp_deeply($o, num(1))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"over number eq"
	);

	check_test(
		sub {
			cmp_deeply($o, num(2))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data as a number (==)
got      : 1
expected : '2'
EOM
		},
		"over number not eq"
	);
}
