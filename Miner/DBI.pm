package Mail::Miner::DBI;
use Mail::Miner::Config;
use base 'Class::DBI::mysql';
__PACKAGE__->set_db('Main','dbi:mysql:'.$Mail::Miner::Config::db,
    $Mail::Miner::Config::username, $Mail::Miner::Config::password);
__PACKAGE__->autocommit(1);
1;
