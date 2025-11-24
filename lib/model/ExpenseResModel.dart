/// amount : "1000"
/// category : "Rent"
/// created_date : "2025-10-24"
/// family_id : "sdf"
/// method : "Cash"
/// note : "This is cash"
/// uuid : "adfsddf"

class ExpenseResModel {
  ExpenseResModel({
      String? amount, 
      String? category, 
      String? createdDate, 
      String? familyId, 
      String? method, 
      String? note, 
      String? uuid,}){
    _amount = amount;
    _category = category;
    _createdDate = createdDate;
    _familyId = familyId;
    _method = method;
    _note = note;
    _uuid = uuid;
}

  ExpenseResModel.fromJson(dynamic json) {
    _amount = json['amount'];
    _category = json['category'];
    _createdDate = json['created_date'];
    _familyId = json['family_id'];
    _method = json['method'];
    _note = json['note'];
    _uuid = json['uuid'];
  }
  String? _amount;
  String? _category;
  String? _createdDate;
  String? _familyId;
  String? _method;
  String? _note;
  String? _uuid;
ExpenseResModel copyWith({  String? amount,
  String? category,
  String? createdDate,
  String? familyId,
  String? method,
  String? note,
  String? uuid,
}) => ExpenseResModel(  amount: amount ?? _amount,
  category: category ?? _category,
  createdDate: createdDate ?? _createdDate,
  familyId: familyId ?? _familyId,
  method: method ?? _method,
  note: note ?? _note,
  uuid: uuid ?? _uuid,
);
  String? get amount => _amount;
  String? get category => _category;
  String? get createdDate => _createdDate;
  String? get familyId => _familyId;
  String? get method => _method;
  String? get note => _note;
  String? get uuid => _uuid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['amount'] = _amount;
    map['category'] = _category;
    map['created_date'] = _createdDate;
    map['family_id'] = _familyId;
    map['method'] = _method;
    map['note'] = _note;
    map['uuid'] = _uuid;
    return map;
  }

}