use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Carp qw(confess);

$SIG{__WARN__} = $SIG{__DIE__} = \&confess;

{
	my $a = {};

	check_test(
		sub {
			cmp_deeply([$a, ["b"]], [shallow($a), ["b"]]);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"shallow eq"
	);

	my $b = [];
	check_test(
		sub {
			cmp_deeply([$a, ["b"]], [shallow($b), ["b"]]);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[0]
   got : $a
expect : $b
EOM
		},
		"shallow not eq"
	);

	check_test(
		sub {
			cmp_deeply([$a."", ["b"]], [shallow($a), ["b"]]);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[0]
   got : '$a'
expect : $a
EOM
		},
		"shallow not eq"
	);

	check_test(
		sub {
			cmp_deeply([$a, ["b"]], [shallow($a), ["a"]]);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[1][0]
   got : 'b'
expect : 'a'
EOM
		},
		"deep after shallow not eq"
	);
}
