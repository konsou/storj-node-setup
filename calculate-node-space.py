#!/usr/bin/python3
import sys

def main():
    # USER INPUT SHOULD BE IN TB!
    user_input = float(sys.argv[1].strip())
    storage_available = user_input / 1.1
    print(f"{storage_available:.2f}TB")

if __name__ == "__main__":
    main()