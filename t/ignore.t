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
			cmp_deeply([[{}, "argh"], ["b"]], [ignore(), ["b"]]);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"ignore"
	);
}
