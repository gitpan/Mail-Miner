#!/usr/bin/perl
use strict;
use Mail::Miner;
use Mail::Miner::Attachment;
use Getopt::Long;
my %options;

GetOptions (\%options, 
    "detach=i", 
    "summary", 
    map {"$_=s"} keys %Mail::Miner::allowed_options
);

# This is getting steadily less fake.

if ($options{detach}) {
    Mail::Miner::Attachment::detach($options{detach});
} elsif (grep { exists $Mail::Miner::allowed_options{$_} } keys %options) {
    Mail::Miner::Message::report(%options);
} else {
    die "This option not implemented or unreleased.\n";
}
