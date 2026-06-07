#!/usr/bin/env python3
"""
Demo: Vampire Numbers and Arithmetic Creatures

Demonstrates the key results from the formal Lean 4 proofs:
1. Enumerates vampire numbers up to 1,000,000
2. Verifies the mod-9 fang constraint
3. Computes creature spectra for various factorizations
4. Finds ghost numbers
5. Tests the fang residue enumeration
"""

from algorithms import (
    is_vampire, creature_spectrum, enumerate_vampires,
    valid_fang_residues_mod9, is_ghost, find_ghost_factorizations,
    digit_multiset, digit_set, num_digits
)


def demo_vampire_examples():
    """Show concrete vampire number examples."""
    print("=" * 60)
    print("VAMPIRE NUMBERS: Concrete Examples")
    print("=" * 60)

    examples = [
        (1260, 21, 60),
        (1395, 15, 93),
        (1435, 35, 41),
        (1530, 30, 51),
        (1560, 60, 26),
    ]

    for v, x, y in examples:
        cs = creature_spectrum(v, x, y)
        dm_v = sorted(digit_multiset(v).elements())
        dm_xy = sorted((digit_multiset(x) + digit_multiset(y)).elements())
        print(f"\n  {v} = {x} × {y}")
        print(f"    Digits of {v}: {dm_v}")
        print(f"    Digits of {x},{y}: {dm_xy}")
        print(f"    Creature Spectrum: {cs}")
        print(f"    Mod-9 check: {x}*{y} mod 9 = {(x*y)%9}, "
              f"{x}+{y} mod 9 = {(x+y)%9} → {'✓' if (x*y)%9 == (x+y)%9 else '✗'}")


def demo_mod9_constraint():
    """Demonstrate the mod-9 fang residue constraint."""
    print("\n" + "=" * 60)
    print("MOD-9 FANG RESIDUE CONSTRAINT")
    print("=" * 60)

    pairs = valid_fang_residues_mod9()
    print(f"\n  Valid (a,b) mod 9 pairs: {pairs}")
    print(f"  Count: {len(pairs)} out of 81 possible pairs")
    print(f"  Exclusion rate: {100*(1 - len(pairs)/81):.1f}%")

    print("\n  Equivalently, (a-1)(b-1) ≡ 1 (mod 9):")
    print("  Units of Z/9Z: {1, 2, 4, 5, 7, 8}")
    for a, b in pairs:
        print(f"    ({a},{b}): ({a}-1)({b}-1) = {(a-1)*(b-1)} ≡ {((a-1)*(b-1))%9} (mod 9)")


def demo_enumerate_vampires():
    """Enumerate and analyze vampire numbers."""
    print("\n" + "=" * 60)
    print("VAMPIRE NUMBER ENUMERATION")
    print("=" * 60)

    # 4-digit vampires
    vamps_4 = enumerate_vampires(10000)
    print(f"\n  4-digit vampire numbers ({len(vamps_4)} found):")
    for v, x, y in vamps_4:
        print(f"    {v} = {x} × {y}")

    # 6-digit vampires (count only)
    vamps_6 = enumerate_vampires(1000000)
    vamps_6_only = [(v, x, y) for v, x, y in vamps_6 if v >= 100000]
    print(f"\n  6-digit vampire numbers: {len(vamps_6_only)} found")
    print(f"  First 10: {[(v,x,y) for v,x,y in vamps_6_only[:10]]}")

    # Density analysis
    total_4 = 9000  # 4-digit numbers
    total_6 = 900000  # 6-digit numbers
    print(f"\n  Density of 4-digit vampires: {len(vamps_4)}/{total_4} = {len(vamps_4)/total_4:.6f}")
    print(f"  Density of 6-digit vampires: {len(vamps_6_only)}/{total_6} = {len(vamps_6_only)/total_6:.6f}")


def demo_creature_spectrum():
    """Demonstrate the Creature Spectrum framework."""
    print("\n" + "=" * 60)
    print("THE CREATURE SPECTRUM")
    print("=" * 60)

    examples = [
        ("Vampire", 1260, 21, 60),
        ("Vampire", 1395, 15, 93),
        ("Ghost", 5082, 66, 77),
        ("Intermediate", 143, 11, 13),
        ("Intermediate", 221, 13, 17),
    ]

    for label, v, x, y in examples:
        cs = creature_spectrum(v, x, y)
        nd_v = num_digits(v)
        nd_xy = num_digits(x) + num_digits(y)
        print(f"\n  [{label}] {v} = {x} × {y}")
        print(f"    Spectrum: overlap={cs['overlap']}, deficit={cs['deficit']}, surplus={cs['surplus']}")
        print(f"    Digit count: v has {nd_v} digits, x+y have {nd_xy} digits")
        print(f"    Conservation: overlap + deficit = {cs['overlap'] + cs['deficit']} = numDigits(v) ✓")
        if nd_v == nd_xy:
            print(f"    Balanced: deficit = surplus = {cs['deficit']} ✓")


def demo_ghost_numbers():
    """Find and analyze ghost numbers."""
    print("\n" + "=" * 60)
    print("GHOST NUMBERS")
    print("=" * 60)

    print("\n  Ghost factorization: 5082 = 66 × 77")
    print(f"    Digits of 5082: {digit_set(5082)}")
    print(f"    Digits of 66: {digit_set(66)}")
    print(f"    Digits of 77: {digit_set(77)}")
    print(f"    Sets disjoint? {is_ghost(5082, 66, 77)}")

    # Find more ghost numbers
    print("\n  Searching for ghost numbers up to 10000...")
    ghosts = []
    for v in range(4, 10001):
        facts = find_ghost_factorizations(v)
        if facts:
            ghosts.append((v, facts[0]))

    print(f"  Found {len(ghosts)} numbers with ghost factorizations")
    print(f"  First 20:")
    for v, (x, y) in ghosts[:20]:
        print(f"    {v} = {x} × {y}  "
              f"(digits v={digit_set(v)}, x={digit_set(x)}, y={digit_set(y)})")


def demo_digit_conservation():
    """Demonstrate the Digit Conservation Law."""
    print("\n" + "=" * 60)
    print("DIGIT CONSERVATION LAW")
    print("=" * 60)
    print("\n  Theorem: For balanced factorizations (numDigits(v) = numDigits(x) + numDigits(y)),")
    print("  the creature spectrum satisfies deficit = surplus.")
    print("\n  Examples:")

    balanced_examples = [
        (1260, 21, 60),
        (1395, 15, 93),
        (5082, 66, 77),
        (143, 11, 13),
    ]

    for v, x, y in balanced_examples:
        cs = creature_spectrum(v, x, y)
        nd_v = num_digits(v)
        nd_xy = num_digits(x) + num_digits(y)
        balanced = "✓" if nd_v == nd_xy else "✗"
        conserved = "✓" if cs['deficit'] == cs['surplus'] else "✗"
        print(f"    {v} = {x} × {y}: balanced={balanced}, "
              f"deficit={cs['deficit']}, surplus={cs['surplus']}, conserved={conserved}")


if __name__ == "__main__":
    demo_vampire_examples()
    demo_mod9_constraint()
    demo_enumerate_vampires()
    demo_creature_spectrum()
    demo_ghost_numbers()
    demo_digit_conservation()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Creature Spectrum of Arithmetic Factorizations

Generates plots showing:
1. The creature spectrum landscape
2. Vampire number distribution and density
3. Fang residue constraint visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_of(n):
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n):
    return Counter(digits_of(n))


def num_digits(n):
    if n == 0:
        return 1
    c = 0
    while n > 0:
        c += 1
        n //= 10
    return c


def creature_spectrum(v, x, y):
    dv = digit_multiset(v)
    dxy = digit_multiset(x) + digit_multiset(y)
    overlap = sum((dv & dxy).values())
    deficit = sum((dv - dxy).values())
    surplus = sum((dxy - dv).values())
    return overlap, deficit, surplus


def enumerate_vampires(limit):
    vampires = []
    nd = 4
    while 10**(nd-1) < limit:
        n = nd // 2
        lo = 10**(n-1)
        hi = 10**n
        v_lo = max(10**(nd-1), lo * lo)
        v_hi = min(limit, 10**nd)
        for x in range(lo, hi):
            y_lo = max(lo, (v_lo + x - 1) // x)
            y_hi = min(hi - 1, (v_hi - 1) // x)
            if y_lo > y_hi:
                continue
            for y in range(max(x, y_lo), y_hi + 1):
                v = x * y
                if v >= v_hi or v < v_lo:
                    continue
                if x % 10 == 0 and y % 10 == 0:
                    continue
                dv = digit_multiset(v)
                dxy = digit_multiset(x) + digit_multiset(y)
                if dv == dxy:
                    vampires.append((v, x, y))
        nd += 2
    vampires.sort()
    return vampires


def plot_fang_residues():
    """Plot the valid fang residue pairs mod 9."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Create the 9x9 grid
    grid = np.zeros((9, 9))
    valid = []
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                grid[a][b] = 1
                valid.append((a, b))

    ax.imshow(grid, cmap='RdYlGn', interpolation='nearest', origin='lower',
              vmin=0, vmax=1)

    for a in range(9):
        for b in range(9):
            color = 'white' if grid[a][b] == 1 else 'gray'
            weight = 'bold' if grid[a][b] == 1 else 'normal'
            ax.text(b, a, f'({a},{b})', ha='center', va='center',
                    fontsize=7, color=color, fontweight=weight)

    ax.set_xlabel('b mod 9', fontsize=12)
    ax.set_ylabel('a mod 9', fontsize=12)
    ax.set_title('Valid Vampire Fang Residue Pairs (mod 9)\n'
                 'Green = valid, Red = forbidden\n'
                 'Only 6 of 81 pairs allowed (92.6% exclusion)',
                 fontsize=13)
    ax.set_xticks(range(9))
    ax.set_yticks(range(9))

    plt.tight_layout()
    plt.savefig('fang_residues.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fang_residues.png")


def plot_vampire_distribution():
    """Plot vampire number distribution."""
    vampires = enumerate_vampires(1000000)
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))

    # Plot 1: 4-digit vampires
    v4 = [v for v, _, _ in vampires if 1000 <= v < 10000]
    axes[0].hist(v4, bins=50, color='darkred', alpha=0.8, edgecolor='black')
    axes[0].set_xlabel('Value', fontsize=12)
    axes[0].set_ylabel('Count', fontsize=12)
    axes[0].set_title(f'Distribution of 4-digit Vampire Numbers ({len(v4)} total)',
                      fontsize=13)

    # Plot 2: 6-digit vampires
    v6 = [v for v, _, _ in vampires if 100000 <= v < 1000000]
    axes[1].hist(v6, bins=100, color='crimson', alpha=0.8, edgecolor='black')
    axes[1].set_xlabel('Value', fontsize=12)
    axes[1].set_ylabel('Count', fontsize=12)
    axes[1].set_title(f'Distribution of 6-digit Vampire Numbers ({len(v6)} total)',
                      fontsize=13)

    plt.tight_layout()
    plt.savefig('vampire_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved vampire_distribution.png")


def plot_creature_spectrum_landscape():
    """Plot creature spectra for random factorizations."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    overlaps = []
    deficits = []
    colors = []
    labels_added = set()

    # Vampire factorizations
    vampires = enumerate_vampires(10000)
    for v, x, y in vampires:
        o, d, s = creature_spectrum(v, x, y)
        overlaps.append(o)
        deficits.append(d)
        colors.append('red')

    # Ghost factorizations
    for v in range(4, 5000):
        for x in range(2, int(v**0.5) + 1):
            if v % x != 0:
                continue
            y = v // x
            if y <= 1:
                continue
            dv = set(digits_of(v))
            dx = set(digits_of(x))
            dy = set(digits_of(y))
            if len(dv & dx) == 0 and len(dv & dy) == 0:
                o, d, s = creature_spectrum(v, x, y)
                overlaps.append(o)
                deficits.append(d + np.random.uniform(-0.1, 0.1))
                colors.append('blue')
                break

    # Random intermediate factorizations
    np.random.seed(42)
    for _ in range(200):
        v = np.random.randint(100, 10000)
        for x in range(2, int(v**0.5) + 1):
            if v % x == 0:
                y = v // x
                o, d, s = creature_spectrum(v, x, y)
                if d > 0 and o > 0:
                    overlaps.append(o + np.random.uniform(-0.1, 0.1))
                    deficits.append(d + np.random.uniform(-0.1, 0.1))
                    colors.append('green')
                break

    ax.scatter(overlaps, deficits, c=colors, alpha=0.6, s=30, edgecolors='black',
               linewidth=0.3)

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='red', label='Vampire (overlap=max, deficit=0)'),
        Patch(facecolor='blue', label='Ghost (overlap=0)'),
        Patch(facecolor='green', label='Intermediate'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=11)

    ax.set_xlabel('Overlap (shared digits)', fontsize=13)
    ax.set_ylabel('Deficit (missing digits)', fontsize=13)
    ax.set_title('The Creature Spectrum Landscape\n'
                 'Every factorization v = x × y maps to a point (overlap, deficit)',
                 fontsize=14)

    plt.tight_layout()
    plt.savefig('creature_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved creature_spectrum.png")


if __name__ == "__main__":
    plot_fang_residues()
    plot_vampire_distribution()
    plot_creature_spectrum_landscape()
    print("\nAll visualizations saved.")
