package Mail::Miner::Message;
use strict;
use MIME::Parser;
use Mail::Miner::DBI;
use Mail::Miner::Attachment qw(detach_attachments);
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
with the "flattened" version.

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
    return Insert(
     "INSERT INTO messages (from_address, subject) VALUES (?,?)",
        $entity->head->get("From") || "Unknown sender",
        $entity->head->get("Subject") || "(No subject)",
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

1;
