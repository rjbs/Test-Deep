use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Carp qw(confess);

$SIG{__WARN__} = $SIG{__DIE__} = \&confess;

{
	my $str = "ferg";
	my $re = qr/$str/;
	check_test(
		sub {
			cmp_deeply("fergal", re($re));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"re eq"
	);

	check_test(
		sub {
			cmp_deeply("feargal", re($re));
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Using Regexp on \$data
   got : 'feargal'
expect : $re
EOM
		},
		"re not eq"
	);

	check_test(
		sub {
			cmp_deeply("fergal", re($str));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"string re eq"
	);

	check_test(
		sub {
			cmp_deeply("feargal", re($str));
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Using Regexp on \$data
   got : 'feargal'
expect : $re
EOM
		},
		"string runre not eq"
	);
}
