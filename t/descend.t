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
			cmp_deeply("a", "a", "scalar eq");
		},
		{
			name => "scalar eq",
			actual_ok => 1,
			diag => "",
		}
	);

	check_test(
		sub {
			cmp_deeply("a", "b", "scalar not eq");
		},
		{
			name => "scalar not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data
   got : 'a'
expect : 'b'
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply("a", undef, "scalar undef");
		},
		{
			name => "scalar undef",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data
   got : 'a'
expect : undef
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply("", undef);
		},
		{
			actual_ok => 0,
			diag => <<EOM,
Compared \$data
   got : ''
expect : undef
EOM
		},
		"scalar undef and blank"
	);
}

{
	check_test(
		sub {
			cmp_deeply(["a", "b"], ["a", "b"], "array eq");
		},
		{
			name => "array eq",
			actual_ok => 1,
			diag => "",
		}
	);
	check_test(
		sub {
			cmp_deeply(["a", "b"], ["a", "c"], "array not eq");
		},
		{
			name => "array not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[1]
   got : 'b'
expect : 'c'
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply(["a", "b"], ["a"], "array got DNE");
		},
		{
			name => "array got DNE",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[1]
   got : 'b'
expect : Does not exist
EOM
		}
	);
	check_test(
		sub {
			cmp_deeply(["a"], ["a", "b"], "array expected DNE");
		},
		{
			name => "array expected DNE",
			actual_ok => 0,
			diag => <<EOM,
Compared \$data->[1]
   got : Does not exist
expect : 'b'
EOM
		}
	);
}

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
Compared \$data->{"key2"}
   got : Does not exist
expect : 'c'
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
Compared \$data->{"key2"}
   got : 'c'
expect : Does not exist
EOM
		}
	);
}

{
	check_test(
		sub {
			cmp_deeply(\"a", \"a", "scalar ref eq");
		},
		{
			name => "scalar ref eq",
			actual_ok => 1,
			diag => "",
		}
	);
	check_test(
		sub {
			cmp_deeply(\"a", \"b", "scalar ref not eq");
		},
		{
			name => "scalar ref not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared \${\$data}
   got : 'a'
expect : 'b'
EOM
		}
	);
}

{
	check_test(
		sub {
			cmp_deeply(\\"a", \\"a", "ref ref eq");
		},
		{
			name => "ref ref eq",
			actual_ok => 1,
			diag => "",
		}
	);
	check_test(
		sub {
			cmp_deeply(\\"a", \\"b", "ref ref not eq");
		},
		{
			name => "ref ref not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared \${\${\$data}}
   got : 'a'
expect : 'b'
EOM
		}
	);
}

{
	check_test(
		sub {
			cmp_deeply(qr/a/, qr/a/, "regexp ref eq");
		},
		{
			name => "regexp ref eq",
			actual_ok => 1,
			diag => "",
		}
	);
	check_test(
		sub {
			cmp_deeply(qr/a/, qr/b/, "regexp ref not eq");
		},
		{
			name => "regexp ref not eq",
			actual_ok => 0,
			diag => <<EOM,
Compared m/\$data/
   got : (?-xism:a)
expect : (?-xism:b)
EOM
		}
	);
}

{
	my @a;
	check_test(
		sub {
			cmp_deeply(\@a, \@a);
		},
		{
			actual_ok => 1,
			diag => "",
		},
		"equal refs"
	);
}

{
	my @a;
	check_test(
		sub {
			cmp_deeply(undef, \@a);
		},
		{
			actual_ok => 0,
		},
		"not calling StrVal on undef"
	);
}
