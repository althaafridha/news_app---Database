import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/main_menu.dart';
import 'package:news_app/register/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant_file.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  late String email, password;
  final _key = GlobalKey<FormState>();
  bool _secureText = true;

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
            appBar: AppBar(),
            body: Form(
              key: _key,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  TextFormField(
                    validator: (e) {
                      if (e!.isEmpty) {
                        return 'Please insert email';
                      }
                    },
                    onSaved: (e) => email = e.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextFormField(
                    obscureText: _secureText,
                    onSaved: (e) => password = e.toString(),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: showHide,
                          icon: Icon(_secureText
                              ? Icons.visibility_off
                              : Icons.visibility)),
                      labelText: 'Password',
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      check();
                    },
                    child: const Text('Login'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()));
                    },
                    child: const Text(
                      'Create new Account',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ));
      case LoginStatus.signIn:
        return MainMenu(signOut: signOut);
    }
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      login();
      // print("$email, $password");
    }
  }

  login() async {
    final url = Uri.parse(BaseUrl.login);
    final response = await http.post(url, body: {
      "email": email,
      "password": password,
    });
    final data = jsonDecode(response.body);
    // print(data);

    int value = data['value'];
    String pesan = data['message'];
    String idUser = data['id_user'];
    String emailAPI = data['email'];
    String usernameAPI = data['username'];

    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, idUser, usernameAPI, emailAPI,);
      });
      print(pesan);
    } else {
      print(pesan);
    }
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  savePref(int value,String id, String username, String email) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("id_user", id);
      preferences.setString("username", username);
      preferences.setString("email", email);
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }
}
