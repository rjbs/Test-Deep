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
			cmp_deeply("wine", any("beer", "wine"))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"any eq"
	);

	check_test(
		sub {
			cmp_deeply("whisky", any("beer", "wine"))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data with Any
got      : 'whisky'
expected : Any of ( 'beer', 'wine' )
EOM
		},
		"any not eq"
	);

	check_test(
		sub {
			cmp_deeply("whisky", any("beer") | "wine")
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data with Any
got      : 'whisky'
expected : Any of ( 'beer', 'wine' )
EOM
		},
		"any with |"
	);

	check_tests(
		sub {
			cmp_deeply("whisky", re("isky") | "wine", "pass");
			cmp_deeply("whisky", re("iskya") | "wine", "fail")
		},
		[
			{ actual_ok => 1 },
			{ actual_ok => 0 }
		],
		"| without any"
	);

}
