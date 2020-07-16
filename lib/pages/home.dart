import 'package:presensi/models/user.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:presensi/pages/profile.dart';
import 'package:presensi/pages/setting.dart';
import 'package:flutter/material.dart';
import 'package:presensi/pages/chat.dart';

class Home extends StatefulWidget {

  final User user;
  const Home({Key key, this.user}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen;
  final List<Widget> screens = [
    Dashboard(),
    // Chat(),
    Profile(),
    // Settings(),
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen == null
            ? Dashboard(user: this.widget.user)
            : currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(AntDesign.scan1),
        backgroundColor: Color(0xFF2979FF),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = Dashboard(
                            user: this
                                .widget
                                .user); // if user taps on this dashboard tab will be active
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          AntDesign.home,
                          color: currentTab == 0 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: currentTab == 0 ? Colors.blue : Colors.grey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // MaterialButton(
                  //   minWidth: 40,
                  //   onPressed: () {
                  //     setState(() {
                  //       currentScreen =
                  //           Chat(); // if user taps on this dashboard tab will be active
                  //       currentTab = 1;
                  //     });
                  //   },
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       Icon(
                  //         Icons.chat,
                  //         color: currentTab == 1 ? Colors.blue : Colors.grey,
                  //       ),
                  //       Text(
                  //         'Chats',
                  //         style: TextStyle(
                  //           color: currentTab == 1 ? Colors.blue : Colors.grey,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),

              // Right Tab bar icons

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // MaterialButton(
                  //   minWidth: 40,
                  //   onPressed: () {
                  //     setState(() {
                  //       currentScreen =
                  //           Profile(); // if user taps on this dashboard tab will be active
                  //       currentTab = 2;
                  //     });
                  //   },
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       Icon(
                  //         Icons.dashboard,
                  //         color: currentTab == 2 ? Colors.blue : Colors.grey,
                  //       ),
                  //       Text(
                  //         'Profile',
                  //         style: TextStyle(
                  //           color: currentTab == 2 ? Colors.blue : Colors.grey,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = Profile(
                            // user: this
                            //     .widget
                            //     .user
                                ); // if user taps on this dashboard tab will be active
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          AntDesign.user,
                          color: currentTab == 3 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Profil',
                          style: TextStyle(
                            color: currentTab == 3 ? Colors.blue : Colors.grey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
