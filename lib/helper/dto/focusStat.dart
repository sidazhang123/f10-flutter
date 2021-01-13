
class FocusStat {

  bool success;
  List<Chans> chans;

	FocusStat.fromJsonMap(Map<String, dynamic> map): 
		success = map["success"],
		chans = List<Chans>.from(map["chans"].map((it) => Chans.fromJsonMap(it)));

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = success;
		data['chans'] = chans != null ? 
			this.chans.map((v) => v.toJson()).toList()
			: null;
		return data;
	}

}
class Chans {

	String ChanName;
	int NoMsg;

	Chans.fromJsonMap(Map<String, dynamic> map):
				ChanName = map["chanName"],
				NoMsg = map["NoMsg"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['chanName'] = ChanName;
		data['NoMsg'] = NoMsg;
		return data;
	}
}
