package InfluxDB::LineProtocol::Typed::Trait::InfluxDB;

use Moose::Role;
use Moose::Util qw(meta_attribute_alias throw_exception);
use Switch::Plain 'sswitch';

meta_attribute_alias('InfluxDB');

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

    sswitch ($type) {
        case 'Str':  {
            return sprintf '"%s"', $value || '';
        }
        case 'Bool': {
            return ($value && $value == 1) ? 'TRUE': 'FALSE';
        }
        case 'Num':  {
            return $value || 0.00;
        }
        case 'Int':  {
            return ($value || 0).'i';
        }
        default: {
            # Only support the above as they are mappable to InfluxDB datatypes
            throw_exception('WrongTypeConstraintGiven', {
                attribute_name => $attr->name,
                given_type     => $attr->type_constraint->name,
                params         => {},
                required_type  => 'Str, Bool, Num or Int',
            });
        }
    }
}

################################################################################

no Moose::Role;
1;

