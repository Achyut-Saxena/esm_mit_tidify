import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComponentsLoadingState {
  final bool videosLoading;
  final bool circleBannersLoading;
  final bool circleTopBannerLoading;
  final bool circleCategoriesLoading;
  final bool businessListLoading;
  final bool nearbyCirclesLoading;
  final bool businessesUnderCategoryLoading;
  final bool circleDetailsLoading;
  final bool savedCirclesLoading;
  final bool suggestedCirclesLoading;

  ComponentsLoadingState(
      {@required this.videosLoading,
      @required this.circleDetailsLoading,
      @required this.circleBannersLoading,
      @required this.savedCirclesLoading,
      @required this.suggestedCirclesLoading,
      @required this.circleTopBannerLoading,
      @required this.businessesUnderCategoryLoading,
      @required this.circleCategoriesLoading,
      @required this.nearbyCirclesLoading,
      @required this.businessListLoading});

  factory ComponentsLoadingState.initial() {
    return ComponentsLoadingState(
        videosLoading: false,
        savedCirclesLoading: false,
        suggestedCirclesLoading: false,
        circleDetailsLoading: false,
        businessesUnderCategoryLoading: false,
        circleBannersLoading: false,
        circleTopBannerLoading: false,
        nearbyCirclesLoading: false,
        circleCategoriesLoading: false,
        businessListLoading: false);
  }

  ComponentsLoadingState copyWith(
      {bool videosLoading,
      bool circleBannersLoading,
      bool circleTopBannerLoading,
      bool circleCategoriesLoading,
      bool businessesUnderCategoryLoading,
      bool nearbyCirclesLoading,
      bool circleDetailsLoading,
      bool savedCirclesLoading,
      bool suggestedCirclesLoading,
      bool businessListLoading}) {
    return ComponentsLoadingState(
        savedCirclesLoading: savedCirclesLoading ?? this.savedCirclesLoading,
        suggestedCirclesLoading:
            suggestedCirclesLoading ?? this.suggestedCirclesLoading,
        circleDetailsLoading: circleDetailsLoading ?? this.circleDetailsLoading,
        businessesUnderCategoryLoading: businessesUnderCategoryLoading ??
            this.businessesUnderCategoryLoading,
        nearbyCirclesLoading: nearbyCirclesLoading ?? this.nearbyCirclesLoading,
        videosLoading: videosLoading ?? this.videosLoading,
        circleBannersLoading: circleBannersLoading ?? this.circleBannersLoading,
        circleTopBannerLoading:
            circleTopBannerLoading ?? this.circleTopBannerLoading,
        circleCategoriesLoading:
            circleCategoriesLoading ?? this.circleCategoriesLoading,
        businessListLoading: businessListLoading ?? this.businessListLoading);
  }
}
