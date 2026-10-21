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

# Three init scripts installed by PRODUCT_COPY_FILES land on paths that a
# module in PRODUCT_PACKAGES also installs through init_rc / LOCAL_INIT_RC:
#
#   vendor/etc/init/android.hardware.media.omx@1.0-service.rc
#   vendor/etc/init/android.hardware.sensors@1.0-service.rc
#   system/etc/init/mediaserver.rc
#
# Each local copy exists for a reason - the sensors HAL needs the input
# group, mediaserver needs graphics, and the OMX service is renamed and
# given the audio group - so none of them can simply be dropped.  Kati
# treats two rules for one output as an error unless this is set; with it,
# it warns and the later rule wins, and PRODUCT_COPY_FILES is evaluated
# after base_rules.mk, so the local copies are the ones installed.
#
# The tidy fix is to install each under its own file name and let init's
# "override" keyword replace the upstream service, which needs the file to
# sort after the original in the same directory.  Until then, keep the
# behaviour this tree has always shipped.
BUILD_BROKEN_DUP_RULES := true

# SPRD hardware
BOARD_USES_SPRD_HARDWARE := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true

# Audio
BOARD_USES_TINYALSA_AUDIO := true
TARGET_TINY_ALSA_IGNORE_SILENCE_SIZE := true

# Android 10 removed the legacy audio_policy.conf parser; AudioPolicyManager
# fails to compile unless the XML one is selected.  Note that the build
# system compares this against the literal 1, not against true.
USE_XML_AUDIO_POLICY_CONF := 1

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

# HIDL
DEVICE_MANIFEST_FILE := device/samsung/scx35-common/configs/manifest.xml

# Kernel
BOARD_CUSTOM_BOOTIMG_MK := device/samsung/scx35-common/mkbootimg.mk
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_TAGS_OFFSET := 0x01d88000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_PAGESIZE := 2048
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

# healthd
BOARD_HAL_STATIC_LIBRARIES := libhealthd.sc8830

# Charger
BOARD_CHARGER_ENABLE_SUSPEND := false
BACKLIGHT_PATH := /sys/class/backlight/panel/brightness

# Enable dex-preoptimization to speed up first boot sequence
WITH_DEXPREOPT := true
WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false

# SELinux policy
#
# The pre-Treble HALs this platform still runs (legacy camera HAL1 inside
# cameraserver, the radio device nodes audioserver and mediaserver open for
# in-call audio, and wpa_supplicant's private ioctls) trip ten upstream
# neverallow rules that cannot be satisfied without rewriting the vendor
# blobs.  The board already boots permissive, so let the policy build.
SELINUX_IGNORE_NEVERALLOWS := true

BOARD_SEPOLICY_DIRS += device/samsung/scx35-common/sepolicy

# System properties
TARGET_SYSTEM_PROP += device/samsung/scx35-common/system.prop

# SPRD offline charger renders its UI dynamically.
# Keep charger_res_images empty to avoid installing legacy bitmap resources.
BOARD_HEALTHD_CUSTOM_CHARGER_RES := hardware/sprd/healthd/charger/res
