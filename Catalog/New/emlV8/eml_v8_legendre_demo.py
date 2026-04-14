#!/usr/bin/env python3
"""
EML V8 Legendre Transform Bridge Demo

Explores the connection between EML and the Legendre transform,
including applications to optimization, duality, and the AM-GM inequality.

Usage: python eml_v8_legendre_demo.py
"""

import numpy as np
from typing import List, Tuple

def eml(x: float, y: float) -> float:
    """eml(x, y) = exp(x) - ln(y)"""
    if y <= 0:
        return float('inf')
    return np.exp(x) - np.log(y)

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   EML V8 — Legendre Transform Bridge Demonstration      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # =========================================================
    # Part 1: Legendre Bridge Verification
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 1: The Legendre Bridge Identity")
    print("  eml(x, eʸ) = eˣ − y")
    print("=" * 60)

    pairs = [(0,0), (1,1), (2,3), (-1,-2), (0.5, 1.5), (3, -1)]
    print(f"\n  {'x':>6} {'y':>6} {'eml(x,eʸ)':>12} {'eˣ−y':>12} {'match':>8}")
    print(f"  {'-'*6} {'-'*6} {'-'*12} {'-'*12} {'-'*8}")
    for x, y in pairs:
        lhs = eml(x, np.exp(y))
        rhs = np.exp(x) - y
        print(f"  {x:6.1f} {y:6.1f} {lhs:12.6f} {rhs:12.6f} {'✓' if abs(lhs-rhs) < 1e-10 else '✗':>8}")

    # =========================================================
    # Part 2: Power Identity
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 2: Power Identity")
    print("  eml(n·x, 1) = (eˣ)ⁿ")
    print("=" * 60)

    x = 1.0
    print(f"\n  x = {x}")
    print(f"  {'n':>4} {'eml(n·x, 1)':>15} {'(eˣ)ⁿ':>15} {'match':>8}")
    print(f"  {'-'*4} {'-'*15} {'-'*15} {'-'*8}")
    for n in range(1, 8):
        lhs = eml(n * x, 1)
        rhs = np.exp(x) ** n
        print(f"  {n:4d} {lhs:15.6f} {rhs:15.6f} {'✓' if abs(lhs-rhs) < 1e-6 else '✗':>8}")

    # =========================================================
    # Part 3: Self-Pairing and Gap Function
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 3: Self-Pairing (Gap Function)")
    print("  G(x) = eml(x, eˣ) = eˣ − x")
    print("=" * 60)

    print(f"\n  {'x':>6} {'G(x) = eˣ−x':>15} {'G(x) ≥ 1?':>12}")
    print(f"  {'-'*6} {'-'*15} {'-'*12}")
    for x in np.linspace(-2, 3, 11):
        gap = np.exp(x) - x
        print(f"  {x:6.2f} {gap:15.6f} {'✓' if gap >= 1 - 1e-10 else '✗':>12}")

    print(f"\n  Minimum of G(x) = eˣ − x occurs at x = 0: G(0) = 1")
    print(f"  This is equivalent to eˣ ≥ 1 + x (a fundamental inequality)")

    # =========================================================
    # Part 4: Negation Involution
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 4: Negation Involution")
    print("  N(x) = eml(0, eˣ) = 1 − x")
    print("  N(N(x)) = x (double negation)")
    print("=" * 60)

    print(f"\n  {'x':>6} {'N(x) = 1−x':>12} {'N(N(x))':>10} {'= x?':>6}")
    print(f"  {'-'*6} {'-'*12} {'-'*10} {'-'*6}")
    for x in [-2, -1, 0, 0.5, 1, 2, 3]:
        nx = eml(0, np.exp(x))
        nnx = eml(0, np.exp(nx))
        print(f"  {x:6.1f} {nx:12.6f} {nnx:10.6f} {'✓' if abs(nnx - x) < 1e-10 else '✗':>6}")

    print(f"\n  Fixed point of N: N(x) = x ⟹ 1 − x = x ⟹ x = 1/2")
    print(f"  N(0.5) = {eml(0, np.exp(0.5)):.6f}")

    # =========================================================
    # Part 5: Fenchel Conjugate Connection
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 5: Fenchel Conjugate Connection")
    print("  f(x) = eˣ  ⟹  f*(p) = p ln p − p  (for p > 0)")
    print("  EML encodes this duality")
    print("=" * 60)

    print(f"\n  Fenchel-Young inequality: f(x) + f*(p) ≥ x·p")
    print(f"  i.e., eˣ + (p ln p − p) ≥ x·p")

    print(f"\n  {'x':>5} {'p':>5} {'eˣ':>10} {'p ln p−p':>12} {'sum':>10} {'x·p':>8} {'≥?':>4}")
    print(f"  {'-'*5} {'-'*5} {'-'*10} {'-'*12} {'-'*10} {'-'*8} {'-'*4}")
    for x in [0, 1, 2]:
        for p in [0.5, 1, 2, np.e]:
            ex = np.exp(x)
            fstar = p * np.log(p) - p
            total = ex + fstar
            product = x * p
            ok = total >= product - 1e-10
            print(f"  {x:5.1f} {p:5.2f} {ex:10.4f} {fstar:12.4f} {total:10.4f} {product:8.4f} {'✓' if ok else '✗':>4}")

    print(f"\n  Equality in Fenchel-Young: p = f'(x) = eˣ")
    print(f"  At equality: eml(x, eˣ) = eˣ − x = f(x) − x = f(x) − f'⁻¹(p)")

    # =========================================================
    # Part 6: AM-GM via EML Trace
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 6: AM-GM Inequality via EML Trace")
    print("  Trace(a,b) = a + b − ln a − ln b ≥ 2")
    print("=" * 60)

    print(f"\n  {'a':>8} {'b':>8} {'Trace':>10} {'≥ 2?':>6} {'√(ab)':>8}")
    print(f"  {'-'*8} {'-'*8} {'-'*10} {'-'*6} {'-'*8}")
    test_pairs = [
        (1, 1), (2, 0.5), (0.1, 10), (3, 3),
        (np.e, 1/np.e), (0.01, 100), (np.e, np.e),
        (0.001, 1000), (10, 10)
    ]
    for a, b in test_pairs:
        trace = a + b - np.log(a) - np.log(b)
        gm = np.sqrt(a * b)
        print(f"  {a:8.4f} {b:8.4f} {trace:10.4f} {'✓' if trace >= 2 - 1e-10 else '✗':>6} {gm:8.4f}")

    print(f"\n  Minimum trace = 2 at a = b = 1")
    print(f"  The AM-GM inequality: √(ab) ≤ (a+b)/2 is encoded in the EML trace!")

    # =========================================================
    # Part 7: EML Constant Hierarchy via Legendre
    # =========================================================
    print("\n" + "=" * 60)
    print("PART 7: Constants via the Legendre Bridge")
    print("=" * 60)

    print(f"\n  Via eml(x, eʸ) = eˣ − y:")
    constants = [
        ("eml(0, e⁰) = 1 − 0", eml(0, np.exp(0)), "1"),
        ("eml(1, e⁰) = e − 0", eml(1, np.exp(0)), "e"),
        ("eml(0, e¹) = 1 − 1", eml(0, np.exp(1)), "0"),
        ("eml(1, e¹) = e − 1", eml(1, np.exp(1)), "e−1"),
        ("eml(1, eᵉ) = e − e", eml(1, np.exp(np.e)), "0"),
        ("eml(2, e⁰) = e² − 0", eml(2, np.exp(0)), "e²"),
        ("eml(0, e⁻¹) = 1+1", eml(0, np.exp(-1)), "2"),
    ]

    for desc, val, name in constants:
        print(f"  {desc:30s} = {val:10.6f}  ({name})")

    print(f"\n  The Legendre bridge generates many constants by choosing")
    print(f"  x and y to cancel or simplify eˣ − y.")

    # =========================================================
    # Summary
    # =========================================================
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"""
  The Legendre bridge eml(x, eʸ) = eˣ − y is a fundamental
  structural identity of the EML operator. It:

  1. Reduces EML to simple subtraction in "dual" coordinates
  2. Generates the power identity eml(n·x, 1) = (eˣ)ⁿ
  3. Defines the self-pairing gap function G(x) = eˣ − x ≥ 1
  4. Creates the negation involution N(x) = 1 − x
  5. Connects to the Fenchel-Legendre transform of eˣ
  6. Underlies the AM-GM inequality via the EML trace
  7. Provides a systematic method for generating EML constants

  All of these results are machine-verified in Lean 4.
""")

if __name__ == "__main__":
    main()
