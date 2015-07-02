use Test::Tester;

use Test::More qw(no_plan);
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

use Test::Deep;

Test::Deep::builder(Test::Tester::capture());

1;
