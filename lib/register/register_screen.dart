import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/constant/constant_file.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _key = GlobalKey<FormState>();

  late String username, email, password;
  bool _secureText = true;

  @override
  Widget build(BuildContext context) {
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
                    return 'Please insert username';
                  }
                },
                onSaved: (e) => username = e.toString(),
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              TextFormField(
                validator: (e) {
                  if (e!.isEmpty) {
                    return 'Please insert email';
                  } else {
                    return null;
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
                child: const Text('Register'),
              )
            ],
          ),
        ));
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    final url = Uri.parse(BaseUrl.register);
    final response = await http.post(url, body: {
      'username': username,
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];

    if (value == 1) {
      Navigator.pop(context);
    } else {
      print(pesan);
    }
  }
}
