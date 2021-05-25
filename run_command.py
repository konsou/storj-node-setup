from subprocess import run, check_output
from typing import List


def run_command(command: List[str]) -> str:
    return check_output(command).decode('utf-8')
