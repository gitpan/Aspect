require 5.008002;

use ExtUtils::MakeMaker;

print <<EOWARN;

This is alpha software. There have been massive API changes since last
version. Please check README and Changes.

EOWARN

WriteMakefile(
	NAME          => 'Aspect',
	ABSTRACT      => 'AOP for Perl',
	VERSION_FROM  => 'lib/Aspect.pm',
	AUTHOR        => 'Ran Eilam <eilara@cpan.org>',
	dist          => { COMPRESS => 'gzip --force --best' },
	PREREQ_PM     => {
		Test::Class      => 0.06_5,
		Devel::Symdump   => 2.03,
		Benchmark::Timer => 0.5,
	},
);

