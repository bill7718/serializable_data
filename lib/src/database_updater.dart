import 'dart:async';
import '../serializable_data.dart';

///
/// Updates a database using the [DataService]
///
class DatabaseUpdater {

  final DataService _data;

  DatabaseUpdater(this._data);

  ///
  /// Updates the database with the items ot be updated and deletes the ones to be deleted.
  ///
  ///
  /// The method only updates records that have been changed since the last update
  ///
  Future<void> update({Iterable<PersistableDataObject>? updates, Iterable<PersistableDataObject>? deletes}) async {
    var c = Completer<void>();

    try {
      var toBeUpdated = <PersistableDataObject>[];
      for (var update in updates ?? <PersistableDataObject>[]) {
        if (!update.isOnDatabase || update.isUpdated) {
          if (update.validate() == null) {
            toBeUpdated.add(update);
          } else {
            throw DataObjectException('Attempting to save invalid data : ${update.validate()} ${update.type} ${update.data}');
          }
        }
      }

      var toBeDeleted = <PersistableDataObject>[];
      for (var delete in deletes ?? <PersistableDataObject>[]) {
        if (delete.isOnDatabase) {
          toBeDeleted.add(delete);
        }
      }

      for (var item in toBeDeleted) {
        await _data.delete(item.dbReference);
      }

      for (var item in toBeUpdated) {
        await _data.set(item.dbReference, item.data);
        item.isOnDatabase = true;
        item.isUpdated = false;
      }

      c.complete();
    } catch (ex, st) {
      c.completeError(ex, st);
    }

    return c.future;
  }
}
