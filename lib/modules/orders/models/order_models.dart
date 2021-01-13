import 'package:eSamudaay/modules/cart/models/cart_model.dart';
import 'package:eSamudaay/modules/orders/models/order_state_data.dart';
import 'package:eSamudaay/utilities/stringConstants.dart';
import 'package:equatable/equatable.dart';

class GetOrderListRequest {
  String phoneNumber;

  GetOrderListRequest({this.phoneNumber});

  GetOrderListRequest.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}

class GetOrderListResponse {
  int count;
  String next;
  String previous;
  List<PlaceOrderResponse> results;

  GetOrderListResponse({this.count, this.results});

  GetOrderListResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<PlaceOrderResponse>();
      json['results'].forEach((v) {
        results.add(new PlaceOrderResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddReviewRequest {
  final int ratingValue;
  final String ratingComment;
  final List<ProductRating> productRatings;

  AddReviewRequest({this.ratingValue, this.ratingComment, this.productRatings});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating_value'] = this.ratingValue;
    data['rating_comment'] = this.ratingComment;
    data['product_ratings'] =
        this.productRatings.map((v) => v.toJson()).toList();
    return data;
  }

  copyWith({
    int ratingValue,
    String ratingComment,
    List<ProductRating> productRatings,
  }) {
    return AddReviewRequest(
      ratingValue: ratingValue ?? this.ratingValue,
      ratingComment: ratingComment ?? this.ratingComment,
      productRatings: productRatings ?? this.productRatings,
    );
  }
}

class ProductRating {
  final int productId;
  final int ratingValue;

  ProductRating({this.productId, this.ratingValue});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['rating_val'] = this.ratingValue;
    return data;
  }

  copyWith({
    int productId,
    int ratingValue,
  }) {
    return ProductRating(
      productId: productId ?? this.productId,
      ratingValue: ratingValue ?? this.ratingValue,
    );
  }
}

class UpdateOrderRequest {
  String phoneNumber;
  List orders;
  String comments;
  String oldStatus;

  UpdateOrderRequest(
      {this.phoneNumber, this.orders, this.comments, this.oldStatus});

  UpdateOrderRequest.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
    if (json['orders'] != null) {
      orders = new List();
      json['orders'].forEach((v) {
        orders.add(v);
      });
    }
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phoneNumber'] = this.phoneNumber;
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    data['comments'] = this.comments;
    print(data);
    return data;
  }
}

class PaymentInfo {

  String upi;

  /// The payment status of the order. Can have following possible values
  ///   I) PENDING : Payment not done
  ///   II) SUCCESS : Payment succeded. Could be online or COD.
  ///   III) FAIL : Online payment failed
  ///   IV) REFUNDED : Money refunded
  ///
  ///  Old Statuses:
  ///   I) INITIATED : Customer marked paid
  ///   II) APPROVED : Merchant approved payment
  ///   III) REJECTED : Merchant rejected the payment claim
  ///
  String status;

  String dt;

  /// A string containing info regarding the source of the payment
  /// e.g. Direct UPI, Deutsche bank, PayTM, OlaMoney etc.
  ///
  String paymentMadeVia;

  /// Amount paid via the [paymentMadeVia] channel in paise. This may be different
  /// than the order total billed amount
  ///
  int amount;

  PaymentInfo({this.upi, this.status, this.dt, this.paymentMadeVia, this.amount});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    upi = json['upi'];
    status = json['status'];
    dt = json['dt'];
    amount = json['amount'];
    paymentMadeVia = json['via'];
  }

  double get amountInRupees => (this.amount ?? 0) / 100;

  bool get isPaymentDone =>
      this.status == PaymentStatus.APPROVED ||
      this.status == PaymentStatus.SUCCESS ||
      this.status == PaymentStatus.REFUNDED;

  bool get isPaymentFailed =>
      this.status == PaymentStatus.FAIL ||
      this.status == PaymentStatus.REJECTED;

  bool get isPaymentPending => this.status == PaymentStatus.PENDING;

  bool get isPaymentInitiated => this.status == PaymentStatus.INITIATED;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upi'] = this.upi;
    data['status'] = this.status;
    data['dt'] = this.dt;
    data['via'] = paymentMadeVia;
    data['amount'] = amount;
    return data;
  }
}

class RazorpayCheckoutOptions extends Equatable {
  final String key;
  final int amount;
  final String name;
  final String orderId;
  final String description;
  final int timeout;
  final String email;
  final String phone;
  final String currency;

  RazorpayCheckoutOptions(this.key, this.amount, this.name, this.orderId,
      this.description, this.timeout, this.email, this.phone, this.currency);

  factory RazorpayCheckoutOptions.fromJson(Map<String, dynamic> json) {
    final String key = json['key'];
    final int amount = json['amount'] ?? razorpayDefaultAmountInInt;
    final String name = json['name'] ?? razorpayDefaultName;
    final String orderId = json['order_id'];
    final int timeout = json['timeout'] ?? razorpayDefaultTimeout;
    final String currency = json['currency'] ?? razorpayDefaultCurrency;
    final String description = json['description'] ?? '';
    final String phone = (json['prefill'] ?? const {})['contact'] ?? '';
    final String email = (json['prefill'] ?? const {})['email'] ?? '';
    if (key == null || orderId == null) return null;
    return RazorpayCheckoutOptions(
        key, amount, name, orderId, description, timeout, email, phone, currency);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> checkoutOptions = Map<String, dynamic>();
    checkoutOptions['key'] = key;
    checkoutOptions['amount'] = amount;
    checkoutOptions['name'] = name;
    checkoutOptions['order_id'] = orderId;
    checkoutOptions['currency'] = currency;
    checkoutOptions['timeout'] = timeout;
    checkoutOptions['description'] = description;
    checkoutOptions['send_sms_hash'] = true;
    checkoutOptions['readonly'] = {
      'name': true
    };
    checkoutOptions['prefill'] = {
      'contact': phone,
      'email': email
    };
    return checkoutOptions;
  }

  @override
  List<Object> get props =>
      [key, amount, name, orderId, description, timeout, email, phone, currency];
}
