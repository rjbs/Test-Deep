# $Header: /home/fergal/my/cvs/Test-Deep/Makefile.PL,v 1.1 2003/03/04 19:42:32 fergal Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
	AUTHOR => 'Fergal Daly <fergal@esatclear.ie>',
	NAME => 'Test::Deep',
	VERSION_FROM => './lib/Test/Deep.pm',
	INSTALLDIRS => 'perl',
);
