use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Carp qw(confess);

$SIG{__WARN__} = $SIG{__DIE__} = \&confess;

{
	my $re = qr/^wi/;
	check_test(
		sub {
			cmp_deeply([qw( wine wind wibble winny window )], array_each( re($re) ))
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"array_each eq"
	);

	check_test(
		sub {
			cmp_deeply([qw( wibble wobble winny window )], array_each( re($re) ))
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Using Regexp on \$data->[1]
   got : 'wobble'
expect : $re
EOM
		},
		"array_each not eq"
	);
}
