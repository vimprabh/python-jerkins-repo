"""A small app that can be tested and packaged by Jenkins."""

import argparse


def greeting(name: str = "world") -> str:
    """Return a greeting, using a default for blank names."""
    return f"Hello, {name.strip() or 'world'}!"


def main() -> None:
    parser = argparse.ArgumentParser(description="Print a greeting")
    parser.add_argument("--name", default="world", help="name to greet")
    args = parser.parse_args()
    print(greeting(args.name))


if __name__ == "__main__":
    main()
