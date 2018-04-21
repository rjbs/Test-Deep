use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
  AUTHOR  => 'Fergal Daly <fergal@esatclear.ie>',
  NAME    => 'Test::Deep',
  VERSION => ##{ $version ##},

  PREREQS_PM => ##{
    use Data::Dumper qw( Dumper );
    $Data::Dumper::Indent = 1;
    my $meta = Dumper $meta{prereqs}{runtime}{requires};
    $meta =~ s/^\$VAR\d+ = |;$//g;
    $meta ##},

  LICENSE => "perl",

  # This is a dumb mistake.  Why did it get done?  I'm the one who did it and I
  # don't know.  It only affects perl 5.8, and stopping doing it now would be a
  # problem, because upgrades wouldn't actually upgrade.  I'll just leave it
  # here until 5.8 is really and truly dead enough. -- rjbs, 2013-11-30
  ($] < 5.010 ? (INSTALLDIRS => 'perl') : ()),

  (ExtUtils::MakeMaker->VERSION < 6.46 ? () : (META_MERGE => ##{
    use Data::Dumper qw( Dumper );
    $Data::Dumper::Indent = 1;
    my $meta = Dumper \%meta;
    $meta =~ s/^\$VAR\d+ = |;$//g;
    $meta ##},
  )),
);
