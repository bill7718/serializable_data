import 'package:serializable_data/src/relationship_specification.dart';

import '../src/data_specification.dart';

class DataSpecificationProvider {
  Map<String, DataSpecification> dataSpecifications =
      <String, DataSpecification>{};

  Map<String, RelationshipSpecification> relationshipSpecifications =
      <String, RelationshipSpecification>{};

  addDataSpecifications(Map<String, DataSpecification> spec,
      {bool override = true}) {
    if (override) {
      dataSpecifications.addAll(spec);
    } else {
      for (var key in spec.keys) {
        if (override) {
          dataSpecifications[key] = (dataSpecifications[key] ?? spec[key])!;
        }
      }
    }
  }

  addRelationshipSpecifications(Map<String, RelationshipSpecification> spec,
      {bool override = true}) {
    if (override) {
      relationshipSpecifications.addAll(spec);
    } else {
      for (var key in spec.keys) {
        if (override) {
          relationshipSpecifications[key] = (relationshipSpecifications[key] ?? spec[key])!;
        }
      }
    }
  }
}
