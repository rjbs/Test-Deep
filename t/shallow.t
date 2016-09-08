use strict;
use warnings;

use lib 't';
use std;

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

{
  my $u = shallow(undef);
  check_tests(
    sub {
      cmp_deeply(undef, $u);
      cmp_deeply("a", $u);
      cmp_deeply("a", $u);
      cmp_deeply("a", undef);
    },
    [
      {
        actual_ok => 1,
      },
      {
        actual_ok => 0,
      },
      {
        actual_ok => 0,
      },
      {
        actual_ok => 0,
      },
    ],
    "deep after shallow not eq"
  );
}

{
  check_test(
    sub {
      cmp_deeply( Test::Deep::EqOverloaded->new, 5);
    },
    {
      actual_ok => 0,
    },
    "comparing a plain scalar leaf against obj without eq"
  );

  local $Test::Deep::LeafWrapper = \&str;
  check_tests(
    sub {
      cmp_deeply( Test::Deep::EqOverloaded->new, 5);
      cmp_deeply( Test::Deep::EqOverloaded->new, 6);
    },
    [
      {
        actual_ok => 1,
      },
      {
        actual_ok => 0,
      },
    ],
    "comparing a plain scalar leaf against obj with eq"
  );
}

{
  package Test::Deep::EqOverloaded;
  use overload q{""} => sub { "5" }, fallback => 1;
  sub new { my $self = {}; bless $self; }
}
