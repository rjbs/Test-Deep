use strict;

use ExtUtils::MakeMaker;

# this ugliness comes from incompatibility of certain versions of
# Test::Tester with certain version of Test::Builder. The problem is
# that people might have an old TT lying around and are also likely to
# have quite a new TB. This detects that situation and hopefully
# demands an install of a newer TT.

my $tt_prereq = "0.04";

if (eval { require Test::Tester; require Test::Builder; 1 } &&
  $Test::Tester::VERSION <= 0.106 &&
  $Test::Builder::VERSION >= 0.78) {

  $tt_prereq = "0.107";
}

WriteMakefile(
  AUTHOR       => 'Fergal Daly <fergal@esatclear.ie>',
  NAME         => 'Test::Deep',
  VERSION_FROM => './lib/Test/Deep.pm',
  PREREQ_PM    => {
    'Test::More'       => '0',
    'Test::Tester'     => $tt_prereq,
    'Test::NoWarnings' => '0.02',
    'Scalar::Util'     => '1.09',

    # apparently CPAN doesn't get the version of Scalar::Util
    'List::Util'       => '1.09',
  },

  ($] < 5.010 ? (INSTALLDIRS => 'perl') : ()),
);
