import 'dart:convert';
import '../serializable_data.dart';

///
/// enables a list of [DataObject]s to be treated as a single [DataObject]
///
class CombinedDataObject implements DataObject {

  /// The list of data object held within this object
  final List<DataObject> objects;

  CombinedDataObject(this.objects);

  /// Returns the value in the first [DataObject] that contains this label
  @override
  dynamic get(String label) {
    for (var object in objects) {
      if (object.get(label) != null) {
        return object.get(label);
      }
    }
    return null;
  }

  /// Calls the [set] method for the first [DataObject] that has the [label]
  /// in its [fields] object
  ///
  ///
  /// If no data object has this field then the method throws an exception
  ///
  @override
  void set(String label, value) {
    for (var object in objects) {
      if (object.fields.contains(label) || object.get(label) != null) {
        object.set(label, value);
        return;
      }
    }

    throw DataObjectException('Set: Cannot field $label in CombinedObject $data');
  }


  /// Returns a merged view of the [data] for each included [DataObject]
  @override
  Map<String, dynamic> get data {
    var response = <String, dynamic>{};
    for (var object in objects) {
      response.addAll(object.data);
    }
    return response;
  }

  /// Returns a combined list of the [fields] for each included [DataObject]
  @override
  List<String> get fields {
    var response = <String>[];
    for (var object in objects) {
      response.addAll(object.fields);
    }
    return response;
  }



  /// Adds the listener to all [DataObject]s in the list.
  @override
  void addListener(String label, Function listener) {
    for (var object in objects) {
      object.addListener(label, listener);
    }
  }

  /// Removes the listener from all [DataObject]s in the list.
  @override
  void removeListener(String label, Function listener) {
    for (var object in objects) {
      object.removeListener(label, listener);
    }
  }


  /// Encode the [data] map for this object
  @override
  toJson() => JsonEncoder().convert(data);

  /// Validate each field in turn for each included [DataObject]
  @override
  String? validate({List<String>? fields}) {
    for (var object in objects) {
      if (object.validate(fields: fields) != null) {
        return object.validate(fields: fields);
      }
    }
    return null;
  }

  @override
  bool get immutable {
    for (var object in objects) {
      if (!object.immutable) return false;
    }
    return true;
  }

  ///
  /// This method throws an Exception as it is not possible to merge into a [CombinedDataObject]
  ///
  @override
  void merge(Map<String, dynamic> map) {
    throw DataObjectException('Cannot merge CombinedDataObjects $data  :: $map');
  }

  //TODO test this code
  @override
  void addToList(String listLabel, DataObject value, {String? key, String? keyValue}) {
    for (var object in objects) {
      if (object.fields.contains(listLabel) || object.get(listLabel) != null) {
        object.addToList(listLabel, value, key: key, keyValue: keyValue);
        return;
      }
    }

    throw DataObjectException('addToList: Cannot add to field $listLabel in CombinedObject $data');
  }

  //TODO test this code
  @override
  void removeFromList(String listLabel, DataObject value, String key, String keyValue) {
    for (var object in objects) {
      if (object.fields.contains(listLabel) || object.get(listLabel) != null) {
        object.removeFromList(listLabel, value, key, keyValue);
        return;
      }
    }

    throw DataObjectException('removeFromList: Cannot remove  $listLabel in CombinedObject $data');
  }
}