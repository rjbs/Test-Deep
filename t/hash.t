use strict;

use Test::More qw(no_plan);

use Test::Deep;

use Test::Tester;
use Test::NoWarnings;

Test::Deep::builder(Test::Tester::capture());

{
	check_test(
		sub {
			cmp_deeply({key1 => "a", key2 => "b"}, {key1 => "a", key2 => "b"},
				"hash eq");
		},
		{
			name => "hash eq",
			actual_ok => 1,
			diag => "",
		}
	);
	check_test(
		sub {
			cmp_deeply({key1 => "a", key2 => "b"}, {key1 => "a", key2 => "c"},
				"hash not eq");
		},
		{
			name => "hash not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->{"key2"}
   got : 'b'
expect : 'c'
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply({key1 => "a"}, {key1 => "a", key2 => "c"},
				"hash got DNE");
		},
		{
			name => "hash got DNE",
			actual_ok => 0,
			diag => <<EOM,
Comparing hash keys of hash keys of \$data
Missing: 'key2'
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply({key1 => "a", key2 => "c"}, {key1 => "a"},
				"hash expected DNE");
		},
		{
			name => "hash expected DNE",
			actual_ok => 0,
			diag => <<EOM,
Comparing hash keys of hash keys of \$data
Extra: 'key2'
EOM
		}
	);
}
