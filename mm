#!/usr/bin/perl
use strict;
use Mail::Miner;
use Mail::Miner::Attachment;
use Getopt::Long;
my %options;

GetOptions (\%options, 
    "detach=i", 
    "summary", 
    "help",
    "debug",
    map {"$_$Mail::Miner::allowed_options{$_}{type}"} keys %Mail::Miner::allowed_options
);

# This is getting steadily less fake.

$Mail::Miner::Message::DEBUG =1 if $options{debug};
delete $options{debug};
help() if $options{help};

if ($options{detach}) {
    Mail::Miner::Attachment::detach($options{detach});
} elsif (grep { exists $Mail::Miner::allowed_options{$_} } keys %options) {
    Mail::Miner::Message::report(%options);
} else {
    print "This option not implemented or unreleased.\n";
    help();
}

sub help {
    print <<EOF;
This is mm, version $Mail::Miner::VERSION

Usage:
 mm --detach 1234 # Detach attachment 1234
 mm [options]     # Find and report messages from the database

Presently available options include:

 --debug - Provide debugging output
 --summary - Give a brief listing of the output
 --help - You're reading it
EOF

my @disp;
for (keys %Mail::Miner::allowed_options) {
    print " --$_$Mail::Miner::allowed_options{$_}{type} - ".$Mail::Miner::allowed_options{$_}{help}."\n";
    no strict 'refs';
    push @disp, $_ if exists &{$Mail::Miner::allowed_options{$_}{package}."::display"};
}

print <<EOF;

If --summary is not given, the default is to produce a mailbox-format
output of the messages matching the search criteria. However, if any of
the following options are given and --summary is not set, then mm will
merely display the information extracted:

EOF

print "  --$_\n" for @disp;

}
