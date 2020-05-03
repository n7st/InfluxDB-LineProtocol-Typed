package InfluxDB::LineProtocol::Typed::Trait::Unsigned;

use Moose::Role;
use Moose::Util 'meta_attribute_alias';

meta_attribute_alias('Unsigned');

our $VERSION = 1.00;

no Moose::Role;
1;
__END__

=head1 NAME

InfluxDB::LineProtocol::Typed::Trait::Unsigned

=head1 VERSION

1.00

=head1 DESCRIPTION

Marks a C<Int> as unsigned.

=head1 SYNOPSIS

This trait is accessible in classes based on L<InfluxDB::LineProtocol::Typed>.
It should be applied to Moose attributes:

    package Local::My::Metric;

    use Moose;

    extends 'InfluxDB::LineProtocol::Typed';

    has some_unsigned_integer => (is => 'ro', isa => 'Int', traits => [ qw(InfluxDB Fieldset Unsigned)]);

    no Moose;
    __PACKAGE__->meta->make_immutable();
    1;

Please note that the C<InfluxDB> trait is also required
(L<InfluxDB::LineProtocol::Typed::Trait::InfluxDB>).

=head1 SUBROUTINES/METHODS

This class provides no methods.

=head1 AUTHOR

L<Mike Jones|mike@netsplit.org.uk>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 by Mike Jones <mike@netsplit.org.uk>.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself