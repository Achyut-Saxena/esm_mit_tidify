import 'package:async_redux/async_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esamudaayapp/main.dart';
import 'package:esamudaayapp/models/loading_status.dart';
import 'package:esamudaayapp/modules/cart/actions/cart_actions.dart';
import 'package:esamudaayapp/modules/cart/views/cart_bottom_view.dart';
import 'package:esamudaayapp/modules/cart/views/cart_view.dart';
import 'package:esamudaayapp/modules/home/models/category_response.dart';
import 'package:esamudaayapp/modules/home/models/merchant_response.dart';
import 'package:esamudaayapp/modules/store_details/actions/store_actions.dart';
import 'package:esamudaayapp/modules/store_details/models/catalog_search_models.dart';
import 'package:esamudaayapp/redux/states/app_state.dart';
import 'package:esamudaayapp/store.dart';
import 'package:esamudaayapp/utilities/colors.dart';
import 'package:esamudaayapp/utilities/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/easy_localization.dart';

class StoreProductListingView extends StatefulWidget {
  @override
  _StoreProductListingViewState createState() =>
      _StoreProductListingViewState();
}

class _StoreProductListingViewState extends State<StoreProductListingView>
    with TickerProviderStateMixin, RouteAware {
  TextEditingController _controller = TextEditingController();

  TabController controller;
  int _currentPosition = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPopNext() {
    store.dispatch(UpdateProductListingDataAction(
        listingData: store.state.productState.productListingDataSource));
    super.didPopNext();
  }

  @override
  void initState() {
    store.state.productState.categories.asMap().forEach((index, a) {
      if (a.categoryId ==
          store.state.productState.selectedCategory.categoryId) {
        _currentPosition = index;
      }
    });
    controller = TabController(
      length: store.state.productState.categories.length,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(() {
      if (!controller.indexIsChanging) {
        if (controller.index != 0) {
          store.dispatch(UpdateSelectedCategoryAction(
              selectedCategory:
                  store.state.productState.categories[controller.index]));
          store.dispatch(UpdateProductListingDataAction(listingData: []));
          store.dispatch(GetCatalogDetailsAction());
        } else {
          store.dispatch(UpdateSelectedCategoryAction(
              selectedCategory:
                  store.state.productState.categories[controller.index]));
          store.dispatch(GetCatalogDetailsAction());
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.icColors,
          ),
        ),
        title: StoreConnector<AppState, _ViewModel>(
            model: _ViewModel(),
            builder: (context, snapshot) {
              return Text(
                snapshot.selectedCategory.categoryName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
      ),
      body: StoreConnector<AppState, _ViewModel>(
          model: _ViewModel(),
          builder: (context, snapshot) {
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 20, right: 20, bottom: 20),
                    child: new TextField(
                      controller: _controller,

//          autofocus: true,
                      decoration: new InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.icColors,
                          ),
                          hintText: "Search for item",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: new BorderSide(
                                color: AppColors.icColors,
                              ))),
                      onSubmitted: (String value) {
                        _controller.text = "";
                        snapshot.updateProductList(snapshot.productTempListing);
                      },
                      onChanged: (text) {
                        if (snapshot.productTempListing.isEmpty) {
                          snapshot.updateTempProductList(snapshot.products);
                        }
                        var filteredResult =
                            snapshot.productTempListing.where((product) {
                          return product.productName
                              .toLowerCase()
                              .contains(text.toLowerCase());
                        }).toList();
                        snapshot.updateProductList(filteredResult);
                      },
                    ),
                  ),
                  Container(
                    height: 50,
                    child: TabBar(
                      isScrollable: true,
                      controller: controller,
                      labelStyle: TextStyle(
                          color: const Color(0xff000000),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Avenir",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                      unselectedLabelStyle: TextStyle(
                          color: const Color(0xff9f9f9f),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Avenir",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                      labelColor: Color(0xff000000),
                      unselectedLabelColor: Color(0xff9f9f9f),
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: (index) {
                        if (index != 0) {
                          snapshot.updateProductList([]);
                        }
                      },
                      tabs: List.generate(
                        snapshot.categories.length,
                        (index) => // All
                            Container(
                          height: 50,
                          child: Center(
                            child: Text(snapshot.categories[index].categoryName,
                                textAlign: TextAlign.left),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ModalProgressHUD(
                      inAsyncCall:
                          snapshot.loadingStatus == LoadingStatus.loading,
                      opacity: 0,
                      child: TabBarView(
                        controller: controller,
//                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(
                          snapshot.categories.length,
                          (index) => snapshot.products.isEmpty
                              ? snapshot.loadingStatus == LoadingStatus.loading
                                  ? Container()
                                  : EmptyViewProduct()
                              : ListView.separated(
                                  padding: EdgeInsets.all(15),
                                  itemCount: snapshot.products.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      height: 15,
                                    );
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ProductListingItemView(
                                      index: index,
                                      imageLink: snapshot.selectedCategory
                                          .images.first.photoUrl,
                                      item: snapshot.products[index],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    height: snapshot.localCartListing.isEmpty ? 0 : 86,
                    duration: Duration(milliseconds: 300),
                    child: BottomView(
                      storeName: snapshot.selectedMerchant?.shopName ?? "",
                      height: snapshot.localCartListing.isEmpty ? 0 : 86,
                      buttonTitle: "VIEW ITEMS",
                      didPressButton: () {
                        snapshot.navigateToCart();
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class EmptyViewProduct extends StatelessWidget {
  const EmptyViewProduct({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ClipPath(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.45,
                      color: const Color(0xfff0f0f0),
                    ),
                    clipper: CustomClipPath(),
                  ),
                ),
                Positioned(
                    bottom: 20,
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: Image.asset(
                      'assets/images/clipart.png',
                      fit: BoxFit.cover,
                    )),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text('screen_order.empty_pro',
                    style: const TextStyle(
                        color: const Color(0xff1f1f1f),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Avenir",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                    textAlign: TextAlign.left)
                .tr(),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30),
              child: Text('screen_order.empty_pro_hint',
                      style: const TextStyle(
                          color: const Color(0xff6f6d6d),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Avenir",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.center)
                  .tr(),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModel extends BaseModel<AppState> {
  Function navigateToCart;
  List<Product> products;
  LoadingStatus loadingStatus;
  List<Product> localCartListing;
  List<Product> productTempListing;
  Merchants selectedMerchant;
  List<CategoriesNew> categories;
  CategoriesNew selectedCategory;
  Function(Product, BuildContext) addToCart;
  Function(Product) removeFromCart;
  Function(String, String) getProducts;
  Function(CategoriesNew) updateSelectedCategory;
  Function(List<Product>) updateTempProductList;
  Function(List<Product>) updateProductList;

  _ViewModel();

  _ViewModel.build(
      {this.navigateToCart,
      this.updateSelectedCategory,
      this.loadingStatus,
      this.selectedCategory,
      this.products,
      this.addToCart,
      this.removeFromCart,
      this.categories,
      this.localCartListing,
      this.getProducts,
      this.productTempListing,
      this.updateTempProductList,
      this.updateProductList,
      this.selectedMerchant})
      : super(equals: [
          products,
          localCartListing,
          selectedMerchant,
          loadingStatus,
          productTempListing,
          selectedCategory,
          categories
        ]);
  @override
  BaseModel fromStore() {
    // TODO: implement fromStore
    return _ViewModel.build(
        addToCart: (item, context) {
          dispatch(AddToCartLocalAction(product: item, context: context));
        },
        removeFromCart: (item) {
          dispatch(RemoveFromCartLocalAction(product: item));
        },
        navigateToCart: () {
          dispatch(NavigateAction.pushNamed('/CartView'));
        },
        getProducts: (categoryId, merchantId) {
          dispatch(UpdateProductListingDataAction(listingData: []));
          dispatch(GetCatalogDetailsAction());
        },
        updateSelectedCategory: (category) {
          dispatch(UpdateSelectedCategoryAction(selectedCategory: category));
        },
        updateTempProductList: (list) {
          dispatch(UpdateProductListingTempDataAction(listingData: list));
        },
        updateProductList: (list) {
          dispatch(UpdateProductListingDataAction(listingData: list));
        },
        categories: state.productState.categories,
        productTempListing: state.productState.productListingTempDataSource,
        loadingStatus: state.authState.loadingStatus,
        selectedCategory: state.productState.selectedCategory,

//        selectedMerchant: state.productState.selectedMerchand,
        products: state.productState.productListingDataSource,
        localCartListing: state.productState.localCartItems);
  }
}

class ProductListingItemView extends StatelessWidget {
  final int index;
  final Product item;
  final String imageLink;
  const ProductListingItemView({Key key, this.index, this.item, this.imageLink})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        model: _ViewModel(),
        builder: (context, snapshot) {
          bool isOutOfStock = item.inStock;
          return IgnorePointer(
            ignoring: !isOutOfStock,
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(
                    left: 13,
                    right: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe7eaf0),
                        offset: Offset(0, 8),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ColorFiltered(
                        child: item.images == null
                            ? Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: CachedNetworkImage(
                                    fit: BoxFit.cover,
//                                                  height: 80,
                                    imageUrl: imageLink,
                                    placeholder: (context, url) =>
                                        CupertinoActivityIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                          child: Icon(Icons.error),
                                        )),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CachedNetworkImage(
                                    height: 500.0,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        item?.images?.first?.photoUrl ?? "",
                                    placeholder: (context, url) =>
                                        CupertinoActivityIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Padding(
                                          padding: const EdgeInsets.all(25.0),
                                          child: Image.network(
                                            imageLink,
                                          ),
                                        )),
                              ),
                        colorFilter: ColorFilter.mode(
                            !isOutOfStock ? Colors.grey : Colors.transparent,
                            BlendMode.saturation),
                      ),
                      !isOutOfStock
                          ? Positioned(
                              bottom: 5,
                              child: // Out of stock
                                  Text("Out of stock",
                                      style: const TextStyle(
                                          color: const Color(0xfff51818),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Avenir",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 12.0),
                                      textAlign: TextAlign.left))
                          : Container()
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(item.productName,
                            style: const TextStyle(
                                color: const Color(0xff515c6f),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Avenir",
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0),
                            textAlign: TextAlign.left),
                        // ₹ 55.00
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                    "₹ ${item.skus.isEmpty ? 0 : item.skus.first.basePrice.toString()}",
                                    style: TextStyle(
                                        color: (!isOutOfStock
                                            ? Color(0xffc1c1c1)
                                            : Color(0xff5091cd)),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Avenir",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 18.0),
                                    textAlign: TextAlign.left),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    item.skus.isEmpty
                                        ? "NA"
                                        : item.skus.first.variationOptions
                                                    .size !=
                                                null
                                            ? item.skus.first.variationOptions
                                                .size
                                            : "NA",
                                    style: TextStyle(
                                        color: Color(0xffa7a7a7),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Avenir",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14.0),
                                    textAlign: TextAlign.left)
                              ],
                            ),
                            CSStepper(
                              backgroundColor: !isOutOfStock
                                  ? Color(0xffb1b1b1)
                                  : AppColors.icColors,
                              didPressAdd: () {
                                item.count = ((item?.count ?? 0) + 1)
                                    .clamp(0, double.nan);
                                snapshot.addToCart(item, context);
                              },
                              didPressRemove: () {
                                item.count = ((item?.count ?? 0) - 1)
                                    .clamp(0, double.nan);
                                snapshot.removeFromCart(item);
                              },
                              value: item.count == 0
                                  ? "Add "
                                  : item.count.toString(),
                            ),
                          ],
                        ),

                        // 500GMS
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

class CSStepper extends StatelessWidget {
  final String value;
  final Function didPressAdd;
  final Function didPressRemove;
  final Color backgroundColor;
  const CSStepper(
      {Key key,
      this.didPressAdd,
      this.didPressRemove,
      this.value,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 73,
      decoration: BoxDecoration(
        color: this.backgroundColor ?? AppColors.icColors,
        borderRadius: BorderRadius.circular(100),
      ),
      child: value.contains("Add")
          ? InkWell(
              onTap: () {
                didPressAdd();
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    Text(value,
                        style: const TextStyle(
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Avenir",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center),
                    Spacer(),
                  ],
                ),
              ),
            )
          : Row(
//      crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      didPressRemove();
                    },
                    child: Container(
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 18,
                      ),
                      width: 24,
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Text(value,
                      style: const TextStyle(
                          color: const Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Avenir",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      didPressAdd();
                    },
                    child: Container(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                      width: 24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
