# 🎙️ Naskah Presentasi & Demo Aplikasi "WisataLokal"

**Nama:** Lukman Fauzi
**NIM:** STI202102540
**Project:** WisataLokal (Travel App Purwokerto)

---

## 1. Pembukaan (30 Detik)

"Assalamu’alaikum Wr. Wb.
Perkenalkan nama saya **Lukman Fauzi**, NIM **STI202102540**.
Pada kesempatan ini, saya akan mendemonstrasikan aplikasi mobile yang saya bangun untuk memenuhi Ujian Akhir Semester Mobile Programming.

Aplikasi ini bernama **WisataLokal**, sebuah aplikasi panduan wisata berbasis Android yang fokus mempromosikan destinasi di sekitar Purwokerto. Aplikasi ini dibangun menggunakan **Flutter** dengan database lokal **SQLite**."

---

## 2. Demonstrasi UI & Navigasi (1 Menit)

_(Buka Aplikasi dari Home Screen HP/Emulator)_

"Pertama, mari kita lihat tampilan antarmukanya.

- **App Icon & Name:** Di home screen, aplikasi sudah menggunakan ikon kustom dan nama 'WisataLokal', bukan default Flutter.
- **Landing Page:** Saat dibuka, kita disambut dengan animasi landing page yang menarik dengan tombol 'Mulai Sekarang'.
- **Dashboard:** Ini adalah halaman utama. UI didesain modern dengan tema Emerald Green.
- **Navigasi:** Saya menggunakan **BottomNavigationBar** di bawah untuk berpindah antar menu: Beranda, Eksplor, Peta, Favorit, dan Profil. Navigasi berjalan smooth tanpa lag."

---

## 3. Demonstrasi CRUD SQLite (2 Menit)

"Inti dari aplikasi ini adalah pengelolaan data destinasi menggunakan SQLite. Mari kita coba fitur CRUD-nya."

**A. CREATE (Tambah Data)**

- _(Masuk ke menu Eksplor/Dashboard, tekan tombol +)_
- "Saya akan mencoba menambahkan destinasi baru."
- "Kita isi Nama: 'Taman Kota Purwokerto'."
- "Deskripsi: 'Tempat santai keluarga di sore hari'."
- "Alamat: 'Jalan Jenderal Sudirman'."
- "**Fitur Spesial - Map Picker:** Untuk lokasi, saya tidak perlu input manual. Saya klik 'Pilih di Peta', peta akan terbuka di default Purwokerto, saya geser pin ke lokasi, lalu pilih. Koordinat otomatis terisi."
- "Saya simpan, dan muncul notifikasi sukses."

**B. READ (Lihat Data)**

- _(Scroll di menu Eksplor)_
- "Data 'Taman Kota' tadi langsung muncul di daftar ini. Ini membuktikan data berhasil 'Created' dan 'Read' dari database lokal."
- "Saya juga bisa mencarinya lewat Search Bar di atas."

**C. UPDATE (Edit Data)**

- _(Klik item 'Taman Kota', masuk ke Detail)_
- "Di halaman Detail, saya bisa klik tombol Edit (pensil)."
- "Saya ubah jam bukanya menjadi 08:00. Saya simpan."
- "Perubahan langsung terlihat real-time."

**D. DELETE (Hapus Data)**

- _(Di halaman Detail, klik tombol Sampah)_
- "Terakhir fitus Delete. Saat diklik, muncul konfirmasi aman 'Apakah Anda yakin?'. Jika ya, data terhapus dan hilang dari list."

---

## 4. Demonstrasi Maps & Lokasi (1 Menit)

_(Pindah ke tab Peta)_
"Aplikasi ini juga mengintegrasikan **OpenStreetMap**."

- "Di menu Peta, kita bisa melihat sebaran lokasi wisata di Purwokerto."
- "Marker ini interaktif, bisa diklik untuk melihat nama wisatanya."
- "Lokasi default aplikasi ini juga sudah diset ke **Alun-alun Purwokerto** sesuai permintaan studi kasus."

---

## 5. Penutup & Teknis (30 Detik)

"Sebagai penutup, aplikasi ini mengimplementasikan:

1.  **Full CRUD SQLite** untuk data persisten.
2.  **Flutter Map** untuk GIS.
3.  **UI/UX Modern** dengan widget Sliver dan Grid.
4.  **Struktur Code** yang rapi (terpisah antara Model, View, dan Database).

Sekian presentasi dari saya. Terima kasih.
Wassalamu’alaikum Wr. Wb."
