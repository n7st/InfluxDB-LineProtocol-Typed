package InfluxDB::LineProtocol::Typed::Trait::InfluxDB;

use Moose::Role;
use Moose::Util qw(meta_attribute_alias throw_exception);

meta_attribute_alias('InfluxDB');

################################################################################

has translator_bool => (is => 'ro', isa => 'CodeRef', lazy_build => 1);
has translator_int  => (is => 'ro', isa => 'CodeRef', lazy_build => 1);
has translator_num  => (is => 'ro', isa => 'CodeRef', lazy_build => 1);
has translator_str  => (is => 'ro', isa => 'CodeRef', lazy_build => 1);
has translators     => (is => 'ro', isa => 'HashRef', lazy_build => 1);

################################################################################

sub as_data {
    my $attr  = shift;
    my $value = shift;

    my $type = q{};

    if (ref $attr->type_constraint && $attr->type_constraint->can('name')) {
        $type = $attr->type_constraint->name;
    } else {
        $type = $attr->type_constraint;
    }

    my $translator = $attr->translators->{$type};

    if ($translator) {
        return $translator->($attr, $value);
    }

    throw_exception('WrongTypeConstraintGiven', {
        attribute_name => $attr->name,
        given_type     => $attr->type_constraint->name,
        params         => {},
        required_type  => 'Str, Bool, Num or Int',
    });
}

################################################################################

sub _build_translators {
    my $self = shift;

    return {
        Str  => $self->translator_str,
        Bool => $self->translator_bool,
        Num  => $self->translator_num,
        Int  => $self->translator_int,
    };
}

sub _build_translator_str {
    return sub {
        my ($attr, $value) = @_;

        if ($value) {
            $value =~ s/([^[:alpha:]])/\\$1/gxms;
        }

        return sprintf '"%s"', $value || q{};
    };
}

sub _build_translator_bool {
    return sub {
        my ($attr, $value) = @_;

        return ($value && $value == 1) ? 'TRUE': 'FALSE';
    };
}

sub _build_translator_int {
    return sub {
        my ($attr, $value) = @_;

        my $flag = $attr->does('Unsigned') ? 'u' : 'i';

        return sprintf '%d%s', ($value || 0), $flag;
    };
}

sub _build_translator_num {
    return sub {
        my ($attr, $value) = @_;

        return $value || 0.00;
    };
}

################################################################################

no Moose::Role;
1;
__END__

=head1 NAME

InfluxDB::LineProtocol::Typed::Trait::InfluxDB

=head1 VERSION

1.00

=head1 DESCRIPTION

Mark an attribute as being intended for submission to InfluxDB.

=head1 SYNOPSIS

This trait is accessible in classes based on L<InfluxDB::LineProtocol::Typed>.
It should be applied to Moose attributes:

    package Local::My::Metric;

    use Moose;

    extends 'InfluxDB::LineProtocol::Typed';

    has some_field => (is => 'ro', isa => 'Str', traits => [ qw(InfluxDB Fieldset)]);

    no Moose;
    __PACKAGE__->meta->make_immutable();
    1;

Please note that this trait should be used in conjunction with one of the
following:

=over 4

=item * L<InfluxDB::LineProtocol::Typed::Trait::Fieldset>

=item * L<InfluxDB::LineProtocol::Typed::Trait::Tagset>

=back

=head1 SUBROUTINES/METHODS

This class provides no methods.

=head1 AUTHOR

L<Mike Jones|mike@netsplit.org.uk>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 by Mike Jones <mike@netsplit.org.uk>.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.