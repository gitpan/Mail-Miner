package Mail::Miner::Message;
use strict;
use MIME::Parser;
use Mail::Miner;
use Mail::Miner::DBI;
use Mail::Miner::Attachment qw(detach_attachments);
use Date::Manip qw(ParseDate UnixDate);
our $DEBUG;

=head1 NAME

Mail::Miner::Message - Backend methods for Mail::Miner message processing

=head1 DESCRIPTION

This module implements some backend functionality for dealing with
messages processed by C<Mail::Miner>, both processing messages before
storing them in the database, and for formatting and displaying them 
afterwards.

=head2 C<process>

This subroutine is the main backend to processing incoming messages. It
saves a message represented as a C<MIME::Entity> object into the
database, separates off attachments, and then updates the database copy
with the "flattened" version. Finally, it calls the C<process>
subroutines of all the C<Mail::Miner::Recogniser> modules that it can
find, allowing them to register assets.

=cut

sub process { 
    my $entity = shift;
    my @body;
    my $content;

    $entity->make_multipart;

    my $msgid = store_message($entity);
    warn "Stored message ID $msgid\n" if $DEBUG;
    $entity = detach_attachments($entity, $msgid);
    warn "Detached attachments\n" if $DEBUG;

    if ($entity->bodyhandle) { 
      no strict 'refs';
      warn "Modules available: @Mail::Miner::modules\n" if $DEBUG;
      for (@Mail::Miner::modules) {
           my $sub = $_."::process";
           if (defined &$sub) {
               warn "Calling $sub\n" if $DEBUG;
#               eval {
                $entity = $sub->($entity, $msgid) || $entity # In case it's duff.
#               }
           }
      }
    }

    update_body($msgid, $entity);
    return $entity;
}

=head2 C<store_message>

This non-exported subroutine stores a C<MIME::Entity> object into the
database, returning its message number. It does B<not> store the body of
the message, which is done by C<update_body>. This is done so that we
can first get a message number, link attachments to the message, strip
off the attachments, and then store the stripped-down body.

=cut

sub store_message {
    my $entity = shift;
    my $head = $entity->head;
    my $format = "%Y-%m-%d %H:%M:%S";
    my $date = UnixDate(ParseDate($head->get("Date") || scalar localtime), $format);

    my $subject = $head->get("Subject");
    chomp $subject; $subject =~ s/^\s+//; $subject =~ s/\s+$//; $subject ||= "(No subject)";

    my $from = $head->get("From");
    chomp $from; $from =~ s/^\s+//; $from =~ s/\s+$//; $from ||= "(Unknown Sender)";

    return Insert(
     "INSERT INTO messages (from_address, subject, received) VALUES (?,?,?)",
        $from, $subject, $date
    );
}

=head2 C<update_body>

    update_body($id, $entity)

This is a utility sub to update a message's entry in the database
with a new set of content, after it's been munged by the attachment
handling code.

=cut

sub update_body {
    my ($id, $entity) = @_;
    my $sth = dbh->prepare("
    UPDATE messages SET content = ?
        WHERE id = ?
    ");

    $sth->execute(
        $entity->as_string,
        $id
    );
    
    $sth->finish;
}

=head2 C<report>

    report(%options)

This is a front-end reporting option to be used from the C<mm>
command line.

=cut

sub report {
    my %options = @_;
    die "Full-text output not yet implemented\n" 
        unless $options{summary};

    my $brief = delete $options{summary};

    my $sql = "SELECT m.id, m.from_address, m.subject, m.received ";
    $sql .= ", content " if !$brief;

    $sql .= "FROM messages m, assets a ";

    my @clauses = ("a.message_id = m.id");

    my %basic = # Add additional "basic" terms here
        ( sender => "from_address" );

    if (%options) { 
        for (keys %basic) {
            next unless exists $options{$_};
            push @clauses, $basic{$_}." LIKE ".dbh->quote("%".$options{$_}."%");
            delete $options{$_};
        }
        for (keys %options) {
            if (!exists $Mail::Miner::allowed_options{$_}) {
                die "Unknown search term $_ (".(join ",", keys %Mail::Miner::allowed_options).")\n";
            }
            my $sub = $Mail::Miner::allowed_options{$_}."::where_clause";
            no strict 'refs';
            push @clauses, $sub->($options{$_});
        }
    }

    my $clause;
    $clause = "WHERE ".(join " AND ", @clauses) if @clauses;
    $sql .= $clause;
    warn $sql if $DEBUG;
    
    my $sth = dbh->prepare($sql);
    $sth->execute();
    if (!$sth->rows) {
        print "No messages matched.\n";
        return;
    }

    print $sth->rows." matched\n";

    my $ids = dbh->selectcol_arrayref("SELECT m.id FROM messages m, assets a $clause", undef, values %options);
    my $id_width = ( sort map {length $_} @$ids )[-1];
    while (my $h = $sth->fetchrow_hashref) {
        # This isn't needed normally, but I need it, so leave it alone
        # until we release.
        chomp for values %$h; 

        printf "%${id_width}i:%10s:%40s:%s\n", 
            $h->{id}, 
            substr($h->{received},0,10), 
            substr($h->{from_address},-40,40), 
            substr($h->{subject},0,$ENV{COLUMNS}?$ENV{COLUMNS}-(53+$id_width):25-$id_width);
    }

    $sth->finish;
}

1;
