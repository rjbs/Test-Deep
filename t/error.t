use strict;

use Test::More qw(no_plan);

use Test::Deep;

use lib '../Test-Tester/lib';
use Test::Tester;

Test::Deep::builder(Test::Tester::capture());

use Test::NoWarnings;

{
	my ($prem, @res) = eval {
		run_tests(
			sub {
				cmp_deeply([shallow([])], [[]], "bad special");
			}
		);
	};

	like($@, qr/^Found a special comparison in \$data->\[0\]\nYou can only the specials in the expects structure/,
		"bad special");
}
