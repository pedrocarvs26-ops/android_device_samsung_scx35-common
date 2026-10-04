/*
   Copyright (c) 2016, Android Open Source Project. All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <string>

#include <android-base/properties.h>
#include "vendor_init.h"
#include "property_service.h"

using namespace android::base;

std::string bootloader;
std::string device;

enum device_variant {
	G360HU,
	G360H,
	I9060I,
	I9060C,
	I9060M,
	G361H,
	G531BT,
	G531H,
	T113NU,
	T113,
	T116,
	T560,
	T561,
	DEVICE_UNSUPPORTED,
};

device_variant match(std::string bl)
{
	if (bl.find("G360HU") != std::string::npos) {
			return G360HU;
	} else if (bl.find("G360H") != std::string::npos) {
			return G360H;
	} else if (bl.find("I9060I") != std::string::npos) {
			return I9060I;
	} else if (bl.find("I9060C") != std::string::npos) {
			return I9060C;
	} else if (bl.find("I9060M") != std::string::npos) {
			return I9060M;
	} else if (bl.find("G361H") != std::string::npos) {
			return G361H;
	} else if (bl.find("G531BT") != std::string::npos) {
			return G531BT;
	} else if (bl.find("G531H") != std::string::npos) {
			return G531H;
	} else if (bl.find("T113NU") != std::string::npos) {
			return T113NU;
	} else if (bl.find("T113") != std::string::npos) {
			return T113;
	} else if (bl.find("T116") != std::string::npos) {
			return T116;
	} else if (bl.find("T560") != std::string::npos) {
			return T560;
	} else if (bl.find("T561") != std::string::npos) {
			return T561;
	} else {
			return DEVICE_UNSUPPORTED;
	}
}

device_variant find_device_variant() {
	bootloader = GetProperty("ro.bootloader", "");
	return match(bootloader);
}

void property_override(char const prop[], char const value[])
{
	prop_info *pi;

	pi = (prop_info*) __system_property_find(prop);
	if (pi)
		__system_property_update(pi, value, strlen(value));
	else
		__system_property_add(prop, strlen(prop), value, strlen(value));
}

static int read_simslot_count()
{
	int count = -1;
	FILE* file = fopen("/proc/simslot_count", "r");

	if (file == nullptr)
		return -1;

	if (fscanf(file, "%d", &count) != 1)
		count = -1;

	fclose(file);
	return count;
}

static void set_wifi_only_properties()
{
	property_override("ro.radio.noril", "1");
	property_override("ro.carrier", "wifi-only");
	property_override("ro.multisim.simslotcount", "0");
	property_override("persist.dsds.enabled", "false");
	property_override("persist.radio.multisim.config", "none");
}

static void set_single_sim_properties()
{
	property_override("ro.radio.noril", "0");
	property_override("ro.multisim.simslotcount", "1");
	property_override("persist.dsds.enabled", "false");
	property_override("persist.radio.multisim.config", "none");
}

static void set_dual_sim_properties()
{
	property_override("ro.radio.noril", "0");
	property_override("ro.multisim.simslotcount", "2");
	property_override("persist.dsds.enabled", "true");
	property_override("persist.radio.multisim.config", "dsds");
}

static void set_radio_properties(device_variant variant)
{
	switch (variant) {
	case T113NU:
	case T113:
	case T560:
		set_wifi_only_properties();
		break;

	case T116:
	case T561:
		set_single_sim_properties();
		break;

	case G360HU:
	case G360H:
	case I9060I:
	case I9060C:
	case I9060M:
	case G361H:
	case G531BT:
	case G531H:
		if (read_simslot_count() == 1)
			set_single_sim_properties();
		else
			set_dual_sim_properties();
		break;

	default:
		break;
	}
}

/*
 * The Broadcom controller holds no address of its own: the factory writes it to
 * /efs/bluetooth/bt_addr, which ro.bt.bdaddr_path points at.  When that file is
 * missing, BluetoothAddress::get_local_address() returns false and
 * android.hardware.bluetooth@1.0-service aborts on
 *
 *     LOG_ALWAYS_FATAL("Open: No Bluetooth Address!")
 *
 * taking Bluetooth down for good, in a restart loop.  Publish a fallback derived
 * from the serial number so the adapter still comes up on units whose factory
 * partition was wiped or fails to mount.
 *
 * The HAL reads the factory file first and only then ro.boot.btmacaddr, so a real
 * address always wins over this one.  The first octet is 0x02: unicast with the
 * locally administered bit set, which is the range reserved for exactly this.
 */
static void set_bluetooth_address_fallback()
{
	/* Never shadow an address the bootloader was kind enough to pass in. */
	if (!GetProperty("ro.boot.btmacaddr", "").empty())
		return;

	std::string serial = GetProperty("ro.serialno", "");

	if (serial.empty())
		serial = GetProperty("ro.boot.serialno", "");

	if (serial.empty())
		return;

	/* FNV-1a, 64 bit. */
	uint64_t hash = 0xcbf29ce484222325ULL;

	for (unsigned char c : serial) {
		hash ^= c;
		hash *= 0x100000001b3ULL;
	}

	char address[18];

	snprintf(address, sizeof(address), "02:%02x:%02x:%02x:%02x:%02x",
		 (unsigned int)((hash >> 32) & 0xff),
		 (unsigned int)((hash >> 24) & 0xff),
		 (unsigned int)((hash >> 16) & 0xff),
		 (unsigned int)((hash >> 8) & 0xff),
		 (unsigned int)(hash & 0xff));

	property_override("ro.boot.btmacaddr", address);
}

void vendor_load_properties()
{

	device_variant variant = find_device_variant();

	switch (variant) {
		case G360H:
			/* core33gdd */
			property_override("ro.product.model", "SM-G360H");
			property_override("ro.product.device", "core33g");
			break;
		case G360HU:
			/* core33gdc */
			property_override("ro.product.model", "SM-G360HU");
			property_override("ro.product.device", "core33g");
			break;
		case I9060I:
			/* grandneove3gxx */
			property_override("ro.product.model", "GT-I9060I");
			property_override("ro.product.device", "grandneove3g");
			break;
		case I9060C:
			/* grandneove3gvj */
			property_override("ro.product.model", "GT-I9060C");
			property_override("ro.product.device", "grandneove3g");
			break;
		case I9060M:
			/* grandneove3gub */
			property_override("ro.product.model", "GT-I9060M");
			property_override("ro.product.device", "grandneove3g");
			break;
		case G361H:
			/* coreprimeve3gxx */
			property_override("ro.product.model", "SM-G361H");
			property_override("ro.product.device", "coreprimeve3g");
			break;
		case G531BT:
			/* grandprimeve3gdtv */
			property_override("ro.product.model", "SM-G531BT");
			property_override("ro.product.device", "grandprimeve3gdtv");
			break;
		case G531H:
			/* grandprimeve3gxx */
			property_override("ro.product.model", "SM-G531H");
			property_override("ro.product.device", "grandprimeve3g");
			break;
		case T113NU:
			/* goyavewifi */
			property_override("ro.product.model", "SM-T113NU");
			property_override("ro.product.device", "goyavewifi");
			break;
		case T113:
			/* goyavewifi */
			property_override("ro.product.model", "SM-T113");
			property_override("ro.product.device", "goyavewifi");
			break;
		case T116:
			/* goyave3g */
			property_override("ro.product.model", "SM-T116");
			property_override("ro.product.device", "goyave3g");
			break;
		case T560:
			/* gtelwifi */
			property_override("ro.product.model", "SM-T560");
			/* Both the T560 and the T561 are built from the gtel3g tree, and
			 * ro.product.device has to agree with ro.product.system.device:
			 * property_derive_build_fingerprint() and friends skip properties
			 * that are already set, so "gtelwifi" would stick forever. */
			property_override("ro.product.device", "gtel3g");
			break;
		case T561:
			/* gtel3g */
			property_override("ro.product.model", "SM-T561");
			property_override("ro.product.device", "gtel3g");
			break;
		default:
			break;
	}

	set_radio_properties(variant);
	set_bluetooth_address_fallback();
}
