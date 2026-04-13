function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'

    # --- Modified commands ---
    # Cek apakah colordiff terinstall
    if type -q colordiff
        alias diff 'colordiff'
    end

    alias grep 'grep --color=auto'
    alias more 'less'
    alias df 'df -h'
    alias du 'du -c -h'
    alias mkdir 'mkdir -p -v'
    alias nano 'nano -w'
    alias ping 'ping -c 5'
    
    # dmesg sering butuh sudo, kita set aman
    alias dmesg 'dmesg -HL'

    # --- New commands ---
    alias da 'date "+%A, %B %d, %Y [%T]"'
    alias du1 'du --max-depth=1'
    alias hist 'history | grep'
    alias openports 'ss --all --numeric --processes --ipv4 --ipv6'
    alias pgg 'ps -Af | grep'
    alias .. 'cd ..'
    alias spotify_spicetify 'spicetify config spotify_path "/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify" && spicetify config prefs_path /home/arukast/.var/app/com.spotify.Client/config/spotify/prefs && sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify && sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps && spicetify backup apply'

    # --- Privileged access ---
    # Logika "if UID != 0" versi Fish
    if test (id -u) -ne 0
        alias scat 'sudo cat'
        alias svim 'sudoedit'
        alias root 'sudo -i'
        alias reboot 'sudo systemctl reboot'
        alias poweroff 'sudo systemctl poweroff'
        alias update 'printf "\nUpdating pacman packages...\n" && sudo pacman -Syu && printf "\nUpdating AUR packages...\n" && yay -Syu && printf "\nUpdating Flatpak packages...\n" && flatpak update'
        alias netctl 'sudo netctl'
        
        # Catatan: Trik "alias sudo='sudo '" ala Bash tidak jalan di Fish.
        # Fish punya cara parsing berbeda, jadi sudo ll (alias) mungkin tidak jalan 
        # kecuali Anda membuat fungsi wrapper, tapi sudo ls -l tetap jalan.
    end

    # --- ls aliases ---
    alias ls 'ls -hF --color=auto'
    alias lr 'ls -R'
    alias ll 'ls -l'
    alias la 'll -A'
    alias lx 'll -BX'
    alias lz 'll -rS'
    alias lt 'll -rt'
    alias lm 'la | more'

    # --- Safety features ---
    alias cp 'cp -i'
    alias mv 'mv -i'
    
    # Versi RM aman pilihan Anda
    alias rm 'rm -Iv --one-file-system'
    
    alias ln 'ln -i'
    alias chown 'chown --preserve-root'
    alias chmod 'chmod --preserve-root'
    alias chgrp 'chgrp --preserve-root'
    
    # Fish menggunakan printf agar lebih konsisten daripada echo -ne
    alias cls 'printf "\033c"'

    # --- Make Shell error tolerant ---
    alias :q 'exit'
    alias :Q 'exit'
    alias :x 'exit'
    alias cd.. 'cd ..'

    # Cek apakah SSD menggunakan driver ntfs3 atau ntfs-3g (fuse)
    alias checkmount 'mount | grep -E "sd[a-z][0-9]"'

    # Cek apakah TRIM didukung oleh hardware/enclosure (Lihat kolom DISC-GRAN)
    # Jika nilainya bukan 0B, berarti TRIM didukung
    alias checktrim 'lsblk -d -o NAME,SIZE,MODEL,DISC-GRAN,DISC-MAX'

    # Cek status "dirty" NTFS tanpa melakukan perubahan (Dry run)
    # alias checkntfs 'sudo ntfsfix -n /dev/sda2'

    # Jalankan TRIM secara manual pada semua drive yang mendukung
    alias dotrim 'sudo fstrim -av'

    # ============================================================
    #  AI Stack — Fish Shell Functions
    #  Place in: ~/.config/fish/functions/ (one file per function)
    #  or source from ~/.config/fish/config.fish
    # ============================================================

    set -g AI_COMPOSE_FILE /home/arukast/ai-stack/docker-compose.yml

    # ── Start ────────────────────────────────────────────────────
    function ai-up
        docker compose -f $AI_COMPOSE_FILE up -d
    end

    # ── Stop ─────────────────────────────────────────────────────
    function ai-down
        docker compose -f $AI_COMPOSE_FILE down
    end

    # ── Restart ──────────────────────────────────────────────────
    function ai-restart
        if test (count $argv) -eq 0
            docker compose -f $AI_COMPOSE_FILE restart
        else
            docker restart $argv[1]
        end
    end

    # ── Logs ─────────────────────────────────────────────────────
    function ai-log
        set lines (test (count $argv) -ge 1; and echo $argv[1]; or echo 30)
        for c in llama-swap open-webui searxng redis
            echo -e "\n=== $c ==="
            docker logs --tail $lines $c 2>&1 | grep -vE "(GET|POST) /health"
        end
    end

    # ── Follow live logs ─────────────────────────────────────────
    function ai-follow
        if test (count $argv) -eq 0
            echo "Usage: ai-follow <container>"
            return 1
        end
        docker logs -f $argv[1] 2>&1 | grep -vE "(GET|POST) /health"
    end

    # ── Status ───────────────────────────────────────────────────
    function ai-status
        echo "=== Docker Containers ==="
        docker compose -f $AI_COMPOSE_FILE ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
        
        echo -e "\n=== GPU VRAM ==="
        nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv,noheader | awk -F',' '{printf "  %s | Used: %s | Free: %s | Util: %s\n", $1, $2, $3, $4}'
        
        echo -e "\n=== Active Models ==="
        curl -sf http://localhost:8000/v1/models | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | sed 's/^/  ✅ /' || echo "  (no model loaded / unreachable)"
    end

    # ── Quick VRAM watch (live) ──────────────────────────────────
    function ai-gpu
        watch -n 1 "nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu,temperature.gpu --format=csv,noheader"
    end

    # ── Update Stack ─────────────────────────────────────────────
    function ai-update
        # Mengganti kompilasi lokal dengan pembaruan Docker image 
        # karena llama-swap menggunakan binary internalnya sendiri.
        docker compose -f $AI_COMPOSE_FILE pull
        docker compose -f $AI_COMPOSE_FILE up -d
        docker image prune -f
    end

    # ── Test Endpoints ───────────────────────────────────────────
    function ai-test
        set endpoints \
            "llama-swap:http://localhost:8000/health" \
            "open-webui:http://localhost:8080" \
            "searxng:http://localhost:8888" \
            "embeddings:http://localhost:8002/health"

        for ep in $endpoints
            set name (echo $ep | cut -d: -f1)
            set url (echo $ep | cut -d: -f2-)
            set status (curl -sf -o /dev/null -w "%{http_code}" $url)
            if test "$status" = "200"
                echo "  ✅ $name ($url)"
            else
                echo "  ❌ $name (status: $status)"
            end
        end

        if docker exec redis redis-cli ping >/dev/null 2>&1
            echo "  ✅ redis (localhost:6379)"
        else
            echo "  ❌ redis (no response)"
        end
    end

    # ── Load Model ───────────────────────────────────────────────
    function ai-load
        if test (count $argv) -eq 0
            echo "Usage: ai-load <model-name>"
            echo "Models (from llama-swap.yaml):"
            echo "  DeepSeek-R1-0528-Qwen3-8B-UD-Q4_K_XL"
            echo "  Qwen 3.5-9B-UD-Q3_K_XL"
            echo "  Qwen 3.5-9B [Thinking · General]"
            echo "  Qwen 3.5-9B [Thinking · Coding]"
            echo "  Qwen 3.5-9B [Instruct · General]"
            echo "  Qwen 3.5-9B [Instruct · Reasoning]"
            return 1
        end
        curl -sf -w "\nHTTP %{http_code}\n" http://localhost:8000/v1/chat/completions \
            -H "Content-Type: application/json" \
            -d "{\"model\": \"$argv[1]\", \"messages\": [{\"role\": \"user\", \"content\": \"hi\"}], \"max_tokens\": 1}"
    end
end

set -x CCACHE_DIR /home/arukast/.ccache
set -x CCACHE_MAXSIZE 5G

fish_add_path /home/arukast/.spicetify
