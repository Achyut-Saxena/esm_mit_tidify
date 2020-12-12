import 'package:async_redux/async_redux.dart';
import 'package:eSamudaay/modules/head_categories/actions/categories_action.dart';
import 'package:eSamudaay/modules/head_categories/models/main_categories_response.dart';
import 'package:eSamudaay/modules/home/actions/home_page_actions.dart';
import 'package:eSamudaay/modules/home/models/merchant_response.dart';
import 'package:eSamudaay/modules/store_details/actions/categories_actions.dart';
import 'package:eSamudaay/redux/states/app_state.dart';
import 'package:eSamudaay/reusable_widgets/plain_business_tile.dart';
import 'package:eSamudaay/themes/custom_theme.dart';
import 'package:eSamudaay/utilities/widget_sizes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BusinessesListUnderSelectedCategoryScreen extends StatefulWidget {
  @override
  _BusinessesListUnderSelectedCategoryScreenState createState() =>
      _BusinessesListUnderSelectedCategoryScreenState();
}

class _BusinessesListUnderSelectedCategoryScreenState
    extends State<BusinessesListUnderSelectedCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        model: _ViewModel(),
        onInit: (store) {
          store.dispatchFuture(ClearPreviousCategoryDetailsAction());
          final String bCatId = store
              .state.homeCategoriesState.selectedCategory.categoryId
              .toString();
          store.dispatchFuture(
              GetBusinessesUnderSelectedCategory(categoryId: bCatId));
          store.dispatchFuture(
              GetPreviouslyBoughtBusinessesListUnderSelectedCategoryAction(
                  categoryId: bCatId));
        },
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: CustomTheme.of(context).colors.brandViolet,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.selectedCategory.categoryName ?? '',
                        style: CustomTheme.of(context).textStyles.topTileTitle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        snapshot.selectedCategory.categoryDescription ?? '',
                        style: CustomTheme.of(context).textStyles.body1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSizes.separatorPadding),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppSizes.separatorPadding),
                        child: Text(
                          'home_stores_categories.featured',
                          style: CustomTheme.of(context)
                              .textStyles
                              .sectionHeading2,
                        ).tr()),
                    ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final Business business =
                              snapshot.businessesUnderSelectedCategory[index];
                          return InkWell(
                            onTap: () {
                              snapshot.navigateToBusiness(business);
                            },
                            child: HybridBusinessTileConnector(
                              business: business,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: AppSizes.widgetPadding,
                          );
                        },
                        itemCount:
                            snapshot.businessesUnderSelectedCategory.length),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _ViewModel extends BaseModel<AppState> {
  _ViewModel();

  Function(Business) navigateToBusiness;
  HomePageCategoryResponse selectedCategory;
  List<Business> previouslyBoughtBusinessesUnderSelectedCategory;
  List<Business> businessesUnderSelectedCategory;

  _ViewModel.build(
      {this.selectedCategory,
      this.navigateToBusiness,
      this.businessesUnderSelectedCategory,
      this.previouslyBoughtBusinessesUnderSelectedCategory})
      : super(equals: [
          selectedCategory,
          previouslyBoughtBusinessesUnderSelectedCategory,
          businessesUnderSelectedCategory,
        ]);

  @override
  BaseModel fromStore() {
    return _ViewModel.build(
      selectedCategory: state.homeCategoriesState.selectedCategory,
      previouslyBoughtBusinessesUnderSelectedCategory: state
          .homeCategoriesState.previouslyBoughtBusinessUnderSelectedCategory,
      businessesUnderSelectedCategory:
          state.homeCategoriesState.businessesUnderSelectedCategory,
      navigateToBusiness: (business) {
        dispatch(UpdateSelectedMerchantAction(selectedMerchant: business));
        dispatch(ResetCatalogueAction());
        dispatch(NavigateAction.pushNamed('/StoreDetailsView'));
      },
    );
  }
}
