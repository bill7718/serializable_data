import 'dart:convert';

///
/// Containing class for an Object that store data in the form of a Map.
///
abstract class DataObject extends Object {
  /// {@template immutable}
  /// If true then the [set] method throws an exception
  /// If false (or null) then the [set] method continues as normal
  /// {@endtemplate}

  /// Label for immutability indicator.
  ///
  ///
  /// {@macro immutable}
  static const String immutableLabel = 'immutable';

  /// Stores the data for this object
  final Map<String, dynamic> _data;

  /// The listeners that are triggered if the [set] method is called on a label
  final Map<String, List<Function>> _listeners = <String, List<Function>>{};

  DataObject(this._data);

  ///
  /// Set the data corresponding to the label with the value
  ///
  /// If the value is null the label is removed from the Map.
  ///
  /// Listeners are called if the value changes
  ///
  void set(String label, dynamic value) {
    if (immutable) {
      throw DataObjectException(
          'Cannot set $runtimeType. It is immutable: $_data');
    }

    //TODO write tests for this code
    if (value is List) {
      if (value.isNotEmpty) {
        var o = value.first;
        if (o is DataObject) {
          var l = <Map<String, dynamic>>[];
          for (var i in value) {
            l.add(i.data);
          }
          _data[label] = l;
          _notify(label);
          return;
        }
      }
    }
    var oldValue = get(label);
    if (value == null) {
      _data.remove(label);
    } else {
      _data[label] = value;
    }
    if (value != oldValue) {
      _notify(label);
    }
  }

  /// Notify listeners of a change to this element in the data object
  ///
  ///
  void _notify(String label) {
    for (var listener in _listeners[label] ?? []) {
      listener();
    }
  }

  ///
  /// Merge the data from the map into this [DataObject]
  ///
  void merge(Map<String, dynamic> map) {
    for (var key in map.keys) {
      set(key, map[key]);
    }
  }

  ///
  /// Get the data corresponding to the label from the DataObject
  ///
  dynamic get(String label) => _data[label];

  /// {@macro immutable}
  bool get immutable => get(immutableLabel) ?? false;

  ///
  /// Returns a copy of the Map containing the data in this DataObject
  ///
  Map<String, dynamic> get data {
    var response = <String, dynamic>{};
    for (var key in _data.keys) {
      response[key] = get(key);
    }
    return response;
  }

  ///
  /// Used to provide a list of the fields used by this DataObject
  ///
  /// Implementing classes do not need to implement this method
  ///
  List<String> get fields => <String>[];

  ///
  /// Used to validate the data in this DataObject
  ///
  /// null - valid
  /// notnull - invalid - classes normally return a code which is used ot look up the error message
  ///
  /// Where [fields] are specified the method should validate only the fields in the list. This enables
  /// a screen containing only a subset of the data for this object to check that it is valid before
  /// moving on. Or by passing just one field in the list an individual screen element can be validated.
  ///
  String? validate({List<String>? fields}) => null;

  ///
  /// Adds a listener [Function] that is called whenever the field corresponding to the
  /// [label] is updated.
  ///
  void addListener(String label, Function listener) {
    _listeners[label] ??= <Function>[];
    _listeners[label]!.add(listener);
  }

  ///
  /// Remove a listener that has been previously added. If the listener is not found the method
  /// does nothing.
  ///
  void removeListener(String label, Function listener) {
    _listeners[label] ??= <Function>[];
    _listeners[label]!.remove(listener);
  }

  ///
  /// Convert the data in the [_map] to a Json Object
  ///
  dynamic toJson() => JsonEncoder().convert(data);

  ///
  /// Adds the [value] to the list corresponding to [listLabel]
  ///
  /// If the list already contains an entry where
  /// _data[key] = _data[keyValue]
  ///
  /// then replace the object with this one
  ///
  void addToList(String listLabel, DataObject value,
      {String? key, String? keyValue}) {
    _data[listLabel] ??= <Map<String, dynamic>>[];
    List currentValue = _data[listLabel];

    var i = 0;
    while (i < currentValue.length) {
      if (key != null && keyValue != null) {
        if (currentValue[i][key] == keyValue) {
          currentValue.removeAt(i);
          i = currentValue.length + 1;
        }
      }
      i++;
    }

    currentValue.add(value.data);
    _data[listLabel] = currentValue;
    _notify(listLabel);
  }

  void removeFromList(
      String listLabel, DataObject value, String key, String keyValue) {
    _data[listLabel] ??= <Map<String, dynamic>>[];
    List currentValue = _data[listLabel];

    var i = 0;
    while (i < currentValue.length) {
      if (currentValue[i][key] == keyValue) {
        currentValue.removeAt(i);
        currentValue.add(value.data);
        _data[listLabel] = currentValue;
        _notify(listLabel);
        i = currentValue.length + 1;
      }

      i++;
    }
  }
}

class DataObjectException implements Exception {
  final String _message;

  DataObjectException(this._message);
}
