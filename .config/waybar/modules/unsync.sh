#!/bin/bash

# --- KONFIGURASI ---
# Path ke folder git bare repository Anda
# Berdasarkan history Anda, path-nya adalah ~/.dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
WORK_TREE="$HOME"

# Perintah git khusus untuk bare repository
GIT_CMD="git --git-dir=$DOTFILES_DIR --work-tree=$WORK_TREE"

# --- LOGIKA PENGECEKAN ---

# 1. Cek apakah folder repo benar-benar ada
if [ ! -d "$DOTFILES_DIR" ]; then
    # Jika tidak ada repo, exit 1 agar modul hilang dari Waybar
    exit 1
fi

# 2. Hitung jumlah file yang berubah (Uncommitted changes)
# --porcelain memberikan output yang bersih untuk diparsing
UNCOMMITTED=$($GIT_CMD status --porcelain 2>/dev/null | wc -l)

# 3. Hitung jumlah commit yang belum di-push ke GitHub (Unpushed commits)
# Mengecek selisih antara HEAD lokal dengan upstream (origin/master atau main)
UNPUSHED=$($GIT_CMD log @{u}..HEAD --oneline 2>/dev/null | wc -l)

# Total perubahan yang perlu "disinkronkan"
TOTAL=$((UNCOMMITTED + UNPUSHED))

# --- OUTPUT KE WAYBAR ---

# Jika ada perubahan (Total > 0), tampilkan modul
if [ "$TOTAL" -gt 0 ]; then
    # Buat tooltip yang informatif
    TOOLTIP="Dotfiles: $UNCOMMITTED changed, $UNPUSHED unpushed"
    
    # Output format JSON sesuai requirement config waybar
    echo "{\"text\": \"$TOTAL\", \"tooltip\": \"$TOOLTIP\", \"class\": \"unsync\"}"
    
    # Exit 0 memberitahu 'exec-if' bahwa modul harus ditampilkan
    exit 0
else
    # Jika bersih (0 perubahan), exit 1 agar modul disembunyikan
    exit 1
fi