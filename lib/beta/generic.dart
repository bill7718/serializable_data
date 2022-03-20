import 'package:injector/injector.dart';
import 'package:serializable_data/beta/data_object_relationship.dart';

import '../src/data_object.dart';
import '../src/data_specification.dart';
import '../src/validators.dart';

const String genericFrequencyLabel = 'frequency';
const String genericEmailLabel = 'email';
const String genericEmailError = 'emailError';

Map<String, String> defaultDataText = {
  genericEmailLabel: 'Email Address',
  genericFrequencyLabel: 'Frequency',
  genericEmailError: 'Please enter a valid email address.'
};

Map<String, DataSpecification> genericDataSpecification() {
  var specifications = <String, DataSpecification>{};

  specifications[genericFrequencyLabel] = DataSpecification(type: DataSpecification.listType, list: [
    ListEntry('M', 'Monthly'),
    ListEntry('A', 'Annually'),
  ]);

  specifications[genericEmailLabel] = DataSpecification(validator: validateEmail, type: DataSpecification.textType);

  return specifications;
}

class Address extends DataObject {

  static const String line1Label = 'line1';
  static const String line2Label = 'line2';
  static const String line3Label = 'line3';
  static const String line4Label = 'line4';
  static const String line5Label = 'line5';

  static const String fullAddressLabel = 'fullAddress';

  Address({Map<String, dynamic>? data}) : super(data ?? <String, dynamic>{});

  String get fullAddress {
    String s = get(line1Label) ?? '\n';
    s  = s + ((get(line2Label) == null) ? '' : '\n${get(line2Label)}') ;
    s  = s + ((get(line3Label) == null) ? '' : '\n${get(line3Label)}') ;
    s  = s + ((get(line4Label) == null) ? '' : '\n${get(line4Label)}') ;
    s  = s + ((get(line5Label) == null) ? '' : '\n${get(line5Label)}') ;

    return s;
  }

  @override
  dynamic get(String label) {
    switch (label) {
      case fullAddressLabel:
        return fullAddress;

      default:
        return super.get(label);
    }
  }
}

void registerSerializableDataDependencies() {
  Injector.appInstance.registerDependency<DataObjectRelationship>(() => DataObjectRelationship());
}
