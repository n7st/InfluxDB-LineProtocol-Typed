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
    ) ]  => (is => 'rw', isa => 'Str', traits => [ qw(InfluxDB Fieldset Tagset) ]);

    has [ qw(
        negative_float
        positive_float
    ) ] => (is => 'rw', isa => 'Num', traits => [ qw(InfluxDB Fieldset) ]);

    has [ qw(
        falseish
        truthy
    ) ] => (is => 'rw', isa => 'Bool', traits => [ qw(InfluxDB Fieldset) ]);

    has some_int  => (is => 'ro', isa => 'Int', traits => [ qw(InfluxDB Fieldset) ]);
    has some_uint => (is => 'ro', isa => 'Int', traits => [ qw(InfluxDB Fieldset Unsigned) ]);

    has tag_only => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Tagset) ]);

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

is $line, 'Example,first_metric="",second_metric="",tag_only="" falseish=FALSE,'
    .'first_metric="",negative_float=0,positive_float=0,second_metric="",'
    .'some_int=0i,some_uint=0u,truthy=FALSE 123000000000',
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
    some_int       => 7,
    some_uint      => -10,
    tag_only       => 'my tag',
}), 'Initialised "Example" report with values';

ok $line = $report->data2line(), 'Got a line with all values';

my $data = <<'DATA';
Example,first_metric="Hello",second_metric="World",tag_only="my tag" falseish=FALSE,
first_metric="Hello",negative_float=-5.55,positive_float=1.01,
second_metric="World",some_int=7i,some_uint=-10u,truthy=TRUE
DATA

$data =~ s/\n//smgx;

my $default_timestamp = 123000000000;

is $line, "${data} ${default_timestamp}", 'Line looks correct';

my $set_timestamp = 456;

ok $line = $report->data2line($set_timestamp);

is $line, "${data} ${set_timestamp}", 'Set the specified timestamp';

$report->first_metric('Goodbye');

$data =~ s/Hello/Goodbye/sgm;

ok $line = $report->data2line();

is $line, "${data} ${default_timestamp}", 'Changed value is correct';

done_testing;