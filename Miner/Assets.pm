package Mail::Miner::Assets;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(file_asset find_assets);
use Mail::Miner;
use Mail::Miner::DBI qw(dbh);

=head1 NAME

Mail::Miner::Assets - Manage information assets in a Mail::Miner database

=head1 DESCRIPTION

"Assets" are items of information stored by C<Mail::Miner> "recogniser"
plugins. A recogniser can file an asset during the processing stage,
and search for assets during the reporting stage.

Hence, here are the two functions this module provides:

=head2 C<file_asset>

    file_asset($msgid, $creator, $content)

For instance, suppose I'm C<Mail::Miner::Recogniser::Language>, which
attempts to determine what language an email's in, (hey, that's a good
idea...)  I'd end up calling something like

    file_asset(1234, "Language", "Japanese");

=cut

sub file_asset {
    my $dbh = dbh();
    my $sth = $dbh->prepare(
        "insert into assets (message_id, creator, asset) values (?,?,?)"
    );
    $sth->execute(@_);
    $sth->finish();
}

