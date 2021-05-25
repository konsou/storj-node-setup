from typing import TypeVar, Callable, Optional, Sequence, Literal

ReturnType = TypeVar("ReturnType")


def ask_user(prompt: str,
             valid_type: Callable[[str], ReturnType],
             valid_literal_values: Sequence[ReturnType] = None,
             default_value: Optional[ReturnType] = None,
             convert_to_lower: bool = False,
             ) -> ReturnType:
    while True:
        user_input = input(prompt).strip()

        if convert_to_lower:
            user_input = user_input.lower()

        if default_value is not None:
            if not user_input:
                print(f"Using default value: {default_value}")
                return default_value

        try:
            # Convert to expected type
            user_input = valid_type(user_input)
        except Exception:
            print(f"Invalid input - expected {valid_type.__name__}")
            continue

        if valid_literal_values is not None:
            if user_input not in valid_literal_values:
                print(f"Invalid input - expected one of: {valid_literal_values}")
                continue

        return user_input


def ask_user_yes_no(prompt: str,
                    default: Literal['y', 'n'] = 'y'
                    ) -> bool:
    options_string = "(Y/n)" if default == 'y' else "(y/N)"
    user_input = ask_user(prompt=f"{prompt} {options_string}: ",
                          valid_type=str,
                          valid_literal_values=("y", "n"),
                          default_value=default,
                          convert_to_lower=True)
    return True if user_input == 'y' else False


if __name__ == '__main__':
    print(ask_user("int: ", valid_type=int, valid_literal_values=(1, 2, 3)))
    print(ask_user("int with default: ", valid_type=int, default_value=2))
    print(ask_user("float: ", valid_type=float))

