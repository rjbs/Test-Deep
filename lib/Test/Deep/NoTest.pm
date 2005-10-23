use strict;
use warnings;

package Test::Deep::NoTest;

use vars qw( $NoTest @ISA @EXPORT );

require Exporter;
@ISA = qw( Exporter );

@EXPORT = qw( eq_deeply );

local $NoTest = 1;
require Test::Deep;
Test::Deep->import("eq_deeply");

1;
