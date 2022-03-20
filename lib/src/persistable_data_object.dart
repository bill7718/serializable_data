
import 'package:injector/injector.dart';
import 'data_object.dart';
import 'helper.dart';

///
/// A [DataObject] that is designed to be persisted in a json database
///
/// It requires a type and generates and sets an id
///
abstract class PersistableDataObject extends DataObject {

  /// The label used for the id
  static const String idLabel = 'id';

  /// The type of the data - used to determine the id of the object in the database
  final String type;

  ///
  /// Should be marked as true if this record is read from the database
  ///
  /// Used by external classes to determine if  this object was ever written to the database. In the event that
  /// it is to be deleted the external class can determine whether to make a delete call
  ///
  bool isOnDatabase = false;

  ///
  /// marked as true if the data on this object is updated
  ///
  bool isUpdated = false;

  PersistableDataObject(this.type, { Map<String, dynamic>? data}) : super(data ?? <String, dynamic>{}) {
    if (get(idLabel) == null) {
      set(idLabel, generateId());
    }
    isUpdated = false;
  }

  @override
  set(String label, dynamic value) {
    isUpdated = true;
    super.set(label, value);
  }

  String get id=>get(idLabel);

  String get dbReference=>type+'/'+id;


  static T? clone<T extends PersistableDataObject>(PersistableDataObject? from) {

    if (from == null) return null;

    var o = Injector.appInstance.get<T>();
    o.merge(from.data);
    o.isUpdated = from.isUpdated;
    o.isOnDatabase = from.isOnDatabase;
    return o;
  }


  static String buildDBReference(String type, String id)=>'$type/$id';

}