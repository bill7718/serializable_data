
///
/// Stores meta data (ie data about data)
///
/// Used by the system to determine how to display, input and process an
/// individual data item
///
class DataSpecification {
  static const String boolType = 'bool';
  static const String currencyType = 'currency';
  static const String textType = 'text';
  static const String dateType = 'date';
  static const String listType = 'list';
  static const String radioListType = 'radio';
  static const String dataObjectType = 'data';
  static const String dataObjectListType = 'dataList';
  static const String percentType = 'percent';
  static const String integerType = 'int';

  /// A code for the label used to describe the field on a screen. If not provided
  /// then the system uses hte field name.
  final String? label;

  /// The field type
  /// - bool : boolean Yes/No
  /// - currency : An amount of money. Stored as an integer number of the lowest currency unit (e.g. cents)
  /// - text : A text field
  /// - date : A date stored as an integer number of days since 1 Jan 1970
  /// - list : A list of data items shown as a drop down list
  /// - radio : A list of data items shown as a set of radio buttons
  /// - data : A data object
  /// - dataList: A list of data objects (e.g. a Product Item in an Order)
  /// - percent: A numeric field that shows a percentage
  /// - int : An integer
  final String? type;

  /// The help that is shown with the field
  final String? help;

  /// For a list or radio, contains the list of the data items shown
  final List<ListEntry> list;

  /// A validator to apply to this field
  final Function validator;

  /// If true then then this field is shown in an abscured (like a password)
  final bool obscure;

  /// Where [type] is [dataObjectType] indicates the object type of the field
  final String? dataType;

  final String? addItemButton;
  final String? addItemQuestion;
  final bool showAddItemQuestion;
  final String? itemDialogTitle;

  /// A default list of fields to use for this item. Applicable to
  /// [data] types
  final List<String>? fields;

  /// Used by date fields. Limits the number of days in advance of today's date that can be selected using
  /// date widget
  final Duration? maxDurationAfter;

  /// Used by date fields. Limits the number of days before today's date that can be selected using
  /// date widget
  final Duration? maxDurationBefore;

  /// Generic metadata recorded against the data.
  final dynamic metaData;

  DataSpecification(
      {this.label,
      this.type,
      this.list = const [],
      this.validator = empty,
      this.obscure = false,
      this.dataType,
      this.help,
      this.maxDurationAfter,
      this.maxDurationBefore,
      this.addItemButton,
      this.addItemQuestion,
      this.showAddItemQuestion = true,
      this.itemDialogTitle,
        this.fields,
        this.metaData
});

  /// A default validator that always returns [null] (valid).
  static String? empty(String? v) => null;

  /// Returns the description associated with the id in a list
  static String? getListDescription(String id, String fieldName, Map<String, DataSpecification> dataSpecifications) {
    return ListEntry.getDescription(id, dataSpecifications[fieldName]?.list ?? []);
  }
}

///
/// An id/description pair that reflects valid values for a data item
///
class ListEntry {

  /// The id
  final String id;

  /// The description
  final String description;

  /// Meta data used to filter selected items.
  final dynamic metaData;

  ListEntry(this.id, this.description, {this.metaData});

  ///
  /// Gets the description associated with the id in the list of items
  ///
  static String? getDescription(String id, List<ListEntry> list) {
    for (var entry in list) {
      if (entry.id == id) {
        return entry.description;
      }
    }
    return null;
  }

  ///
  /// Gets the metadata associated with the id in  a list.
  ///
  static dynamic getMetaData(String id, List<ListEntry> list) {
    for (var entry in list) {
      if (entry.id == id) {
        return entry.metaData;
      }
    }
    return null;
  }
}


