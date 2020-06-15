import 'package:async_redux/async_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esamudaayapp/models/loading_status.dart';
import 'package:esamudaayapp/modules/cart/actions/cart_actions.dart';
import 'package:esamudaayapp/modules/home/actions/home_page_actions.dart';
import 'package:esamudaayapp/modules/home/models/cluster.dart';
import 'package:esamudaayapp/modules/home/models/merchant_response.dart';
import 'package:esamudaayapp/modules/home/views/cart_bottom_navigation_view.dart';
import 'package:esamudaayapp/modules/login/actions/login_actions.dart';
import 'package:esamudaayapp/modules/register/model/register_request_model.dart';
import 'package:esamudaayapp/redux/states/app_state.dart';
import 'package:esamudaayapp/utilities/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HomePageMainView extends StatefulWidget {
  @override
  _HomePageMainViewState createState() => _HomePageMainViewState();
}

class _HomePageMainViewState extends State<HomePageMainView> {
  String address = "";
  @override
  Widget build(BuildContext context) {
    return UserExceptionDialog<AppState>(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          centerTitle: false,
          title: StoreConnector<AppState, _ViewModel>(
              model: _ViewModel(),
              builder: (context, snapshot) {
                return Text(snapshot?.cluster?.clusterName ?? "",
                    style: TextStyle(
                      fontFamily: 'JTLeonor',
                      color: Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ));
              }),
          leading: ImageIcon(
            AssetImage('assets/images/location2.png'),
            color: AppColors.mainColor,
          ),
          actions: <Widget>[
            StoreConnector<AppState, _ViewModel>(
                model: _ViewModel(),
                builder: (context, snapshot) {
                  address = snapshot.userAddress;
                  return InkWell(
                    onTap: () {
                      snapshot.navigateToCart();
                    },
                    child: NavigationCartItem(
                      icon: ImageIcon(
                        AssetImage('assets/images/bag2.png'),
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),
            StoreConnector<AppState, _ViewModel>(
                onInit: (store) {
//                store.dispatch(GetLocationAction());
                  store.dispatch(GetCartFromLocal());
                  store.dispatch(GetUserFromLocalStorageAction());
                },
                model: _ViewModel(),
                builder: (context, snapshot) {
                  return IconButton(
                      icon: ImageIcon(
                        AssetImage('assets/images/search_icon.png'),
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        snapshot.navigateToProductSearch();
                      });
                }),
            NavigationNotificationItem(
              icon: Icon(
                Icons.notifications_none,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        body: StoreConnector<AppState, _ViewModel>(
            model: _ViewModel(),
            builder: (context, snapshot) {
              return ModalProgressHUD(
                inAsyncCall: snapshot.loadingStatus == LoadingStatus.loading &&
                    snapshot.merchants.isEmpty,
                child: ListView(
                  padding: EdgeInsets.all(15.0),
                  children: <Widget>[
                    snapshot.banners.isEmpty
                        ? Container()
                        : CarouselSlider(
                            enlargeCenterPage: true,
                            items: snapshot.banners.isEmpty
                                ? [Container()]
                                : snapshot.banners
                                    .map((banner) => Padding(
                                          padding: const EdgeInsets.only(
                                              left: 2.0, right: 2.0),
                                          child: InkWell(
                                            onTap: () {},
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                              child: CachedNetworkImage(
                                                  height: 500.0,
                                                  fit: BoxFit.cover,
                                                  imageUrl: banner.photoUrl,
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Center(
                                                        child:
                                                            Icon(Icons.error),
                                                      )),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            height: 200,
                            aspectRatio: 16 / 9,
                            viewportFraction: 1.0,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            pauseAutoPlayOnTouch: Duration(seconds: 10),
//                  enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                    // Stores near you
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text('screen_home.store_near_you',
                              style: const TextStyle(
                                  color: const Color(0xff2c2c2c),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Avenir",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.0),
                              textAlign: TextAlign.left)
                          .tr(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                snapshot.updateSelectedMerchant(
                                    snapshot.merchants[index]);
                                snapshot.navigateToStoreDetailsPage();
                              },
                              child: StoresListView(
                                items: snapshot.merchants[index]?.description ??
                                    "",
                                shopImage: snapshot.merchants[index].images ==
                                            null ||
                                        snapshot.merchants[index].images.isEmpty
                                    ? null
                                    : snapshot
                                        .merchants[index].images.first.photoUrl,
                                name: snapshot.merchants[index].businessName,
                                deliveryStatus:
                                    snapshot.merchants[index].hasDelivery,
                                shopClosed: snapshot.merchants[index].isOpen,
                              ));
                        },
                        itemCount: snapshot.merchants.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 10,
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class StoresListView extends StatelessWidget {
  final String shopImage;
  final String name;
  final String items;
  final bool deliveryStatus;
  final bool shopClosed;

  const StoresListView(
      {Key key,
      this.shopImage,
      this.name,
      this.deliveryStatus,
      this.items,
      this.shopClosed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 79,
            height: 79,
            margin: new EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      shopClosed ? Colors.grey : Colors.transparent,
                      BlendMode.saturation),
                  child: shopImage == null
                      ? Image.asset(
                          'assets/images/shop1.png',
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          height: 500.0,
                          fit: BoxFit.cover,
                          imageUrl: shopImage,
                          placeholder: (context, url) => Icon(
                                Icons.image,
                                size: 30,
                              ),
                          errorWidget: (context, url, error) => Center(
                                child: Icon(Icons.error),
                              )),
                ),
                shopClosed
                    ? Positioned(
                        bottom: 5,
                        child: // Out of stock
                            Text('common.closed',
                                    style: const TextStyle(
                                        color: const Color(0xfff51818),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Avenir",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12.0),
                                    textAlign: TextAlign.left)
                                .tr())
                    : Container()
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name,
                      style: const TextStyle(
                          color: const Color(0xff2c2c2c),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Avenir",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.left),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(items,
                        style: const TextStyle(
                            color: const Color(0xff7c7c7c),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Avenir",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.left),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: deliveryStatus
                            ? ImageIcon(
                                AssetImage('assets/images/delivery.png'),
                                color: shopClosed
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              )
                            : shopClosed
                                ? Image.asset('assets/images/group236.png')
                                : Image.asset('assets/images/no_delivery.png'),
                      ),
                      Text(
                          deliveryStatus
                              ? tr("shop.delivery_ok")
                              : tr("shop.delivery_no"),
                          style: const TextStyle(
                              color: const Color(0xff7c7c7c),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Avenir",
                              fontStyle: FontStyle.normal,
                              fontSize: 14.0),
                          textAlign: TextAlign.left),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ViewModel extends BaseModel<AppState> {
  _ViewModel();
  String userAddress;
  Function navigateToAddAddressPage;
  Function navigateToProductSearch;
  Function navigateToStoreDetailsPage;
  Function updateCurrentIndex;
  VoidCallback navigateToCart;
  Function(Business) updateSelectedMerchant;
  int currentIndex;
  List<Business> merchants;
  List<Photo> banners;
  LoadingStatus loadingStatus;
  Cluster cluster;
  _ViewModel.build(
      {this.navigateToAddAddressPage,
      this.navigateToCart,
      this.cluster,
      this.banners,
      this.navigateToProductSearch,
      this.navigateToStoreDetailsPage,
      this.updateCurrentIndex,
      this.currentIndex,
      this.loadingStatus,
      this.merchants,
      this.userAddress,
      this.updateSelectedMerchant})
      : super(equals: [
          currentIndex,
          merchants,
          banners,
          loadingStatus,
          userAddress,
          cluster
        ]);

  @override
  BaseModel fromStore() {
    // TODO: implement fromStore
    return _ViewModel.build(
        cluster: state.authState.cluster,
        userAddress:
            state.authState.user != null ? state.authState.user.address : "",
        loadingStatus: state.authState.loadingStatus,
        merchants: state.homePageState.merchants,
        banners: state.homePageState.banners,
        navigateToCart: () {
          dispatch(NavigateAction.pushNamed('/CartView'));
        },
        updateSelectedMerchant: (merchant) {
          dispatch(UpdateSelectedMerchantAction(selectedMerchant: merchant));
        },
        navigateToStoreDetailsPage: () {
          dispatch(NavigateAction.pushNamed('/StoreDetailsView'));
        },
        navigateToAddAddressPage: () {
          dispatch(NavigateAction.pushNamed('/AddAddressView'));
        },
        navigateToProductSearch: () {
          dispatch(UpdateSelectedTabAction(1));
        },
        currentIndex: state.homePageState.currentIndex);
  }
}
