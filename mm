#!/usr/bin/perl
use strict;
use Mail::Miner;
use Mail::Miner::Attachment;
use Getopt::Long;
my %options;

GetOptions (\%options, "detach=i");

# This is basically fake for now.

if ($options{detach}) {
    Mail::Miner::Attachment::detach($options{detach});

} else {
    die "This option not implemented or unreleased.\n";
}
