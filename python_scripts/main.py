import os.path
from tempfile import TemporaryDirectory
import sys

from ip_address import get_local_primary_ip, get_public_ip
from user_input import ask_user_yes_no, ask_user
from system import system
from identity import identity_is_authorized


def main():
    print(f"Detect system...")
    operating_environment = system()
    if operating_environment.os != "Linux":
        print(f"{operating_environment.os} is not supported. This script only runs on Linux.")
        sys.exit(1)
    print(f"System is {operating_environment}")

    temp_dir: TemporaryDirectory = TemporaryDirectory(prefix='storj-node-setup-')
    print(f"Temp dir is {temp_dir}")
    mount_dir_base = "/mnt"
    print(f"Getting IP address info...")
    local_ip_address = get_local_primary_ip()
    public_ip_address = get_public_ip()
    print(f"Done.")

    print(f"""\
    
    
BEFORE YOU BEGIN

CONNECTIVITY
  -your server must have a static IP set 
  -Storj port must have been opened and redirected to this machine in the router
    -docs: https://docs.storj.io/node/dependencies/port-forwarding
  -current local IP: {local_ip_address}
  -current public IP: {public_ip_address if public_ip_address else '(unknown)'}


IDENTITY 
  -you need one of these:
    -an auth token from https://registration.storj.io/ OR
    -an authorized identity

It's not a good idea to generate an identity on a Raspberry Pi or
other hardware that's not powerful because it will take forever.
It's better to generate an identity on your main computer.

Identity generation guide: https://documentation.storj.io/dependencies/identity
""")
    generate_identity = ask_user_yes_no(prompt="Generate identity now?",
                                        default='n')

    identity_source_location = None

    if generate_identity:
        print('Generating identity')
        # TODO
        # set identity location here
    else:
        print('Not generating identity')

    if not identity_source_location:
        identity_source_location = ask_user(
            "Please enter a directory to copy the identity files from."
            "\nNote: this directory should have a subdirectory called 'storagenode' "
            "\nthat contains the actual identity files."
            "\nIdentity directory:  ",
            valid_type=str)
        identity_source_location = os.path.expanduser(identity_source_location)  # expand "~"

    identity_authorized = identity_is_authorized(identity_source_location)
    print(f"Identity authorized: {identity_authorized}")


if __name__ == '__main__':
    main()
