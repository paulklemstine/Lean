#!/usr/bin/env python3
"""
EML Two-Button Calculator Game
================================
An interactive console game where you try to reach target numbers
using only the EML operation and the constant 1.

Goal: Reach the target value in the fewest EML operations.
"""

import math
import sys

def eml(x, y):
    """EML operator: eml(x,y) = exp(x) - ln(y)"""
    if y <= 0:
        return float('inf')
    try:
        return math.exp(x) - math.log(y)
    except OverflowError:
        return float('inf')

class EMLCalculator:
    def __init__(self):
        self.stack = [1.0]  # Start with just 1
        self.history = ["1"]
        self.operations = 0

    def push_one(self):
        """Push the constant 1 onto the stack."""
        self.stack.append(1.0)
        self.history.append("1")

    def apply_eml(self):
        """Apply EML to the top two stack elements."""
        if len(self.stack) < 2:
            print("  Need at least 2 values on the stack!")
            return False
        y = self.stack.pop()
        x = self.stack.pop()
        y_hist = self.history.pop()
        x_hist = self.history.pop()
        result = eml(x, y)
        self.stack.append(result)
        self.history.append(f"eml({x_hist}, {y_hist})")
        self.operations += 1
        return True

    def display(self):
        """Display current stack state."""
        print(f"\n  Stack ({len(self.stack)} values, {self.operations} operations):")
        for i, (val, hist) in enumerate(zip(self.stack, self.history)):
            marker = " ←" if i == len(self.stack) - 1 else ""
            if math.isfinite(val):
                print(f"    [{i}] {val:>16.8f}  =  {hist}{marker}")
            else:
                print(f"    [{i}] {'∞':>16}  =  {hist}{marker}")

def known_constants():
    """Return a dictionary of known EML-constructible constants."""
    e = math.e
    return {
        "e": (e, 1, "eml(1, 1)"),
        "e²": (e**2, 2, "eml(eml(1,1), 1) with adjustment"),
        "e-1": (e - 1, 2, "eml(1, eml(1,1))"),
        "e^e": (e**e, 2, "eml(eml(1,1), 1)"),
        "0": (0.0, 3, "eml(1, exp(e))"),
        "e^e-e": (e**e - e, 3, "eml(eml(1,1), eml(eml(1,1),1))"),
        "1": (1.0, 0, "leaf"),
    }

def play_challenge(target_name, target_value, par):
    """Play a challenge to reach a target value."""
    print(f"\n{'='*60}")
    print(f"  CHALLENGE: Reach {target_name} ≈ {target_value:.8f}")
    print(f"  Par: {par} operations")
    print(f"{'='*60}")

    calc = EMLCalculator()

    while True:
        calc.display()
        print()
        print("  Commands: [1] Push 1  [e] Apply EML  [q] Quit  [r] Reset")
        cmd = input("  > ").strip().lower()

        if cmd == 'q':
            return False
        elif cmd == 'r':
            calc = EMLCalculator()
            continue
        elif cmd == '1':
            calc.push_one()
        elif cmd == 'e':
            calc.apply_eml()
        else:
            print("  Unknown command!")
            continue

        # Check if target reached
        if calc.stack and math.isfinite(calc.stack[-1]):
            if abs(calc.stack[-1] - target_value) < 1e-8:
                print(f"\n  🎉 SUCCESS! Reached {target_name} in {calc.operations} operations!")
                if calc.operations <= par:
                    print(f"  ⭐ At or under par ({par})! Excellent!")
                else:
                    print(f"  (Par was {par})")
                return True

    return False

def demo_mode():
    """Run demonstrations of EML computations."""
    print("\n" + "=" * 60)
    print("  EML TWO-BUTTON CALCULATOR — DEMO MODE")
    print("=" * 60)

    print("\n  Building constants from scratch using only eml and 1:\n")

    # Build e
    print("  Step 1: e = eml(1, 1)")
    result = eml(1, 1)
    print(f"           = exp(1) - ln(1) = {result:.10f}")

    # Build e^e
    print(f"\n  Step 2: e^e = eml(e, 1) = eml(eml(1,1), 1)")
    result = eml(eml(1, 1), 1)
    print(f"              = exp(e) - ln(1) = {result:.10f}")

    # Build e - 1
    print(f"\n  Step 3: e-1 = eml(1, e) = eml(1, eml(1,1))")
    result = eml(1, eml(1, 1))
    print(f"              = exp(1) - ln(e) = {result:.10f}")

    # Build 0
    print(f"\n  Step 4: 0 = eml(1, e^e) = eml(1, eml(eml(1,1), 1))")
    result = eml(1, eml(eml(1, 1), 1))
    print(f"            = exp(1) - ln(e^e) = exp(1) - e = {result:.10f}")

    # Build e^e - e
    print(f"\n  Step 5: e^e - e = eml(e, e^e)")
    e_val = eml(1, 1)
    ee_val = eml(e_val, 1)
    result = eml(e_val, ee_val)
    print(f"                  = exp(e) - ln(e^e) = exp(e) - e = {result:.10f}")

    # Build -1
    print(f"\n  Step 6: -1 = eml(0, e)")
    zero = eml(1, eml(eml(1, 1), 1))
    result = eml(zero, eml(1, 1))
    print(f"             = exp(0) - ln(e) = 1 - 1 = {result:.10f}")

    # Negation identity
    print(f"\n  NEGATION IDENTITY: eml(0, exp(x)) = 1 - x")
    for x in [0, 1, 2, -1, 0.5]:
        result = eml(0, math.exp(x))
        print(f"    x = {x:5.1f}: eml(0, exp({x})) = {result:.6f} = 1 - {x} = {1-x:.6f}")

    print()

def main():
    print()
    print("╔" + "═" * 58 + "╗")
    print("║" + " THE EML TWO-BUTTON CALCULATOR ".center(58) + "║")
    print("║" + " Build any number from just eml(x,y) and 1 ".center(58) + "║")
    print("╚" + "═" * 58 + "╝")
    print()
    print("  The EML operator eml(x,y) = exp(x) - ln(y) is universal:")
    print("  with just this one operation and the constant 1, you can")
    print("  compute any elementary function.")
    print()

    if len(sys.argv) > 1 and sys.argv[1] == '--demo':
        demo_mode()
        return

    print("  Modes:")
    print("    [d] Demo: Watch EML build famous constants")
    print("    [p] Play: Try to reach targets yourself")
    print("    [q] Quit")
    print()

    mode = input("  Choose mode > ").strip().lower()

    if mode == 'd':
        demo_mode()
    elif mode == 'p':
        challenges = [
            ("e ≈ 2.718", math.e, 1),
            ("e^e ≈ 15.15", math.e**math.e, 2),
            ("e-1 ≈ 1.718", math.e - 1, 2),
            ("0", 0.0, 3),
            ("e^e-e ≈ 12.43", math.e**math.e - math.e, 3),
        ]

        for name, target, par in challenges:
            if not play_challenge(name, target, par):
                break
    else:
        print("  Goodbye!")

if __name__ == "__main__":
    main()
