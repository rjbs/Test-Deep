use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Carp qw(confess);

$SIG{__WARN__} = $SIG{__DIE__} = \&confess;

{
	check_test(
		sub {
			cmp_deeply("wine", str("wine"))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"string eq"
	);

	check_test(
		sub {
			cmp_deeply("wine", str("wind"))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Comparing \$data as a string (eq)
got      : 'wine'
expected : 'wind'
EOM
		},
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
