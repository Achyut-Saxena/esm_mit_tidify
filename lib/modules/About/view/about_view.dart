import 'package:eSamudaay/utilities/colors.dart';
import 'package:flutter/material.dart';

class AboutView extends StatefulWidget {
  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.icColors,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/indicator.gif',
                  height: 200,
                  width: 200,
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Product by'
                  '\nNirmund Digital Distributions Pvt Ltd',
                  style: TextStyle(
                    color: Color(0xff797979),
                    fontSize: 18,
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}