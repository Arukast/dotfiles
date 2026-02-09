#!/usr/bin/env python
from pynvml import *
from ctypes import byref

# --- KONFIGURASI USER ---
OFFSET_MHZ = 175        # Core Undervolt (Sweet Spot Anda) | Nilai undervolt (mulai dari 100-200)
MAX_CLOCK_MHZ = 1735    # Target max boost clock
MIN_CLOCK_MHZ = 210     # Idle Clock
MEM_OFFSET_MHZ = 1000    # Memory Overclock (+500 adalah start aman) Mengikuti dengan setingan MSI Afterburner INPUT 1000 = HASIL +500 MHz Efektif
# ------------------------

try:
    nvmlInit()
    device = nvmlDeviceGetHandleByIndex(0)

    # 1. Set Locked Clocks (Min & Max Frequency)
    # Ini mencegah GPU boost berlebihan yang boros daya/panas.
    nvmlDeviceSetGpuLockedClocks(device, MIN_CLOCK_MHZ, MAX_CLOCK_MHZ)
    print(f"Locked Clocks set: {MIN_CLOCK_MHZ} - {MAX_CLOCK_MHZ} MHz")

    # 2. Set Clock Offset (Metode Baru / Future-Proof)
    # Kita harus mendefinisikan struct 'c_nvmlClockOffset_t'
    offset_struct = c_nvmlClockOffset_t()
    offset_struct.version = nvmlClockOffset_v1
    offset_struct.type = NVML_CLOCK_GRAPHICS  # Target Core Clock
    offset_struct.pstate = NVML_PSTATE_0      # Target Performance State Tertinggi
    offset_struct.clockOffsetMHz = OFFSET_MHZ

    core_struct = c_nvmlClockOffset_t()
    core_struct.version = nvmlClockOffset_v1
    core_struct.type = NVML_CLOCK_GRAPHICS  # Target: CORE
    core_struct.pstate = NVML_PSTATE_0
    core_struct.clockOffsetMHz = OFFSET_MHZ
    nvmlDeviceSetClockOffsets(device, byref(core_struct))
    print(f"Core Offset set: +{OFFSET_MHZ} MHz")
    
    # 3. Set Memory Offset (Overclock)
    mem_struct = c_nvmlClockOffset_t()
    mem_struct.version = nvmlClockOffset_v1
    mem_struct.type = NVML_CLOCK_MEM      # Target: MEMORY
    mem_struct.pstate = NVML_PSTATE_0
    mem_struct.clockOffsetMHz = MEM_OFFSET_MHZ
    nvmlDeviceSetClockOffsets(device, byref(mem_struct))
    print(f"Memory Offset set: +{MEM_OFFSET_MHZ} MHz")

    # Catatan untuk HP Victus:
    # Power Limit (PL) biasanya dikunci oleh firmware HP.
    # Baris di bawah ini kemungkinan besar akan error atau diabaikan.
    # nvmlDeviceSetPowerManagementLimit(device, 60000) 

except NVMLError as err:
    print(f"Error: {err}")

finally:
    nvmlShutdown()
