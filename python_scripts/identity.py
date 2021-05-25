import urllib.request
import os
import stat
import zipfile

from typing import Union

Path = Union[str, os.PathLike]


def download_identity_executable(url: str,
                                 destination_dir: Path,
                                 ) -> Path:
    """Download the identity executable to given directory.
    Return the full file name for the downloaded executable."""
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


if __name__ == '__main__':
    URL = "https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip"
    dest = download_identity_executable(url=URL,
                                        destination_dir='z:\\')
    print(dest)





