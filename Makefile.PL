use ExtUtils::MakeMaker;

print <<EOWARN;

This is alpha software. Remember to read the 'README' file.

EOWARN

WriteMakefile(
    'NAME'		=> 'Aspect',
    'VERSION_FROM'	=> 'lib/Aspect.pm', # finds $VERSION
    'PREREQ_PM'		=> {
    	Class::MethodMaker  => '1.02',
    	IO::Scalar          => '1.125',
	Hook::LexWrap       => '0.20',
    },
    dist                => {
        # don't ask about existing .tar.gz files
        COMPRESS => 'gzip --force --best'
    },
);
