from ip_address import get_local_primary_ip, get_public_ip
from user_input import ask_user_yes_no


def main():
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
\
""")
    generate_identity = ask_user_yes_no(prompt="Generate identity now?",
                                        default='n')

    if generate_identity:
        print('Generating identity')
    else:
        print('Not generating identity')


if __name__ == '__main__':
    main()
