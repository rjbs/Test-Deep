# $Header: /home/fergal/my/cvs/Test-Deep/Makefile.PL,v 1.7 2003/07/12 14:48:27 fergal Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR => 'Fergal Daly <fergal@esatclear.ie>',
	NAME => 'Test::Deep',
	VERSION_FROM => './lib/Test/Deep.pm',
	INSTALLDIRS => 'perl',
	PREREQ_PM => {
		Test::Tester => '0.04',
		Test::NoWarnings => '0.02',
		Scalar::Util => '1.09',
		List::Util => '1.09', # apparently CPAN doesn't get the version of Scalar::Util
	}
);

if ($Scalar::Util::VERSION < 1.10)
{
	print <<EOM

*** Scalar::Util's version is less than 1.10, you will be missing some
*** functionality from number() comparisons
EOM
}
