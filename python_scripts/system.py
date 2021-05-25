import os
import platform


def detect_os_bitness() -> str:
    return platform.architecture()[0]


def detect_os_architecture() -> str:
    return os.uname()[4]
