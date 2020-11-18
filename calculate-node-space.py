#!/usr/bin/python3
import sys

def main():
    # USER INPUT SHOULD BE IN TB!
    try:
        user_input = float(sys.argv[1].strip())
    except IndexError:
        print("ERROR: No total storage space given.")
        print(f"Usage: {sys.argv[0]} TOTAL_SPACE")
        print("Space should be in TB.")
        sys.exit(1)
    storage_available = user_input / 1.1
    print(f"{storage_available:.2f}TB")

if __name__ == "__main__":
    main()
