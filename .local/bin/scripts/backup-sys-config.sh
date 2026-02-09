#!/bin/bash

# ================= KONFIGURASI =================
# GANTI BAGIAN INI SESUAI LOKASI DRIVE EKSTERNAL ANDA
# Tips: Cek lokasi mount dengan perintah `lsblk` atau `df -h`
# Contoh: "/run/media/budi/DATA_DRIVE/Backup_System"
BACKUP_DIR="/run/media/USERNAME/NAMA_DRIVE/Arch_Config_Backup"

# Buat folder berdasarkan tanggal hari ini
DATE=$(date +%Y-%m-%d)
TARGET="$BACKUP_DIR/$DATE"

# Cek apakah script dijalankan sebagai Root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Script ini harus dijalankan dengan sudo!"
  echo "Gunakan: sudo ./backup-sys-config.sh"
  exit 1
fi

# Cek apakah drive eksternal terpasang
if [ ! -d "$BACKUP_DIR" ]; then
    echo "⚠️  Peringatan: Folder tujuan tidak ditemukan!"
    echo "Mencoba membuat folder induk di: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Cek lagi jika gagal membuat (misal drive belum dicolok)
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "❌ Gagal. Pastikan Drive Eksternal sudah dimount."
        exit 1
    fi
fi

echo "=== 🚀 Memulai Backup Konfigurasi Sistem ke: $TARGET ==="
mkdir -p "$TARGET"

# ================= DAFTAR FILE PENTING =================
# Tambahkan file lain di sini jika perlu
FILES=(
    "/etc/fstab"                  # Tabel partisi & mount point (Nyawa OS)
    "/etc/default/grub"           # Settingan Bootloader & Kernel Parameters
    "/etc/mkinitcpio.conf"        # Config Module Kernel (Penting untuk NVIDIA)
    "/etc/pacman.conf"            # Config repo pacman
    "/etc/hostname"               # Nama komputer
    "/etc/hosts"                  # Network mapping lokal
    "/etc/locale.gen"             # Bahasa sistem
    "/etc/locale.conf"            # Config bahasa
    "/etc/vconsole.conf"          # Config font terminal
    "/etc/nftables.conf"          # Firewall Rules (Karena Anda pakai nftables)
    "/etc/modprobe.d"             # Config Module tambahan (NVIDIA options dll)
    "/etc/udev/rules.d"           # Aturan hardware khusus
    "/etc/systemd/system"         # Service custom yang mungkin Anda buat
    # --- KONFIGURASI DNS KHUSUS (Unbound & DNSCrypt) ---
    # Membackup satu folder penuh agar semua file config & rules terbawa
    "/etc/unbound"            # Berisi unbound.conf dan root.hints
    "/etc/dnscrypt-proxy"     # Berisi dnscrypt-proxy.toml, forwarding-rules, blacklist, dll
    
    # --- OPSIONAL: NetworkManager (Hati-hati, isi Password WiFi!) ---
    # Hapus baris di bawah ini jika Anda ingin upload hasil backup ke GitHub
    "/etc/NetworkManager/system-connections" 
)

# ================= PROSES COPY =================

for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        # cp --parents akan membuat folder tree otomatis
        # misal: /etc/fstab akan disimpan di $TARGET/etc/fstab
        cp -r --parents "$file" "$TARGET"
        echo "✅ OK: $file"
    else
        echo "Example: ⚠️  Skip (File tidak ada): $file"
    fi
done

# ================= BACKUP DAFTAR PAKET (BONUS) =================
# Ini berguna agar Anda tahu aplikasi apa saja yang terinstall di sistem ini
echo "📦 Membackup daftar aplikasi terinstall..."
pacman -Qqe > "$TARGET/pkglist_native.txt"
pacman -Qqm > "$TARGET/pkglist_aur.txt"

echo "======================================================="
echo "🎉 Backup Selesai!"
echo "Lokasi: $TARGET"
echo "======================================================="
