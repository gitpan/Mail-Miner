#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Address;
use Mail::Miner::DBI;

$Mail::Miner::allowed_options{address}{package} = __PACKAGE__;
$Mail::Miner::allowed_options{address}{type} = "";
$Mail::Miner::allowed_options{address}{help} = "Match messages which contain an address";

sub process {
    my ($entity, $msgid) = @_;

    # add keywords to database
    Mail::Miner::Assets::file_asset($msgid, "Address", $_) for 
      find_addresses( $entity->bodyhandle->as_string());
    return $entity;
}

sub find_addresses {
    my $body = shift;
    my @lines = split /\n/, $body;
    my @found;
    my $last =0;
    my $uk_postcode = qr/[A-Z][A-Z]\d{1,3}\s+\d{1,2}[A-Z][A-Z]/;
    my $us_zipcode = qr/[A-Z][A-Z]\s+\d{5}/;

    for (0..$#lines) {
        if ($lines[$_] =~ /(.*\b($uk_postcode|$us_zipcode)\b)/) {
        push @found, join "\n", @lines[$last+1..$_];
        } elsif ($lines[$_] !~ /\w/) {
            $last = $_;
        }
    }
    return @found;
}

sub pre_filter {
    return q{EXISTS (SELECT * FROM assets WHERE message_id = m.id AND creator = 'Address')};
}

sub post_filter {
    return @_;
}

my %done;

sub display {
    my ($k) = shift; # next thing is irrelevant
    my $sth = dbh->prepare("SELECT asset FROM assets WHERE message_id = ?
    AND creator = 'Address'");
    $sth->execute($k->{id});
    my @row;
    while (@row = $sth->fetchrow) {
        next if $done{$k->{from_address}}{$row[0]}++;
        print "Address found in message $k->{id} from $k->{from_address}:\n";
        print $row[0]."\n\n";
    }
    $sth->finish();

}

1;
