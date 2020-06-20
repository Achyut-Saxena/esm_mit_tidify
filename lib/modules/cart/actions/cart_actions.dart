import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:esamudaayapp/models/loading_status.dart';
import 'package:esamudaayapp/modules/cart/models/cart_model.dart';
import 'package:esamudaayapp/modules/cart/models/charge_details_response.dart';
import 'package:esamudaayapp/modules/home/actions/home_page_actions.dart';
import 'package:esamudaayapp/modules/store_details/actions/store_actions.dart';
import 'package:esamudaayapp/modules/store_details/models/catalog_search_models.dart';
import 'package:esamudaayapp/redux/actions/general_actions.dart';
import 'package:esamudaayapp/redux/states/app_state.dart';
import 'package:esamudaayapp/repository/cart_datasourse.dart';
import 'package:esamudaayapp/utilities/URLs.dart';
import 'package:esamudaayapp/utilities/api_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetCartFromLocal extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    List<Product> localCartList = await CartDataSource.getListOfCartWith();
    var merchant = await CartDataSource.getListOfMerchants();

    return state.copyWith(
        productState: state.productState.copyWith(
            localCartItems: localCartList,
            selectedMerchant: state.productState.selectedMerchand != null
                ? state.productState.selectedMerchand
                : merchant.isEmpty ? null : merchant.first));
  }
}

class UpdateCartListAction extends ReduxAction<AppState> {
  final List<Product> localCart;

  UpdateCartListAction({this.localCart});
  @override
  FutureOr<AppState> reduce() {
    // TODO: implement reduce
    return state.copyWith(
        productState: state.productState.copyWith(localCartItems: localCart));
  }
}

class AddToCartLocalAction extends ReduxAction<AppState> {
  final Product product;
  final BuildContext context;
  AddToCartLocalAction({this.product, this.context});
  @override
  FutureOr<AppState> reduce() async {
    var merchant = await CartDataSource.getListOfMerchants();
    if (merchant.isNotEmpty) {
      if (merchant.first.businessId !=
          state.productState.selectedMerchand.businessId) {
        showDialog(
            context: context,
            child: AlertDialog(
              title: Text("E-samudaay"),
              content: Text(
                  'Items from other store will be cleared. Would you like to continue.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Continue'),
                  onPressed: () async {
                    await CartDataSource.deleteAllMerchants();
                    await CartDataSource.deleteAll();
//                    var merchant = MerchantLocal(
//                        merchantID:
//                            state.productState.selectedMerchand.merchantID,
//                        cardViewLine2:
//                            state.productState.selectedMerchand.cardViewLine2,
//                        displayPicture:
//                            state.productState.selectedMerchand.displayPicture,
//                        address1: state
//                            .productState.selectedMerchand.address.addressLine1,
//                        address2: state
//                            .productState.selectedMerchand.address.addressLine2,
//                        shopName: state.productState.selectedMerchand.shopName);
//                    merchant.flag = state.productState.selectedMerchand.flags
//                            .contains('DELIVERY')
//                        ? 'DELIVERY'
//                        : "";
                    await CartDataSource.insertToMerchants(
                        business: state.productState.selectedMerchand);
                    bool isInCart = await CartDataSource.isAvailableInCart(
                        id: product.productId.toString());
                    if (isInCart) {
                      await CartDataSource.update(product);
                    } else {
                      await CartDataSource.insert(product: product);
                    }
                    List<Product> allCartNewList = [];
                    List<Product> allCartItems =
                        state.productState.productListingDataSource;
                    allCartItems.forEach((value) {
                      if (value.productId == product.productId) {
                        value.count = product.count;
                      }
                      allCartNewList.add(value);
                    });
                    var localCartItems =
                        await CartDataSource.getListOfCartWith();
                    Navigator.pop(context);
                    dispatch(UpdateProductListingDataAction(
                        listingData: allCartNewList));
                    dispatch(UpdateCartListAction(localCart: localCartItems));
                  },
                )
              ],
            ));
      } else {
        await CartDataSource.deleteAllMerchants();
        await CartDataSource.insertToMerchants(
            business: state.productState.selectedMerchand);
        bool isInCart = await CartDataSource.isAvailableInCart(
            id: product.productId.toString());
        if (isInCart) {
          await CartDataSource.update(product);
        } else {
          await CartDataSource.insert(product: product);
        }
        List<Product> allCartNewList = [];
        List<Product> allCartItems =
            state.productState.productListingDataSource;
        allCartItems.forEach((value) {
          if (value.productId == product.productId) {
            value.count = product.count;
          }
          allCartNewList.add(value);
        });
        var localCartItems = await CartDataSource.getListOfCartWith();

        return state.copyWith(
            productState: state.productState.copyWith(
          productListingDataSource: allCartNewList,
          localCartItems: localCartItems,
        ));
      }
    } else {
      await CartDataSource.deleteAllMerchants();
      await CartDataSource.insertToMerchants(
          business: state.productState.selectedMerchand);
      bool isInCart = await CartDataSource.isAvailableInCart(
          id: product.productId.toString());
      if (isInCart) {
        await CartDataSource.update(product);
      } else {
        await CartDataSource.insert(product: product);
      }
      List<Product> allCartNewList = [];
      List<Product> allCartItems = state.productState.productListingDataSource;
      allCartItems.forEach((value) {
        if (value.productId == product.productId) {
          value.count = product.count;
        }
        allCartNewList.add(value);
      });
      var localCartItems = await CartDataSource.getListOfCartWith();

      return state.copyWith(
          productState: state.productState.copyWith(
        productListingDataSource: allCartNewList,
        localCartItems: localCartItems,
      ));
    }
    return null;
  }
}

class RemoveFromCartLocalAction extends ReduxAction<AppState> {
  final Product product;

  RemoveFromCartLocalAction({this.product});
  @override
  FutureOr<AppState> reduce() async {
    bool isInCart = await CartDataSource.isAvailableInCart(
        id: product.productId.toString());
    if (isInCart) {
      if (product.count == 0.0) {
        await CartDataSource.delete(product.productId.toString());
      } else {
        await CartDataSource.update(product);
      }
    }
    List<Product> allItemsNewList = [];
    List<Product> allItemList = state.productState.productListingDataSource;
//    Item selectedProduct = state.productState.selectedProduct;

    allItemList.forEach((value) {
      if (value.productId == product.productId) {
        value.count = product.count;
      }
//      if (state.productState?.selectedProduct != null &&
//          state.productState.selectedProduct.id == value.id) {
//        selectedProduct.inCart = product.inCart;
//      }
      allItemsNewList.add(value);
    });
    var localCartItems = await CartDataSource.getListOfCartWith();
    if (localCartItems.isEmpty) {
      await CartDataSource.deleteAllMerchants();
    }
    return state.copyWith(
        productState: state.productState.copyWith(
      productListingDataSource: allItemsNewList,
      localCartItems: localCartItems,
//            selectedProduct: state.productState?.selectedProduct
//                ?.copyWith(inCart: selectedProduct?.inCart)
    ));
  }
}

class PlaceOrderAction extends ReduxAction<AppState> {
  final PlaceOrderRequest request;

  PlaceOrderAction({this.request});

  @override
  FutureOr<AppState> reduce() async {
    print(request.toJson());
    var response = await APIManager.shared.request(
        url: ApiURL.placeOrderUrl,
        params: request.toJson(),
        requestType: RequestType.post);

    if (response.status == ResponseStatus.success200) {
//      request.order.status = "UNCONFIRMED";
      var responseModel = PlaceOrderResponse.fromJson(response.data);

      Fluttertoast.showToast(msg: 'Order Placed');
      await CartDataSource.deleteAllMerchants();
      await CartDataSource.deleteAll();
      dispatch(GetCartFromLocal());
      dispatch(UpdateSelectedTabAction(1));
      dispatch(NavigateAction.pushNamedAndRemoveAll("/myHomeView"));
      return state.copyWith(
          productState:
              state.productState.copyWith(placeOrderResponse: responseModel));
    } else {
//      request.order.status = "COMPLETED";
      Fluttertoast.showToast(msg: response.data['message']);
    }
    return null;
  }

  void before() => dispatch(ChangeLoadingStatusAction(LoadingStatus.loading));

  void after() => dispatch(ChangeLoadingStatusAction(LoadingStatus.success));
}

class GetOrderTaxAction extends ReduxAction<AppState> {
  @override
  FutureOr<AppState> reduce() async {
    var response = await APIManager.shared.request(
        url: ApiURL.getBusinessesUrl +
            "${state.productState.selectedMerchand.businessId}" +
            "/charges",
        params: {"": ""},
        requestType: RequestType.get);
    if (response.status == ResponseStatus.success200) {
      List<Charge> charge = new List<Charge>();
      response.data.forEach((v) {
        charge.add(new Charge.fromJson(v));
      });
      return state.copyWith(
          productState: state.productState.copyWith(charges: charge));
    } else {
      Fluttertoast.showToast(msg: response.data['message']);
      return null;
    }
  }

  void before() => dispatch(ChangeLoadingStatusAction(LoadingStatus.loading));

  void after() => dispatch(ChangeLoadingStatusAction(LoadingStatus.success));
}
