use strict;
use warnings;

use t::std;

{
  check_test(
    sub {
      cmp_deeply("wine", ~any("beer", "wine"))
    },
    {
      actual_ok => 0,
      diag => <<EOM,
Comparing \$data with None
got      : 'wine'
expected : None of ( Any of ( 'beer', 'wine' ) )
EOM
    },
    "~ eq fail"
  );

  check_test(
    sub {
      cmp_deeply("whisky", ~any("beer", "wine"))
    },
    {
      actual_ok => 1,
      diag => "",
    },
    "~ eq ok"
  );

  check_test(
    sub {
      cmp_deeply("whisky", ~str("beer") | "wine")
    },
    {
      actual_ok => 1,
      diag => "",
    },
    "~ with | match none"
  );

  check_test(
    sub {
      cmp_deeply("wine", ~str("beer") | "wine")
    },
    {
      actual_ok => 1,
      diag => "",
    },
    "~ with | match alternative"
  );

  check_test(
    sub {
      cmp_deeply("beer", ~str("beer") | "wine")
    },
    {
      actual_ok => 0,
      diag => <<EOM,
Comparing \$data with Any
got      : 'beer'
expected : Any of ( None of ( 'beer' ), 'wine' )
EOM
    },
    "~ with | fail"
  );
}
