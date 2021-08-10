import platform
from collections import namedtuple

SystemInfo = namedtuple("SystemInfo", "os architecture bitness")


def detect_os_bitness() -> str:
    return platform.architecture()[0]


def detect_os_architecture() -> str:
    return platform.uname()[4]


def system() -> SystemInfo:
    return SystemInfo(os=platform.system(),
                      architecture=detect_os_architecture(),
                      bitness=detect_os_bitness())


if __name__ == '__main__':
    print(system())
