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
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'error'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'errno'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'domain'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'range'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'mode'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '44 118 9508311'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '44 118 9500110'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Address',
            'asset' => 'Andrew Josey                                The Open Group  
Austin Group Chair                          Apex Plaza,Forbury Road,
Email: a.josey@opengroup.org                Reading,Berks.RG1 1AX,England'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'error'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'errno'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'domain'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'range'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Keywords',
            'asset' => 'mode'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '44 118 9508311'
          },
          {
            'creator' => 'Mail::Miner::Recogniser::Phone',
            'asset' => '44 118 9500110'
          }
);

ok(eq_set(\@got, \@expected), "Correct assets with MIME::Entity");

Mail::Miner::Assets->analyse(
    gethead => sub {$message->head->as_string},
    getbody => sub {$message->bodyhandle->as_string},
    store   => sub {ok(1, "Store passes us stuff");
                    ok(eq_set(\@_, \@expected), 
                    "Store passes us accurate stuff");}
            
    );
