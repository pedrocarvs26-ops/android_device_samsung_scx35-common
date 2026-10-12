#
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
#

LOCAL_PATH := $(call my-dir)

# Os blobs sc8830 (camera, gps, ril, omx) foram compilados com gnustl e pedem
# libstlport/libstdc++ em DT_NEEDED. O Android.mk do stlport so e' processado se
# alguem o incluir, e o gtel3g declara libstlport no PRODUCT_PACKAGES sem que
# isso aconteca: o modulo ficava undefined e o build parava em
# "depends on undefined module libstlport".
include $(BUILD_TOP)/external/stlport/Android.mk


ifneq ($(filter grandprimeve3g coreprimeve3g core33g grandneove3g gtel3g,$(TARGET_DEVICE)),)
include $(call all-subdir-makefiles,$(LOCAL_PATH))

endif
