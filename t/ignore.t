use strict;

use Test::More qw(no_plan);

use Test::Deep;

use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Test::NoWarnings;

{
	check_test(
		sub {
			cmp_deeply([[{}, "argh"], ["b"]], [ignore(), ["b"]]);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"ignore"
	);
}
