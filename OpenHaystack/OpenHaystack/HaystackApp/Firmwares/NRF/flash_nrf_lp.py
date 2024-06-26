#!/bin/python3
from pynrfjprog import LowLevel
from intelhex import IntelHex
from base64 import b64decode
import argparse


def flash_openhaystack_fw(advertisement_key, hex_path, snr=None):
    """
    Flash openhaystack firmware to device
    @param (optional) int snr: Specify serial number of DK to run example on.
    """
    # Check if paramters are valid
    if len(advertisement_key) != 28:
        ak_len = len(advertisement_key)
        print(f'[!] Advertisement key should be 27 bytes but is {ak_len} bytes')
        exit(-1)

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
        
    print(f'[*] Device family: {device_family}')
        
    if device_family == "UNKNOWN":
        print(f'Exiting...')
        exit(-1)

    print(f'[*] Opening API with device family {device_family}, reading the device version.')
    with LowLevel.API(device_family) as api:
        # Open the loaded DLL and connect to an emulator probe. If several are connected a pop up will appear.
        if snr is not None:
            api.connect_to_emu_with_snr(snr)
        else:
            api.connect_to_emu_without_snr()
        device_version = api.read_device_version()

    print(f'[*] Device version: {device_version}')
    
    # Select hex file according to device family and device version
    hex_file_path = f'{hex_path}{device_family}_{device_version.split("_")[0]}_openHayStack_lp2.hex'

    print(f'[*] Patching hex file \'{hex_file_path}\' with supplied keys')

    # Open hex file and patch cryptographic keys
    ih = IntelHex(hex_file_path)

    ak_address = ih.find(b'OFFLINEFINDINGPUBLICKEYHERE!')
    print(f'[*] AK address in hex file is {ak_address}')
    ih.puts(ak_address, advertisement_key)

    # Initialize an API object with the target family. This will load nrfjprog.dll with the proper target family.
    api = LowLevel.API(device_family)
    # Open the loaded DLL and connect to an emulator probe. If several are connected a pop up will appear.
    api.open()
    try:
        if snr is not None:
            api.connect_to_emu_with_snr(snr)
        else:
            api.connect_to_emu_without_snr()

        # Just for info
        device_version = api.read_device_version()
        print(f'[*] Device version {device_version}')

        # Erase all the flash of the device
        print('[*] Erasing all flash in the microcontroller.')
        api.erase_all()

        # Program the parsed hex into the device's memory
        print(f'[*] Writing patched {hex_file_path} to device.')
        for segment in ih.segments():
            api.write(segment[0], ih.gets(segment[0], segment[1] - segment[0]), True)

        # Reset the device and run.
        api.sys_reset()
        api.go()
        print('[*] Program started')

        # Close the loaded DLL to free resources.
        api.close()

        print('[*] Flashed openHayStack Firmware successfully')

    except LowLevel.APIError:
        api.close()
        raise


if __name__ == "__main__":
    # Parse arguments given when calling the script via command line
    parser = argparse.ArgumentParser()
    parser.add_argument('-ak', '--advertisement-key', help="Base64 encoded Advertisement key (27 bytes)", required=True)
    parser.add_argument('-ph', '--path-to-hex', help="Path to hexfile, defaults to script folder", default="")
    args = vars(parser.parse_args())
    flash_openhaystack_fw(advertisement_key=b64decode(args['advertisement_key']), hex_path=args['path_to_hex'])
