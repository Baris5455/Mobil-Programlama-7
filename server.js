const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// MySQL bağlantısı
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root', // MySQL kullanıcı adı
  password: '047870', // MySQL şifresi
  database: 'ogrenci_db' // Veritabanı adı
});

db.connect((err) => {
  if (err) {
    console.error('MySQL bağlantı hatası: ' + err.stack);
    return;
  }
  console.log('MySQL bağlantısı başarılı');
});

// JSON verilerini almak için body-parser middleware kullanıyoruz
app.use(bodyParser.json());

// Öğrenci ekleme API'si
app.post('/ogrenciler', (req, res) => {
  const { ogrenciID, ad, soyad, BolumId } = req.body;

  // Alanlar boş ise hata döndür
  if (!ogrenciID || !ad || !soyad || !BolumId) {
    return res.status(400).send('Tüm alanlar doldurulmalıdır.');
  }

  const query = 'INSERT INTO Ogrenci (ogrenciID, ad, soyad, BolumId) VALUES (?, ?, ?, ?)';

  db.query(query, [ogrenciID, ad, soyad, BolumId], (err, results) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      res.status(500).send('Veritabanı hatası');
    } else {
      res.status(201).send({ message: 'Öğrenci başarıyla eklendi!' });
    }
  });
});

// Öğrenci listeleme API'si
app.get('/ogrenciler', (req, res) => {
  const query = 'SELECT * FROM Ogrenci'; // Veritabanındaki tüm öğrencileri alıyoruz

  db.query(query, (err, results) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      res.status(500).send('Veritabanı hatası');
    } else {
      res.status(200).json(results); // Öğrencileri JSON formatında döndürüyoruz
    }
  });
});

// Öğrenci silme API'si
app.delete('/ogrenciler/:ogrenciID', (req, res) => {
  const { ogrenciID } = req.params; // Parametre olarak gelen öğrenci ID'si

  const query = 'DELETE FROM Ogrenci WHERE ogrenciID = ?';

  db.query(query, [ogrenciID], (err, results) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      return res.status(500).send('Veritabanı hatası');
    }

    if (results.affectedRows > 0) {
      res.status(200).send({ message: 'Öğrenci başarıyla silindi!' });
    } else {
      res.status(404).send('Öğrenci bulunamadı');
    }
  });
});

// Öğrenci güncelleme API'si
app.put('/ogrenciler/:ogrenciID', (req, res) => {
  const { ogrenciID } = req.params; // Parametre olarak gelen öğrenci ID'si
  const { ad, soyad, BolumId } = req.body; // Güncellenmek istenen bilgiler

  // Alanların boş olup olmadığını kontrol et
  if (!ad || !soyad || !BolumId) {
    return res.status(400).send('Tüm alanlar doldurulmalıdır.');
  }

  const query = 'UPDATE Ogrenci SET ad = ?, soyad = ?, BolumId = ? WHERE ogrenciID = ?';

  db.query(query, [ad, soyad, BolumId, ogrenciID], (err, results) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      return res.status(500).send('Veritabanı hatası');
    }

    if (results.affectedRows > 0) {
      res.status(200).send({ message: 'Öğrenci başarıyla güncellendi!' });
    } else {
      res.status(404).send('Öğrenci bulunamadı');
    }
  });
});




// Sunucu çalışıyor
app.listen(port, () => {
  console.log(`Sunucu çalışıyor: http://localhost:${port}`);
});
