package Mail::Miner::DBI;
use DBI;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(dbh Insert);

my $connection_string = "dbi:mysql:dbname=mailminer";
my ($user, $auth) = ();

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

    $sth->execute(
        @_
    );

    my $id = dbh->{'mysql_insertid'};

    unless ($id) {
        my $s = dbh->selectall_arrayref('SELECT LAST_INSERT_ID()');
        $id = $s->[0][0];
    }

    warn "no row id returned on row creation" unless $id;
    $sth->finish;

    return $id;
}

1;
