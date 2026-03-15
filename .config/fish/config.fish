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
    #  Stack: llama-swap · open-webui · searxng · redis
    #  Place in: ~/.config/fish/functions/ (one file per function)
    #  or source from ~/.config/fish/config.fish
    # ============================================================

    # ── Start ────────────────────────────────────────────────────
    function ai-up
        echo "🚀 Starting AI stack..."
        # Uses docker compose so containers are created if missing
        docker compose -f /home/arukast/ai-stack/docker-compose.yml up -d
        echo ""
        echo "💡 Waiting for health checks... run 'ai-status' in ~30s"
    end

    # ── Stop ─────────────────────────────────────────────────────
    function ai-down
        echo "🛑 Stopping AI stack..."
        # FIX: was referencing non-existent 'llama-embed' container
        # llama-swap manages the embedding server internally — no separate container
        docker stop open-webui llama-swap searxng redis 2>/dev/null
        echo "✅ All containers stopped"
    end

    # ── Restart single container ──────────────────────────────────
    function ai-restart
        if test (count $argv) -eq 0
            echo "Usage: ai-restart <container>"
            echo "Containers: open-webui llama-swap searxng redis"
            return 1
        end
        echo "🔄 Restarting $argv[1]..."
        docker restart $argv[1]
    end

    # ── Logs ─────────────────────────────────────────────────────
    function ai-log
        set lines 30
        if test (count $argv) -ge 1
            set lines $argv[1]
        end

        echo "<==================================> llama-swap <==================================>"
        # Filter health-check spam AND show only errors+model load events for clarity
        docker logs --tail $lines llama-swap 2>&1 \
            | grep -v "GET /health" \
            | grep -v "POST /health"
        echo ""
        echo "<==================================> open-webui <==================================>"
        docker logs --tail $lines open-webui 2>&1
        echo ""
        echo "<==================================> searxng <==================================>"
        docker logs --tail $lines searxng 2>&1
        echo ""
        echo "<==================================> redis <==================================>"
        docker logs --tail $lines redis 2>&1
    end

    # ── Follow a single container's logs live ────────────────────
    function ai-follow
        if test (count $argv) -eq 0
            echo "Usage: ai-follow <container>"
            echo "Containers: open-webui llama-swap searxng redis"
            return 1
        end
        set container $argv[1]
        if test "$container" = "llama-swap"
            docker logs -f llama-swap 2>&1 | grep -v "GET /health"
        else
            docker logs -f $container
        end
    end

    # ── Status ───────────────────────────────────────────────────
    function ai-status
        echo "=== Docker containers ==="
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
            --filter "name=open-webui" \
            --filter "name=llama-swap" \
            --filter "name=searxng" \
            --filter "name=redis"
        echo ""

        echo "=== llama-server processes (spawned by llama-swap) ==="
        set procs (ps aux | grep llama-server | grep -v grep)
        if test -n "$procs"
            echo $procs
        else
            echo "  (none running — no model currently loaded)"
        end
        echo ""

        echo "=== GPU VRAM ==="
        nvidia-smi --query-gpu=name,memory.used,memory.free,memory.total,utilization.gpu \
            --format=csv,noheader,nounits \
            | awk -F',' '{
                printf "  GPU:  %s\n", $1
                printf "  VRAM: %s MiB used / %s MiB free / %s MiB total\n", $2, $3, $4
                printf "  Util: %s%%\n", $5
            }'
        echo ""

        echo "=== Loaded model (llama-swap) ==="
        curl -sf http://localhost:8000/v1/models 2>/dev/null \
            | python3 -c "
    import sys, json
    try:
        data = json.load(sys.stdin)
        models = data.get('data', [])
        if models:
            for m in models:
                print('  ✅ Active:', m['id'])
        else:
            print('  (no model loaded — idle)')
    except:
        print('  (llama-swap not reachable)')
    " 
    end

    # ── Quick VRAM watch (live) ───────────────────────────────────
    function ai-gpu
        watch -n 1 "nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu,temperature.gpu --format=csv,noheader"
    end

    # ── Update llama.cpp and rebuild ─────────────────────────────
    function ai-update
        set LLAMA_DIR /home/arukast/llama.cpp

        echo "🔄 Pulling latest llama.cpp..."
        cd $LLAMA_DIR || begin
            echo "❌ Directory $LLAMA_DIR not found"
            return 1
        end

        set before (git rev-parse --short HEAD)
        git pull
        set after (git rev-parse --short HEAD)

        if test "$before" = "$after"
            echo "✅ Already up to date ($before) — no rebuild needed"
            return 0
        end

        echo "📝 Changes since $before:"
        git log --oneline $before..HEAD
        echo ""

        echo "🔨 Rebuilding with ccache..."
        rm -rf build
        cmake -B build \
            -DGGML_CUDA=ON \
            -DCMAKE_CUDA_ARCHITECTURES=86 \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_COMPILER_LAUNCHER=ccache \
            -DCMAKE_CXX_COMPILER_LAUNCHER=ccache

        if cmake --build build -j(nproc)
            echo ""
            echo "✅ Build successful! New version: "(git rev-parse --short HEAD)
            echo "💡 Run 'ai-down && ai-up' to apply changes"
            echo ""
            ccache --show-stats --verbose | grep -E "cache hit|cache miss|files in cache|cache size"
        else
            echo "❌ Build failed — containers still running old binary"
            return 1
        end
    end

    # ── Test all endpoints are reachable ─────────────────────────
    function ai-test
        echo "🔍 Testing stack endpoints..."
        echo ""

        # llama-swap health
        set swap_status (curl -sf -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null)
        if test "$swap_status" = "200"
            echo "  ✅ llama-swap    http://localhost:8000   ($swap_status)"
        else
            echo "  ❌ llama-swap    http://localhost:8000   (got: $swap_status)"
        end

        # open-webui
        set webui_status (curl -sf -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null)
        if test "$webui_status" = "200"
            echo "  ✅ open-webui    http://localhost:8080   ($webui_status)"
        else
            echo "  ❌ open-webui    http://localhost:8080   (got: $webui_status)"
        end

        # searxng
        set searx_status (curl -sf -o /dev/null -w "%{http_code}" http://localhost:8888 2>/dev/null)
        if test "$searx_status" = "200"
            echo "  ✅ searxng       http://localhost:8888   ($searx_status)"
        else
            echo "  ❌ searxng       http://localhost:8888   (got: $searx_status)"
        end

        # redis
        set redis_ok (docker exec redis redis-cli ping 2>/dev/null)
        if test "$redis_ok" = "PONG"
            echo "  ✅ redis         localhost:6379          (PONG)"
        else
            echo "  ❌ redis         localhost:6379          (no response)"
        end

        # embedding server
        set embed_status (curl -sf -o /dev/null -w "%{http_code}" http://localhost:8002/health 2>/dev/null)
        if test "$embed_status" = "200"
            echo "  ✅ embeddings    http://localhost:8002   ($embed_status)"
        else
            echo "  ❌ embeddings    http://localhost:8002   (got: $embed_status — model may not be loaded yet)"
        end
    end

    # ── Load a specific model on demand ──────────────────────────
    function ai-load
        if test (count $argv) -eq 0
            echo "Usage: ai-load <model-name>"
            echo ""
            echo "Available models (from llama-swap config):"
            echo "  DeepSeek-R1-0528-Qwen3-8B-UD-Q4_K_XL"
            echo "  Llama-3.1-8B-Instruct-UD-Q4_K_XL"
            echo "  Qwen3.5-9B-UD-Q3_K_XL"
            echo "  Qwen3-VL-8B-Instruct"
            echo "  bge-m3-q8_0.gguf"
            return 1
        end

        set model $argv[1]
        echo "📦 Requesting model load: $model"
        set response (curl -sf -w "\n%{http_code}" \
            http://localhost:8000/v1/chat/completions \
            -H "Content-Type: application/json" \
            -d "{\"model\": \"$model\", \"messages\": [{\"role\": \"user\", \"content\": \"hi\"}], \"max_tokens\": 1}" \
            2>/dev/null)
        echo "Response: $response"
    end
end

set -x CCACHE_DIR /home/arukast/.ccache
set -x CCACHE_MAXSIZE 5G

fish_add_path /home/arukast/.spicetify
