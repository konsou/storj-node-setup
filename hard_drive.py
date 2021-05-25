from run_command import run_command


def serial(device: str) -> str:
    device_info = run_command(["udevadm", "info", "--query=all", f"--name={device}"])
    for line in device_info.split('\n'):
        if 'ID_SERIAL_SHORT' in line:
            return line
    return "(NO SERIAL)"

    # SERIAL =$(udevadm info --query=all --name="$1" | grep ID_SERIAL_SHORT)
    # echo
    # "${SERIAL: -4}" | tr
    # '[:upper:]' '[:lower:]'  # to lower case

if __name__ == '__main__':
    print(serial('/dev/sdb'))