package InfluxDB::LineProtocol::Typed;

use DDP;
use Moose;
use Time::HiRes 'gettimeofday';

with qw(
    InfluxDB::LineProtocol::Typed::Trait::InfluxDB
    InfluxDB::LineProtocol::Typed::Trait::Tagset
    InfluxDB::LineProtocol::Typed::Trait::Fieldset
);

################################################################################

has measurement => (is => 'ro', isa => 'Str', required => 1);

################################################################################

sub data2line {
    my $self      = shift; # TODO: precision
    my $timestamp = shift || sprintf('%s%06d000', gettimeofday);

    my (@tags, @fields);

    foreach my $attr ($self->meta->get_all_attributes) {
        if ($attr->does('InfluxDB')) {
            my $kv = sprintf('%s=%s',
                $attr->name,
                $attr->as_data($attr->get_value($self)),
            );

            push @tags,   $kv if $attr->does('Tagset');
            push @fields, $kv if $attr->does('Fieldset');
        }
    }

    p @tags;
    p @fields;

    return 1;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
