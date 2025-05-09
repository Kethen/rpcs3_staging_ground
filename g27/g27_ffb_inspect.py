import struct
import sys

def parse_file_header(handle):
	file_header_format = "<IHHIIII"
	header_bytes = handle.read(24)

	if len(header_bytes) != 24:
		return None

	tup = struct.unpack(file_header_format, header_bytes)
	ret = {}
	ret["magic_number"] = tup[0]
	ret["major_version"] = tup[1]
	ret["minor_version"] = tup[2]
	ret["reserved_1"] = tup[3]
	ret["reserved_2"] = tup[4]
	ret["snap_len"] = tup[5]
	ret["link_type_and_info"] = tup[6]
	return ret

def parse_record_header(handle):
	record_header_format = "<IIII"
	header_bytes = handle.read(16)

	if len(header_bytes) != 16:
		return None

	tup = struct.unpack(record_header_format, header_bytes)
	ret = {}
	ret["time_sec"] = tup[0]
	ret["time_sub_sec"] = tup[1]
	ret["captured_packet_length"] = tup[2]
	ret["original_packet_length"] = tup[3]
	return ret

def parse_usbpcap_header(handle):
	usbpcap_header_format = "<HQIHBHHBBI"
	header_bytes = handle.read(27)

	if len(header_bytes) != 27:
		return None

	tup = struct.unpack(usbpcap_header_format, header_bytes)
	ret = {}
	ret["header_len"] = tup[0]
	ret["irp_id"] = tup[1]
	ret["status"] = tup[2]
	ret["function"] = tup[3]
	ret["info"] = tup[4]
	ret["bus"] = tup[5]
	ret["device"] = tup[6]
	ret["endpoint"] = tup[7]
	ret["transfer"] = tup[8]
	ret["data_len"] = tup[9]

	remainder_bytes = None
	if ret["header_len"] > 27:
		remainder_bytes = handle.read(ret["header_len"] - 27)

	if remainder_bytes is not None and ret["transfer"] == 2:
		control_extend_format = "<B"
		tup = struct.unpack(control_extend_format, remainder_bytes)
		ret["stage"] = tup[0]

	return ret

def filter_ffb_effect(data):
	if len(data) != 16:
		return
	if data[0] == 0xf8:
		logged = False
		if data[1] == 0x2:
			print("changing wheel range to 200 degree with ext_cmd 0x2")
			logged = True
		if data[1] == 0x3:
			print("changing wheel range to 900 degree with ext_cmd 0x3")
			logged = True
		if data[1] == 0x81:
			print("changing wheel range to {} degree with ext_cmd 0x81".format(data[2] | (data[3] << 8)))
			logged = True
		if data[1] == 0x12:
			print("changing wheel led to {}".format(hex(data[2])))
			logged = True
		if not logged:
			print("ext cmd {}".format(hex(data[1])))
		return

	slot_mask = data[0] >> 4
	cmd = data[0] & 0xf

	if cmd == 0xd:
		# gran turismo 6 does not set this at all
		if data[1] == 0:
			print("setting asap loop")
		else:
			print("setting 2ms loop {}".format(data[1]))
	if cmd == 0xf:
		# odd, gran turismo 6 also does not touch this
		if data[1] == 0:
			print("setting deadband to off")
		else:
			print("setting deadband to on {}".format(data[1]))


handle = open(sys.argv[1], "rb")

file_header = parse_file_header(handle)
if file_header is None:
	exit(1)
#print(file_header)

while True:
	record_header = parse_record_header(handle)
	if record_header is None:
		break
	#print(record_header)

	usbpcap_header = parse_usbpcap_header(handle)
	if usbpcap_header is None:
		break
	#print(usbpcap_header)

	if usbpcap_header["data_len"] != 0:
		data = handle.read(usbpcap_header["data_len"])
		if len(data) != usbpcap_header["data_len"]:
			break
		#print(data)
		filter_ffb_effect(data)
