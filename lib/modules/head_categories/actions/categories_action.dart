import 'dart:async';
import 'package:eSamudaay/modules/head_categories/models/main_categories_response.dart';
import 'package:eSamudaay/modules/home/models/merchant_response.dart';
import 'package:eSamudaay/utilities/URLs.dart';
import 'package:eSamudaay/utilities/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:eSamudaay/redux/states/app_state.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetHomePageCategoriesAction extends ReduxAction<AppState> {
  GetHomePageCategoriesAction();

  @override
  FutureOr<AppState> reduce() async {
    final response = await APIManager.shared.request(
        url: ApiURL.getHomePageCategoriesUrl(state.authState.cluster.clusterId),
        requestType: RequestType.get,
        params: null);

    if (response.status == ResponseStatus.success200) {
      if (response.data != null && response.data is Map) {
        final parsedCategoriesResponse =
            HomePageCategoriesResponse.fromJson(response.data);
        debugPrint(
            'Before putting in state ${parsedCategoriesResponse.catalogCategories.length}');
        return state.copyWith(
            homeCategoriesState: state.homeCategoriesState.copyWith(
          homePageCategories: parsedCategoriesResponse,
        ));
      }
    } else {
      Fluttertoast.showToast(msg: response.data['message']);
    }
    return null;
  }
}

class SelectHomePageCategoryAction extends ReduxAction<AppState> {
  final HomePageCategoryResponse selectedCategory;

  SelectHomePageCategoryAction({@required this.selectedCategory})
      : assert(selectedCategory != null);

  @override
  FutureOr<AppState> reduce() {
    return state.copyWith(
        homeCategoriesState: state.homeCategoriesState
            .copyWith(selectedCategory: selectedCategory));
  }
}

class ClearPreviousCategoryDetailsAction extends ReduxAction<AppState> {

  ClearPreviousCategoryDetailsAction();

  @override
  FutureOr<AppState> reduce() {
    return state.copyWith(
      homeCategoriesState: state.homeCategoriesState.copyWith(
        previouslyBoughtBusinessUnderSelectedCategory: [],
        businessesUnderSelectedCategory: []
      )
    );
  }

}

class GetPreviouslyBoughtBusinessesListAction extends ReduxAction<AppState> {
  GetPreviouslyBoughtBusinessesListAction();

  @override
  FutureOr<AppState> reduce() async {
    final response = await APIManager.shared.request(
        url: ApiURL.getBusinessesUrl,
        requestType: RequestType.get,
        params: {
          "cluster_id": state.authState.cluster.clusterId,
          "ordered": true,
          "ag_orderitems": true,
        });
    if (response.status == ResponseStatus.success200) {
      if (response.data != null &&
          response.data is Map &&
          response.data['results'] != null &&
          response.data['results'] is List) {
        final List<Business> parsedPreviouslyBoughtBusinesses =
            (response.data['results'] as List).map((v) {
          return Business.fromJson(v);
        }).toList();
        return state.copyWith(
            homeCategoriesState: state.homeCategoriesState.copyWith(
          previouslyBoughtBusinesses: parsedPreviouslyBoughtBusinesses,
        ));
      }
    } else {
      Fluttertoast.showToast(msg: response.data['message']);
    }
    return null;
  }
}

class GetPreviouslyBoughtBusinessesListUnderSelectedCategoryAction
    extends ReduxAction<AppState> {
  final String categoryId;

  GetPreviouslyBoughtBusinessesListUnderSelectedCategoryAction(
      {@required this.categoryId})
      : assert(categoryId != null);

  @override
  FutureOr<AppState> reduce() async {
    final response = await APIManager.shared.request(
        url: ApiURL.getBusinessesUrl,
        requestType: RequestType.get,
        params: {
          "cluster_id": state.authState.cluster.clusterId,
          "ordered": true,
          "ag_orderitems": true,
          "bcat_id": categoryId
        });
    if (response.status == ResponseStatus.success200) {
      if (response.data != null &&
          response.data is Map &&
          response.data['results'] != null &&
          response.data['results'] is List) {
        final List<Business>
            parsedPreviouslyBoughtBusinessesUnderSelectedCategory =
            (response.data['results'] as List).map((v) {
          return Business.fromJson(v);
        }).toList();
        return state.copyWith(
            homeCategoriesState: state.homeCategoriesState.copyWith(
          previouslyBoughtBusinessUnderSelectedCategory:
              parsedPreviouslyBoughtBusinessesUnderSelectedCategory,
        ));
      }
    } else {
      Fluttertoast.showToast(msg: response.data['message']);
    }
    return null;
  }
}

class GetBusinessesUnderSelectedCategory extends ReduxAction<AppState> {
  final String categoryId;

  GetBusinessesUnderSelectedCategory({@required this.categoryId})
      : assert(categoryId != null);

  @override
  FutureOr<AppState> reduce() async {
    final response = await APIManager.shared.request(
        url: ApiURL.getBusinessesUrl,
        requestType: RequestType.get,
        params: {
          "bcat": categoryId,
          "cluster_id": state.authState.cluster.clusterId
        });
    if (response.status == ResponseStatus.success200) {
      if (response.data != null &&
          response.data is Map &&
          response.data['results'] != null &&
          response.data['results'] is List) {
        final List<Business> businessesUnderSelectedCategory =
            (response.data['results'] as List).map((v) {
          return Business.fromJson(v);
        }).toList();
        return state.copyWith(
            homeCategoriesState: state.homeCategoriesState.copyWith(
          businessesUnderSelectedCategory: businessesUnderSelectedCategory,
        ));
      }
    } else {
      Fluttertoast.showToast(msg: response.data['message']);
    }
    return null;
  }
}
