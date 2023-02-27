import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/constant/constant_file.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  File? _image;
  final picker = ImagePicker();

  final _key = GlobalKey<FormState>();

  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController id_user = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _key,
            child: ListView(
              children: [
                _image == null
                    ? Image.asset(
                        "assets/images/placeholder.jpeg",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _image!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    choiceImage();
                  },
                  child: const Text('Choose Image'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: content,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                TextFormField(
                  controller: id_user,
                  validator: (e) {
                    if (e!.isEmpty) {
                      return "Please insert id user";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Id User',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    uploadNews();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future choiceImage() async {
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  Future uploadNews() async {
    final url = Uri.parse(BaseUrl.addNews);
    var request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile(
        'image', File(_image!.path).readAsBytes().asStream(), File(_image!.path).lengthSync(),
        filename: _image!.path.split("/").last));
    print(_image!.path.toString());
    request.fields['title'] = title.text;
    request.fields['content'] = content.text;
    request.fields['description'] = description.text;
    request.fields['id_user'] = id_user.text;

    var pic = await http.MultipartFile.fromPath('image', _image!.path);
    request.files.add(pic);
    var response = await request.send();

    try {
      if (response.statusCode == 200) {
        print('Image Uploaded');
        Navigator.pop(context);
      } else {
        print(response.statusCode);
        print('Image Not Uploaded');
      }
    } catch (e) {
      print(e);
    }
  }

//  String id_user = "";

//   getPref() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       id_user = preferences.getString("id_user").toString();
//     });
//     log(id_user.toString());
//   }
}
