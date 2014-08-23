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

my $mm_ver = ExtUtils::MakeMaker->VERSION;

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

  LICENSE => "perl",

  # This is a dumb mistake.  Why did it get done?  I'm the one who did it and I
  # don't know.  It only affects perl 5.8, and stopping doing it now would be a
  # problem, because upgrades wouldn't actually upgrade.  I'll just leave it
  # here until 5.8 is really and truly dead enough. -- rjbs, 2013-11-30
  ($] < 5.010 ? (INSTALLDIRS => 'perl') : ()),

  ($mm_ver < 6.46 ? () : (META_MERGE => {
    resources => {
        license     =>      'http://dev.perl.org/licenses/',
        homepage    =>      'http://github.com/rjbs/Test-Deep/',
        bugtracker  =>      'http://github.com/rjbs/Test-Deep/issues/',
        repository  =>      'http://github.com/rjbs/Test-Deep/',
        MailingList =>      'http://lists.perl.org/list/perl-qa.html',
    },
  })),

);
