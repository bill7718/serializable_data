
///
/// Describes the relationship between 2 objects
///
/// For example if the relationship was between a teacher and students with only male students to be allowed then the specification might be
/// ```
///   from : Teacher,
///   to: Student,
///   type: classMember,
///   filterLabel : gender,
///   filterValue : male,
///   descriptionLabel: name,
///   relationshipLabel: maleStudent
/// ```
///
class RelationshipSpecification {

  static const int isOptional = 0;
  static const int isMandatory = 1;
  static const int mandatoryButMayBeEmpty = 2;

  /// The object type the relationship goes from
  final String from;

  /// The object type the relationship goes to
  final String to;

  /// Describes the type of the relationship
  final String type;

  /// Where the relationship is based on a filtered list of items in the to object this is the fieldLabel which is filtered
  final String? filterLabel;

  /// Where the relationship is based on a filtered list of items in the to object this is the fieldValue which is filtered
  final String? filterValue;

  /// Where the relationship is selected on a screen this is the label in the dataobject of the description to be shown
  final String? descriptionLabel;

  /// This is the label to be shown on the page
  final String? relationshipLabel;

  /// If true then there are many items relationships of this type and they have an order e.g. applicants for a loan
  final bool isSequenced;

  /// Specifies whether this relationship must exist. Takes 3 values
  ///
  /// - 0 the relationship is optional e.g. DIP -> Broker Fee
  /// - 1 the relationship is mandatory e.g. DIP -> Loan Requirements
  /// - 2 the relationship must exist but may be empty Applicant -> Income
  final int mandatory;


  RelationshipSpecification(this.from, this.to, this.type, {  this.filterLabel, this.filterValue, this.descriptionLabel,
    this.relationshipLabel, this.isSequenced = false, this.mandatory = isOptional });

}