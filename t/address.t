
use Test::More tests=>3;
use_ok("Mail::Miner::Recogniser::Address");

my @x = Mail::Miner::Recogniser::Address->process(getbody => sub{<<EOF});

> > > >             Grilf Ferley
> > > >             21b Winkle Street
> > > >             Belfast BT1 4ZZ, County Antrim,
EOF

is ($x[0], 
"Grilf Ferley
21b Winkle Street
Belfast BT1 4ZZ, County Antrim,");

my @x = Mail::Miner::Recogniser::Address->process(getbody => sub{<<EOF});
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             This is not an address
> > > >             Grilf Ferley
> > > >             21b Winkle Street
> > > >             Belfast BT1 4ZZ, County Antrim,
EOF

is ((split /\n/,$x[0]), 10, "Maximum of ten lines");
