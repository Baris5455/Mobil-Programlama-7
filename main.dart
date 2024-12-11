import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OgrenciListesi(),
    );
  }
}

// Öğrenci Listesi Ekranı
class OgrenciListesi extends StatefulWidget {
  const OgrenciListesi({super.key});

  @override
  OgrenciListesiState createState() => OgrenciListesiState();
}

class OgrenciListesiState extends State<OgrenciListesi> {
  List<dynamic> ogrenciler = [];

  @override
  void initState() {
    super.initState();
    // Başlangıçta öğrenci listesine veri çekmek
    getOgrenciler();
  }

  // Öğrencileri API'den al
  getOgrenciler() async {
    final response = await http.get(Uri.parse('http://192.168.56.1:3000/ogrenciler'));

    if (response.statusCode == 200) {
      setState(() {
        ogrenciler = json.decode(response.body);
      });
    } else {
      print('Veri alınamadı');
    }
  }

  // Öğrenci ekleme
  addOgrenci(int ogrenciID, String ad, String soyad, int bolumId) async {
    var url = Uri.parse('http://192.168.56.1:3000/ogrenciler');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: json.encode({
      'ogrenciID' : ogrenciID,
      'ad': ad,
      'soyad': soyad,
      'BolumId': bolumId,
    }));

    if (response.statusCode == 201) {
      print("Öğrenci başarıyla eklendi");
      getOgrenciler();  // Öğrenci eklendikten sonra tekrar listeyi al
    } else {
      print('Öğrenci eklenemedi');
    }
  }

  // Öğrenci silme
  deleteOgrenci(int ogrenciID) async {
    var url = Uri.parse('http://192.168.56.1:3000/ogrenciler/$ogrenciID');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      getOgrenciler();  // Öğrenci silindikten sonra tekrar listeyi al
    } else {
      print('Öğrenci silinemedi');
    }
  }

  // Öğrenci güncelleme
  updateOgrenci(int ogrenciID, String ad, String soyad, int bolumId) async {
    var url = Uri.parse('http://192.168.56.1:3000/ogrenciler/$ogrenciID');
    var response = await http.put(url, headers: {
      'Content-Type': 'application/json',
    }, body: json.encode({
      'ad': ad,
      'soyad': soyad,
      'BolumId': bolumId,
    }));

    if (response.statusCode == 200) {
      getOgrenciler();  // Öğrenci güncellendikten sonra tekrar listeyi al
    } else {
      print('Öğrenci güncellenemedi');
    }
  }

  // Öğrenci güncelleme formunu göstermek
  void showUpdateForm(BuildContext context, int ogrenciID, String currentAd, String currentSoyad, int currentBolumId) {
    final adController = TextEditingController(text: currentAd);
    final soyadController = TextEditingController(text: currentSoyad);
    final bolumController = TextEditingController(text: currentBolumId.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenci Güncelle'),
        content: Column(
          children: [
            TextField(
              controller: adController,
              decoration: const InputDecoration(labelText: 'Ad'),
            ),
            TextField(
              controller: soyadController,
              decoration: const InputDecoration(labelText: 'Soyad'),
            ),
            TextField(
              controller: bolumController,
              decoration: const InputDecoration(labelText: 'Bölüm ID'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateOgrenci(ogrenciID, adController.text, soyadController.text, int.parse(bolumController.text));
              Navigator.of(context).pop();
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
      ),
      body: ListView.builder(
        itemCount: ogrenciler.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('${ogrenciler[index]['ad']} ${ogrenciler[index]['soyad']}'),
              subtitle: Text('Bölüm ID: ${ogrenciler[index]['BolumId'].toString()}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  deleteOgrenci(ogrenciler[index]['ogrenciID']);
                },
              ),
              onTap: () {
                showUpdateForm(context, ogrenciler[index]['ogrenciID'], ogrenciler[index]['ad'], ogrenciler[index]['soyad'], ogrenciler[index]['BolumId']);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Öğrenci eklemek için form açılacak
          showDialog(
            context: context,
            builder: (context) {
              final idController = TextEditingController();
              final adController = TextEditingController();
              final soyadController = TextEditingController();
              final bolumController = TextEditingController();

              return AlertDialog(
                title: const Text('Yeni Öğrenci Ekle'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'ID'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: adController,
                      decoration: const InputDecoration(labelText: 'Ad'),
                    ),
                    TextField(
                      controller: soyadController,
                      decoration: const InputDecoration(labelText: 'Soyad'),
                    ),
                    TextField(
                      controller: bolumController,
                      decoration: const InputDecoration(labelText: 'Bölüm ID'),
                      keyboardType: TextInputType.number,
                    ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addOgrenci(int.parse(idController.text),adController.text, soyadController.text, int.parse(bolumController.text));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
