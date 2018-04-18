use strict;
use warnings;

use Test::Deep::NoTest;

# make sure we didn't load Test::Builder

my $ok = not exists( ${Test::Builder::}{"new"});
print "1..2\n";
print $ok ? "" : "not ";
print "ok 1\n";

my $different = not cmp_deeply([1,2,3], [4,5,6]);
print $different ? '':  'not ';
print "ok 2\n";
