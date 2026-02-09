#!/bin/bash

# --- KONFIGURASI ---
STATE_FILE="/tmp/hyprsunset_mode"
MANUAL_TEMP=5000

# Pastikan file state ada
if [ ! -f "$STATE_FILE" ]; then echo "auto" > "$STATE_FILE"; fi

# --- FUNGSI PRINT STATUS (UNTUK WAYBAR) ---
# Bagian ini membaca status untuk ditampilkan sebagai icon/text
print_status() {
    MODE=$(cat "$STATE_FILE")
    case $MODE in
        "auto")
            echo '{"text": "🕒 Auto", "tooltip": "Mode: Otomatis (Sesuai Config)", "class": "auto"}'
            ;;
        "manual")
            echo '{"text": "🌙 On", "tooltip": "Mode: Manual ('$MANUAL_TEMP'K)", "class": "manual"}'
            ;;
        "off")
            echo '{"text": "☀️ Off", "tooltip": "Mode: Mati Total", "class": "off"}'
            ;;
    esac
}

# --- FUNGSI TOGGLE (LOGIKA GANTI MODE) ---
if [ "$1" == "toggle" ]; then
    # Baca mode saat ini
    CURRENT=$(cat "$STATE_FILE")

    # Matikan process hyprsunset yang lama (HANYA binary, bukan script ini)
    # Menggunakan -x (exact) atau killall agar script tidak bunuh diri
    pkill -x hyprsunset || true
    
    # Tunggu sebentar untuk memastikan process mati
    sleep 0.1

    case $CURRENT in
        "auto")
            # Auto -> Manual
            # Jalankan mode manual, lepaskan dari shell (disown)
            hyprsunset --temperature $MANUAL_TEMP > /dev/null 2>&1 & disown
            NEW_MODE="manual"
            ;;
        "manual")
            # Manual -> Off
            # Tidak menyalakan apa-apa
            NEW_MODE="off"
            ;;
        *)
            # Off -> Auto
            # Jalankan tanpa argumen (baca config)
            hyprsunset > /dev/null 2>&1 & disown
            NEW_MODE="auto"
            ;;
    esac

    # Simpan state baru
    echo "$NEW_MODE" > "$STATE_FILE"

    # Update Waybar SEGERA
    pkill -SIGRTMIN+8 waybar
    
    # Keluar dengan sukses
    exit 0
else
    # Jika tidak ada argumen "toggle", jalankan print_status
    print_status
fi