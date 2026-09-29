HELLO, STRANGER — EXHIBITION BUILD
=================================

WHAT CHANGED
------------
1. Settings diramping menjadi kontrol yang relevan: master volume, fullscreen, dan LAN server URL.
2. Tujuh quest unik, satu per day/level, dengan tantangan makin kompleks.
3. Timer per day mengecil: 5:00, 4:30, 4:00, 3:30, 3:00, 2:30, 2:00.
4. NPC diacak setiap day tetapi tetap diam di dalam lokasi zonanya: Kantin, Lapangan, Kelas, Perpustakaan.
5. Pa Adrian dan Bu Veyra tetap ditempatkan di Kelas sesuai brief terbaru.
6. Dialog lebih natural dan selalu memakai username pemain.
7. Username pemain muncul di atas sprite MC.
8. Setiap day memiliki 2–3+ item yang dicari, interaksi NPC, dan logic/story question atau mini puzzle.
9. Ada optional bonus question untuk menambah run points tanpa memaksa semua pengunjung.
10. Score dipengaruhi completion, kecepatan, jumlah tantangan, dan perfect run.
11. Game over saat timer habis, retry quest tetap mempertahankan quest yang sudah selesai sebelumnya.
12. Ending setelah Day 7 selesai.
13. Leaderboard tidak memakai kolom rank. Menampilkan PLAYER, SCORE, QUESTS 1–7, TIME.
14. Leaderboard auto refresh setiap 2 detik.
15. Save per username. Save lokal + sinkronisasi LAN server.
16. Load Game menerima username dan mencoba server terlebih dahulu, lalu fallback ke local save.

QUEST FLOW
----------
DAY 1  Dua Barang yang Nyelip
- Bu Imas di Kantin
- Cari buku catatan + kertas pesanan
- Bonus logic question
- Kembali ke Bu Imas

DAY 2  Kelas, Clue, dan Satu Jawaban
- Bu Veyra di Kelas
- Cari 2 item
- Tanya Orin untuk clue
- Logic question sosial/voting
- Kembali ke Bu Veyra

DAY 3  Pesanan, Meja, dan Tebakannya
- Eira di Kantin
- Cari 2 item
- Tanya Bu Imas
- Logic question tentang petunjuk meja
- Kembali ke Eira

DAY 4  Rak Rahasia
- Sora di Perpustakaan
- Cari 3 buku
- Tanya Bu Veyra
- Logic category puzzle
- Kembali ke Sora

DAY 5  Latihan Belum Dimulai
- Mika di Lapangan
- Tanya Orin
- Cari bola
- Antar ke Lapangan
- Cari 2 cone
- Optional culture/logic question
- Kembali ke Mika

DAY 6  Deadline dan Lima Potongan
- Orin di Kelas
- Cari 2 halaman
- Tanya Bu Veyra
- Susun laporan 5 bagian
- Logic time question
- Kembali ke Orin

DAY 7  Tujuh Hari, Tiga Barang, Satu Clue
- Pa Adrian di Kelas
- Cari kartu, botol, topi di tiga zona berbeda
- Tanya Sora untuk clue
- Final deduction question
- Kembali ke Pa Adrian
- Ending

3-COMPUTER EXHIBITION
---------------------
PC C = SERVER + LEADERBOARD DISPLAY
- Jalankan: exhibition_server/start_server.bat
- Server default port: 8765
- Cari IPv4 PC C dengan `ipconfig`.
- Biarkan terminal server terbuka.

PC A/B = PLAYER
- Settings -> LAN SERVER
- Masukkan `http://IP-PC-C:8765`
- Save Settings
- Main seperti biasa.
- F5 menyimpan progress lokal + LAN.

PC C DISPLAY
- Jalankan server.
- Buka game.
- Buka Leaderboard.
- Data akan refresh otomatis.

TROUBLESHOOT
-------------
Kalau A/B tidak bisa connect:
- pastikan ketiga PC di Wi-Fi/LAN yang sama;
- pastikan port 8765 diizinkan Windows Firewall (Private Network);
- cek IP PC C dengan `ipconfig`;
- ping IP PC C dari A/B;
- pastikan URL Settings memakai IP PC C, bukan 127.0.0.1.

STATIC CHECK
------------
- Semua file referensi `res://` yang dianalisis tersedia.
- Tidak ada penggunaan `var :=` pada script utama hasil rework.
- Integer division yang berpotensi menjadi warning dibersihkan dengan pembagian float/floor.
- ZIP integrity diperiksa setelah build.

CATATAN JUJUR
-------------
Environment pembuatan ini tidak menyediakan executable Godot, jadi runtime F6/F5 tidak dapat dijalankan langsung di sandbox. Build disiapkan untuk Godot 4.x dan sudah melalui static/resource sanity checks.


V10 INPUT & GAMEPLAY
---------------------
- E = bicara / lanjut dialog.
- F = ambil item / menaruh item pada target yang ditunjuk.
- G = menyerahkan quest ke NPC pada tahap RETURN.
- TAB = buka/tutup inventory ringkas.
- F5 = save progress lokal + sinkronisasi LAN.
- ESC = pause menu (Save, Settings, Guide, Save & Exit).
- Panah kuning = arah target quest.
- Item demo memakai visual sparkle kuning procedural agar asset final bisa diganti tim tanpa mengubah sistem quest.
- Day 1 dua item dicari di Lapangan karena interior masih menjadi area yang sedang disempurnakan.
- Spawn item dipilih acak dari spot yang tersedia di zona quest.
- Dialog player memakai portrait sesuai gender dan username yang diinput.
- Label NPC/MC dikecilkan dan diskalakan agar tetap terbaca tanpa menutupi map.
