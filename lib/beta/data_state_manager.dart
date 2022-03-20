import 'dart:async';

import 'package:injector/injector.dart';
import '../src/relationship_specification.dart';
import '../src/database_reader.dart';
import '../src/database_updater.dart';
import 'data_object_relationship.dart';
import '../src/persistable_data_object.dart';

///
/// Manages data state within a journey
///
class DataStateManager {
  /// A map of the state data
  final Map<String, PersistableDataObject> data =
      <String, PersistableDataObject>{};

  /// A map of the data relationships maintained by this journey
  final Map<String, DataObjectRelationship> relationships =
      <String, DataObjectRelationship>{};

  /// A map containing the relationships between the data held in this journey
  final Map<String, RelationshipSpecification> specifications;

  final List<PersistableDataObject> dropped = <PersistableDataObject>[];

  /// Reads the external datastore
  final DatabaseReader reader;

  /// Updates the external datastore
  final DatabaseUpdater updater;

  /// Holds the list of ids for which this object has read relationships from the database
  final Set<String> fromIds = <String>{};

  DataStateManager(this.specifications, this.reader, this.updater);

  ///
  /// Get an object of type T from the map or create it.
  ///
  /// If the item is present on the database then it is retrieved
  ///
  /// Does not add the item to the state object
  ///
  Future<T> getOrCreate<T extends PersistableDataObject>({String? id}) async {
    var c = Completer<T>();

    try {
      if (id != null) {
        var response = PersistableDataObject.clone<T>(data[id]);
        response ??= await reader.get<T>(id);
        c.complete(response);
      } else {
        var response = Injector.appInstance.get<T>();
        fromIds.add(response.id);
        c.complete(response);
      }
    } catch (ex, st) {
      c.completeError('${T.runtimeType} $id ${ex.toString()}', st);
    }

    return c.future;
  }

  ///
  /// Retrieve [DataObjectRelationship] object based on the [id] provided and
  /// add them to the state object.
  ///
  Future<void> readRelationships(String id) async {
    var c = Completer<void>();
    try {
      if (fromIds.contains(id)) {
        c.complete();
        return c.future;
      }

      var list = await reader.query<DataObjectRelationship>(
          field: DataObjectRelationship.fromIdLabel, value: id);
      for (var item in list) {
        relationships[item.id] = item;
      }
      fromIds.add(id);
      c.complete();
    } catch (ex, st) {
      c.completeError(' $id ${ex.toString()}', st);
    }
    return c.future;
  }

  ///
  /// Get an object of type T from the map if it is related to the
  /// [fromId] provided with a relationship of type [spec]
  ///
  /// If the item is present on the database then it is retrieved
  /// In addition the relationships for the [fromId] are retrieved into the state
  ///
  /// Does not add the item to the state object -
  ///
  Future<T> getOrCreateBySpecification<T extends PersistableDataObject>(
      String spec, String fromId) async {
    var c = Completer<T>();
    try {
      var match = await _matchRelationship(fromId: fromId, type: spec);
      if (match == null) {
        var response = Injector.appInstance.get<T>();
        fromIds.add(response.id);
        c.complete(response);
      } else {
        if (data[match.toId] != null) {
          c.complete(PersistableDataObject.clone<T>(data[match.toId])!);
        } else {
          var response = await reader.get<T>(match.toId!);
          c.complete(response);
        }
      }
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException('$spec $fromId ${ex.toString()}'), st);
    }
    return c.future;
  }

  ///
  /// Gets a [DataObjectRelationship] for the [spec] and [fromId] provided. If it does not exist
  /// then a new object is created. Used when you want to generate a relationship between 2 existing
  /// data objects
  ///
  Future<DataObjectRelationship> getOrCreateRelationshipBySpecification(
      String spec, String fromId) async {
    var c = Completer<DataObjectRelationship>();

    try {
      var match = await _matchRelationship(fromId: fromId, type: spec);
      if (match == null) {
        c.complete(DataObjectRelationship.specification(
            specifications[spec]!, fromId));
      } else {
        c.complete(PersistableDataObject.clone<DataObjectRelationship>(match));
      }
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException('$spec $fromId ${ex.toString()}'), st);
    }

    return c.future;
  }

  ///
  /// Returns a list of the child objects related to the provided [fromId] with the relationship type as [spec]
  ///
  Future<List<T>> listBySpecification<T extends PersistableDataObject>(
      String spec, String fromId) async {
    var c = Completer<List<T>>();

    try {
      await readRelationships(fromId);
      var matches = await _matchRelationships(fromId: fromId, type: spec);
      if (matches.isEmpty) {
        c.complete(<T>[]);
      } else {
        var response = <T>[];
        for (var item in matches) {
          var r = PersistableDataObject.clone<T>(data[item.toId]);
          r ??= await reader.get<T>(item.toId!);
          response.add(r);
        }
        c.complete(response);
      }
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException('$spec $fromId ${ex.toString()}'), st);
    }

    return c.future;
  }

  ///
  /// Update the data in the state setting the relationships up as specified
  /// by the [spec] and [fromId] provided
  ///
  /// - [o] is added to the [relationships] map if it is a [DataObjectRelationship]
  /// - otherwise [o] is added to the [data] map
  /// - where [spec] and [fromId] is provided the method looks for a link in [relationships] that links the parent
  /// [fromId] to the [id] of [o]. If one is not found then it is added. If necessary the system retrieves the linkd
  /// associated with [fromId] from the database first.
  ///
  Future<void> setState(PersistableDataObject o,
      {String? spec, String? fromId}) async {
    var c = Completer<void>();

    try {
      if ((spec == null && fromId != null) ||
          (spec != null && fromId == null)) {
        throw 'spec and fromId must be both present or both absent';
      }

      if (o is DataObjectRelationship) {
        relationships[o.id] = o;
        c.complete();
      } else {
        data[o.id] = o;
        if (spec != null && fromId != null) {
          // find a matching relationship - if found then leave it alone
          var rel =
              await _matchRelationship(fromId: fromId, toId: o.id, type: spec);
          if (rel == null) {
            rel = Injector.appInstance.get<DataObjectRelationship>();
            rel.set(DataObjectRelationship.fromIdLabel, fromId);
            rel.set(DataObjectRelationship.fromTypeLabel,
                specifications[spec]!.from);
            rel.set(DataObjectRelationship.toIdLabel, o.id);
            rel.set(
                DataObjectRelationship.toTypeLabel, specifications[spec]!.to);
            rel.set(DataObjectRelationship.relationshipTypeLabel, spec);
            if (specifications[spec]!.isSequenced) {
              var seq = await _getLastSequenceNumber(fromId, spec);
              rel.set(DataObjectRelationship.sequenceNumberLabel, seq + 1);
            }
            relationships[rel.id] = rel;
          }
        }

        c.complete();
      }
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException('$fromId $spec ${o.data} ${ex.toString()}'),
          st);
    }

    return c.future;
  }

  Future<void> synchronizeList(
      List<PersistableDataObject> items, String spec, String fromId) async {
    var c = Completer<void>();
    try {
      var current = await listBySpecification(spec, fromId);
      Map<String, PersistableDataObject> currentMap =
          <String, PersistableDataObject>{};
      for (var item in current) {
        currentMap[item.id] = item;
      }

      for (var item in items) {
        currentMap.remove(item.id);
        await setState(item, spec: spec, fromId: fromId);
      }

      // remove any items from the current map that are still there
      for (var item in currentMap.values) {
        var rel = await _matchRelationship(fromId: fromId, toId: item.id);
        drop(rel!);
      }
      c.complete();
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException(
              '$fromId $spec ${items.toString()} ${ex.toString()}'),
          st);
    }

    return c.future;
  }

  Future<List<DataObjectRelationship>> _matchRelationships(
      {String? fromId, String? toId, String? type}) async {
    var c = Completer<List<DataObjectRelationship>>();
    try {
      fromId != null ? await readRelationships(fromId) : {};
      var matches = <DataObjectRelationship>[];
      for (var item in relationships.values) {
        bool match = fromId == null ? true : item.fromId == fromId;
        match = toId == null ? match : match && item.toId == toId;
        match = type == null ? match : match && item.relationshipType == type;
        match = (match & item.active);

        if (match) {
          matches.add(item);
        }
      }
      c.complete(matches);
    } catch (ex, st) {
      c.completeError(ex, st);
    }

    return c.future;
  }

  Future<DataObjectRelationship?> _matchRelationship(
      {String? fromId, String? toId, String? type}) async {
    var c = Completer<DataObjectRelationship?>();
    try {
      var response =
          await _matchRelationships(fromId: fromId, type: type, toId: toId);
      if (response.isEmpty) {
        c.complete(null);
      } else {
        if (response.length == 1) {
          c.complete(response.first);
        } else {
          throw Exception('too many matches $fromId $toId $type');
        }
      }
    } catch (ex, st) {
      c.completeError('$fromId $toId $type -  ${ex.toString()}', st);
    }

    return c.future;
  }

  Future<int> _getLastSequenceNumber(String fromId, String spec) async {
    var c = Completer<int>();

    try {
      var matches = await _matchRelationships(fromId: fromId, type: spec);
      int lastSeq = -1;
      for (var item in matches) {
        int seq = item.sequence!;
        lastSeq = lastSeq < seq ? seq : lastSeq;
      }
      c.complete(lastSeq);
    } catch (ex, st) {
      c.completeError('$fromId $spec -  ${ex.toString()}', st);
    }

    return c.future;
  }

  ///
  /// Saves the state of this State object to the database
  ///
  Future<void> save() async {
    var c = Completer<void>();

    try {
      var updates = <PersistableDataObject>[];

      // not all items in the 'dropped' list are deleted
      var deletes = <PersistableDataObject>[];
      for (var droppedItem in dropped) {
        // if we have never saved the item to the data base then do not delete it
        if (droppedItem.isOnDatabase) {
          // if the item is locked by an audit event then make it inactive and don't do anything else
          if (droppedItem is DataObjectRelationship) {
            if (droppedItem.locked) {
              droppedItem.set(DataObjectRelationship.activeLabel, false);
              updates.add(droppedItem);
            } else {
              // the item is on the database and is not locked. So it can be deleted
              deletes.addAll(await _getChildrenToDelete(droppedItem));
            }
          }
        }
      }

      updates.addAll(data.values);
      updates.addAll(relationships.values);

      await updater.update(updates: updates);

      c.complete();
    } catch (ex, st) {
      c.completeError(ex, st);
    }
    return c.future;
  }

  T? get<T extends PersistableDataObject>() {
    T? response;
    for (var item in data.values) {
      if (item is T) {
        if (response != null) {
          throw DataStateManagerException(
              'More than one ${response.type} in this state object');
        } else {
          response = PersistableDataObject.clone<T>(item);
          response != null ? fromIds.add(response.id) : {};
        }
      }
    }
    return response;
  }

  ///
  /// Remove this relationship from the state object
  ///
  /// The method removes any children from the state unless them have any other relevant parents
  ///
  void drop(PersistableDataObject object, {bool origin = true}) {
    if (origin) {
      dropped.add(object);
    }

    if (object is DataObjectRelationship) {
      relationships.remove(object.id);
      var child = data[object.toId];
      child != null ? drop(child, origin: false) : {};
    } else {
      // only remove the object if does not have any parents in the state object
      var found = false;
      for (var relationship in relationships.values) {
        if (relationship.toId == object.id) {
          found = true;
        }
      }
      if (!found) {
        data.remove(object.id);
        for (var relationship in relationships.values) {
          drop(relationship, origin: false);
        }
      }
    }
  }

  ///
  /// If the object has no parents then it can be deleted along with all of it's child relationships
  ///
  Future<List<PersistableDataObject>> _getChildrenToDelete(
      DataObjectRelationship relationship) async {
    var c = Completer<List<PersistableDataObject>>();

    var response = <PersistableDataObject>[relationship];
    // get the parents
    var otherParents = false;
    var relationships = await reader.query<DataObjectRelationship>(
        field: DataObjectRelationship.toIdLabel, value: relationship.toId);
    for (var rel in relationships) {
      if (rel.id != relationship.id) {
        otherParents = true;
      }
      if (otherParents) {
        c.complete(response);
      } else {
        var child = await reader.get(relationship.toId!);
        response.add(child);
        var childParentRelationships =
            await reader.query<DataObjectRelationship>(
                field: DataObjectRelationship.fromIdLabel, value: child.id);
        for (var rel in childParentRelationships) {
          response.addAll(await _getChildrenToDelete(rel));
        }
        c.complete(response);
      }
    }

    return c.future;
  }

  Future<T> queryOrCreate<T extends PersistableDataObject>(
      {String? field, String? value}) async {
    var c = Completer<T>();

    try {
      if (field != null) {
        for (var item in data.values) {
          if (item is T) {
            if (item.get(field) == value) {
              c.complete(PersistableDataObject.clone<T>(item));
              return c.future;
            }
          }
        }

        var o = await reader.query<T>(field: field, value: value);
        if (o.isNotEmpty) {
          c.complete(o.first);
          return c.future;
        }

        var response = Injector.appInstance.get<T>();
        fromIds.add(response.id);
        c.complete(response);
      } else {
        var response = Injector.appInstance.get<T>();
        fromIds.add(response.id);
        c.complete(response);
      }
    } catch (ex, st) {
      c.completeError('${T.runtimeType}  ${ex.toString()}', st);
    }

    return c.future;
  }

  static DataStateManager clone(DataStateManager current) {
    var response = DataStateManager(
        current.specifications, current.reader, current.updater);

    for (var item in current.data.values) {
      response.data[item.id] = PersistableDataObject.clone(item)!;
    }

    for (var item in current.relationships.values) {
      response.relationships[item.id] = PersistableDataObject.clone(item)!;
    }

    return response;
  }

  Future<List<PersistableDataObject>>
      getParentsBySpecification<T extends PersistableDataObject>(
          String spec, String toId) async {
    var c = Completer<List<T>>();

    try {
      var matches = await _matchRelationships(toId: toId, type: spec);
      if (matches.isEmpty) {
        c.complete(<T>[]);
      } else {
        var response = <T>[];
        for (var match in matches) {
          response.add(data[match.fromId] as T);
        }
        c.complete(response);
      }
    } catch (ex, st) {
      c.completeError(
          DataStateManagerException('$spec $toId ${ex.toString()}'), st);
    }

    return c.future;
  }
}

class DataStateManagerException implements Exception {
  final String _message;

  DataStateManagerException(this._message);

  @override
  String toString() => _message;
}
