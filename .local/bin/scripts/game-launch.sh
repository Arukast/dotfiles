#!/bin/bash
# ==============================================================================
# game-launch.sh - Universal Gaming Optimizer & GPU Selector Script
# ==============================================================================
#
# TUTORIAL & USAGE:
# 
# 1. RUN ON NVIDIA RTX 3050 (High Performance Mode - Default):
#    Use this mode for demanding 3D games.
#    - In Steam Launch Options:
#      /home/arukast/.local/bin/game-launch.sh %command%
#    - From Terminal:
#      /home/arukast/.local/bin/game-launch.sh ./game-executable
#
# 2. RUN ON AMD R5 INTEGRATED GPU (iGPU / Power Saving Mode):
#    Use this mode for 2D games, visual novels, emulation, or playing on battery.
#    - In Steam Launch Options:
#      /home/arukast/.local/bin/game-launch.sh --igpu %command%
#    - From Terminal:
#      /home/arukast/.local/bin/game-launch.sh --igpu ./game-executable
#
# 3. GAMESCOPE INTEGRATION (Wayland/Hyprland Anti-Stutter & Proton Fix):
#    Gamescope runs the game in a nested micro-compositor, fixing Wayland & Proton bugs.
#    It is auto-enabled by default if the 'gamescope' command is installed.
#
#    - Customizing Gamescope Output Resolution & Refresh Rate:
#      (It auto-detects your active monitor's resolution/Hz via hyprctl, but you can override):
#      GAMESCOPE_WIDTH=2560 GAMESCOPE_HEIGHT=1440 GAMESCOPE_REFRESH=144 /home/arukast/.local/bin/game-launch.sh %command%
#
#    - Premium AMD FSR Upscaling (Render at 720p, upscale to 1080p using FSR):
#      GAMESCOPE_RENDER_WIDTH=1280 GAMESCOPE_RENDER_HEIGHT=720 /home/arukast/.local/bin/game-launch.sh %command%
#
#    - Disable Gamescope (Run game directly in your desktop workspace):
#      USE_GAMESCOPE=0 /home/arukast/.local/bin/game-launch.sh %command%
#
# ==============================================================================

if [ "$1" = "--igpu" ]; then
    shift # Remove --igpu argument so it doesn't get passed to the game
    
    # --- 1: AMD INTEGRATED GPU MODE ---
    # Natively route all Vulkan requests to your AMD Radeon iGPU driver
    export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.json
    
    # Mesa Shader Cache Optimizations (prevents stuttering on AMD)
    export MESA_SHADER_CACHE_DIR="$HOME/.cache/mesa_shaders"
    export MESA_SHADER_CACHE_MAX_SIZE="10G"
    mkdir -p "$MESA_SHADER_CACHE_DIR"
    
else
    # --- 2: NVIDIA DEDICATED GPU MODE (DEFAULT) ---
    # Natively offloads rendering to the NVIDIA GPU (PRIME Offload)
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    # NVIDIA Shader Cache (Anti-Stutter)
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nvidia_shaders"
    export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
    export __GL_SHADER_DISK_CACHE_SIZE=10737418240 # 10GB Cache
    mkdir -p "$__GL_SHADER_DISK_CACHE_PATH"

    # NVIDIA Stutter & Latency Fixes
    export __GL_GSYNC_ALLOWED=1
    export __GL_VRR_ALLOWED=1
    export __GL_THREADED_OPTIMIZATIONS=1
    export vblank_mode=0 

    # Nvidia yield optimization (Busy-wait instead of yielding CPU on Wayland/Hyprland)
    export __GL_YIELD="NOTHING"
fi

# --- 3: COMMON SETTINGS (Active for both GPUs) ---
export MANGOHUD_DLSYM=1

# --- 4: GAMESCOPE CONFIGURATION & EXECUTION ---
# Gamescope runs the game in a nested Wayland session to fix Proton/Wayland compatibility issues.
if command -v gamescope &>/dev/null && [ "${USE_GAMESCOPE:-1}" != "0" ]; then
    echo "[game-launch] Gamescope detected! Initializing nested compositor..." >&2

    # Dynamic monitor resolution & refresh rate detection for Hyprland
    DETECTED_W=""
    DETECTED_H=""
    DETECTED_R=""

    if command -v hyprctl &>/dev/null && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        # Try JSON parsing with jq if available
        if command -v jq &>/dev/null; then
            MONITOR_INFO=$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | "\(.width) \(.height) \(.refreshRate)"' 2>/dev/null)
            if [ -z "$MONITOR_INFO" ] || [ "$MONITOR_INFO" = "null null null" ]; then
                MONITOR_INFO=$(hyprctl -j monitors 2>/dev/null | jq -r '.[0] | "\(.width) \(.height) \(.refreshRate)"' 2>/dev/null)
            fi
            if [ -n "$MONITOR_INFO" ] && [ "$MONITOR_INFO" != "null null null" ]; then
                read -r DETECTED_W DETECTED_H DETECTED_R <<< "$MONITOR_INFO"
            fi
        fi
        
        # Fallback to text parsing if jq is not present or failed
        if [ -z "$DETECTED_W" ]; then
            RAW_LINE=$(hyprctl monitors 2>/dev/null | grep -E -o '[0-9]+x[0-9]+@[0-9.]+' | head -n 1)
            if [ -n "$RAW_LINE" ]; then
                DETECTED_W=$(echo "$RAW_LINE" | cut -d'x' -f1)
                DETECTED_H=$(echo "$RAW_LINE" | cut -d'x' -f2 | cut -d'@' -f1)
                DETECTED_R=$(echo "$RAW_LINE" | cut -d'@' -f2 | cut -d'.' -f1)
            fi
        fi
    fi

    # Set final display parameters (Defaulting to 1920x1080@60 if undetected)
    GAMESCOPE_W="${GAMESCOPE_WIDTH:-${DETECTED_W:-1920}}"
    GAMESCOPE_H="${GAMESCOPE_HEIGHT:-${DETECTED_H:-1080}}"
    GAMESCOPE_R="${GAMESCOPE_REFRESH:-${DETECTED_R:-60}}"

    # Clean float refresh rate to integer
    if [[ "$GAMESCOPE_R" == *.* ]]; then
        GAMESCOPE_R=$(echo "$GAMESCOPE_R" | cut -d'.' -f1)
    fi

    GAMESCOPE_ARGS=(
        "-W" "$GAMESCOPE_W"
        "-H" "$GAMESCOPE_H"
        "-r" "$GAMESCOPE_R"
        "-f"                     # Force Fullscreen
        "--force-grab-cursor"    # Ensure cursor stays locked in game
    )

    # Optional Render Resolution & FSR Upscaling (e.g. gamescope -w 1280 -h 720 -F fsr)
    if [ -n "$GAMESCOPE_RENDER_WIDTH" ] && [ -n "$GAMESCOPE_RENDER_HEIGHT" ]; then
        GAMESCOPE_ARGS+=("-w" "$GAMESCOPE_RENDER_WIDTH" "-h" "$GAMESCOPE_RENDER_HEIGHT")
        if [ "$GAMESCOPE_RENDER_WIDTH" -lt "$GAMESCOPE_W" ]; then
            echo "[game-launch] Render resolution is lower than display. Enabling AMD FSR upscaling!" >&2
            GAMESCOPE_ARGS+=("-F" "fsr")
        fi
    fi

    # Execute game within Gamescope (nested Wayland) + GameMode + MangoHud
    if [ -z "$VK_DRIVER_FILES" ]; then
        # NVIDIA Dedicated GPU Mode (Default)
        # We run Gamescope itself on the display-driving AMD iGPU (highly stable)
        # and offload the game inside Gamescope to the NVIDIA dGPU.
        echo "[game-launch] NVIDIA mode: Running Gamescope on iGPU and offloading game to dGPU..." >&2

        # Unset offload variables for the gamescope compositor process
        unset __NV_PRIME_RENDER_OFFLOAD
        unset __GLX_VENDOR_LIBRARY_NAME
        unset __VK_LAYER_NV_optimus

        # Execute gamescope on iGPU, and pass offload + Nvidia env vars to the game inside
        exec gamescope "${GAMESCOPE_ARGS[@]}" -- env \
            __NV_PRIME_RENDER_OFFLOAD=1 \
            __GLX_VENDOR_LIBRARY_NAME=nvidia \
            __VK_LAYER_NV_optimus=NVIDIA_only \
            __GL_SHADER_DISK_CACHE=1 \
            __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nvidia_shaders" \
            __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 \
            __GL_SHADER_DISK_CACHE_SIZE=10737418240 \
            __GL_GSYNC_ALLOWED=1 \
            __GL_VRR_ALLOWED=1 \
            __GL_THREADED_OPTIMIZATIONS=1 \
            vblank_mode=0 \
            __GL_YIELD="NOTHING" \
            gamemoderun mangohud "$@"
    else
        # AMD Integrated GPU Mode
        echo "[game-launch] Running: gamescope ${GAMESCOPE_ARGS[*]} -- gamemoderun mangohud $*" >&2
        exec gamescope "${GAMESCOPE_ARGS[@]}" -- gamemoderun mangohud "$@"
    fi
else
    # Fallback / Directly execute without gamescope if not installed or disabled
    if [ "${USE_GAMESCOPE:-1}" = "0" ]; then
        echo "[game-launch] Gamescope is explicitly disabled. Running directly..." >&2
    else
        echo "[game-launch] Warning: 'gamescope' command not found! Please install gamescope. Running directly..." >&2
    fi
    exec gamemoderun mangohud "$@"
fi
