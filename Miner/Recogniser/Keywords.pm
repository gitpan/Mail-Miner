#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Keywords;
use Lingua::EN::Keywords;
use Mail::Miner::DBI;

$Mail::Miner::allowed_options{keyword}{package} = __PACKAGE__;
$Mail::Miner::allowed_options{about}{package} = __PACKAGE__;
$Mail::Miner::allowed_options{keyword}{type} = "=s";
$Mail::Miner::allowed_options{about}{type} = "=s";
$Mail::Miner::allowed_options{keyword}{help} = "Match messages containing the given (space-separated) keywords";
$Mail::Miner::allowed_options{about}{help} = "Alias for --keyword";

sub process {
    my ($entity, $msgid) = @_;
    my $string = $entity->bodyhandle->as_string();
    return if length $string > 1024*80; # 80k of text is too much.

    # add keywords to database
    Mail::Miner::Assets::file_asset($msgid, "Keywords", $_) for 
      keywords( $string );
    return $entity;
}

sub pre_filter {
    my ($search_string) = @_;
    my $subselect = q{EXISTS (SELECT * FROM assets WHERE message_id = m.id AND creator = 'Keywords' AND asset = %s)};

    return join "\nAND\n" =>
	   map { sprintf $subselect, dbh->quote($_) }
           split " ",
           $search_string;
}

sub post_filter {
    return @_;
}


1;
