from run_command import run_command


def serial(device: str) -> str:
    print(run_command(["udevadm", "info", "--query=all", f"--name={device}"]))

    # SERIAL =$(udevadm info --query=all --name="$1" | grep ID_SERIAL_SHORT)
    # echo
    # "${SERIAL: -4}" | tr
    # '[:upper:]' '[:lower:]'  # to lower case