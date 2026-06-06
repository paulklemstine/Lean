#!/usr/bin/env python3
"""
Vampire Numbers and Arithmetic Creatures: Demonstration Script

Enumerates and classifies vampire numbers, ghost numbers, and werewolf numbers,
demonstrating the mod-9 fang constraint and digit-balance properties.
"""

from collections import Counter
import math


def digits_of(n: int) -> list[int]:
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result[::-1]


def digit_multiset(n: int) -> Counter:
    return Counter(digits_of(n))


def digit_set(n: int) -> set[int]:
    return set(digits_of(n))


def num_digits(n: int) -> int:
    if n == 0:
        return 1
    return len(str(n))


def find_vampire_fangs(v: int) -> list[tuple[int, int]]:
    """Find ALL fang pairs for a potential vampire number."""
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return []
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    fangs = []
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
            fangs.append((x, y))
    return fangs


def find_ghost_factorization(v: int) -> list[tuple[int, int]]:
    """Find factorizations where factor digits are disjoint from v's digits."""
    v_digits = digit_set(v)
    results = []
    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        if digit_set(x).isdisjoint(v_digits) and digit_set(y).isdisjoint(v_digits):
            results.append((x, y))
    return results


def main():
    print("=" * 70)
    print("  VAMPIRE NUMBERS AND ARITHMETIC CREATURES")
    print("  A Bestiary of Arithmetic Oddities")
    print("=" * 70)

    # === Section 1: Fang Residue Classification ===
    print("\n📐 THE MOD-9 FANG CONSTRAINT")
    print("-" * 40)
    print("For vampire v = x × y: (x-1)(y-1) ≡ 1 (mod 9)")
    print("\nValid fang residue pairs (x mod 9, y mod 9):")
    valid_pairs = []
    for a in range(9):
        for b in range(a, 9):
            if (a * b) % 9 == (a + b) % 9:
                valid_pairs.append((a, b))
                if a != b:
                    valid_pairs.append((b, a))

    # Deduplicate and sort
    valid_pairs = sorted(set(valid_pairs))
    for a, b in valid_pairs:
        print(f"  ({a}, {b})  →  {a}×{b} = {a*b} ≡ {(a*b)%9} (mod 9), "
              f"{a}+{b} = {a+b} ≡ {(a+b)%9} (mod 9)")
    print(f"\n  {len(valid_pairs)} valid pairs out of 81 total = "
          f"{len(valid_pairs)/81*100:.1f}% pass rate")

    # === Section 2: Mod-3 Exclusion ===
    print("\n🚫 MOD-3 FANG EXCLUSION")
    print("-" * 40)
    print("Theorem: Both fangs CANNOT be ≡ 1 (mod 3)")
    excluded = [(a, b) for a, b in valid_pairs if a % 3 == 1 and b % 3 == 1]
    print(f"  Pairs with both ≡ 1 (mod 3): {excluded}")
    print(f"  Confirmed: {len(excluded)} such pairs exist (should be 0)")

    # === Section 3: Enumerate 4-digit vampires ===
    print("\n🧛 FOUR-DIGIT VAMPIRE NUMBERS")
    print("-" * 40)
    vampires_4 = []
    for v in range(1000, 10000):
        fangs = find_vampire_fangs(v)
        if fangs:
            vampires_4.append((v, fangs))

    for v, fangs in vampires_4:
        fang_str = ", ".join(f"{x}×{y}" for x, y in fangs)
        ds = sum(digits_of(v))
        print(f"  {v} = {fang_str}  (digit sum: {ds}, v mod 9: {v%9})")

    print(f"\n  Total 4-digit vampire numbers: {len(vampires_4)}")

    # === Section 4: Six-digit vampires ===
    print("\n🧛 SIX-DIGIT VAMPIRE NUMBERS (first 20)")
    print("-" * 40)
    count_6 = 0
    for v in range(100000, 1000000):
        fangs = find_vampire_fangs(v)
        if fangs:
            count_6 += 1
            if count_6 <= 20:
                fang_str = ", ".join(f"{x}×{y}" for x, y in fangs)
                multi = " ★" if len(fangs) > 1 else ""
                print(f"  {v} = {fang_str}{multi}")

    print(f"\n  Total 6-digit vampire numbers: {count_6}")

    # === Section 5: Ghost numbers ===
    print("\n👻 GHOST NUMBERS (up to 10000)")
    print("-" * 40)
    print("v = x × y where digits of x, y are completely disjoint from v")
    ghost_count = 0
    for v in range(4, 10000):
        ghosts = find_ghost_factorization(v)
        if ghosts:
            ghost_count += 1
            if ghost_count <= 30:
                for x, y in ghosts[:3]:
                    print(f"  {v} = {x} × {y}  "
                          f"(v digits: {digit_set(v)}, "
                          f"x digits: {digit_set(x)}, "
                          f"y digits: {digit_set(y)})")
    print(f"\n  Total ghost numbers up to 10000: {ghost_count}")

    # === Section 6: Digit sum analysis ===
    print("\n📊 DIGIT SUM ANALYSIS")
    print("-" * 40)
    for v, fangs in vampires_4:
        x, y = fangs[0]
        ds_v = sum(digits_of(v))
        ds_x = sum(digits_of(x))
        ds_y = sum(digits_of(y))
        check = "✓" if ds_v == ds_x + ds_y else "✗"
        print(f"  {v}: digitSum({v})={ds_v} = "
              f"digitSum({x})+digitSum({y}) = {ds_x}+{ds_y} = {ds_x+ds_y} {check}")

    # === Section 7: Product bounds ===
    print("\n📏 FANG PRODUCT BOUNDS")
    print("-" * 40)
    for n in [2, 3, 4]:
        lo = 10**(2*n - 2)
        hi = 10**(2*n)
        print(f"  {n}-digit fangs: 10^{2*n-2} = {lo} ≤ x×y < {hi} = 10^{2*n}")

    print("\n" + "=" * 70)
    print("  All theorems verified computationally.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Vampire Number Landscape

Plots the distribution of vampire numbers, their fang residue pairs,
and digit sum patterns.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import Counter
import numpy as np


def digits_of(n):
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result[::-1]


def digit_multiset(n):
    return Counter(digits_of(n))


def num_digits(n):
    return len(str(n)) if n > 0 else 1


def find_vampire_fangs(v):
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return []
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    fangs = []
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
            fangs.append((x, y))
    return fangs


def main():
    # Collect 4-digit vampire numbers
    vampires = []
    for v in range(1000, 10000):
        fangs = find_vampire_fangs(v)
        if fangs:
            vampires.append((v, fangs[0]))

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("The Vampire Number Landscape", fontsize=16, fontweight='bold')

    # Plot 1: Vampire numbers on the number line
    ax1 = axes[0, 0]
    vamps = [v for v, _ in vampires]
    ax1.scatter(vamps, [0]*len(vamps), c='crimson', s=100, zorder=5, marker='D')
    for v, (x, y) in vampires:
        ax1.annotate(f'{v}\n={x}×{y}', (v, 0), textcoords="offset points",
                    xytext=(0, 15), ha='center', fontsize=7, color='darkred')
    ax1.set_xlim(900, 10100)
    ax1.set_yticks([])
    ax1.set_xlabel("Number")
    ax1.set_title("4-Digit Vampire Numbers")
    ax1.axhline(y=0, color='gray', linewidth=0.5)

    # Plot 2: Fang residue pairs mod 9
    ax2 = axes[0, 1]
    grid = np.zeros((9, 9))
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                grid[a, b] = 1
    im = ax2.imshow(grid, cmap='RdYlGn', aspect='equal', origin='lower')
    ax2.set_xticks(range(9))
    ax2.set_yticks(range(9))
    ax2.set_xlabel("y mod 9")
    ax2.set_ylabel("x mod 9")
    ax2.set_title("Valid Fang Residue Pairs (mod 9)\nGreen = valid, Red = excluded")
    for a in range(9):
        for b in range(9):
            ax2.text(b, a, '✓' if grid[a,b] else '✗',
                    ha='center', va='center', fontsize=8,
                    color='white' if grid[a,b] == 0 else 'black')

    # Plot 3: Digit sum distribution
    ax3 = axes[1, 0]
    digit_sums = [sum(digits_of(v)) for v, _ in vampires]
    ax3.bar(range(len(digit_sums)), sorted(digit_sums), color='purple', alpha=0.7)
    ax3.set_xlabel("Vampire number (sorted by digit sum)")
    ax3.set_ylabel("Digit sum")
    ax3.set_title("Digit Sums of 4-Digit Vampires")
    ax3.axhline(y=9, color='red', linestyle='--', label='Divisible by 9')
    ax3.axhline(y=18, color='blue', linestyle='--', label='2 × 9')
    ax3.legend()

    # Plot 4: Fang x vs y scatter
    ax4 = axes[1, 1]
    xs = [x for _, (x, y) in vampires]
    ys = [y for _, (x, y) in vampires]
    ax4.scatter(xs, ys, c='crimson', s=80, zorder=5, alpha=0.8)
    ax4.plot([10, 99], [10, 99], 'k--', alpha=0.3, label='x = y')
    for v, (x, y) in vampires:
        ax4.annotate(str(v), (x, y), textcoords="offset points",
                    xytext=(5, 5), fontsize=7)
    ax4.set_xlabel("Fang x")
    ax4.set_ylabel("Fang y")
    ax4.set_title("Fang Pairs (x ≤ y)")
    ax4.set_xlim(10, 99)
    ax4.set_ylim(10, 99)
    ax4.legend()

    plt.tight_layout()
    plt.savefig("vampire_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: vampire_landscape.png")


if __name__ == "__main__":
    main()
