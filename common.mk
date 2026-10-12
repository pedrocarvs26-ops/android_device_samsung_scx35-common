# Copyright (C) 2017 The Lineage Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := device/samsung/scx35-common

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay-lineage

# Default USB configuration
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	persist.sys.usb.config=mtp

# Audio
PRODUCT_PACKAGES += \
	audio.r_submix.default \
	audio_hw.xml \
	audio_para \
	audio_effects_vendor.conf \
	audio_policy_configuration.xml \
	codec_pga.xml \
	tiny_hw.xml \
	audio.primary.sc8830 \
	libaudio-resampler

# audio_policy_configuration.xml pulls these in with XInclude, so they have
# to be installed next to it.
PRODUCT_COPY_FILES += \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml

# Bluetooth
PRODUCT_PACKAGES += \
	bluetooth.default \
	libbt-vendor

# Codecs
PRODUCT_PACKAGES += \
	libcolorformat_switcher \
	libstagefrighthw \
	libstagefright_sprd_mpeg4dec \
	libstagefright_sprd_mpeg4enc \
	libstagefright_sprd_h264dec \
	libstagefright_sprd_h264enc \
	libstagefright_sprd_vpxdec \
	libstagefright_sprd_aacdec \
	libstagefright_sprd_mp3dec

# seccomp
PRODUCT_COPY_FILES += \
	device/samsung/scx35-common/seccomp/mediacodec-seccomp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy

# Media config
PRODUCT_PACKAGES += \
	media_codecs.xml

MEDIA_XML_CONFIGS := \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml

PRODUCT_COPY_FILES += \
	$(foreach f,$(MEDIA_XML_CONFIGS),$(f):$(TARGET_COPY_OUT_VENDOR)/etc/$(notdir $(f)))

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/system/etc/init/android.hardware.media.omx@1.0-service.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.media.omx@1.0-service.rc \
    $(LOCAL_PATH)/system/etc/init/android.hardware.sensors@1.0-service.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.sensors@1.0-service.rc \
	$(LOCAL_PATH)/system/etc/init/mediaserver.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/mediaserver.rc


# Common compatibility libraries
PRODUCT_PACKAGES += \
	libion_shim \
	libgps_shim \
	libstlport


# GPS
PRODUCT_PACKAGES += \
	libgpspc \
	libefuse \
	gps.conf \
	gps.xml

# HWC
PRODUCT_PACKAGES += \
	libHWCUtils \
	gralloc.sc8830 \
    hwcomposer.sc8830 \
    sprd_gsp.sc8830 \
	libmemoryheapion \
	libion_sprd \
	memtrack.sc8830

# System init.rc files
PRODUCT_PACKAGES += \
	chown_service.rc \
	gpsd.rc \
	macloader.rc \
	set_mac.rc \
	swap.rc \
	wpa_supplicant.rc

# Rootdir files
PRODUCT_PACKAGES += \
	init.board.rc \
	init.wifi.rc \
	init.sc8830.rc \
	init.sc8830.usb.rc \
	ueventd.sc8830.rc

# Lights
PRODUCT_PACKAGES += \
	lights.sc8830

# Camera config
PRODUCT_PROPERTY_OVERRIDES += \
	camera.disable_zsl_mode=1

# Wifi
PRODUCT_PACKAGES += \
	wpa_supplicant \
	wpa_supplicant.conf \
	hostapd \
	macloader \
	libandroid_net \
	wpa_supplicant_overlay.conf \
	p2p_supplicant_overlay.conf

# Disable treble OMX
PRODUCT_PROPERTY_OVERRIDES += \
	persist.media.treble_omx=false

# ART device props
#
# The JIT is off because its code cache wants memfd_create(), which the
# 3.10 kernel does not implement; system_server takes SIGSEGV/SEGV_ACCERR
# the first time it tries to write to a JIT region.
PRODUCT_PROPERTY_OVERRIDES += \
	# dalvik.vm.usejit=false nao entra: o runtime_libart.mk do A12 ja define
	# usejit=true e o build.prop rejeita sysprop duplicado.
	dalvik.vm.dex2oat-flags=--no-watch-dog \
	dalvik.vm.image-dex2oat-filter=quicken \
	dalvik.vm.dex2oat-filter=quicken \
	pm.dexopt.first-boot=quicken \
	pm.dexopt.boot=verify \
	pm.dexopt.install=verify \
	pm.dexopt.bg-dexopt=verify \
	pm.dexopt.ab-ota=quicken \
	pm.dexopt.inactive=verify \
	pm.dexopt.shared=quicken

# Compile the boot image and system server ahead of time (18.1 port:
# product vars cannot live in BoardConfig*.mk).
# speed-profile foi removido no Android 12: o dex2oat nao aceita a flag e o
# dexpreopt falha com "Unknown argument: speed-profile". verify e' o filtro de
# A12 e nao exige compilacao antecipada.
# O dex2oatd do Android 12 (usado no javalib/dexpreopt) nao aceita o token
# "speed" como argumento solto; ele sai do DefaultCompilerFilter do go_defaults.
# quicken e' o equivalente low-RAM valido.
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := quicken
# O boot-image-profile do go_defaults faz o dexpreopt do boot art usar o filtro
# speed-profile, que o dex2oatd do A12 nao aceita. Esvaziamos a lista de apps
# para o dexpreopt cair no DefaultCompilerFilter (quicken).
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION :=
PRODUCT_DEXPREOPT_SPEED_APPS :=
PRODUCT_DEXPREOPT_SYSTEM_SERVER_APPS :=
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER :=

# HIDL (HAL Interface Definition Language)
PRODUCT_PACKAGES += \
	scx35-common.vintf

include $(LOCAL_PATH)/hidl.mk

# Performance
PRODUCT_PROPERTY_OVERRIDES += \
	sys.use_fifo_ui=1

# Permissions
PERMISSIONS_XML_FILES := \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml \
	frameworks/native/data/etc/android.software.sip.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.camera.autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.software.midi.xml \
	frameworks/native/data/etc/android.software.app_widgets.xml \
	packages/wallpapers/LivePicker/android.software.live_wallpaper.xml

ifneq ($(PRODUCT_TYPE),go)
PERMISSIONS_XML_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml
endif

PRODUCT_COPY_FILES += \
	$(foreach f,$(PERMISSIONS_XML_FILES),$(f):$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/$(notdir $(f)))

# sdcardfs
PRODUCT_PROPERTY_OVERRIDES += \
	ro.sys.sdcardfs=true

# Inherit Android Go defaults
ifeq ($(PRODUCT_TYPE),go)
$(call inherit-product, build/make/target/product/go_defaults.mk)
# O go_defaults.mk do Android 12 ainda usa os filtros speed-profile, que o
# dex2oat de A12 nao aceita ("Unknown argument: speed-profile") e trava o
# dexpreopt do javalib. Verify nao compila nada.
PRODUCT_PROPERTY_OVERRIDES += \
	pm.dexopt.install=verify \
	pm.dexopt.install-bulk=verify \
	pm.dexopt.bg-dexopt=verify \
	pm.dexopt.ab-ota=verify \
	pm.dexopt.first-boot=verify \
	pm.dexopt.boot=verify \
	dalvik.vm.dex2oat-filter=verify
# Disable Scudo to use jemalloc (saves ~50-100MB RAM)
PRODUCT_DISABLE_SCUDO := true
PRODUCT_PROPERTY_OVERRIDES += \
	dalvik.vm.heapstartsize=8m \
	dalvik.vm.heapgrowthlimit=128m \
	dalvik.vm.heapsize=256m \
	dalvik.vm.heaptargetutilization=0.75 \
	dalvik.vm.heapminfree=512k \
	dalvik.vm.heapmaxfree=8m
else
# Dalvik heap config
$(call inherit-product, frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk)
endif

# Debug build configuration
ifneq ($(filter eng userdebug,$(TARGET_BUILD_VARIANT)),)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	persist.sys.root_access=1

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.usb.config=mtp,adb
endif

# Memory configuration
PRODUCT_PROPERTY_OVERRIDES += \
	ro.config.low_ram=true \
	ro.statsd.enable=false

PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
