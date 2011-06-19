use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'OneFourty',
    AUTHOR       => q{MARCO FONTANI <MFONTANI@cpan.org>},
    VERSION_FROM => 'lib/OneFourty.pm',
    ABSTRACT     => 'Meet the 140 chars challenge!',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'                 => 0,
        'YAML'                       => 0,
        'Text::Xslate'               => '1.3000',
        'Dancer'                     => 1.3060,
        'Dancer::Template::Xslate'   => 0.01,
        'Dancer::Plugin::Cache::CHI' => '1.0.1',
        'Net::Twitter'               => 3.17001,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'OneFourty-*' },
);
