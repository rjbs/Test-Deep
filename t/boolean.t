use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Test::NoWarnings;

{
	check_tests(
		sub {
			cmp_deeply(1, bool(1), "num 1");
			cmp_deeply("abds", bool(1), "string");
			cmp_deeply(0, bool(0), "num 0");
			cmp_deeply("", bool(0), "string");
		},
		[
			({
				actual_ok => 1,
				diag => "",
			}) x 4
		],
		"ok"
	);

	check_tests(
		sub {
			cmp_deeply(1, bool(0), "num 1");
			cmp_deeply("abds", bool(0), "string");
			cmp_deeply(0, bool(1), "num 0");
			cmp_deeply("", bool(1), "string");
		},
		[
			{
				actual_ok => 0,
				diag => <<EOM,
Comparing \$data as a boolean
got      : '1'
expected : '0'
EOM
			},
			({
				actual_ok => 0,
			}) x 3,
		],
		"string not eq"
	);
}

{
	require "t/over.pm";

	my $o = Over->new("wine");

	check_test(
		sub {
			cmp_deeply($o, str("wine"))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"over string eq"
	);

	check_test(
		sub {
			cmp_deeply($o, str("wind"))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data as a string (eq)
got      : wine
expected : 'wind'
EOM
		},
		"over string not eq"
	);
}
