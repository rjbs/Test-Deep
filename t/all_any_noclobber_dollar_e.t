use strict;
use warnings;
use lib 't/lib';

use Std;

{
    $^E = 11;
    all(123);
    is( 0 + $^E, 11, 'all() doesn’t overwrite $^E' );
}

{
    $^E = 11;
    any(123);
    is( 0 + $^E, 11, 'any() doesn’t overwrite $^E' );
}
