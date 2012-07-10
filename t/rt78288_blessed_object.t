use strict;
use warnings FATAL => 'all';

use t::std;

check_test(
    sub { cmp_deeply('Foo', isa('Foo')) },
    {
        actual_ok => 0,
        diag => <<EOM,
Checking class of \$data with isa()
   got : 'Foo'
expect : blessed into 'Foo'
EOM
    },
    'isa on a string'
);



