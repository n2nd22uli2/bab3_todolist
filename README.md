# 📝 To-Do List App

Aplikasi manajemen tugas sederhana berbasis **Flutter** dengan penyimpanan lokal menggunakan **SQLite** (via `sqflite`). Mendukung fitur tambah, edit, hapus, pencarian, dan filter status tugas.

---

## 📱 Tampilan Fitur

- ✅ Tambah & edit tugas (judul + deskripsi)
- 🗑️ Hapus tugas satu per satu atau hapus semua yang selesai
- 🔍 Pencarian tugas berdasarkan judul
- 🔽 Filter berdasarkan status: **Semua**, **Belum Selesai**, **Selesai**
- 💾 Data tersimpan secara lokal menggunakan SQLite
- 📅 Menampilkan tanggal pembuatan tugas

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                        # Entry point aplikasi
├── models/
│   └── todo.dart                    # Model data Todo
├── database/
│   └── database_helper.dart         # Singleton helper SQLite (CRUD)
└── screens/
    ├── todo_list_screen.dart        # Halaman utama daftar tugas
    └── todo_list_form.dart          # Form tambah & edit tugas
```

---

## 🚀 Cara Menjalankan

### Prasyarat

Pastikan sudah menginstall:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi stabil terbaru)
- Android Studio / VS Code dengan plugin Flutter & Dart
- Emulator Android / iOS atau perangkat fisik

### Langkah Instalasi

1. **Clone repositori ini**
   ```bash
   git clone https://github.com/username/todo-list-app.git
   cd todo-list-app
   ```

2. **Install dependensi**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📦 Dependensi

| Package | Versi | Kegunaan |
|--------|-------|---------|
| [`sqflite`](https://pub.dev/packages/sqflite) | ^2.x | Database SQLite lokal |
| [`path`](https://pub.dev/packages/path) | ^1.x | Manajemen path file database |

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
```

---

## 🗄️ Struktur Database

Nama database: `todo_database.db`

### Tabel: `todos`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER | Primary key, auto increment |
| `title` | TEXT | Judul tugas (wajib diisi) |
| `description` | TEXT | Deskripsi tugas (opsional) |
| `isDone` | INTEGER | Status: `0` = belum selesai, `1` = selesai |
| `createdAt` | TEXT | Waktu pembuatan (format ISO 8601) |

> Database mendukung migrasi (`onUpgrade`): versi 2 menambahkan kolom `priority`.

---

## ⚙️ Fitur Database (DatabaseHelper)

| Method | Fungsi |
|--------|--------|
| `insertTodo(todo)` | Menambah tugas baru |
| `getTodos({statusFilter, keyword})` | Mengambil daftar tugas dengan filter & pencarian |
| `getAllTodos()` | Mengambil semua tugas tanpa filter |
| `getTodoById(id)` | Mengambil satu tugas berdasarkan ID |
| `updateTodo(todo)` | Memperbarui data tugas |
| `toggleTodoStatus(id, isDone)` | Mengubah status selesai/belum |
| `deleteTodo(id)` | Menghapus satu tugas |
| `clearCompletedTodos()` | Menghapus semua tugas yang selesai |

---

## 📋 Alur Penggunaan

```
Buka App
   │
   ▼
TodoListScreen (Halaman Utama)
   ├── 🔍 Cari tugas berdasarkan judul
   ├── 🏷️ Filter: Semua / Belum Selesai / Selesai
   ├── ☑️ Centang tugas → ubah status
   ├── ✏️ Tekan ikon edit → buka TodoFormScreen (mode edit)
   ├── 🗑️ Tekan ikon hapus → konfirmasi → hapus
   └── ➕ Tekan FAB → buka TodoFormScreen (mode tambah)

TodoFormScreen (Form Tugas)
   ├── Input judul (wajib)
   ├── Input deskripsi (opsional)
   └── Simpan → kembali ke halaman utama
```

---

## 🧩 Arsitektur

Proyek ini menggunakan pola **stateful widget** dengan pendekatan sederhana tanpa state management tambahan:

- **Model** → representasi data (`Todo`)
- **DatabaseHelper** → singleton yang mengelola semua operasi database
- **Screen** → UI yang langsung memanggil `DatabaseHelper` untuk membaca/menulis data

---

## 🛠️ Pengembangan Lebih Lanjut

Beberapa ide untuk pengembangan selanjutnya:

- [ ] Tambahkan fitur prioritas tugas (sudah disiapkan di skema database)
- [ ] Notifikasi / reminder untuk tugas
- [ ] Dark mode
- [ ] Kategori / label tugas
- [ ] State management (Provider / Riverpod / BLoC)
- [ ] Sinkronisasi cloud (Firebase)

---

## 📄 Lisensi

Proyek ini menggunakan lisensi [MIT](LICENSE).

---

> Dibuat dengan ❤️ menggunakan Flutter & SQLite
