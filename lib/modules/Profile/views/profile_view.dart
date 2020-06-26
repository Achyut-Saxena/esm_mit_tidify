import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esamudaayapp/models/loading_status.dart';
import 'package:esamudaayapp/modules/Profile/action/profile_update_action.dart';
import 'package:esamudaayapp/modules/Profile/model/profile_update_model.dart';
import 'package:esamudaayapp/modules/address/actions/address_actions.dart';
import 'package:esamudaayapp/modules/address/models/addess_models.dart';
import 'package:esamudaayapp/redux/states/app_state.dart';
import 'package:esamudaayapp/utilities/custom_widgets.dart';
import 'package:esamudaayapp/utilities/keys.dart';
import 'package:esamudaayapp/utilities/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:regexed_validator/regexed_validator.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String latitude, longitude;
  File _image;
  final picker = ImagePicker();
  Address address;

  getAddress(_ViewModel snapshot) async {
    address = await UserManager.getAddress();
    if (address != null) {
      addressController.text = address.prettyAddress;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, _ViewModel>(
          onInit: (store) {},
          model: _ViewModel(),
          builder: (context, snapshot) {
            if (snapshot.loadingStatus != LoadingStatus.loading) {
              getAddress(snapshot);
            }

            nameController.text = snapshot.user.profileName;
            phoneNumberController.text = snapshot.user.userProfile.phone != null
                ? snapshot.user.userProfile.phone
                : "";

            return WillPopScope(
              onWillPop: () async {
                return Future.value(
                    false); //return a `Future` with false value so this route cant be popped or closed.
              },
              child: ModalProgressHUD(
                inAsyncCall: snapshot.loadingStatus == LoadingStatus.loading,
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    brightness: Brightness.light,
                    leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                          ),
                          InkWell(
                            onTap: () {
                              _settingModalBottomSheet(context, snapshot);
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: new BoxDecoration(
                                  boxShadow: [
                                    new BoxShadow(
                                      color: Colors.white30,
                                      blurRadius: 0.0,
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _image != null
                                          ? FileImage(_image)
                                          : snapshot.user.profilePic.photoUrl !=
                                                  null
                                              ? new NetworkImage(snapshot
                                                  .user.profilePic.photoUrl)
                                              : AssetImage(
                                                  'assets/images/user.jpg'))),
                            ),
                          ),
                          //name
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextInputBG(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                          validator: (value) {
                                            if (value.length == 0) return null;
                                            if (value.length < 3) {
                                              return tr(
                                                  'screen_register.name.empty_error');
                                              return null;
                                            }
                                            return null;
                                          },
                                          autovalidate: true,
                                          enabled: false,
                                          controller: nameController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            hintText:
                                                tr('screen_recommended.name'),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              color: const Color(0xff1a1a1a),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Avenir",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 13.0),
                                          textAlign: TextAlign.center),
                                    ),
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.blueAccent,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //pin code
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextInputBG(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                          enabled: false,
                                          validator: (value) {
                                            if (value.length == 0) return null;
                                            if (value.length < 10 ||
                                                !validator.phone(value)) {
                                              return tr(
                                                  'screen_phone.valid_phone_error_message');
                                            }
                                            return null;
                                          },
                                          autovalidate: true,
                                          controller: phoneNumberController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText:
                                                tr('screen_recommended.phone'),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              color: const Color(0xff1a1a1a),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Avenir",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 13.0),
                                          textAlign: TextAlign.center),
                                    ),
                                    Icon(
                                      Icons.phone_iphone,
                                      color: Colors.blueAccent,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //address
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 40.0),
                            child: TextInputBG(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                          maxLines: null,
                                          // enableInteractiveSelection: false,
                                          validator: (value) {
                                            if (value.isEmpty) return null;
//                                          if (value.length < 10) {
//                                            return tr(
//                                                'screen_register.address.empty_error');
//                                            return null;
//                                          }
                                            return null;
                                          },
                                          autovalidate: true,
                                          controller: addressController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            hintText: tr(
                                                'screen_register.address.title'),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              color: const Color(0xff1a1a1a),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Avenir",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 13.0),
                                          textAlign: TextAlign.center),
                                    ),
                                    Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: Keys
                                                    .googleAPIkey, // Put YOUR OWN KEY here.
                                                onPlacePicked: (result) {
                                                  // Handle the result in your way
                                                  print(
                                                      result?.formattedAddress);
                                                  // print(result?.a);
                                                  if (result
                                                          ?.formattedAddress !=
                                                      null) {
                                                    addressController.text =
                                                        result
                                                            ?.formattedAddress;
                                                  }
//                                                if (result?.postalCode !=
//                                                    null) {
//                                                  pinCodeController.text =
//                                                      result?.postalCode;
//                                                }
                                                  latitude = result
                                                      .geometry.location.lat
                                                      .toString();
                                                  longitude = result
                                                      .geometry.location.lng
                                                      .toString();
                                                  print(result.adrAddress);
                                                  Navigator.of(context).pop();
                                                },
//                                              initialPosition: HomePage.kInitialPosition,
                                                useCurrentLocation: true,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.add_location,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //location
                          //Register_but
                          // Rectangle 10
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                if (nameController.text.isNotEmpty &&
                                    addressController.text.isNotEmpty &&
                                    phoneNumberController.text.isNotEmpty) {
                                  if ((nameController.text.length < 3 ||
                                      !nameController.text
                                          .contains(new RegExp(r'[a-z]')))) {
                                    Fluttertoast.showToast(
                                        msg: tr(
                                            'screen_register.name.empty_error'));
                                  } else if (phoneNumberController.text.length <
                                          10 ||
                                      !validator
                                          .phone(phoneNumberController.text)) {
                                    Fluttertoast.showToast(
                                        msg: tr(
                                            'screen_phone.valid_phone_error_message'));
                                  } else {
                                    snapshot.profileUpdate(
                                        _image,
                                        addressController.text !=
                                                address.prettyAddress
                                            ? AddressRequest(
                                                addressName:
                                                    nameController.text,
                                                lat: latitude != null
                                                    ? double.parse(latitude)
                                                    : 0.0,
                                                lon: longitude != null
                                                    ? double.parse(longitude)
                                                    : 0.0,
                                                prettyAddress:
                                                    addressController.text,
                                                geoAddr: GeoAddr(pincode: ""))
                                            : null,
                                        address.addressId);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "all fields required");
                                }
                              },
                              child: Hero(
                                tag: '#getOtp',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      height: 60,
                                      child: Stack(children: [
                                        // Rectangle 10
                                        PositionedDirectional(
                                          top: 0,
                                          start: 0,
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(100)),
                                                  gradient: LinearGradient(
                                                      begin: Alignment(
                                                          0.023085936903953545,
                                                          0.5),
                                                      end: Alignment(
                                                          0.980859398841858,
                                                          0.5),
                                                      colors: [
                                                        const Color(0xff00dab2),
                                                        const Color(0xff3a90d3),
                                                        const Color(0xff3a90d3)
                                                      ]))),
                                        ),
                                        // Get OTP
                                        PositionedDirectional(
                                          top: 16.000030517578125,
                                          start: 0,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                              height: 22,
                                              child: Text(
                                                      'screen_register.update',
                                                      style: const TextStyle(
                                                          color: const Color(
                                                              0xffffffff),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Avenir",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 16.0),
                                                      textAlign:
                                                          TextAlign.center)
                                                  .tr()),
                                        )
                                      ])),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void _settingModalBottomSheet(context, _ViewModel snapshot) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child: Text("Image Upload From ?")),
                ),
                new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imageSelectorCamera(snapshot);
                      Navigator.pop(context);
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text('Gallery'),
                  onTap: () {
                    imageSelectorGallery(snapshot);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  imageSelectorGallery(_ViewModel snapshot) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
//      snapshot.profileUpdate(_image);
    });
  }

  //display image selected from camera
  imageSelectorCamera(_ViewModel snapshot) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile.path);
//      snapshot.profileUpdate(_image);
    });
  }

  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}

class _ViewModel extends BaseModel<AppState> {
  _ViewModel();

  Function() getAddress;
  Data user;
  LoadingStatus loadingStatus;
  Function(File image, AddressRequest address, String addressID) profileUpdate;
  Function navigateToHomePage;
  bool isPhoneNumberValid;
  String userPhone;
  String userName;
  String userAddress;

  _ViewModel.build(
      {this.navigateToHomePage,
      this.profileUpdate,
      this.loadingStatus,
      this.isPhoneNumberValid,
      this.userPhone,
      this.userName,
      this.userAddress,
      this.user,
      this.getAddress})
      : super(equals: [
          loadingStatus,
          isPhoneNumberValid,
          userPhone,
          userName,
          userAddress,
          user
        ]);

  @override
  BaseModel fromStore() {
    // TODO: implement fromStore
    return _ViewModel.build(
        user: state.authState.user,
        userAddress: "",
        loadingStatus: state.authState.loadingStatus,
        navigateToHomePage: () {
          //dispatch(NavigateAction.pushNamed('/myHomeView'));
        },
        getAddress: () {
          dispatch(GetAddressAction());
        },
        profileUpdate: (image, address, addressId) {
          if (address != null && address.prettyAddress != "") {
            dispatch(
                UpdateAddressAction(request: address, addressID: addressId));
          }
          if (image != null) {
            dispatch(UploadImageAction(imageFile: image));
          }

          ///dispatch(UpdateProfileAction(request: request));
        });
  }
}
