use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Mail::Miner',
    'VERSION_FROM'	=> 'Miner.pm', # finds $VERSION
    'EXE_FILES'     => ['mm', 'mm_process'],
    'PMLIBDIRS'    => [ 'Miner', 'Audit' ],
    'PREREQ_PM'		=> {
        "MIME::Parser"  => 0,
        "Date::Manip"   => 0,
        "Mail::Address" => 0,
        "DBI"           => 0,
        "DBD::mysql"    => 0
        }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Miner.pm', # retrieve abstract from module
       AUTHOR     => 'Simon Cozens <simon@cpan.org>') : ()),
);

print <<EOF;

Before you can use this, you'll need to create a mysql database with
the schema as described in miner.sql. Then arrange for your incoming
mail to be delivered through either mm_process or Mail::Audit::Miner.
Enjoy.

EOF
