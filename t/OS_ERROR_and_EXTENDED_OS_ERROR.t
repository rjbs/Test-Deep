use strict;
use warnings;

use Test::More;
use Test::NoWarnings;

plan tests => 2;

use Test::Deep;

{
    local $! = 5;
    all();

    is(
        0 + $!,
        5,
        'loading all() leaves $! alone',
    );
}
