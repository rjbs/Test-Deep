# $Header: /home/fergal/my/cvs/Test-Deep/Makefile.PL,v 1.8 2003/09/16 23:33:50 fergal Exp $

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
