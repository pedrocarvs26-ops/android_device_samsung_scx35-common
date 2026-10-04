# Copyright (C) 2017 The Lineage Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# SPRD hardware
BOARD_USES_SPRD_HARDWARE := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true

# Audio
BOARD_USES_TINYALSA_AUDIO := true
TARGET_TINY_ALSA_IGNORE_SILENCE_SIZE := true

# Platform
TARGET_ARCH := arm
TARGET_BOARD_PLATFORM := sc8830
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := cortex-a7
TARGET_NO_BOOTLOADER := true
BOARD_VENDOR := samsung

# Bluetooth
USE_BLUETOOTH_BCM4343 := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/samsung/scx35-common/bluetooth
BOARD_CUSTOM_BT_CONFIG := device/samsung/scx35-common/bluetooth/libbt_vndcfg.txt

# Graphics
USE_SPRD_DITHER := true
USE_SPRD_HWCOMPOSER := true
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# Kernel
BOARD_CUSTOM_BOOTIMG_MK := device/samsung/scx35-common/mkbootimg.mk
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_TAGS_OFFSET := 0x01d88000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_PAGESIZE := 2048
# 18.1 port: the OTA tools repack boot.img from these args alone. Every boot
# image known to start on this board carries the tags offset below; without
# it the repacked image falls back to 0x100.
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_KERNEL_SEPARATED_DT := true
BOARD_KERNEL_IMAGE_NAME := zImage
TARGET_KERNEL_CROSS_COMPILE_PREFIX := arm-eabi-
KERNEL_TOOLCHAIN := $(shell pwd)/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin

# Bionic
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true

# Lights
TARGET_HAS_BACKLIT_KEYS := false

# Target shims
TARGET_LD_SHIM_LIBS := \
	/system/vendor/bin/gpsd|libgps_shim.so

# Init
TARGET_INIT_VENDOR_LIB := libinit_sec

# GPS
TARGET_SPECIFIC_HEADER_PATH := device/samsung/scx35-common/include

# healthd: BOARD_HAL_STATIC_LIBRARIES is obsolete since R; dropped (18.1 port)

# Charger
BOARD_CHARGER_ENABLE_SUSPEND := false
BACKLIGHT_PATH := /sys/class/backlight/panel/brightness

# Enable dex-preoptimization to speed up first boot sequence
WITH_DEXPREOPT := true
WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false

# 18.1 port: seven outputs are claimed by both a module rule and a
# PRODUCT_COPY_FILES rule (init_rc/LOCAL_INIT_RC/BUILD_PREBUILT vs copy).
# Keep the historical behavior: the copy wins.
BUILD_BROKEN_DUP_RULES := true

# 18.1 port: pre-Treble HALs (camera HAL1 in cameraserver, radio nodes
# in audioserver/mediaserver) trip upstream neverallows; board boots permissive.
SELINUX_IGNORE_NEVERALLOWS := true

# SELinux policy
BOARD_SEPOLICY_DIRS += device/samsung/scx35-common/sepolicy

# System properties
TARGET_SYSTEM_PROP += device/samsung/scx35-common/system.prop

# SPRD offline charger renders its UI dynamically.
# Keep charger_res_images empty to avoid installing legacy bitmap resources.
BOARD_HEALTHD_CUSTOM_CHARGER_RES := hardware/sprd/healthd/charger/res
