#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <libusb-1.0/libusb.h>

void ps3_control_00(libusb_device_handle *handle){
	// bmRequestType 00, bRequest 09, wValue 0001, wIndex 0000, wLength 0000

	int interface_claim_status = libusb_claim_interface(handle, 0);
	if(interface_claim_status != 0){
		printf("failed claiming interface 0, %s\n", libusb_error_name(interface_claim_status));
		return;
	}

	uint8_t buf[1024];

	printf("sending control transfer 0x00 0x09 0x0001 0x0000\n");
	int control_transfer_status = libusb_control_transfer(handle, 0x00, 0x09, 0x0001, 0x0000, (char *)buf, 0x0000, 0);
	if(control_transfer_status < 0){
		printf("control transfer failed, %s\n", libusb_error_name(control_transfer_status));
	}

	if(control_transfer_status == 0){
		printf("control transfer succeed, %d bytes received:\n", control_transfer_status);
		for(int i = 0;i < control_transfer_status;i++){
			if(i == 0){
				printf("%02x", buf[i]);
			}else{
				printf(", %02x", buf[i]);
			}
		}
	}

	int interface_release_status = libusb_release_interface(handle, 0);
	if(interface_release_status != 0){
		printf("failed releaseing interface 0, %s\n", libusb_error_name(interface_release_status));
	}
	printf("\n");
}

void ps3_control_a1(libusb_device_handle *handle){
	// this one is weird, it never happens on passthrough, but only emulated
	// bmRequestType a1, bRequest 01, wValue 0300, wIndex 0000, wLength 0091

	int interface_claim_status = libusb_claim_interface(handle, 0);
	if(interface_claim_status != 0){
		printf("failed claiming interface 0, %s\n", libusb_error_name(interface_claim_status));
		return;
	}

	uint8_t buf[0x91];

	printf("sending control transfer 0xa1 0x01 0x0300 0x0000\n");
	int control_transfer_status = libusb_control_transfer(handle, 0xa1, 0x01, 0x300, 0, (char *)buf, 0x91, 0);
	if(control_transfer_status < 0){
		printf("control transfer failed, %s\n", libusb_error_name(control_transfer_status));
	}

	if(control_transfer_status == 0){
		printf("control transfer succeed, %d bytes received:\n", control_transfer_status);
		for(int i = 0;i < control_transfer_status;i++){
			if(i == 0){
				printf("%02x", buf[i]);
			}else{
				printf(", %02x", buf[i]);
			}
		}
	}

	int interface_release_status = libusb_release_interface(handle, 0);
	if(interface_release_status != 0){
		printf("failed releaseing interface 0, %s\n", libusb_error_name(interface_release_status));
	}
	printf("\n");
}

void get_set_config(libusb_device_handle *handle){
	// odd, it fails in passthrough
	// passthrough set configuration: 1, -6
	int set_status = libusb_set_configuration(handle, 1);
	printf("set config 1 status %d\n", set_status);

	int get_value = 0;
	int get_status = libusb_get_configuration(handle, &get_value);

	printf("get config %d status %d\n", get_value, get_status);
}


int main(){
	int libusb_init_status = libusb_init_context(NULL, NULL, 0);
	if(libusb_init_status != 0){
		printf("failed initializing libusb, %s\n", libusb_error_name(libusb_init_status));
		exit(1);
	}

	libusb_device_handle *g27_handle = libusb_open_device_with_vid_pid(NULL, 0x046d, 0xc29b);
	if(g27_handle == NULL){
		printf("failed opening g27 usb handle\n");
		exit(1);
	}

	int set_detach_status = libusb_set_auto_detach_kernel_driver(g27_handle, 1);
	if(set_detach_status != 0){
		printf("failed enabling auto kernel driver detach, %s\n", libusb_error_name(set_detach_status));
		exit(1);
	}

	int interface_claim_status = libusb_claim_interface(g27_handle, 0);
	if(interface_claim_status != 0){
		printf("failed claiming interface 0, %s\n", libusb_error_name(interface_claim_status));
		exit(1);
	}

	get_set_config(g27_handle);
	ps3_control_00(g27_handle);
	ps3_control_a1(g27_handle);

	libusb_close(g27_handle);
}

