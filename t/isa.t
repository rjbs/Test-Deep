use strict;

use Test::More qw(no_plan);

use Test::Deep;

use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Test::NoWarnings;

{
	my $a = {};

	check_test(
		sub {
			cmp_deeply($a, isa("HASH"));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"isa eq"
	);
}

{
	my $b = bless {}, "B";

	check_test(
		sub {
			cmp_deeply($b, isa("B"));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"isa eq"
	);


	check_test(
		sub {
			cmp_deeply($b, isa("A"));
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Checking class of \$data with isa()
   got : $b
expect : 'A'
EOM
		},
		"isa eq"
	);

	@A::ISA = ();
	@B::ISA = ("A");

	check_test(
		sub {
			cmp_deeply($b, isa("A"));
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"isa eq"
	);
}
