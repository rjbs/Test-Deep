use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Carp qw(confess);

$SIG{__WARN__} = $SIG{__DIE__} = \&confess;

{
	my $bless_a = bless {}, "A::Class";
	my $bless_b = bless {}, "B::Class";
	my $nobless = {};

	check_test(
		sub {
			cmp_deeply([$bless_a], [noclass($bless_b)]);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"no class eq"
	);

	check_test(
		sub {
			cmp_deeply([$bless_a], [noclass($nobless)]);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"no class eq unblessed"
	);

	check_test(
		sub {
			cmp_deeply([$bless_a], [$bless_b]);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[0]
   got : $bless_a
expect : $bless_b
EOM
		},
		"class not eq"
	);

	check_test(
		sub {
			cmp_deeply([$bless_a], [$nobless]);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[0]
   got : $bless_a
expect : $nobless
EOM
		},
		"class not eq unblessed"
	);

	my $bless_c = bless [$bless_a], "C::Class";

	check_test(
		sub {
			cmp_deeply(
				$bless_c,
				bless([noclass($nobless)], "C::Class")
			);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"class eq on/off"
	);
}
