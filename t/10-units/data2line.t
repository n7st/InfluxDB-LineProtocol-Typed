#!/usr/bin/env perl -T

use strict;
use warnings;

use Test::Exception;
use Test::Most;
use Test::Time::HiRes time => 123;

package MyReport {
    use Moose;

    extends 'InfluxDB::LineProtocol::Typed';

    has [ qw(
        first_metric
        second_metric
    ) ]  => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Fieldset Tagset) ]);

    has [ qw(
        negative_float
        positive_float
    ) ] => (is => 'ro', isa => 'Num', traits => [ qw(InfluxDB Fieldset) ]);

    has [ qw(
        falseish
        truthy
    ) ] => (is => 'ro', isa => 'Bool', traits => [ qw(InfluxDB Fieldset) ]);

    no Moose;
    __PACKAGE__->meta->make_immutable();
    1;
}

my $report;

throws_ok { MyReport->new() } 'Moose::Exception::AttributeIsRequired',
    'Throws exception about "measurement" being required';

# Default values are empty - create a report with the frozen time and the
# defaults
ok $report = MyReport->new({ measurement => 'Example' }),
    'Initialised "Example" report';

ok my $line = $report->data2line(), 'Got a line with the current timestamp';

is $line, 'Example,first_metric="",second_metric="" falseish=FALSE,first_metric="",negative_float=0,positive_float=0,second_metric="",truthy=FALSE 123000000000',
    'Line contains correct empty values';

# Provide values
ok $report = MyReport->new({
    measurement    => 'Example',
    first_metric   => 'Hello',
    second_metric  => 'World',
    positive_float => 1.01,
    negative_float => -5.55,
    falseish       => 0,
    truthy         => 1,
}), 'Initialised "Example" report with values';

ok $line = $report->data2line(), 'Got a line with all values';

is $line, 'Example,first_metric="Hello",second_metric="World" falseish=FALSE,'.
    'first_metric="Hello",negative_float=-5.55,positive_float=1.01,'.
    'second_metric="World",truthy=TRUE 123000000000',
    'Treat the database like the database would like to be treated';

done_testing;