# change 'tests => 1' to 'tests => last_test_to_print';

use blib;
use Test::More tests => 5;
    
use_ok('Mail::Miner'); 

use MIME::Entity;
use MIME::Parser;

my $message;
my $parser = new MIME::Parser;
$parser->output_to_core(1);
isa_ok($message = $parser->parse_open("test-message"),"MIME::Entity");

my @got = Mail::Miner::Assets->analyse(
    gethead => sub {$message->head->as_string},
    getbody => sub {$message->bodyhandle->as_string}
    );

my @expected = (
          {
            'creator' => 'Mail::Miner::Recogniser::Address',
            'asset' => 'Andrew Josey                                The Open Group  
Austin Group Chair                          Apex Plaza,Forbury Road,
Email: a.josey@opengroup.org                Reading,Berks.RG1 1AX,England'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '+44 118 9508311 ext 2250'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '+44 118 9500110'
          },
);

is_deeply(
          [grep {$_->{creator} !~ /Keyword|Spam/} @got],
# Keyword algorithm changes
# Spam is optional
          \@expected, "Correct assets with MIME::Entity");

Mail::Miner::Assets->analyse(
    gethead => sub {$message->head->as_string},
    getbody => sub {$message->bodyhandle->as_string},
    store   => sub {ok(1, "Store passes us stuff");
ok(eq_set([grep {$_->{creator} !~ /Keyword|Spam/} # Keyword algorithm changes
                                                  # Spam is optional
           @_], \@expected), 
                    "Store passes us accurate stuff");}
            
    );
