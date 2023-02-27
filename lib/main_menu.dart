import 'package:flutter/material.dart';
import 'package:news_app/viewTabs/category/category_screen.dart';
import 'package:news_app/viewTabs/home/home_screen.dart';
import 'package:news_app/viewTabs/news/news_screen.dart';
import 'package:news_app/viewTabs/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  const MainMenu({super.key, required this.signOut});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String username = "", email = "";

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: signOut,
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: const TabBarView(
          children: [
            HomePage(),
            NewsPage(),
            CategoryPage(),
            ProfilePage()
          ],
          // child: Text('username : $username,\n email : $email'),
        ),
        bottomNavigationBar: const TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.newspaper),
              text: "News",
            ),
            Tab(
              icon: Icon(Icons.list),
              text: "Category",
            ),
            Tab(
              icon: Icon(Icons.person),
              text: "Profile",
            ),
            ]),
      ),
    );
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString('username').toString();
      email = preferences.getString('email').toString();
    });
  }

  signOut() {
    setState(() {
      widget.signOut();
    });
  }
}
