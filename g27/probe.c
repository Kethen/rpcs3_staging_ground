#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <libusb-1.0/libusb.h>

void ps3_control_a1(libusb_device_handle *handle){
	// this one is weird, it never happens on passthrough, but only emulated
	// bmRequestType a1, bRequest 01, wValue 0300, wIndex 0000, wLength 145

	uint8_t buf[145];

	printf("sending control transfer 0xa1 0x01 0x0300 0x0000\n");
	int control_transfer_status = libusb_control_transfer(handle, 0xa1, 0x01, 0x300, 0, (char *)buf, 145, 0);
	if(control_transfer_status < 0){
		printf("control transfer failed, %d\n", control_transfer_status);
		return;
	}

	printf("control transfer succeed, %d bytes received:\n", control_transfer_status);
	for(int i = 0;i < control_transfer_status;i++){
		if(i == 0){
			printf("%02x", buf[i]);
		}else{
			printf(", %02x", buf[i]);
		}
	}
	printf("\n");
}

int main(){
	int libusb_init_status = libusb_init_context(NULL, NULL, 0);
	if(libusb_init_status != 0){
		printf("failed initializing libusb\n");
		exit(1);
	}

	libusb_device_handle *g27_handle = libusb_open_device_with_vid_pid(NULL, 0x046d, 0xc29b);
	if(g27_handle == NULL){
		printf("failed opening g27 usb handle\n");
		exit(1);
	}

	ps3_control_a1(g27_handle);

	libusb_close(g27_handle);
}

