#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Phone;
use Mail::Miner::DBI;

$Mail::Miner::allowed_options{phone}{package} = __PACKAGE__;
$Mail::Miner::allowed_options{phone}{type} = "";
$Mail::Miner::allowed_options{phone}{help} = "Match messages which contain a phone number";
$Mail::Miner::allowed_options{telephone}{package} = __PACKAGE__;
$Mail::Miner::allowed_options{telephone}{type} = "";
$Mail::Miner::allowed_options{telephone}{help} = 'Alias for --phone';

sub process {
    my ($entity, $msgid) = @_;

    # add keywords to database
    Mail::Miner::Assets::file_asset($msgid, "Phone", $_) for 
      find_addresses( $entity->bodyhandle->as_string());
    return $entity;
}

sub find_addresses {
    my $body = shift;
    my $usphone = qr/\(?\d{3}\)?\s+\d{3}-\d{4}/;
    my $ukphone = qr/(\+?44\s*|\(?0)[17]\d{2,5}\)?\s*\d{3}\s*\d+/;
    my @found;
    push @found, $1 while $body =~ /\b($usphone|$ukphone)\b/g;
    return @found;
}

sub pre_filter {
    return q{EXISTS (SELECT * FROM assets WHERE message_id = m.id AND creator = 'Phone')};
}

sub post_filter {
    return @_;
}

my %done;

sub display {
    my ($k) = shift; # next thing is irrelevant
    my $sth = dbh->prepare("SELECT asset FROM assets WHERE message_id = ?
    AND creator = 'Phone'");
    $sth->execute($k->{id});
    my @row;
    while (@row = $sth->fetchrow) {
        next if $done{$k->{from_address}}{$row[0]}++;
        print "Phone numbers found in message $k->{id} from $k->{from_address}:\n";
        print $row[0]."\n\n";
    }
    $sth->finish();

}

1;
