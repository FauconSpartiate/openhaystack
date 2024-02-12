#!/bin/python3
from pynrfjprog import LowLevel
from intelhex import IntelHex
from base64 import b64decode
import argparse


def check_NRF_connection():
    """
    Check device connection
    """

    # Detect the device family of your device. Initialize an API object with UNKNOWN family and read the device's
    # family. This step is performed so this example can be run in all devices without customer input.
    print('[*] Reading the device family.')
    with LowLevel.API(
            # Using with construction so there is no need to open or close the API class.
            LowLevel.DeviceFamily.UNKNOWN) as api:
        if snr is not None:
            api.connect_to_emu_with_snr(snr)
        else:
            api.connect_to_emu_without_snr()
        device_family = api.read_device_family()
        
    if device_family == "UNKNOWN"
        exit(-1)
        
    print(f'[*] Opening API with device family {device_family}, reading the device version.')
    with LowLevel.API(device_family) as api:
        # Open the loaded DLL and connect to an emulator probe. If several are connected a pop up will appear.
        if snr is not None:
            api.connect_to_emu_with_snr(snr)
        else:
            api.connect_to_emu_without_snr()
        device_version = api.read_device_version()

    print(f'[*] Device version {device_version}')
    
    if device_family == "UNKNOWN"
        exit(-1)
    
if __name__ == "__main__":
    check_NRF_connection()
