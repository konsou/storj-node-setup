#!/usr/bin/python3
import sys

def print_usage_help():
    print(f"Usage: {sys.argv[0]} TOTAL_SPACE")
    print(f"eg. {sys.argv[0]} 2TB")
    print("Space should be in TB.")

def main():
    # USER INPUT SHOULD BE IN TB!
    try:
        user_input = sys.argv[1].strip()
    except IndexError:
        print("ERROR: No total storage space given.")
        print_usage_help()
        sys.exit(1)

    total_space = user_input.split('TB')[0]
    
    try:
        total_space = float(total_space)
    except ValueError:
        print("ERROR: Invalid storage space given ({sys.argv[1]}).")
        print_usage_help()
        sys.exit(1)

    storage_available = total_space / 1.1
    print(f"{storage_available:.2f}TB")

if __name__ == "__main__":
    main()
