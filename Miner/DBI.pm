package Mail::Miner::DBI;
use DBI;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(dbh Insert);

# Fucking hack.
my $connection_string = "dbi:Pg:dbname=mailminer";
my ($user, $auth);

=head1 NAME

  Mail::Miner::DBI -  Get a Mail::Miner DBI handler

=head1 SYNOPSYS

  use Mail::Miner::DBI;
  dbh->do("...")

=head1 DESCRIPTION

Utility methods for dealing with the DBI.

=head1 C<dbh>

This is a handy way of getting a handle on a database connection
to the C<Mail::Miner> database, creating it if necessary.

=cut

sub dbh () {
    if (!$Mail::Miner::DBI::dbh) {
        $Mail::Miner::DBI::dbh = DBI->connect(
            $connection_string, $user, $auth, {AutoCommit => 1}
        );
    }
    $Mail::Miner::DBI::dbh;
}

=head1 C<Insert> 

    my $id = Insert($sql, @bind_values);

Performs an insert statement and returns the ID of the new row.

=cut

sub Insert {
    my $sql = shift;
    my $sth = dbh->prepare($sql);
    my $table;
    $sql =~ /INTO (\w+)/i and $table = $1;

    $sth->execute(
        @_
    );
    if ($table eq "assets") {
        # Don't need to return a row
        $sth->finish;
        return;
    }

    # XXX This is horribly Pg specific. Write a DBIx module to
    # abstract it. DBIx::SearchBuilder::Handle has solutions for Oracle,
    # mysql and Postgres.
    my $oid = $sth->{'pg_oid_status'};
    my $sql = "SELECT id FROM $table WHERE oid = ?";
    my $sth2 = dbh->prepare($sql);
    $sth2->execute($oid);
    my @row = $sth2->fetchrow;
    unless ($row[0]) {
        warn "Can't find $table.id  for OID $oid";
        return(undef);
    }
    $id = $row[0];

    warn "no row id returned on row creation" unless $id;
    $sth->finish;
    $sth2->finish;

    return $id;
}

1;
