use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Mail::Miner',
    'VERSION_FROM'	=> 'Miner.pm', # finds $VERSION
   'EXE_FILES'     => ['mm', 'mm_process'],
    'PMLIBDIRS'    => [ 'Miner', 'Audit' ],
    'PREREQ_PM'		=> { Class::DBI::mysql => 0, 
                         Class::DBI => 0.90,
                         Lingua::EN::Keywords => 0,
                         Mail::Address => 0,
                         MIME::Parser => 0
                       },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Miner.pm', # retrieve abstract from module
       AUTHOR     => 'Simon Cozens <simon@cpan.org>') : ()),
);

use Term::ReadKey;
print "\nNow it's time to set up the Mail::Miner database.\n";
my ($database, $username, $password);
do {{
    print "What is the name of your mail database? ";
    if (defined $database) { print "[$database] "; }
    my $newdatabase = <STDIN>; chomp $newdatabase;
    $database = $newdatabase || $database;

    print "And your username? ";
    if (defined $username) { print "[$username] "; }
    my $newusername = <STDIN>; chomp $newusername;
    $username = $newusername || $username;

    ReadMode 2;
    print "And finally, your password? ";
    $password = ReadLine 0;
    chomp $password;
    ReadMode 0;

    print "\n\nIs that correct? [y]\n";
    my $ok = <>; redo if $ok =~ /n/i;
    
    print "\nThanks. Now writing the configuration file.\n";
}};

$username = quotemeta $username;
$password = quotemeta $password;
$database = quotemeta $database;

open OUT, ">Miner/Config.pm" or die $!;
print OUT <<EOF;
package Mail::Miner::Config;

our (\$db, \$username, \$password) = 
    ("$database", "$username", "$password");

1;

EOF

print "Now you need to do a make.\n";
