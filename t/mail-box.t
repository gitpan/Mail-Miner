# change 'tests => 1' to 'tests => last_test_to_print';

use blib;
BEGIN { 

    require Test::More;
    eval { use Mail::Message; use Mail::Box::Manager; };
    if (@$) {
        Test::More->import(skip_all => "Mail::Box not installed");
    } else {
        Test::More->import(tests => 3);
    }
}
    
use_ok('Mail::Miner'); 
my $message = Mail::Box::Manager->new->open("test-message")->message(0);

isa_ok($message,"Mail::Message");

my @got = Mail::Miner::Assets->analyse(
    gethead => sub {$message->head},
    getbody => sub {$message->body->decoded}
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

is_deeply ([ grep {$_->{creator} !~ /Keyword|Spam/} @got ], 
        \@expected, "Correct assets with MIME::Entity");