use strict;
use warnings;
use ExtUtils::MakeMaker;

my %params = (
  NAME          => 'FetchJS',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/FetchJS.pm',
  ABSTRACT_FROM => 'lib/FetchJS.pm',
  LICENSE       => 'perl',
  PREREQ_PM     => {
    'Archive::Tar'             => 0,
    'Archive::Zip'             => 0,
    'CLI::Dispatch'            => 0,
    'CSS::Minifier::XS'        => 0,
    'Data::Dump'               => 0,
    'File::HomeDir'            => 0,
    'File::Spec'               => 0,
    'File::Which'              => 0,
    'Furl'                     => 0,
    'HTTP::Date'               => 0,
    'JavaScript::Minifier::XS' => 0,
    'List::Util'               => 0,
    'LWP::Protocol::https'     => 0,
    'LWP::UserAgent'           => 0,
    'Path::Extended'           => 0,
    'Test::More'               => '0.47',
    'Test::UseAllModules'      => '0.10',
    'URI'                      => 0,
    'Web::Scraper'             => 0,
  },
  EXE_FILES => [qw/fetch_js/],
  META_MERGE => {
    resources => {
      repository => 'https://github.com/charsbar/fetch_js',
    },
  },
);

my $eumm = $ExtUtils::MakeMaker::VERSION;
delete $params{META_MERGE}       if $eumm < 6.46;
delete $params{LICENSE}          if $eumm < 6.31;

WriteMakefile(%params);
