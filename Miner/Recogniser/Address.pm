#!/usr/bin/perl -w

package Mail::Miner::Recogniser::Address;

$Mail::Miner::recognisers{"".__PACKAGE__} = 
    {
     title    => "Physical Addresses",
     help     => "Match messages which contain an address",
     keyword  => "address",
    };

sub process {
    my ($class, %hash) = @_;

    my @lines = split /\n/, $hash{getbody}->();
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

1;
