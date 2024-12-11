const http = require('http');

const data = JSON.stringify({
  ogrenciID: 1,
  ad: 'Ali',
  soyad: 'Yılmaz',
  BolumId: 101
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/ogrenciler',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
};

// POST isteği gönderme
const req = http.request(options, (res) => {
  let responseData = '';
  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log('Response:', responseData);
  });
});

req.on('error', (error) => {
  console.error('Error:', error);
});

req.write(data);
req.end();
