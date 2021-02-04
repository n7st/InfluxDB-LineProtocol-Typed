# InfluxDB::LineProtocol::Typed

Type-safe serialisation to InfluxDB's
[line protocol](https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/).

## Usage

Measurements are [Moose](https://metacpan.org/pod/Moose) objects based on this
library. Tags and fields are attributes on the object which use the `Tagset`
and/or `Fieldset` traits.

Create a class:

```perl
package SomeMeasurement;

use Moose;

extends 'InfluxDB::LineProtocol::Typed';

has my_tag   => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Tagset) ]);
has my_field => (is => 'ro', isa => 'Num', traits => [ qw(InfluxDB Fieldset) ]);
has my_both  => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Tagset Fieldset) ]);

no Moose;
__PACKAGE__->meta->make_immutable();
1;
```

Then, initialise the class, set the attributes and use `data2line()` to retrieve
the line for submission to InfluxDB's HTTP API:

```perl
use SomeMeasurement;

my $measurement = SomeMeasurement->new({
    measurement => 'Measurement name here',
    my_tag      => 'Some tag here',
    my_field    => -5.01,
    my_both     => 'Hello, world',
});

my $line = $measurement->data2line();
```

You can use several of Moose's built-in data types:

* `Str` (mapped to [String](https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/#string))
* `Num` (mapped to [Float](https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/#float))
* `Int` (mapped to [Integer](https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/#integer))
* `Bool` (mapped to [Boolean](https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/#boolean))

InfluxDB **v2.0+** supports unsigned integers. Unsigned integers are a little
more complex and require an extra trait:

```perl
has my_unsigned_integer => (is => 'ro', isa => 'Int', traits => [ qw(InfluxDB Fieldset Unsigned) ]);
```

Please note that attempting to use unsigned integers for older versions of
InfluxDB breaks data submission with an "invalid number" error.

### Submitting lines to InfluxDB's API

The generated line should be submitted to your InfluxDB API using either a
client library such as [InfluxDB::HTTP](https://metacpan.org/pod/InfluxDB::HTTP)
or a user agent like [Mojo::UserAgent](https://mojolicious.org/perldoc/Mojo/UserAgent)
or [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent).
