package InfluxDB::LineProtocol::Typed;

use Moose;
use Time::HiRes 'gettimeofday';

with qw(
    InfluxDB::LineProtocol::Typed::Trait::InfluxDB
    InfluxDB::LineProtocol::Typed::Trait::Tagset
    InfluxDB::LineProtocol::Typed::Trait::Fieldset
);

our $VERSION = 1.00;

################################################################################

has measurement => (is => 'ro', isa => 'Str', required => 1);

################################################################################

sub data2line {
    my $self      = shift;
    my $timestamp = shift || sprintf '%s%06d000', gettimeofday;

    my (@tags, @fields);

    foreach my $attr ($self->meta->get_all_attributes) {
        if ($attr->does('InfluxDB')) {
            my $kv = sprintf '%s=%s', $attr->name, $attr->as_data($attr->get_value($self));

            if ($attr->does('Tagset')) {
                push @tags, $kv;
            }

            if ($attr->does('Fieldset')) {
                push @fields, $kv;
            }
        }
    }

    return $self->_format_line(\@tags, \@fields, $timestamp);
}

################################################################################

sub _format_line {
    my $self      = shift;
    my $tags      = shift;
    my $fields    = shift;
    my $timestamp = shift;

    # myMeasurement,tag1=value1,tag2=value2 fieldKey="fieldValue" 1556813561098000000
    my $line = $self->measurement;

    if (@{$tags}) {
        $line .= sprintf ',%s', join q{,}, @{$tags};
    }

    if (@{$fields}) {
        $line .= sprintf ' %s', join q{,}, @{$fields};
    }

    return sprintf '%s %d', $line, $timestamp;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

InfluxDB::LineProtocol::Typed

=head1 VERSION

1.00

=head1 DESCRIPTION

Generate type safe InfluxDB line protocol reports. Extra parts are required for
submitting the line to the database.

=head1 SYNOPSIS

Reports should be created as their own class based on
L<InfluxDB::LineProtocol::Typed>. Traits are used to define whether the report
metric will end up in the tags or fields. You may specify as many tags or fields
as you like.

    package Local::My::Metric;

    use Moose;

    extends 'InfluxDB::LineProtocol::Typed';

    has first_value  => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Tagset) ]);
    has second_value => (is => 'ro', isa => 'Num', traits => [ qw(InfluxDB Tagset Fieldset) ]);

    no Moose;
    __PACKAGE__->meta->make_immutable();
    1;

=head1 SUBROUTINES/METHODS

=over 4

=item * C<data2line($timestamp)>

C<$timestamp> is an optional UNIX timestamp which defaults to now (nanoseconds).
You may provide your own timestamp either as a second, millisecond or nanosecond
value.

Serialises the report to line protocol. Using the above C<Local::My::Metric>
example:

    use Local::My::Metric;

    my $report = Local::My::Metric->new({
        first_value  => 'Foo',
        second_value => -1.23,
    });

    my $line = $report->data2line();

    my $line_at_specific_time = $report->data2line(1588427643459);

=back

=head1 BUGS AND LIMITATIONS

This library is only for serialising data to InfluxDB's line protocol and does
not provide a means of submitting it to the database's API. I would suggest
looking at one of the below integration libraries for submitting generated data.

=head1 SEE ALSO

=over 4

=item * L<InfluxDB::HTTP>

=item * L<AnyEvent::InfluxDB>

=item * L<InfluxDB::LineProtocol>

A procedural library for serialising data as line protocol.

=back

=head1 AUTHOR

L<Mike Jones|mike@netsplit.org.uk>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 by Mike Jones <mike@netsplit.org.uk>.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.