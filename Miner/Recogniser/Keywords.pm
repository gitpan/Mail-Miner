#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Keywords;
use Lingua::EN::Keywords;
use Mail::Miner::DBI;

$Mail::Miner::allowed_options{keyword} = __PACKAGE__;
$Mail::Miner::allowed_options{keywords} = __PACKAGE__;
$Mail::Miner::allowed_options{about} = __PACKAGE__;

sub process {
    my ($entity, $msgid) = @_;

    # add keywords to database
    Mail::Miner::Assets::file_asset($msgid, "Keywords", $_) for 
      keywords( $entity->bodyhandle->as_string());
    return $entity;
}

sub pre_filter {
    my ($search_string) = @_;
    my $subselect = q{SELECT * FROM assets WHERE message_id = m.id AND creator = 'Keywords' AND asset = %s)};

    return join "\nAND\n" =>
	   map { sprintf $subselect, dbh->quote($_) }
           split " ",
           $search_string;
}

sub post_filter {
    return @_;
}


1;
