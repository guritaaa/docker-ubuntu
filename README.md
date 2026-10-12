
# GURITA VPS - Ubuntu 22.04 Container

Image Docker Ubuntu 22.04 (LTS) yang dioptimasi sebagai environment VPS portabel berbasis OpenSSH Server, dilengkapi custom login banner, locale Asia/Jakarta, dan utilitas administrasi sistem lengkap.

---

## 🚀 Fitur Utama

- **Base Image:** Ubuntu 22.04 LTS (`amd64`).
- **Pre-Configured SSH:** Layanan OpenSSH Server siap pakai dengan regenerasi host key otomatis saat boot.
- **Custom MOTD & Login Banner:** Tampilan pre-auth banner dan ringkasan status sistem interaktif (User, Uptime, Tanggal).
- **Network & System Tools:** Sudah mencakup `curl`, `wget`, `htop`, `net-tools`, `iproute2`, `rsync`, `socat`, `jq`, `vim`, dan `tmux`.
- **Timezone & Locale:** Dikonfigurasi default ke timezone `Asia/Jakarta` (WIB) dan `en_US.UTF-8`.

---

## 🛠️ Prasyarat

Pastikan Docker Engine sudah terpasang di sistem Anda:
```bash
docker --version

```

---

## 📦 Build Image

Clone repository atau simpan `Dockerfile` di direktori kerja Anda, lalu jalankan perintah build:

```bash
# Build dengan default password (root)
docker build -t gurita-ubuntu .

# Build dengan custom root password
docker build -t gurita-ubuntu --build-arg ROOT_PASSWORD="PasswordKuatAnda123" .

```

---

## ▶️ Menjalankan Container

### 1. Jalankan di Background (Detached)

Petakan port host (misalnya `2222`) ke port SSH container (`22`):

```bash
docker run -d \
  --name gurita-vps \
  -p 2222:22 \
  --restart unless-stopped \
  gurita-ubuntu

```

### 2. Opsi Menggunakan Volume (Persisten Data)

Jika ingin menyimpan data home directory agar tidak hilang saat container dihapus:

```bash
docker run -d \
  --name gurita-vps \
  -p 2222:22 \
  -v gurita_data:/root \
  --restart unless-stopped \
  gurita-ubuntu

```

---

## 🔑 Mengakses Container via SSH

Setelah container berjalan, lakukan koneksi SSH dari terminal lokal atau client SSH (PuTTY/Termius):

```bash
ssh root@localhost -p 2222

```

*Masukkan password yang Anda tentukan pada saat build (default: `root`).*

---

## 🛑 Perintah Manajemen Container

| Tindakan | Perintah |
| --- | --- |
| **Cek status container** | `docker ps -f name=gurita-vps` |
| **Melihat log startup** | `docker logs gurita-vps` |
| **Stop container** | `docker stop gurita-vps` |
| **Start container** | `docker start gurita-vps` |
| **Masuk langsung via bash** | `docker exec -it gurita-vps /bin/bash` |
| **Hapus container** | `docker rm -f gurita-vps` |

---

## ⚠️ Catatan Keamanan

1. Jangan gunakan password bawaan (`root`) untuk server yang terhubung langsung ke internet publik.
2. Sangat disarankan untuk mengubah konfigurasi ke SSH Key Authentication (`AuthorizedKeys`) jika digunakan untuk lingkungan production.

```
