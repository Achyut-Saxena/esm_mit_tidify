import 'package:async_redux/async_redux.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esamudaayapp/modules/accounts/views/accounts_view.dart';
import 'package:esamudaayapp/modules/home/actions/home_page_actions.dart';
import 'package:esamudaayapp/modules/home/models/merchant_response.dart';
import 'package:esamudaayapp/modules/home/views/home_page_main_view.dart';
import 'package:esamudaayapp/modules/login/actions/login_actions.dart';
import 'package:esamudaayapp/modules/orders/views/orders_View.dart';
import 'package:esamudaayapp/modules/search/views/Search_View.dart';
import 'package:esamudaayapp/redux/states/app_state.dart';
import 'package:esamudaayapp/utilities/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomeView extends StatefulWidget {
  MyHomeView({
    Key key,
  }) : super(key: key);
  @override
  _MyHomeViewState createState() => _MyHomeViewState();
}

class _MyHomeViewState extends State<MyHomeView> with TickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();

  final Key keyOne = PageStorageKey('dailyLog');

  final Key keyTwo = PageStorageKey('projects');

  final Key keyThree = PageStorageKey('queue');

  GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

  Widget currentPage({index: int}) {
    if (index == 0) {
      return HomePageMainView(
//        key: keyOne,
          );
    } else if (index == 1) {
      return ProductSearchView();
//      return CartView(
//        key: keyTwo,
//      );
    } else if (index == 2) {
      return OrdersView();
//      return ProfileView(
//        key: keyThree,
//      );
    } else {
      return AccountsView();
//      return ProductDetailsView();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: StoreConnector<AppState, _ViewModel>(
          model: _ViewModel(),
          onInit: (store) async {
            store.dispatchFuture(GetClusterDetailsAction()).then((value) {
              store.dispatch(GetMerchantDetails());
//              store.dispatch(GetBannerDetailsAction());
            });
            store.dispatch(GetUserFromLocalStorageAction());
          },
          builder: (context, snapshot) {
            return BottomNavigationBar(
              currentIndex: snapshot.currentIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/path330.png'),
                    color: Colors.black,
                  ),
                  activeIcon: ImageIcon(
                    AssetImage('assets/images/path330.png'),
                    color: AppColors.mainColor,
                  ),
                  title: new Text(
                    tr('screen_home.tab_bar.store'),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/search_icon.png'),
                    color: Colors.black,
                  ),
                  activeIcon: ImageIcon(
                    AssetImage('assets/images/search_icon.png'),
                    color: AppColors.mainColor,
                  ),
                  title: new Text(
                    tr('screen_home.tab_bar.search'),
                  ),
                ),
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/images/path338.png'),
                      color: Colors.black,
                    ),
                    activeIcon: ImageIcon(
                      AssetImage('assets/images/path338.png'),
                      color: AppColors.mainColor,
                    ),
                    title: Text(
                      tr('screen_home.tab_bar.orders'),
                    )),
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/images/path5.png'),
                      color: Colors.black,
                    ),
                    activeIcon: ImageIcon(
                      AssetImage('assets/images/path5.png'),
                      color: AppColors.mainColor,
                    ),
                    title: Text(
                      'screen_home.tab_bar.account',
                    ).tr())
              ],
              onTap: (index) {
                snapshot.updateCurrentIndex(index);
              },
            );
          }),
      body: StoreConnector<AppState, _ViewModel>(
          model: _ViewModel(),
          builder: (context, snapshot) {
            return PageStorage(
                bucket: bucket,
                child: currentPage(index: snapshot.currentIndex));
          }),
    );
  }

  double height(BuildContext context, int totalItemCount) {
    var totalHeight = MediaQuery.of(context).size.height;
    var emptySpace = totalHeight - 250 + 150;
    var numberOfItemsInEmptySpace = (emptySpace ~/ 150).toInt();
    var remainingItemCount = totalItemCount - numberOfItemsInEmptySpace;
    return emptySpace + (130 * remainingItemCount);
  }
}

class _ViewModel extends BaseModel<AppState> {
  _ViewModel();
  Function navigateToAddAddressPage;
  Function navigateToProductSearch;
  Function updateCurrentIndex;
  VoidCallback getMerchants;
  Function(Business) updateSelectedMerchant;
  int currentIndex;
  _ViewModel.build(
      {this.navigateToAddAddressPage,
      this.getMerchants,
      this.navigateToProductSearch,
      this.updateCurrentIndex,
      this.updateSelectedMerchant,
      this.currentIndex})
      : super(equals: [currentIndex]);

  @override
  BaseModel fromStore() {
    // TODO: implement fromStore
    return _ViewModel.build(
        updateSelectedMerchant: (merchant) {
          dispatch(UpdateSelectedMerchantAction(selectedMerchant: merchant));
        },
        getMerchants: () {
          dispatch(GetMerchantDetails());
        },
        navigateToAddAddressPage: () {
          dispatch(NavigateAction.pushNamed('/AddAddressView'));
        },
        navigateToProductSearch: () {
          dispatch(NavigateAction.pushNamed('/ProductSearchView'));
        },
        updateCurrentIndex: (index) {
          dispatch(UpdateSelectedTabAction(index));
        },
        currentIndex: state.homePageState.currentIndex);
  }
}