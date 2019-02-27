package InfluxDB::LineProtocol::Typed::Untappd;

use Moose;

extends 'InfluxDB::LineProtocol::Typed';

################################################################################

has [ qw(rating lat lon)         ] => (is => 'ro', isa => 'Num',  traits => [ qw(InfluxDB Tagset Fieldset) ]);
has [ qw(beer_name brewery_name) ] => (is => 'ro', isa => 'Str',  traits => [ qw(InfluxDB Tagset)          ]);
has [ qw(trueish falseish)       ] => (is => 'ro', isa => 'Bool', traits => [ qw(InfluxDB Tagset)          ]);

has notrait => (is => 'ro', isa => 'Str', default => 'Nope');

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

