require 5.008002;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME          => 'Aspect',
	ABSTRACT      => 'AOP for Perl',
	VERSION_FROM  => 'lib/Aspect.pm',
	AUTHOR        => 'Ran Eilam <eilara@cpan.org>',
	dist          => {COMPRESS => 'gzip --force --best'},
	PREREQ_PM     => {Devel::Symdump => 2.03},
);
