import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color bottom_naivigation_color = Colors.grey.shade200;
Color textfield_border_color = Colors.white;
Color btnColor = const Color.fromARGB(255, 100, 208, 197);
Color textfieldicon = const Color.fromARGB(255, 41, 116, 112);
Color app_bc = const Color.fromRGBO(100, 208, 197, 1);

Color bc = Colors.green.shade50;

TextStyle subheader = GoogleFonts.poppins(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 15,
);
TextStyle buyandsell_details_text = GoogleFonts.openSans(
  textStyle: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  ),
);
const String publishkey =
    'pk_test_51OFewFLG8GWemPagc5fLK4VvJ4e1smN0zMAi2CHkoba7FlxmjddLCcvyMFgxdlPTF2zUPIb5rYPfkDWkSVWT5m5E0046sHPVee';
const String catApiKey =
    "live_IDXUY3yzZZLiBQReOnqK1njehRuZsnQlEAkiudVF7SVVn679Uc4rdexeZKTCH21r";
Color filtercolor = const Color.fromARGB(255, 116, 226, 215);

TextStyle style = const TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 20,
  color: Colors.black,
);
TextStyle splashScreentext = GoogleFonts.openSans(
  fontWeight: FontWeight.bold,
  fontSize: 30,
  color: Colors.black,
);
TextStyle little = const TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 15,
  color: Colors.grey,
);
TextStyle name = GoogleFonts.poppins(
  textStyle: const TextStyle(
    fontWeight: FontWeight.w500,
    // Other text style properties...
    fontSize: 18,
    color: Colors.white,
  ),
);
TextStyle title = const TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 20,
  color: Colors.black,
);
TextStyle description = const TextStyle(
  fontWeight: FontWeight.w300,
  fontSize: 17,
  color: Colors.black,
);
TextStyle buttontxtstyle = TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 20,
  color: buttontxtcolor,
);

class AppConstants {
  static double screenHeight = 0.0;
  static double screenWidth = 0.0;

  static void initialize(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }
}

// firebase notification server key
const String ServerKey =
    'ya29.c.c0ASRK0GbOMdrkNCPtpxEWcmvLb-FIeWtYLjQAMyKtAP8PJzoBTPu9fIC8LN_wDGG170vBFEzijNrv9hZYxnBL79TH8WebFAnfwfMV7ursE3KQGRC7kua-GKhdRTsqpYPNkuQrgQoOBrtiMQQOcZ6-cVgaKZvuohvXvCqbPY7Py5awzBxDKdFnG3ld0lUzW7ACkPS4xiZpGnGJAjynBxBNjVJkEfUXE7xAVwowwEBwDJmxUA3vy3xoPCUboVPtNYk4bc2-Po-5zHhG3D--tBWQM3gvoENCyT9ol7LgN7JM5vlAsdAah9FLrNSs8Vr1VqNEuvGWvR7Hebw6jcpgkqEFpF7lxD98ZA21B1MWoDkKAh3l8jzsFivLLVls8MrbN389Pra-mXcrIbFZnfpduyhhfp-j7X8zfSme56SfM-0wuwYt4ewgzUcaQ4Im5zdF8x0lqhB4sdtV9dIwdhVS6gnOxbSs81x5yy9RjYWoBoomcWd-sBgnt-SX5Wvv5FSQwJBUzZgSsRxtvmzxI_IFcjbm52-Ue5vIy92Sf_nUdUrjy-uRiM2g347msXI5Sf3ogkbvflQR7JZrMq9RamiRhWnjtU8zIhdSW51kO2uaZ6OmIUek9cZgSWsOQbwbV5Uzo14nqy_en1r5vnIB3dUyaehqqJ42ma7eoFbf123u9OmdInoJrOxdh5pgShiZBzawbWtXVI9ehZb4VevO1osmom9hrU-BckUaeFIW-VXhi0QVjrYlm2M46WFOtcvkrfatXp0Bd7yrdw51VQ7YaBkYil3MUp9eUW6jY1b-O5nW201V6w0d0eR7V7mXseshtmx4pSVMjpx59nsRg36ymgeBXhrtm1w-vpivf3F5v8ljsJjgrwaS3fFgveQs-v2kII8uX-eQ3FU5uWlv0SZItFwWS4OXmSgWVx52F1vQ_274Rj8iMX1W2mcbIkSh9g-WOuJhIlb-1oxw1t7ziJseFZ8f9lj1YO8-Upoi7sRhiwxoqJpy4rRxXiJ_fj4Xcx';

Color buttontxtcolor = Colors.white;

Color color = Colors.green.shade300;
Color appbarBackground = Colors.grey.shade200;
Color pickColor = Colors.white;
Color appbarColor = Colors.grey.shade200;
Color showColor = appbarColor;
Color activeColor = Colors.grey.shade300;
Color sentmsgColor = Colors.yellow.shade200;
Color getmsgColor = Colors.cyan.shade200;

//agora.io tokens api
const String _appId = '460bb44c5af242d1a0f68903d5316413';
const String _token =
    "007eJxTYJjA9bblllbZog3PuiSqttROE1K6fsz73VGj2R/UbHPWvQlUYDAxM0hKMjFJNk1MMzIxSjFMNEgzs7A0ME4xNTY0MzE0XrNuTnpDICOD1+UdDIxQCOIzMxSkljAwAACPtyBr";
const String _channel = 'pet';
const String _appCertficate = "6f822a3efde346dfb522ad016760cd40";
