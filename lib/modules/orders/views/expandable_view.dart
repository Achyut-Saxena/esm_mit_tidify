import 'package:async_redux/async_redux.dart';
import 'package:eSamudaay/models/loading_status.dart';
import 'package:eSamudaay/modules/orders/actions/actions.dart';
import 'package:eSamudaay/modules/orders/models/order_models.dart';
import 'package:eSamudaay/modules/orders/views/orders_View.dart';
import 'package:eSamudaay/redux/actions/general_actions.dart';
import 'package:eSamudaay/redux/states/app_state.dart';
import 'package:eSamudaay/store.dart';
import 'package:eSamudaay/utilities/colors.dart';
import 'package:eSamudaay/utilities/customAlert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableListView extends StatefulWidget {
  final int merchantIndex;
  final Function(bool) didExpand;

  const ExpandableListView({Key key, this.merchantIndex, this.didExpand})
      : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController reviewController = TextEditingController();
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        model: _ViewModel(),
        builder: (context, snapshot) {
          var orderStatus = snapshot
              .getOrderListResponse.results[widget.merchantIndex].orderStatus;
          return new Column(
            children: <Widget>[
              InkWell(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, top: 15, right: 15),
                      child: OrdersListView(
                        isExpanded: expandFlag,
                        orderId: snapshot.getOrderListResponse
                            .results[widget.merchantIndex].orderShortNumber,
                        shopImage: snapshot
                                        .getOrderListResponse
                                        .results[widget.merchantIndex]
                                        .businessImages ==
                                    null ||
                                snapshot
                                    .getOrderListResponse
                                    .results[widget.merchantIndex]
                                    .businessImages
                                    .isEmpty
                            ? ""
                            : snapshot
                                .getOrderListResponse
                                .results[widget.merchantIndex]
                                .businessImages
                                .first
                                .photoUrl,
                        name: snapshot.getOrderListResponse
                            .results[widget.merchantIndex].businessName,
                        deliveryStatus: snapshot.getOrderListResponse
                                .results[widget.merchantIndex].deliveryType !=
                            "SELF_PICK_UP",
                        items: "",
                        date: DateFormat('dd MMMM, hh:mm a').format(
                            DateTime.parse(snapshot.getOrderListResponse
                                    .results[widget.merchantIndex].created)
                                .toLocal()),
                        //"20 -April, 07.45 PM ",
                        price:
                            "₹ ${snapshot.getOrderListResponse.results[widget.merchantIndex].orderTotal / 100.0}",
                      ),
                    ),
                    AnimatedContainer(
                      margin: EdgeInsets.only(top: 10),
                      height: expandFlag ? 0 : 0.5,
                      color: Colors.grey,
                      duration: Duration(milliseconds: 200),
                    )
                  ],
                ),
                onTap: () {
                  if (!expandFlag) {
                    store
                        .dispatchFuture(GetOrderDetailsAPIAction(
                            orderId: snapshot.getOrderListResponse
                                .results[widget.merchantIndex].orderId))
                        .whenComplete(() {
                      // call the details api
                      widget.didExpand(expandFlag);
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    });
                  } else {
                    // call the details api
                    widget.didExpand(expandFlag);
                    setState(() {
                      expandFlag = !expandFlag;
                    });
                  }
                },
              ),
              ExpandableContainer(
                  expanded: expandFlag,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        ///Catalog order items view
                        if (snapshot
                            .getOrderListResponse
                            .results[widget.merchantIndex]
                            .orderItems != null && snapshot
                            .getOrderListResponse
                            .results[widget.merchantIndex]
                            .orderItems
                            .isNotEmpty)
                          ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            padding:
                                EdgeInsets.only(top: 16, left: 15, right: 15),
                            shrinkWrap: true,
                            itemCount: snapshot
                                        .getOrderListResponse
                                        .results[widget.merchantIndex]
                                        .orderItems ==
                                    null
                                ? 0
                                : snapshot
                                    .getOrderListResponse
                                    .results[widget.merchantIndex]
                                    .orderItems
                                    .length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Container(
                                height: 7,
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              var price = snapshot
                                      .getOrderListResponse
                                      .results[widget.merchantIndex]
                                      .orderItems[index]
                                      .unitPrice *
                                  snapshot
                                      .getOrderListResponse
                                      .results[widget.merchantIndex]
                                      .orderItems[index]
                                      .quantity
                                      .toDouble();
                              return Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    // Faux Sued Ankle Mango - 500 GM x 3
                                    Text(
                                        snapshot
                                                .getOrderListResponse
                                                .results[widget.merchantIndex]
                                                .orderItems[index]
                                                .productName +
                                            " ${snapshot.getOrderListResponse.results[widget.merchantIndex].orderItems[index].variationOption.size != null ? snapshot.getOrderListResponse.results[widget.merchantIndex].orderItems[index].variationOption.size : ""}"
                                                " -  x " +
                                            snapshot
                                                .getOrderListResponse
                                                .results[widget.merchantIndex]
                                                .orderItems[index]
                                                .quantity
                                                .toString(),
                                        style: const TextStyle(
                                            color: const Color(0xff7c7c7c),
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Avenir-Medium",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                        textAlign: TextAlign.left),
                                    // ₹ 55.00
                                    Text("₹ ${price / 100}",
                                        style: const TextStyle(
                                            color: const Color(0xff6f6f6f),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Avenir-Medium",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                        textAlign: TextAlign.left)
                                  ],
                                ),
                              );
                            },
                          ),
                        ////////////////////////////////////////////////////////
                        ///Free form order items list
                        if (snapshot
                            .getOrderListResponse
                            .results[widget.merchantIndex]
                            .freeFormOrderItems != null && snapshot
                            .getOrderListResponse
                            .results[widget.merchantIndex]
                            .freeFormOrderItems
                            .isNotEmpty)
                          ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            padding:
                                EdgeInsets.only(top: 16, left: 15, right: 15),
                            shrinkWrap: true,
                            itemCount: snapshot
                                        .getOrderListResponse
                                        .results[widget.merchantIndex]
                                        .freeFormOrderItems ==
                                    null
                                ? 0
                                : snapshot
                                    .getOrderListResponse
                                    .results[widget.merchantIndex]
                                    .freeFormOrderItems
                                    .length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Container(
                                height: 7,
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              var price = snapshot
                                  .getOrderListResponse
                                  .results[widget.merchantIndex]
                                  .freeFormOrderItems[index]
                                  .quantity
                                  .toDouble();
                              return Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        snapshot
                                                .getOrderListResponse
                                                .results[widget.merchantIndex]
                                                .freeFormOrderItems[index]
                                                .skuName +
                                            snapshot
                                                .getOrderListResponse
                                                .results[widget.merchantIndex]
                                                .freeFormOrderItems[index]
                                                .quantity
                                                .toString(),
                                        style: const TextStyle(
                                            color: const Color(0xff7c7c7c),
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Avenir-Medium",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                        textAlign: TextAlign.left),
                                    Text("₹ ${price / 100}",
                                        style: const TextStyle(
                                            color: const Color(0xff6f6f6f),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Avenir-Medium",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                        textAlign: TextAlign.left)
                                  ],
                                ),
                              );
                            },
                          ),
                        ////////////////////////////////////////////////////////
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Payment Details
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 15, right: 15),
                              child: Text('screen_order.payment_details',
                                      style: const TextStyle(
                                          color: const Color(0xff000000),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Avenir-Medium",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 16.0),
                                      textAlign: TextAlign.center)
                                  .tr()
                                  .tr(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                              ),
                              child: Column(
                                children: <Widget>[
                                  ListView.separated(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: 3,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return index == 0
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                // Item Total
                                                Text('screen_order.item_total',
                                                        style: const TextStyle(
                                                            color: const Color(
                                                                0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign:
                                                            TextAlign.left)
                                                    .tr(), // ₹ 175.00
                                                Text(
                                                    "₹ ${snapshot.
                                                    getOrderListResponse.results
                                                    [widget.merchantIndex].
                                                    itemTotal / 100}" ??
                                                        "0.0",
                                                    style:
                                                        const TextStyle(
                                                            color:
                                                                const Color(
                                                                    0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                    textAlign: TextAlign.left)
                                              ],
                                            )
                                          : index == 1
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    // Item Total
                                                    Text('Delivery Charge',
                                                        style: const TextStyle(
                                                            color: const Color(
                                                                0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign: TextAlign
                                                            .left), // ₹ 175.00
                                                    Text(
                                                        "₹ ${snapshot.getOrderListResponse.results[widget.merchantIndex].deliveryCharges / 100}",
                                                        style: const TextStyle(
                                                            color: const Color(
                                                                0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign:
                                                            TextAlign.left)
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    // Item Total
                                                    Text('Other Charges',
                                                        style: const TextStyle(
                                                            color: const Color(
                                                                0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign: TextAlign
                                                            .left), // ₹ 175.00
                                                    Text(
                                                        "₹ ${snapshot.getOrderListResponse.results[widget.merchantIndex].otherCharges / 100}",
                                                        style: const TextStyle(
                                                            color: const Color(
                                                                0xff696666),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Avenir-Medium",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign:
                                                            TextAlign.left)
                                                  ],
                                                );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 13,
                                      );
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 0.5,
                                          margin: EdgeInsets.only(bottom: 10),
                                          color: Colors.grey,
                                        ),
                                        // Amount to be paid
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('screen_order.total',
                                                      style: const TextStyle(
                                                          color: const Color(
                                                              0xff696666),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              "Avenir-Medium",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 16.0),
                                                      textAlign: TextAlign.left)
                                                  .tr(),
                                              // ₹ 195.00
                                              // ₹ 195.00
                                              Text(
                                                  "₹ ${snapshot.getOrderListResponse.results[widget.merchantIndex].orderTotal / 100}",
                                                  style: const TextStyle(
                                                      color: const Color(
                                                          0xff5091cd),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily:
                                                          "Avenir-Medium",
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 16.0),
                                                  textAlign: TextAlign.left)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                        // Please pay your bill amount to the  merchant directly using Cash, Card or UPI
                        orderStatus == "CONFIRMED"
                            ? Container(
                                color: Color(0xfff2f2f2),
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ImageIcon(
                                          AssetImage('assets/images/pen2.png')),
                                    ),
                                    Expanded(
                                      child: Text('screen_order.please_pay',
                                              style: const TextStyle(
                                                  color:
                                                      const Color(0xff4b4b4b),
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Avenir-Medium",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 14.0),
                                              textAlign: TextAlign.left)
                                          .tr(),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        orderStatus == "COMPLETED"
                            ? Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                height: 55,
                                child: Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        // Rate us
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text('screen_order.rate',
                                                  style: const TextStyle(
                                                      color: const Color(
                                                          0xff6c6c6c),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          "Avenir-Medium",
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 18.0),
                                                  textAlign: TextAlign.left)
                                              .tr(),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            await showDialog<String>(
                                              context: context,
                                              builder: (builder) {
                                                return StoreConnector<AppState,
                                                        _ViewModel>(
                                                    model: _ViewModel(),
                                                    builder:
                                                        (context, snapshot) {
                                                      return CustomAlertDialog(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        content: Container(
                                                          height: 250,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              new BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: const Color(
                                                                0xFFFFFF),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .all(new Radius
                                                                        .circular(
                                                                    32.0)),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              // Rate our service
                                                              snapshot.loadingStatus ==
                                                                      LoadingStatusApp
                                                                          .submitted
                                                                  ? Container(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .green,
                                                                        size:
                                                                            100,
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              Text(
                                                                  snapshot.loadingStatus ==
                                                                          LoadingStatusApp
                                                                              .submitted
                                                                      ? tr(
                                                                          'screen_order.rate_ok')
                                                                      : tr(
                                                                          'screen_order.rate_our'),
                                                                  style: const TextStyle(
                                                                      color: const Color(
                                                                          0xff222222),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontFamily:
                                                                          "Avenir-Medium",
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      fontSize:
                                                                          20.0),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left),
                                                              snapshot.loadingStatus ==
                                                                      LoadingStatusApp
                                                                          .submitted
                                                                  ? Container()
                                                                  : Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              11,
                                                                          bottom:
                                                                              15),
                                                                      child:
                                                                          IgnorePointer(
                                                                        ignoring: snapshot.loadingStatus == LoadingStatusApp.loading || widget != null
                                                                            ? snapshot.getOrderListResponse.results[widget.merchantIndex].rating ==
                                                                                null
                                                                            : false,
                                                                        child:
                                                                            RatingBar(
                                                                          initialRating: widget != null
                                                                              ? snapshot.getOrderListResponse.results[widget.merchantIndex].rating != null ? snapshot.getOrderListResponse.results[widget.merchantIndex].rating.ratingValue != null ? snapshot.getOrderListResponse.results[widget.merchantIndex].rating.ratingValue.ceilToDouble() : 0 : 0
                                                                              : 0,
                                                                          minRating:
                                                                              1,
                                                                          itemSize:
                                                                              27,
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          allowHalfRating:
                                                                              false,
                                                                          itemCount:
                                                                              5,
                                                                          itemPadding:
                                                                              EdgeInsets.symmetric(horizontal: 2.0),
                                                                          itemBuilder: (context, _) =>
                                                                              Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Colors.amber,
                                                                          ),
                                                                          onRatingUpdate:
                                                                              (rate) {
                                                                            rating =
                                                                                rate.toInt();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                              snapshot.loadingStatus ==
                                                                      LoadingStatusApp
                                                                          .submitted
                                                                  ? Container()
                                                                  : Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              15),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            80,
                                                                        child:
                                                                            Form(
                                                                          key:
                                                                              _formKey,
                                                                          child:
                                                                              IgnorePointer(
                                                                            ignoring:
                                                                                snapshot.loadingStatus == LoadingStatusApp.loading,
                                                                            child:
                                                                                TextFormField(
//                                                            expands: true,
                                                                              maxLines: null,
                                                                              controller: reviewController,
                                                                              validator: (value) {
                                                                                return value.isEmpty ? tr('screen_order.feedback') : null;
                                                                              },
                                                                              decoration: new InputDecoration(
                                                                                  border: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  hintStyle: TextStyle(color: const Color(0xffb7b7b7), fontWeight: FontWeight.w400, fontFamily: "Avenir-Medium", fontStyle: FontStyle.normal, fontSize: 14.0),
                                                                                  hintText: tr('screen_order.write_feedback')),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                              // Rectangle 2088
                                                              snapshot.loadingStatus ==
                                                                      LoadingStatusApp
                                                                          .submitted
                                                                  ? Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10))
                                                                  : Container(),
                                                              IgnorePointer(
                                                                ignoring: snapshot
                                                                        .loadingStatus ==
                                                                    LoadingStatusApp
                                                                        .loading,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    if (snapshot
                                                                            .loadingStatus ==
                                                                        LoadingStatusApp
                                                                            .submitted) {
                                                                      snapshot.updateLoadingStatus(
                                                                          LoadingStatusApp
                                                                              .success);
                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      if (_formKey
                                                                          .currentState
                                                                          .validate()) {
                                                                        // call feedback api
                                                                        FocusScope.of(context)
                                                                            .requestFocus(FocusNode());

                                                                        snapshot.rateOrder(
                                                                            AddReviewRequest(
                                                                                ratingComment: reviewController.text,
                                                                                ratingValue: rating),
                                                                            snapshot.getOrderListResponse.results[widget.merchantIndex].orderId);
                                                                        reviewController.text =
                                                                            "";
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      AnimatedContainer(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    width: snapshot.loadingStatus ==
                                                                            LoadingStatusApp.loading
                                                                        ? 40
                                                                        : 141,
                                                                    height: 38,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(
                                                                                22)),
                                                                        color: const Color(
                                                                            0xff5091cd)),
                                                                    child: // Submit
                                                                        Center(
                                                                      child: snapshot.loadingStatus ==
                                                                              LoadingStatusApp
                                                                                  .loading
                                                                          ? Container(
                                                                              height: 75,
                                                                              width: 75,
                                                                              child: Image.asset(
                                                                                'assets/images/indicator.gif',
                                                                                height: 75,
                                                                                width: 75,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              snapshot.loadingStatus == LoadingStatusApp.submitted || true ? tr('screen_order.ok') : tr('screen_order.submit'),
                                                                              style: const TextStyle(color: const Color(0xffffffff), fontWeight: FontWeight.w400, fontFamily: "Avenir-Medium", fontStyle: FontStyle.normal, fontSize: 16.0),
                                                                              textAlign: TextAlign.left),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                            );
                                          },
                                          child: IgnorePointer(
                                            ignoring: widget != null
                                                ? snapshot
                                                        .getOrderListResponse
                                                        .results[widget
                                                            .merchantIndex]
                                                        .rating !=
                                                    null
                                                : true,
                                            child: RatingBar(
                                              initialRating: widget != null
                                                  ? snapshot
                                                              .getOrderListResponse
                                                              .results[widget
                                                                  .merchantIndex]
                                                              .rating !=
                                                          null
                                                      ? snapshot
                                                                  .getOrderListResponse
                                                                  .results[widget
                                                                      .merchantIndex]
                                                                  .rating
                                                                  .ratingValue !=
                                                              null
                                                          ? snapshot
                                                              .getOrderListResponse
                                                              .results[widget
                                                                  .merchantIndex]
                                                              .rating
                                                              .ratingValue
                                                              .ceilToDouble()
                                                          : 0
                                                      : 0
                                                  : 0,
                                              minRating: 0,
                                              itemSize: 25,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 1.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              tapOnlyMode: true,
                                              ignoreGestures: true,
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        snapshot.updateOrderId(
                                          snapshot
                                              .getOrderListResponse
                                              .results[widget.merchantIndex]
                                              .orderId,
                                        );
                                        if (snapshot
                                                    .getOrderListResponse
                                                    .results[
                                                        widget.merchantIndex]
                                                    .businessPhones !=
                                                null &&
                                            snapshot
                                                .getOrderListResponse
                                                .results[widget.merchantIndex]
                                                .businessPhones
                                                .isNotEmpty) {
                                          var url =
                                              'tel:${snapshot.getOrderListResponse.results[widget.merchantIndex].businessPhones.first}';
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  tr("new_changes.no_contact"));
                                        }
//                                        Navigator.of(context)
//                                            .pushNamed('/Support');
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.phone,
                                            size: 15,
                                            color: AppColors.icColors,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'new_changes.call',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Avenir-Medium',
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ).tr(),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        Container(
                          height: 0.5,
                          color: Color(0xffe6e6e6),
                        )
                      ],
                    ),
                  ))
            ],
          );
        });
  }
}

class ExpandableContainer extends StatefulWidget {
  bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  _ExpandableContainerState createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        height: widget.expanded ? null : widget.collapsedHeight,
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _ViewModel extends BaseModel<AppState> {
  Function(String orderId) updateOrderId;
  GetOrderListResponse getOrderListResponse;
  Function(AddReviewRequest, String) rateOrder;
  Function(LoadingStatusApp) updateLoadingStatus;
  LoadingStatusApp loadingStatus;

  _ViewModel();

  _ViewModel.build(
      {this.getOrderListResponse,
      this.rateOrder,
      this.loadingStatus,
      this.updateLoadingStatus,
      this.updateOrderId})
      : super(equals: [getOrderListResponse, loadingStatus]);

  @override
  BaseModel fromStore() {
    // TODO: implement fromStore
    return _ViewModel.build(
        rateOrder: (request, orderId) {
          dispatch(AddRatingAPIAction(request: request, orderId: orderId));
        },
        updateLoadingStatus: (loadingStatus) {
          dispatch(ChangeLoadingStatusAction(loadingStatus));
        },
        updateOrderId: (value) {
          dispatch(OrderSupportAction(orderId: value));
        },
        loadingStatus: state.authState.loadingStatus,
        getOrderListResponse: state.productState.getOrderListResponse);
  }
}
