require 5.008;
use ExtUtils::MakeMaker;

print <<EOWARN;

This is alpha software. Remember to read the 'README' file.

EOWARN

WriteMakefile(
    'NAME'		=> 'Aspect',
    'VERSION_FROM'	=> 'lib/Aspect.pm', # finds $VERSION
    'PREREQ_PM'		=> {
    	Class::MethodMaker  => 1.02,
    	IO::Scalar          => 1.125,
	Hook::LexWrap       => 0.20,
	Test::More          => 0.45,
    },
    dist                => {
        # don't ask about existing .tar.gz files
        COMPRESS => 'gzip --force --best'
    },
);
