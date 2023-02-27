import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news_app/model/news_model.dart';
import 'package:news_app/viewTabs/news/edit_news_screen.dart';
import '../../constant/constant_file.dart';
import 'add_news_screen.dart';
import 'package:http/http.dart' as http;

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final list = <NewsModel>[];
  var loading = false;

  @override
  void initState() {
    super.initState();
    _lihatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddNewsPage()));
          },
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return _lihatData();
          },
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Center(
                              // data akan ditampilkan dalam bentuk sejajar dan dipanggil sesuai isi collection 'barang'
                              child: Row(
                                children: [
                                  // kontraktor
                                  Material(
                                    elevation: 5,
                                    child: Container(
                                      height: 120,
                                      width: 385,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                if (i != null)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      BaseUrl.insertImage +
                                                          x.image.toString(),
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                else
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      "assets/images/placeholder.jpeg",
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      x.title.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3.0,
                                                    ),
                                                    Text(
                                                      x.dateNews.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                MyUpdateForm(x)));
                                                  },
                                                  icon: const Icon(Icons.edit),
                                                  iconSize: 20,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    print(x.idNews.toString());
                                                    dialogDelete(
                                                        x.idNews.toString());
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  iconSize: 20,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          ]),
                    );
                  }),
        ));
  }

  Future _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(BaseUrl.detailNews));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = NewsModel(
            api['id_news'],
            api['image'],
            api['title'],
            api['description'],
            api['content'],
            api['date_news'],
            api['id_user'],
            api['username']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  delete(String id_news) async {
    final response = await http.post(Uri.parse(BaseUrl.deletelNews), body: {
      "id_news": id_news,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];

    if (value == 1) {
      print(id_news);
      _lihatData();
    } else {
      print(pesan);
    }
  }

  dialogDelete(String id_news) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Hapus Data"),
            content: const Text("Apakah anda yakin ingin menghapus data ini?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Tidak")),
              TextButton(
                  onPressed: () {
                    delete(id_news);
                    Navigator.pop(context);
                  },
                  child: const Text("Ya")),
            ],
          );
        });
  }
}
