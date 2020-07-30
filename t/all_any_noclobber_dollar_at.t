use strict;
use warnings;
use lib 't/lib';

use Std;

{
    $@ = 'hello';
    all(123);
    is( $@, 'hello', 'all() doesn’t overwrite $@' );
}

{
    $@ = 'hello';
    any(123);
    is( $@, 'hello', 'any() doesn’t overwrite $@' );
}
