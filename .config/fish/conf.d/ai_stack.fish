# ==============================================================================
# AI Stack — Fish Shell Functions (~/.config/fish/conf.d/ai_stack.fish)
# Automatically sourced by Fish Shell
# ==============================================================================

set -g AI_COMPOSE_FILE "$HOME/ai-stack/docker-compose.yml"

# ── Start Stack ────────────────────────────────────────────────
function ai-up
    docker compose -f $AI_COMPOSE_FILE up -d
end

# ── Stop Stack ─────────────────────────────────────────────────
function ai-down
    docker compose -f $AI_COMPOSE_FILE down
end

# ── Restart Services ───────────────────────────────────────────
function ai-restart
    if test (count $argv) -eq 0
        docker compose -f $AI_COMPOSE_FILE restart
    else
        docker restart $argv[1]
    end
end

# ── Logs Summary ───────────────────────────────────────────────
function ai-log
    set lines (test (count $argv) -ge 1; and echo $argv[1]; or echo 30)
    for c in llama-swap open-webui searxng redis
        printf "\n=== %s ===\n" "$c"
        docker logs --tail $lines $c 2>&1 | grep -vE "(GET|POST) /health"
    end
end

# ── Follow Live Logs ───────────────────────────────────────────
function ai-follow
    if test (count $argv) -eq 0
        echo "Usage: ai-follow <container>"
        return 1
    end
    docker logs -f $argv[1] 2>&1 | grep -vE "(GET|POST) /health"
end

# ── Stack Status & GPU Info ────────────────────────────────────
function ai-status
    echo "=== Docker Containers ==="
    docker compose -f $AI_COMPOSE_FILE ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

    printf "\n=== GPU VRAM ===\n"
    nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv,noheader | awk -F',' '{printf "  %s | Used: %s | Free: %s | Util: %s\n", $1, $2, $3, $4}'

    printf "\n=== Active Models ===\n"
    curl -sf http://localhost:8000/v1/models | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | sed 's/^/  ✅ /' || echo "  (no model loaded / unreachable)"
end

# ── Quick VRAM Watch (Live) ────────────────────────────────────
function ai-gpu
    watch -n 1 "nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu,temperature.gpu --format=csv,noheader"
end

# ── Update Docker Stack ────────────────────────────────────────
function ai-update
    docker compose -f $AI_COMPOSE_FILE pull
    docker compose -f $AI_COMPOSE_FILE up -d
    docker image prune -f
end

# ── Test Endpoints ─────────────────────────────────────────────
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

# ── Load Model into llama-swap ─────────────────────────────────
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
