#!/usr/bin/env python3
"""Run all five Twilight Zone applications in sequence."""

from .holographic_vault import main as vault_main
from .mirror_debugger import main as debugger_main
from .gravity_blockchain import main as gravity_main
from .vampire_qec import main as vampire_main
from .infinite_compression import main as compression_main


def main():
    print("\n" + "█" * 60)
    print("█  TWILIGHT ZONE APPLICATIONS — P² = P MIRROR FRAMEWORK  █")
    print("█" * 60 + "\n")

    apps = [
        ("1/5", vault_main),
        ("2/5", debugger_main),
        ("3/5", gravity_main),
        ("4/5", vampire_main),
        ("5/5", compression_main),
    ]

    for label, fn in apps:
        print(f"\n{'▓' * 60}")
        print(f"  Running Application {label}")
        print(f"{'▓' * 60}\n")
        try:
            fn()
        except Exception as e:
            print(f"  [ERROR] {e}")
        print()


if __name__ == "__main__":
    main()
