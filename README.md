# NusaEvent Hub

Aplikasi Flutter untuk menemukan seminar/workshop, melihat poster acara dan denah venue, serta melakukan pendaftaran tiket.

## Pengembangan UI/UX
- Header aplikasi dengan identitas NusaEvent Hub dan navigasi tiga tab.
- Hero banner bergradasi dengan ringkasan jumlah acara, kategori, dan tiket.
- Pencarian berdasarkan judul acara, pembicara, lokasi, dan kategori.
- Filter kategori dan ketersediaan kuota.
- Kartu acara dengan poster, informasi pembicara, jadwal, harga, dan status pendaftaran.
- Galeri poster dalam grid; poster dapat dibuka untuk melihat ukuran lebih besar.
- Denah venue menggunakan gambar dan mendukung zoom serta geser.
- Form pendaftaran, tiket terdaftar, dan pembatalan tiket tetap tersedia.

## Menjalankan aplikasi
1. Ekstrak folder project.
2. Buka folder `tugas_sesi_5` di VS Code.
3. Jalankan `flutter pub get`.
4. Jalankan `flutter run -d chrome` untuk menjalankan melalui Google Chrome, atau pilih emulator/perangkat dari VS Code.

## Aset gambar
Semua poster acara dan denah berada di `assets/images/`. Folder tersebut sudah didaftarkan pada bagian `assets` di `pubspec.yaml`.
