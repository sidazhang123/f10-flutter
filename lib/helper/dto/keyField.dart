
class KeyField {

  String Msg;
  List<String> Contain;

	KeyField.fromJsonMap(Map<String, dynamic> map): 
		Msg = map["Msg"],
		Contain = List<String>.from(map["Contain"]);

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['Msg'] = Msg;
		data['Contain'] = Contain;
		return data;
	}
}
