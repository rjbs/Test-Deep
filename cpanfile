use ExtUtils::MakeMaker;

# this ugliness comes from incompatibility of certain versions of
# Test::Tester with certain version of Test::Builder. The problem is
# that people might have an old TT lying around and are also likely to
# have quite a new TB. This detects that situation and hopefully
# demands an install of a newer TT.

my $required_tester = '0.04';

if (eval { require Test::Tester; require Test::Builder; 1 } &&
  $Test::Tester::VERSION <= 0.106 &&
  $Test::Builder::VERSION >= 0.78) {

  $required_tester = '0.107';
}

my $eumm = ExtUtils::MakeMaker->VERSION;

my %phase_prereqs = (
  'Test::More'   => '0.88',
  'Test::Tester' => $required_tester,
);

my %global_prereqs = (
  'Test::Builder' => '0',
  'Scalar::Util'  => '1.09',

  # apparently CPAN doesn't get the version of Scalar::Util
  'List::Util' => '1.09',

  $eumm < 6.55_01 ? %phase_prereqs : (),
);

my $phase = $eumm >= 6.55_01 ? $eumm >= 6.63_03 ? 'test' : 'build' : 0;
if ($phase) {
    on $phase => sub {
        requires $_, $phase_prereqs{$_} for keys %phase_prereqs;
    };
}

requires $_, $global_prereqs{$_} for keys %global_prereqs;
