import 'dart:async';
import 'package:injector/injector.dart';
import '../serializable_data.dart';


///
/// Reads Data using a [DataService] and returns the data as
/// fully formed [PersistableDataObject]s rather than maps.
///
class DatabaseReader {
  final DataService _data;

  DatabaseReader(this._data);

  ///
  /// Returns a Future List <T> of matching objects
  ///
  /// e.g.
  /// ```
  ///  var users = await query<User>('User', field: 'email', value: 'a@b.com');
  /// ```
  Future<List<T>> query<T extends PersistableDataObject>({String? ref, String? field, value}) async {
    var c = Completer<List<T>>();

    String dbRef = ref ?? Injector.appInstance.get<T>().type;

    var response = <T>[];
    var maps = await _data.query(dbRef, field: field, value: value);
    for (var map in maps) {
      var data = ref == null ? Injector.appInstance.get<T>() : Injector.appInstance.get<PersistableDataObject>(dependencyName: ref);
      data.merge(map);
      data.isUpdated = false;
      data.isOnDatabase = true;
      response.add(data as T);
    }
    c.complete(response);
    return c.future;
  }

  ///
  /// Get an object from the database
  /// - ref: The database reference of the object
  /// - m : The data that is retrieved
  ///
  /// If the entry is not found the application throws an Exception
  ///
  Future<T> get<T extends PersistableDataObject>(String id) async {
    var c = Completer<T>();
    try {
      var map = await _data.get(Injector.appInstance
          .get<T>()
          .type + '/' + id);
      var response = Injector.appInstance.get<T>();
      response.merge(map);
      response.isOnDatabase = true;
      response.isUpdated = false;
      c.complete(response);
    } catch (ex) {
      c.completeError(DataObjectException('get : $id not found : ${ex.toString()}'));
    }

    return c.future;
  }
}
