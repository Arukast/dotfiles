#!/bin/bash

# 1. Dictionary Bar (8 tingkat, angka 0 tetap jadi bar paling bawah)
bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"
for ((i=0; i<${#bar}; i++)); do
    dict="${dict}s/$i/${bar:$i:1}/g;"
done

# 2. Config Cava (Diatur agar irit resource)
config_file="/tmp/waybar_cava_config"
echo "[general]
# Framerate 20-25 sudah cukup halus untuk mata dan sangat irit CPU
framerate = 60
bars = 16

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7" > $config_file

# 3. Jalankan satu aliran data (Single Stream)
# Mematikan proses lama agar tidak tumpang tindih
pkill -f "cava -p $config_file"

# Langsung alirkan output cava ke sed tanpa loop Bash
# Ini meminimalisir penggunaan resource secara drastis
stdbuf -o0 cava -p "$config_file" | stdbuf -o0 sed -u "$dict"