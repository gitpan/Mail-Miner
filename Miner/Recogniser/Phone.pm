#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Phone;
$Mail::Miner::recognisers{"".__PACKAGE__} = 
    {
     title => "Phone numbers",
     help  => "Match messages which contain a phone number",
     keyword => "phone"
    };

sub process {
    my ($class, %hash) = @_;
    my $body = $hash{getbody}->();
    my $usphone = qr/\(?\d{3}\)?\s+\d{3}-\d{4}/;
    my $ukphone = qr/(\+?44\s*|\(?0)[127]\d{2,5}\)?\s*\d{3}\s*\d+/;
    my @found;
    push @found, $1 while $body =~ /\b($usphone|$ukphone)\b/g;
    return @found;
}

1;
