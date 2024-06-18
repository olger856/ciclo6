import 'package:evento_c6_app/src/service/authService/ShareApiTokenService.dart';
import 'package:evento_c6_app/src/view/AdminHomePage.dart';
import 'package:evento_c6_app/src/view/UserHomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String accountEmail = "";
  String accountName = "";
  String accountFoto = "";
  String accountRole = "";

  @override
  void initState() {
    loadUserProfile();
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  }

  Future<void> loadUserProfile() async {
    final loginDetails = await ShareApiTokenService.loginDetails();

    if (loginDetails != null) {
      setState(() {
        accountName = truncateText(loginDetails.user?.name ?? "", 10);
        accountEmail = truncateText(loginDetails.user?.email ?? "", 15);
        accountFoto = loginDetails.user?.foto ?? "";
        accountRole = loginDetails.user?.role ?? "";
      });
    }
  }

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + "...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
         if (accountRole == 'admin') 
        Container(
         
          child: AdminHomePage(),
        ),
        if (accountRole == 'user') 
        Container(
          child: UserHomePage(),
        ),
      ],
    );
  }
}
