import urllib.request
import os
import stat
import zipfile

from typing import Union
from system import system
from tempfile import TemporaryDirectory
from subprocess import check_call

Path = Union[str, os.PathLike, TemporaryDirectory]

# NOTES
# identity authorization command example:
# identity authorize storagenode <token> --identity-dir /home/konso/storagenode_signed/
# THE DIRECTORY SHOULD HAVE A SUBDIRECTORY NAMED "storagenode" THAT CONTAINS THE IDENTITY FILES
#
# REMEMBER TO CREATE THE DIRECTORY /home/(user)/.local/share/storj/identity/ !!


def identity_download_url() -> str:
    download_locations = {
        ("Linux", "armv6l", "32bit"): "https://github.com/storj/storj/releases/latest/download/identity_linux_arm.zip",
        ("Linux", "armv6l", "64bit"): "https://github.com/storj/storj/releases/latest/download/identity_linux_arm64.zip",
        ("Linux", "x86_64", "64bit"): "https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip",
    }
    current_system = system()
    try:
        return download_locations[current_system]
    except KeyError:
        raise EnvironmentError(f"Unknown or unsupported system: {current_system}")


def download_identity_executable(url: str,
                                 destination_dir: Path,
                                 ) -> Path:
    """Download the identity executable to given directory.
    Return the full file name for the downloaded executable."""

    if isinstance(destination_dir, TemporaryDirectory):
        destination_dir = destination_dir.name

    destination_dir = os.path.expanduser(destination_dir)

    destination_filename = os.path.join(destination_dir, 'identity')

    print(f"Downloading identity executable from {url}...")
    downloaded_file = urllib.request.urlretrieve(url)

    print(f"Unzipping the identity executable to {destination_dir}...")
    with zipfile.ZipFile(downloaded_file[0], 'r') as zf:
        zf.extractall(destination_dir)

    print(f"Making the file executable...")
    current_permissions = os.stat(destination_filename)
    os.chmod(destination_filename, current_permissions.st_mode | stat.S_IEXEC)

    print(f"Identity executable downloaded to {destination_filename}")
    return destination_filename


def identity_is_authorized(identity_dir: Path) -> bool:
    identity_dir = os.path.expanduser(identity_dir)  # expand "~"

    with open(f"{identity_dir}/storagenode/ca.cert", encoding='utf-8') as f:
        ca_cert = f.read()

    if ca_cert.count("BEGIN") != 2:
        return False

    with open(f"{identity_dir}/storagenode/identity.cert", encoding='utf-8') as f:
        identity_cert = f.read()

    if identity_cert.count("BEGIN") != 3:
        return False

    return True


def authorize_identity(identity_dir: Path,
                       auth_token: str,
                       identity_executable_path: Path = None,
                       temp_dir: Path = None):
    """identity_dir should have a subdir 'storagenode' that contains the identity files"""
    identity_dir = os.path.expanduser(identity_dir)

    if identity_executable_path is None:
        print(f"No identity_executable_path set")
        if temp_dir is None:
            print(f"No temp_dir set - getting a new one...")
            temp_dir = TemporaryDirectory(prefix='storj-node-setup-')
        else:
            temp_dir = os.path.expanduser(temp_dir)

        identity_executable_path = download_identity_executable(url=identity_download_url(),
                                                                destination_dir=temp_dir)

    identity_executable_path = os.path.expanduser(identity_executable_path)

    check_call([identity_executable_path, "authorize", "storagenode", auth_token, "--identity-dir", identity_dir])


if __name__ == '__main__':
    id_dir = input("Check this identity dir if it's authorized: ")
    authorized = identity_is_authorized(id_dir)
    if not authorized:
        token = input("Auth token: ")
        authorize_identity(identity_dir=id_dir,
                           auth_token=token,
                           )





