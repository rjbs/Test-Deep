use strict;
use warnings;
use lib 't/lib';

use Std;

{
    $! = 11;
    all(123);
    is( 0 + $!, 11, 'all() doesn’t overwrite $!' );
}

{
    $! = 11;
    any(123);
    is( 0 + $!, 11, 'any() doesn’t overwrite $!' );
}
