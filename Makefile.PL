# $Header: /home/fergal/my/cvs/Test-Deep/Makefile.PL,v 1.2 2003/03/19 19:12:16 fergal Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR => 'Fergal Daly <fergal@esatclear.ie>',
	NAME => 'Test::Deep',
	VERSION_FROM => './lib/Test/Deep.pm',
	INSTALLDIRS => 'perl',
	PREREQ_PM => {
		Test::Tester => '0.04',
	}
);
