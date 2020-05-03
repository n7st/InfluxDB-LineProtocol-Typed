#!/usr/bin/env perl -T

use strict;
use warnings;

use Test::Most;
use Test::Time::HiRes time => 4567;

package ReportWithoutMetrics {
    use Moose;

    extends 'InfluxDB::LineProtocol::Typed';

    no Moose;
    __PACKAGE__->meta->make_immutable();
    1;
}

my $report = ReportWithoutMetrics->new({ measurement => 'Example' });

ok my $line = $report->data2line();

is $line, 'Example 4567000000000', 'Got the right data';

done_testing;