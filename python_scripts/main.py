import os.path
from tempfile import TemporaryDirectory
import sys

import distro

from ip_address import get_local_primary_ip, get_public_ip
from user_input import ask_user_yes_no, ask_user
from system import system
from identity import identity_is_authorized, authorize_identity

SUPPORTED_DISTROS = ["ubuntu", "debian", "raspbian"]


def main():
    print(f"Detect system...")
    operating_environment = system()
    if operating_environment.os != "Linux":
        print(f"{operating_environment.os} is not supported. This script only runs on Linux.")
        sys.exit(1)
    print(f"System is {operating_environment.os} {operating_environment.architecture} {operating_environment.bitness}")
    current_distro = distro.id()
    print(f"Distro is {current_distro}")
    if current_distro not in SUPPORTED_DISTROS:
        print(f"{current_distro} is not officially supported for this script!")
        print(f"Supported distros are:")
        for d in SUPPORTED_DISTROS:
            print(f"    * {d}")
        print(f"Things might work or not. Press ENTER to continue, Ctrl-C to exit.")
        input()

    temp_dir: TemporaryDirectory = TemporaryDirectory(prefix='storj-node-setup-')
    print(f"Temp dir is {temp_dir.name}")
    mount_dir_base = "/mnt"
    print(f"Getting IP address info...")
    local_ip_address = get_local_primary_ip()
    public_ip_address = get_public_ip()
    print(f"Done.")

    print(f"""\
    
    
BEFORE YOU BEGIN

CONNECTIVITY
  - your server must have a static IP set 
  - Storj port must have been opened and redirected to this machine in the router
    * docs: https://docs.storj.io/node/dependencies/port-forwarding
  - current local IP: {local_ip_address}
  - current public IP: {public_ip_address if public_ip_address else '(unknown)'}


IDENTITY 
  - you need one of these:
    * an auth token from https://registration.storj.io/ OR
    * an auth token and an unauthorized identity OR
    * an authorized identity

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
            "\n      that contains the actual identity files."
            "\nIdentity directory:  ",
            valid_type=str)
        identity_source_location = os.path.expanduser(identity_source_location)  # expand "~"

    while True:
        identity_authorized = identity_is_authorized(identity_source_location)
        print(f"Identity authorized: {identity_authorized}")
        if identity_authorized:
            break

        if ask_user_yes_no("Authorize the identity now?"):
            auth_token = ask_user("Enter authorization token: ", valid_type=str)
            authorize_identity(identity_dir=identity_source_location,
                               auth_token=auth_token,
                               temp_dir=temp_dir)
        else:
            print(f"Need an authorized identity to continue. Quitting.")
            sys.exit(1)

    # setup




if __name__ == '__main__':
    main()
