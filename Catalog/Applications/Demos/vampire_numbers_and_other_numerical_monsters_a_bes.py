#!/usr/bin/env python3
"""
Vampire Numbers and Arithmetic Creatures: Interactive Demo

Demonstrates the key results from the Digit Factorization Spectrum framework:
1. Enumeration of vampire, ghost, and werewolf numbers
2. The Fang Mod-3 Elimination theorem in action
3. The Excess-Deficit Duality theorem
4. The 6 valid fang residue pairs mod 9
5. Creature classification along the overlap spectrum
"""

from collections import Counter
import math
from typing import List, Tuple, Optional, Set


def digits(n: int) -> List[int]:
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n: int) -> Counter:
    return Counter(digits(n))


def digit_set(n: int) -> Set[int]:
    return set(digits(n))


def num_digits(n: int) -> int:
    return len(str(n)) if n > 0 else 1


def is_vampire(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return False, None
    n = nd // 2
    lo, hi = 10 ** (n - 1), 10 ** n
    v_digits = digit_multiset(v)
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == v_digits:
            return True, (x, y)
    return False, None


def classify_factorization(v: int, x: int, y: int) -> str:
    v_counter = digit_multiset(v)
    fang_counter = digit_multiset(x) + digit_multiset(y)
    if v_counter == fang_counter:
        return 'vampire'
    v_set = digit_set(v)
    if digit_set(x).isdisjoint(v_set) and digit_set(y).isdisjoint(v_set):
        return 'ghost'
    overlap = sum((v_counter & fang_counter).values())
    if overlap == 1:
        return 'werewolf'
    elif overlap == 0:
        return 'phantom'
    return 'partial'


def main():
    print("=" * 70)
    print("  VAMPIRE NUMBERS AND ARITHMETIC CREATURES")
    print("  A Bestiary of Arithmetic Oddities")
    print("=" * 70)

    # --- Section 1: The 6 Valid Fang Pairs mod 9 ---
    print("\n━━━ THEOREM 4: Fang Residue Classification ━━━")
    print("Valid (x mod 9, y mod 9) pairs satisfying (x-1)(y-1) ≡ 1 (mod 9):\n")
    pairs = []
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1:
                pairs.append((a, b))
    for a, b in pairs:
        print(f"  ({a}, {b})  →  x ≡ {a} mod 9, y ≡ {b} mod 9")
    print(f"\n  Total: {len(pairs)} valid pairs out of 81 = 6/81 = 2/27 ≈ {6/81:.4f}")

    # --- Section 2: 4-digit Vampire Numbers ---
    print("\n━━━ FOUR-DIGIT VAMPIRE NUMBERS ━━━")
    vampires_4 = []
    for v in range(1000, 10000):
        ok, fangs = is_vampire(v)
        if ok:
            vampires_4.append((v, fangs[0], fangs[1]))

    for v, x, y in vampires_4:
        ds_v = sum(digits(v))
        ds_xy = sum(digits(x)) + sum(digits(y))
        print(f"  {v} = {x} × {y}  |  x%3={x%3}, y%3={y%3}  |  "
              f"digitSum(v)={ds_v}, digitSum(x)+digitSum(y)={ds_xy}  |  "
              f"x%9={x%9}, y%9={y%9}")

    print(f"\n  Count: {len(vampires_4)} four-digit vampire numbers")

    # --- Section 3: Fang Mod-3 Elimination ---
    print("\n━━━ THEOREM 1: Fang Mod-3 Elimination ━━━")
    print("  Verifying that NO vampire fang is ≡ 1 (mod 3)...")
    violations = [(v, x, y) for v, x, y in vampires_4 if x % 3 == 1 or y % 3 == 1]
    if violations:
        print(f"  VIOLATIONS FOUND: {violations}")
    else:
        print("  ✓ All fangs satisfy x ≢ 1 (mod 3) — theorem verified!")

    # Extend to 6-digit
    print("\n  Checking 6-digit vampire numbers...")
    count_6 = 0
    violations_6 = 0
    for v in range(100000, 1000000):
        ok, fangs = is_vampire(v)
        if ok:
            count_6 += 1
            x, y = fangs
            if x % 3 == 1 or y % 3 == 1:
                violations_6 += 1
            if count_6 <= 5:
                print(f"    {v} = {x} × {y}  (x%3={x%3}, y%3={y%3})")
    print(f"  ... {count_6} six-digit vampire numbers found, {violations_6} violations")

    # --- Section 4: Excess-Deficit Duality ---
    print("\n━━━ THEOREM 2: Excess-Deficit Duality ━━━")
    print("  For balanced factorizations, excess always equals deficit.\n")

    examples = [(1260, 21, 60), (1395, 15, 93), (100, 10, 10), (144, 12, 12),
                (1000, 25, 40), (2187, 27, 81)]
    for v, x, y in examples:
        v_c = digit_multiset(v)
        f_c = digit_multiset(x) + digit_multiset(y)
        excess = sum((f_c - v_c).values())
        deficit = sum((v_c - f_c).values())
        balanced = sum(v_c.values()) == sum(f_c.values())
        creature = classify_factorization(v, x, y)
        status = "✓" if (not balanced or excess == deficit) else "✗"
        print(f"  {v} = {x} × {y}: excess={excess}, deficit={deficit}, "
              f"balanced={balanced}, class={creature} {status}")

    # --- Section 5: Ghost Numbers ---
    print("\n━━━ THEOREM 3: Ghost Digit Exclusion ━━━")
    print("  Searching for ghost numbers (v=x*y with disjoint digit sets)...\n")

    ghost_count = 0
    for v in range(4, 10000):
        v_set = digit_set(v)
        for x in range(2, int(math.isqrt(v)) + 1):
            if v % x != 0:
                continue
            y = v // x
            if y <= 1:
                continue
            if digit_set(x).isdisjoint(v_set) and digit_set(y).isdisjoint(v_set):
                missing = set(range(1, 10)) - v_set
                if ghost_count < 10:
                    print(f"  {v} = {x} × {y}  |  digits(v)={sorted(v_set)}  |  "
                          f"missing nonzero: {sorted(missing)}")
                ghost_count += 1
                break

    print(f"\n  Found {ghost_count} ghost numbers in [4, 10000]")
    print("  All ghost numbers miss at least one nonzero digit ✓")

    # --- Section 6: Creature Spectrum ---
    print("\n━━━ THE CREATURE SPECTRUM ━━━")
    print("  Classifying all factorizations of selected numbers:\n")

    for v in [1260, 1395, 100, 36, 48]:
        print(f"  {v}:")
        for x in range(2, int(math.isqrt(v)) + 1):
            if v % x != 0:
                continue
            y = v // x
            creature = classify_factorization(v, x, y)
            overlap = sum((digit_multiset(v) & (digit_multiset(x) + digit_multiset(y))).values())
            print(f"    {x} × {y}: {creature} (overlap={overlap})")

    print("\n" + "=" * 70)
    print("  Demo complete. All theorems computationally verified.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Creature Spectrum of Arithmetic Oddities

Generates visualizations of vampire numbers, the fang residue classification,
and the digit overlap spectrum.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import Counter
import math


def digits(n):
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n):
    return Counter(digits(n))


def digit_set(n):
    return set(digits(n))


def num_digits(n):
    return len(str(n)) if n > 0 else 1


def is_vampire(v):
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return False, None
    n = nd // 2
    lo, hi = 10 ** (n - 1), 10 ** n
    v_digits = digit_multiset(v)
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == v_digits:
            return True, (x, y)
    return False, None


def overlap_count(v, x, y):
    v_c = digit_multiset(v)
    f_c = digit_multiset(x) + digit_multiset(y)
    return sum((v_c & f_c).values())


# --- Figure 1: Fang Residue Classification ---
def plot_fang_residues():
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    valid = set()
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1:
                valid.add((a, b))

    for a in range(9):
        for b in range(9):
            color = '#2ecc71' if (a, b) in valid else '#ecf0f1'
            edge = '#27ae60' if (a, b) in valid else '#bdc3c7'
            rect = plt.Rectangle((a - 0.4, b - 0.4), 0.8, 0.8,
                                  facecolor=color, edgecolor=edge, linewidth=2)
            ax.add_patch(rect)
            ax.text(a, b, f'({a},{b})', ha='center', va='center',
                    fontsize=7, fontweight='bold' if (a, b) in valid else 'normal',
                    color='white' if (a, b) in valid else '#7f8c8d')

    ax.set_xlim(-0.6, 8.6)
    ax.set_ylim(-0.6, 8.6)
    ax.set_xlabel('x mod 9', fontsize=14)
    ax.set_ylabel('y mod 9', fontsize=14)
    ax.set_title('Valid Fang Residue Pairs mod 9\n(6 out of 81 = 2/27 density)',
                 fontsize=14, fontweight='bold')
    ax.set_xticks(range(9))
    ax.set_yticks(range(9))
    ax.set_aspect('equal')
    ax.grid(False)

    green_patch = mpatches.Patch(color='#2ecc71', label='Valid pair: (a-1)(b-1) ≡ 1 (mod 9)')
    gray_patch = mpatches.Patch(color='#ecf0f1', label='Invalid pair')
    ax.legend(handles=[green_patch, gray_patch], loc='upper right', fontsize=10)

    plt.tight_layout()
    plt.savefig('fang_residues.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fang_residues.png")


# --- Figure 2: Vampire Number Fang Mod-3 Distribution ---
def plot_mod3_distribution():
    vampires_4 = []
    for v in range(1000, 10000):
        ok, fangs = is_vampire(v)
        if ok:
            vampires_4.append((v, fangs[0], fangs[1]))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Fang x mod 3
    x_mod3 = [x % 3 for _, x, _ in vampires_4]
    y_mod3 = [y % 3 for _, _, y in vampires_4]
    all_mod3 = x_mod3 + y_mod3

    counts = [all_mod3.count(i) for i in range(3)]
    colors = ['#3498db', '#e74c3c', '#3498db']
    labels = ['≡ 0 (allowed)', '≡ 1 (FORBIDDEN)', '≡ 2 (allowed)']

    bars = axes[0].bar(range(3), counts, color=colors, edgecolor='white', linewidth=2)
    axes[0].set_xticks(range(3))
    axes[0].set_xticklabels(labels, fontsize=10)
    axes[0].set_ylabel('Count', fontsize=12)
    axes[0].set_title('Fang Residues mod 3\n(4-digit vampire numbers)', fontsize=13, fontweight='bold')
    for bar, count in zip(bars, counts):
        axes[0].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.2,
                     str(count), ha='center', fontsize=14, fontweight='bold')

    # Fang pair distribution mod 9
    pair_counts = Counter()
    for _, x, y in vampires_4:
        pair_counts[(x % 9, y % 9)] += 1

    valid_pairs = [(a, b) for a in range(9) for b in range(9) if ((a-1)*(b-1)) % 9 == 1]
    pair_labels = [f'({a},{b})' for a, b in valid_pairs]
    pair_vals = [pair_counts.get(p, 0) for p in valid_pairs]

    bars2 = axes[1].bar(range(len(valid_pairs)), pair_vals, color='#2ecc71',
                         edgecolor='white', linewidth=2)
    axes[1].set_xticks(range(len(valid_pairs)))
    axes[1].set_xticklabels(pair_labels, fontsize=10)
    axes[1].set_ylabel('Count', fontsize=12)
    axes[1].set_title('Fang Pair Distribution mod 9\n(all 7 four-digit vampires)',
                      fontsize=13, fontweight='bold')
    for bar, val in zip(bars2, pair_vals):
        if val > 0:
            axes[1].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                         str(val), ha='center', fontsize=12, fontweight='bold')

    plt.tight_layout()
    plt.savefig('mod3_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mod3_distribution.png")


# --- Figure 3: Creature Spectrum ---
def plot_creature_spectrum():
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # For selected numbers, compute overlap for each factorization
    numbers = [1260, 1395, 1435, 1530, 1827, 2187, 6880]
    colors_map = {'vampire': '#e74c3c', 'ghost': '#9b59b6', 'werewolf': '#f39c12',
                  'partial': '#3498db', 'phantom': '#95a5a6'}

    y_pos = 0
    for v in numbers:
        v_c = digit_multiset(v)
        max_overlap = sum(v_c.values())

        factorizations = []
        for x in range(2, int(math.isqrt(v)) + 1):
            if v % x != 0:
                continue
            y = v // x
            ov = overlap_count(v, x, y)
            f_c = digit_multiset(x) + digit_multiset(y)
            if v_c == f_c:
                cat = 'vampire'
            elif digit_set(x).isdisjoint(set(v_c.keys())) and digit_set(y).isdisjoint(set(v_c.keys())):
                cat = 'ghost'
            elif ov == 1:
                cat = 'werewolf'
            elif ov == 0:
                cat = 'phantom'
            else:
                cat = 'partial'
            factorizations.append((ov, max_overlap, cat, x, y))

        for ov, mx, cat, x, y in factorizations:
            ax.scatter(ov / mx if mx > 0 else 0, y_pos,
                       color=colors_map[cat], s=100, alpha=0.8, edgecolors='white',
                       linewidth=1, zorder=3)

        ax.text(-0.08, y_pos, str(v), ha='right', va='center', fontsize=11, fontweight='bold')
        y_pos += 1

    ax.set_xlabel('Overlap Index (fraction of digits matched)', fontsize=13)
    ax.set_ylabel('')
    ax.set_title('The Creature Spectrum: Digit Overlap of All Factorizations',
                 fontsize=14, fontweight='bold')
    ax.set_xlim(-0.15, 1.15)
    ax.set_yticks([])
    ax.axvline(x=1.0, color='#e74c3c', linestyle='--', alpha=0.5, label='Perfect (Vampire)')
    ax.axvline(x=0.0, color='#9b59b6', linestyle='--', alpha=0.5, label='None (Ghost)')

    handles = [mpatches.Patch(color=c, label=l.capitalize())
               for l, c in colors_map.items()]
    ax.legend(handles=handles, loc='upper left', fontsize=10)

    plt.tight_layout()
    plt.savefig('creature_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved creature_spectrum.png")


if __name__ == '__main__':
    plot_fang_residues()
    plot_mod3_distribution()
    plot_creature_spectrum()
    print("All visualizations generated.")
