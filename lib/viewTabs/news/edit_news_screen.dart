import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/constant/constant_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../../model/news_model.dart';

class MyUpdateForm extends StatefulWidget {
  final NewsModel tampilNews;

  MyUpdateForm(this.tampilNews);

  @override
  _MyUpdateFormState createState() => _MyUpdateFormState();
}

class _MyUpdateFormState extends State<MyUpdateForm> {
  File? _image;
  final picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String title, content, description, id_users, id_news;
  late TextEditingController txtTitle, txtContent, txtDescription;

  check() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      _submitForm();
    } else {}
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final url = Uri.parse(BaseUrl.editNews);
    final request = http.MultipartRequest('POST', url);

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );
    }

    request.fields.addAll({
      'title': title,
      'content': content,
      'description': description,
      'id_news': id_news,
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final responseJson = json.decode(responseString);
      Navigator.pop(context);
      print(responseJson);
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future getImage() async {
    var pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_users = preferences.getString("id_user")!;
    });
    txtTitle = TextEditingController(text: widget.tampilNews.title);
    txtContent = TextEditingController(text: widget.tampilNews.content);
    txtDescription = TextEditingController(text: widget.tampilNews.description);
  }

  @override
  void initState() {
    super.initState();
    getPref();

    id_news = widget.tampilNews.idNews;
    title = widget.tampilNews.title;
    content = widget.tampilNews.content;
    description = widget.tampilNews.description;
  }

  @override
  Widget build(BuildContext context) {
    final url = BaseUrl.insertImage;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: _image == null
                        ? (widget.tampilNews.image! == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 50.0,
                              )
                            : Image.network(url + widget.tampilNews.image,
                                fit: BoxFit.cover))
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.tampilNews.title,
                  onSaved: (value) => title = value!,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.tampilNews.content,
                  onSaved: (value) => content = value!,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.tampilNews.description,
                  onSaved: (value) => description = value!,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.tampilNews.idNews,
                  onSaved: (value) => id_news = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter id news';
                    }
                    return null;
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Id_news',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: check,
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}