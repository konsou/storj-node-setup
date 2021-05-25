from typing import Type, TypeVar, Callable, Optional, Sequence

ReturnType = TypeVar("ReturnType")


def ask_user(prompt: str,
             valid_type: Callable[[str], ReturnType],
             valid_literal_values: Sequence[ReturnType] = None,
             default_value: Optional[ReturnType] = None,
             ) -> ReturnType:
    while True:
        user_input = input(prompt).strip()

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


if __name__ == '__main__':
    print(ask_user("int: ", valid_type=int, valid_literal_values=(1, 2, 3)))
    print(ask_user("int with default: ", valid_type=int, default_value=2))
    print(ask_user("float: ", valid_type=float))

