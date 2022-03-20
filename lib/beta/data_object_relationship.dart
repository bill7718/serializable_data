import '../serializable_data.dart';

///
/// Models the relationship between 2 [PersistableDataObject]s
///
class DataObjectRelationship extends PersistableDataObject {
  static const String objectType = 'DataObjectRelationship';

  static const String fromIdLabel = 'fromId';
  static const String toIdLabel = 'toId';
  static const String fromTypeLabel = 'fromType';
  static const String toTypeLabel = 'toType';
  static const String relationshipTypeLabel = 'relationshipType';

  static const String sequenceNumberLabel = 'sequence';

  static const String activeLabel = 'active';

  /// This item contains reference keys to events that require a snapshot of the data to be retained
  ///
  /// An example might be a student in a class. It might be necessary to
  /// record which students we in a class at the time of an assessment.
  ///
  /// In this case the id of the assessment record might be the snapshot key. This allows the
  /// system to determine which relationships were in force at the time of the assessment.
  ///
  /// Buy convention relationships with a snapshot value present are never deleted. they are made inactve
  static const String snapshotLabel = 'snapshot';

  /// If this attribute is true then the relationship is not present
  ///
  /// So where for example a Student has no exam certificates we would model that by creating a relationship
  /// with the absent value set. If the relationship is not present this means that we have no record of the
  /// students exam certificates but this might be because we have not asked about them.
  static const String absentLabel = 'absent';

  DataObjectRelationship({Map<String, dynamic>? data}) : super(objectType, data: data);

  DataObjectRelationship.data({required PersistableDataObject from, required PersistableDataObject to, required String type, int? sequenceNumber})
      : super(objectType) {
    set(relationshipTypeLabel, type);
    set(fromTypeLabel, from.type);
    set(fromIdLabel, from.id);
    set(toTypeLabel, to.type);
    set(toIdLabel, to.id);
    set(sequenceNumberLabel, sequenceNumber);
  }

  DataObjectRelationship.specification(RelationshipSpecification specification, String fromId) : super(objectType) {
    set(fromTypeLabel, specification.from);
    set(toTypeLabel, specification.to);
    set(relationshipTypeLabel, specification.type);
    set(fromIdLabel, fromId);
  }

  String? get toType => get(toTypeLabel);
  String? get fromType => get(fromTypeLabel);
  String? get relationshipType => get(relationshipTypeLabel);
  String? get toId => get(toIdLabel);
  String? get fromId => get(fromIdLabel);
  int? get sequence => get(sequenceNumberLabel);
  bool get locked => snapshots.isNotEmpty;

  bool get active => super.get(activeLabel) ?? true;
  List<String> get snapshots => super.get(snapshotLabel) ?? <String>[];

  set sequence(int? s) => set(sequenceNumberLabel, s);


  @override
  dynamic get(String label) {
    switch (label) {
      case snapshotLabel:
        return snapshots;

      case activeLabel:
        return active;

      case absentLabel:
        return toId == null;

      default:
        return super.get(label);
    }
  }

  void addSnapshot(String id) {
    var s = snapshots;
    s.add(id);
    set(snapshotLabel, s);
  }
}




