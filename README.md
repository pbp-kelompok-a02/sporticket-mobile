**Nama anggota kelompok**:  
- Laudya Michelle Alexandra (2406419594)  
- Ali Akbar Murthadha (2406495754)  
- Fidan Khalil Salman (2406408501)  
- Ahmad Aqeel Saniy (2306275941)  
- Haris Azzahra Lunaaya (2406425930)

Tema            : Penjualan tiket olahraga (5 jenis olahraga)  
Nama Aplikasi   : SPORTICKET

**PEMBAGIAN MODUL**  
Account (michelle) → Event (aqeel) → Ticket (fidan) → Order (ali) → Review (luna)

**Tautan Sheets PAS Planning**  
https://docs.google.com/spreadsheets/d/1NmntSv9dasmsV7V2li1rIm7cTCm7ffiQdOlci4FY0AE/edit?usp=sharing

**Deskripsi Aplikasi**  
Sporticket adalah platform penjualan tiket digital pertandingan olahraga yang dirancang untuk memberikan kemudahan kepada penggemar olahraga sepak bola, basket, voli, badminton, dan tenis dalam membeli tiket untuk event-event olahraga favorit mereka. Aplikasi ini menawarkan pengalaman pengguna yang cepat, aman, dan efisien dalam membeli tiket untuk berbagai event olahraga, dengan integrasi pemilihan kategori tiket (reguler atau VIP), sistem notifikasi, dan akses mudah ke riwayat pembelian. Fitur-fitur lengkap aplikasi Sporticket dijelaskan lebih lanjut dalam bagian daftar modul.

**Daftar Modul**  
1. Modul Event Pertandingan (Admin)  
    - Model: Event (nama pertandingan, home team, away team, deskripsi, poster, venue, date, kapasitas).  
    - CRUD:
        * Create → admin tambah event baru
        * Read → lihat daftar event (detail event ada di card event)
        * Update → edit detail event (misalnya ganti venue, ubah jadwal, update deskripsi).
        * Delete → hapus event.  
    - AJAX: menampilkan notifikasi sukses/gagal ketika admin tambah/edit/hapus event tanpa reload.

2. Modul Tiket (Admin)
    - Model: Ticket (event [FK ke event], kategori tiket: VIP/Reguler, harga, stok).
    - CRUD:
        * Create → admin tambah tiket (reguler/vip) untuk event.
        * Read → tampilkan daftar tiket per event.
        * Update → admin update stok/harga tiket.
        * Delete → hapus kategori tiket tertentu.
    - AJAX: update stok tiket dan hapus tiket secara realtime tanpa reload halaman.

3. Modul Pesanan (Buyer)
    - Model: Order (user, tiket, jumlah, status: pending/confirmed/cancelled).
    - CRUD:
        * Create → user buat pesanan tiket.
        * Read → user lihat riwayat pesanan/pembelian.
        * Update → user bisa ubah jumlah tiket ketika masih pending.
        * Delete → user bisa hapus/batalkan pesanan ketika pesanan pending atau sudah confirmed.
    - AJAX: submit order, hapus order, edit order via AJAX → muncul notifikasi sukses/gagal tanpa reload.

4. Modul Review Event (Buyer)
    - Model: Review (user, event [FK], rating, komentar, tanggal).
    - CRUD:
        * Create → user kasih review pada event yang dihadiri.
        * Read → tampilkan daftar review di halaman detail event.
        * Update → user bisa edit review-nya.
        * Delete → user hapus review sendiri.
    - AJAX: tambah review tanpa reload → langsung muncul di daftar review.

5. Modul Akun (Buyer & Admin)
    - Model: User (nama, email, password, role [Admin/Buyer], nomor_telepon, photo_profile).
    - CRUD:
        * Create → Registrasi (User membuat akun baru, hanya untuk akun Buyer karena Admin adalah superuser).
        * Read → Lihat detail profil pengguna (nama, email, no. telepon, role)
        * Update → Edit informasi profil (misalnya ganti nama, nomor telepon) dan ubah password.
        * Delete → Hapus Akun 
    - AJAX: update detail profil tanpa reload halaman

**Deskripsi peran pengguna**
- Admin (hardcoded, 1 akun superuser)  
    Admin dapat membuat event pertandingan dan tiket pertandingan, melihat tiket dan event yang ada, mengedit tiket pertandingan dan event yang ada (ganti jadwal / lokasi), dan menghapus tiket pertandingan dan event yang ada.    
- Pembeli (Regular user)  
    Pembeli dapat melihat detail tiket dan riwayat pembelian, membeli tiket pertandingan, ganti/update jumlah tiket yang dibeli, membatalkan pembelian tiket, membuat review event, mengedit review event yang ia buat, dan menghapus review event yang ia buat.

**Alur pengintegrasian data di aplikasi dengan aplikasi web (PWS)**  
**Django sebagai back-end API:**  
Django bertindak sebagai penyedia layanan web (web service) yang mengirimkan dan menerima data dalam format JSON  
Proses pengembangan pada sisi Django meliputi:  
**1. Perancangan Model**  
- Mendefinisikan struktur data yang akan digunakan dan disimpan dalam database, seperti model untuk pengguna, pembeli, serta lainnya. 

**2. Pembuatan Serializer**  
- Mengubah data model menjadi format JSON agar dapat dikirim ke client (Flutter).  
- Menerima data JSON dari Flutter kemudian memvalidasinya sebelum disimpan ke database.  

**3. Pembuatan View atau ViewSet**  
- Mengatur logika proses CRUD (Create, Read, Update, Delete).  
- Menentukan bagaimana data diambil, diproses, atau disimpan melalui API.  

**4. Routing atau URL Configuration**  
- Mendefinisikan endpoint API, misalnya:
 `/api/products/`, `/api/auth/login/`, dan sebagainya. 

**5. Konfigurasi Autentikasi**  
- Menggunakan cookie/session, Django akan mengelola session berbasis cookie agar Flutter tetap memiliki status login.

**6. Konfigurasi CORS**  
- Agar Flutter dapat mengakses API, Django perlu mengizinkan origin tertentu melalui konfigurasi CORS.

**Endpoint API dari Django:**  
Setelah backend selesai dibangun, Django menyediakan endpoint-endpoint yang dapat diakses oleh aplikasi Flutter. Endpoint ini nantinya akan digunakan untuk:  
- Mengambil data (GET)
- Mengirim data baru (POST)
- Memperbarui data (PUT/PATCH)
- Menghapus data (DELETE)

Contoh implementasi: https://server.com/api/products/

**Flutter sebagai front-end API:**  
Flutter berfungsi sebagai aplikasi client yang mengakses API Django. Flutter melakukan komunikasi melalui HTTP request dan menerima respons berupa JSON.  
**Tahapan di sisi Flutter:**  
**1. Mengirim request ke Django**
- Menggunakan library seperti http, dio, atau pbp_django_auth

**2. Menerima respons JSON**
- Data yang diterima diparsing menjadi model Dart.

**3. Pengolahan data**
- Data di-store dalam state management (misalnya Provider, Bloc, Riverpod).

**4. Menampilkan data pada UI**
- Data yang sudah diproses ditampilkan ke dalam komponen UI Flutter. 

**5. Penanganan error**
- Flutter akan menangani error seperti input tidak valid, koneksi gagal, dll


**Tautan PWS** = https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/

**Tautan design** = https://www.figma.com/design/HXRRzkW7WdbLWYq2gYPcRV/PAS-PBP-A02?node-id=0-1&p=f&t=hoqW4dAuSgROBtpq-0

**Tautan APK** = sporticket
[![Build Status](https://app.bitrise.io/app/22bc4334-bd5c-4cd0-9e0c-1f0e4970bba1/status.svg?token=_z71TV6Y0tfCF_orDf1gxw&branch=master)](https://app.bitrise.io/app/22bc4334-bd5c-4cd0-9e0c-1f0e4970bba1)

**Download aplikasi versi terbaru**: [DOWNLOAD APK] (https://app.bitrise.io/app/22bc4334-bd5c-4cd0-9e0c-1f0e4970bba1/installable-artifacts/0558b3e66f4b23a0/public-install-page/1db61361c9fd6c6a6e99f28bcfac15f3)
