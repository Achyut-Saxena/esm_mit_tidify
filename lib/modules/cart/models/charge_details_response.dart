class CartCharges {
  Charge deliveryCharge;
  Charge packingCharge;
  Charge serviceCharge;

  CartCharges({this.deliveryCharge, this.packingCharge, this.serviceCharge});

  CartCharges.fromJson(List json) {
    if (json != null && json.isNotEmpty) {
      json.forEach((v) {
        Charge _charge = new Charge.fromJson(v);
        if (_charge.chargeName == "DELIVERY") {
          deliveryCharge = _charge;
        } else if (_charge.chargeName == "PACKING") {
          packingCharge = packingCharge;
        } else if (_charge.chargeName == "SERVICE") {
          serviceCharge = _charge;
        }
      });
    }
  }
}

class Charge {
  String businessId;
  String chargeName;
  int chargeValue;
  String chargeType;
  int maxValue;
  String chargeState;

  Charge(
      {this.businessId,
      this.chargeName,
      this.chargeValue,
      this.chargeType,
      this.maxValue,
      this.chargeState});

  Charge.fromJson(Map<String, dynamic> json) {
    businessId = json['business_id'];
    chargeName = json['charge_name'];
    chargeValue = json['charge_value'];
    chargeType = json['charge_type'];
    maxValue = json['max_value'];
    chargeState = json['charge_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_id'] = this.businessId;
    data['charge_name'] = this.chargeName;
    data['charge_value'] = this.chargeValue;
    data['charge_type'] = this.chargeType;
    data['max_value'] = this.maxValue;
    data['charge_state'] = this.chargeState;
    return data;
  }

  double get amount {
    try {
      return (this.chargeValue ?? 0) / 100;
    } catch (e) {
      return 0.0;
    }
  }
}
