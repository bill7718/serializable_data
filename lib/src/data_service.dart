
///
/// Interface for interaction with the database
///
abstract class DataService {

  ///
  /// Read from the database using
  /// - ref : The database table/object to read
  /// - field : The field to filter on
  /// - value: The value ot filter on
  ///
  /// If no records are found the method returns an empty list
  ///
  Future<List<Map<String, dynamic>>> query(String ref, {String? field, value});

  ///
  /// Put an object into the database
  /// - ref: The database reference of the new object
  /// - m : The data that is updated / inserted
  ///
  Future<void> set(String ref, Map<String, dynamic> m);

  ///
  /// Get an object from the database
  /// - ref: The database reference of the object
  /// - m : The data that is retrieved
  ///
  /// If the entry is not found the application throws an Exception
  ///
  Future<Map<String, dynamic>> get(String ref);

  ///
  /// Delete an object from the database
  ///
  /// Returns a map containing the data of the deleted record
  ///
  Future<Map<String, dynamic>> delete(String ref);
}
