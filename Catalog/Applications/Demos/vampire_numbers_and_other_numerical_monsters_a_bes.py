"""
Digit-Morphic Factorization Demo
=================================

Demonstrates the key mathematical results from the Arithmetic Bestiary:
1. Vampire number enumeration and verification
2. The Generalized Casting-Out Theorem in multiple bases
3. Digit Defect Parity Theorem verification
4. Fang Residue Constraint analysis
5. Arithmetic creature classification
"""

from algorithms import (
    is_vampire, find_fangs, digit_defect, digit_sum,
    digit_multiset, num_digits, digits_base,
    check_mod_constraint, valid_residue_pairs,
    count_valid_residue_pairs, fang_constraint_density,
    is_ghost_number, is_werewolf_number,
    classify_factorization, enumerate_vampires
)
from collections import Counter
from math import isqrt


def demo_casting_out_theorem():
    """
    Demonstrate the Generalized Casting-Out Theorem:
    For any base b >= 2, if v = x*y is digit-morphic, then x*y ≡ x+y (mod b-1).
    """
    print("\n" + "=" * 70)
    print("DEMO 1: THE GENERALIZED CASTING-OUT THEOREM")
    print("=" * 70)
    print()
    print("Theorem: For digit-morphic factorization v = x*y in base b,")
    print("         x*y ≡ x + y (mod b-1)")
    print("         Equivalently: (x-1)(y-1) ≡ 1 (mod b-1)")
    print()

    # Base 10 examples
    print("Base 10 (mod 9):")
    vampires_10k = enumerate_vampires(10000)
    for v in vampires_10k[:8]:
        fangs = find_fangs(v)
        for x, y in fangs:
            lhs = (x * y) % 9
            rhs = (x + y) % 9
            fang_check = ((x - 1) * (y - 1)) % 9
            print(f"  {v} = {x} × {y}: "
                  f"x*y mod 9 = {lhs}, x+y mod 9 = {rhs}, "
                  f"(x-1)(y-1) mod 9 = {fang_check} {'✓' if fang_check == 1 else '✗'}")

    # Verify in other bases
    print("\nCross-base verification:")
    for b in [8, 12, 16]:
        m = b - 1
        # Find vampire numbers in this base
        found = 0
        for v in range(b**3, b**4):
            n = 2  # 4-digit numbers
            lo, hi = b**(n-1), b**n
            for x in range(lo, hi):
                if v % x != 0:
                    continue
                y = v // x
                if y < x or y >= hi:
                    continue
                mv = digit_multiset(v, b)
                mxy = digit_multiset(x, b) + digit_multiset(y, b)
                if mv == mxy:
                    fang_ok = ((x-1)*(y-1)) % m == 1 % m
                    print(f"  Base {b}: {v} = {x} × {y}, "
                          f"(x-1)(y-1) mod {m} = {((x-1)*(y-1))%m} {'✓' if fang_ok else '✗'}")
                    found += 1
                    if found >= 3:
                        break
            if found >= 3:
                break


def demo_digit_defect_parity():
    """
    Demonstrate the Digit Defect Parity Theorem:
    When digit counts match, the digit defect is always even.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: DIGIT DEFECT PARITY THEOREM")
    print("=" * 70)
    print()
    print("Theorem: If numDigits(v) = numDigits(x) + numDigits(y),")
    print("         then digitDefect(v, x, y) is always even.")
    print()

    # Systematic check for 2-digit × 2-digit products
    defect_histogram: dict[int, int] = {}
    total_checked = 0
    all_even = True

    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            if num_digits(v) == num_digits(x) + num_digits(y):
                d = digit_defect(v, x, y)
                defect_histogram[d] = defect_histogram.get(d, 0) + 1
                total_checked += 1
                if d % 2 != 0:
                    all_even = False

    print(f"Checked {total_checked} factorizations (2-digit × 2-digit with 4-digit product)")
    print(f"All defects even: {all_even} ✓" if all_even else f"Parity violated! ✗")
    print()
    print("Digit defect distribution:")
    for d in sorted(defect_histogram.keys()):
        count = defect_histogram[d]
        bar = "█" * min(count // 10, 40)
        print(f"  Defect {d:2d}: {count:5d} factorizations {bar}")

    # Classification
    morphic = defect_histogram.get(0, 0)
    near_miss = defect_histogram.get(2, 0)
    distant = sum(v for k, v in defect_histogram.items() if k >= 4)
    print(f"\nClassification:")
    print(f"  Morphic (vampire):   {morphic:5d} ({100*morphic/total_checked:.2f}%)")
    print(f"  Near-miss (defect 2): {near_miss:5d} ({100*near_miss/total_checked:.2f}%)")
    print(f"  Distant (defect ≥4): {distant:5d} ({100*distant/total_checked:.2f}%)")


def demo_fang_residue_analysis():
    """
    Analyze the fang residue constraint across different bases.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: FANG RESIDUE CONSTRAINT ANALYSIS")
    print("=" * 70)
    print()
    print("For base b, valid fang pairs (x,y) must satisfy")
    print("(x-1)(y-1) ≡ 1 (mod b-1).")
    print()

    print(f"{'Base':>6} {'b-1':>5} {'φ(b-1)':>7} {'Valid pairs':>12} {'Density':>10}")
    print("-" * 45)
    for b in range(2, 33):
        m = b - 1
        n_pairs = count_valid_residue_pairs(b)
        density = fang_constraint_density(b)

        # Compute Euler totient
        phi = 0
        for k in range(m):
            from math import gcd
            if gcd(k, m) == 1:
                phi += 1

        print(f"{b:>6} {m:>5} {phi:>7} {n_pairs:>12} {density:>10.4f}")

    print()
    print("Key insight: Valid pairs count = φ(b-1) always!")
    print("This is because (x-1) must be a unit mod (b-1),")
    print("and y-1 is uniquely determined as its inverse.")


def demo_creature_classification():
    """
    Classify numbers into arithmetic creature types.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: ARITHMETIC CREATURE CLASSIFICATION")
    print("=" * 70)
    print()

    print("Vampire numbers up to 1,000,000:")
    vampires = enumerate_vampires(999999)
    print(f"  Count: {len(vampires)}")
    if vampires:
        print(f"  First 10: {vampires[:10]}")
        print(f"  Last 5: {vampires[-5:]}")

    print(f"\nGhost numbers up to 10,000:")
    ghosts = []
    for v in range(4, 10001):
        if is_ghost_number(v):
            ghosts.append(v)
    print(f"  Count: {len(ghosts)}")
    if ghosts:
        print(f"  First 10: {ghosts[:10]}")

    print(f"\nWerewolf numbers up to 10,000:")
    werewolves = []
    for v in range(4, 10001):
        if is_werewolf_number(v):
            werewolves.append(v)
    print(f"  Count: {len(werewolves)}")
    if werewolves:
        print(f"  First 10: {werewolves[:10]}")


def demo_density_obstruction():
    """
    Demonstrate the density obstruction theorem.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: DENSITY OBSTRUCTION THEOREM")
    print("=" * 70)
    print()
    print("In base b ≥ 3, residue pair (1,1) CANNOT form digit-morphic fangs")
    print("because (1-1)(1-1) = 0 ≢ 1 (mod b-1).")
    print()

    for b in [3, 5, 10, 16, 100]:
        m = b - 1
        val = (0 * 0) % m
        print(f"  Base {b:3d}: (0)(0) mod {m} = {val} ≠ 1 ✓")


def demo_spectral_vacuity():
    """
    Verify the Spectral Vacuity Theorem computationally.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: SPECTRAL VACUITY THEOREM")
    print("=" * 70)
    print()
    print("Theorem: There are no 'spectral numbers' — if sorted digits match,")
    print("the multisets are identical.")
    print()
    print("Verification: checking all 4-digit factorizations...")

    spectral_found = 0
    checked = 0
    for v in range(1000, 10000):
        for x in range(10, 100):
            if v % x != 0:
                continue
            y = v // x
            if y < 10 or y > 99:
                continue
            checked += 1
            mv = sorted(digits_base(v))
            mxy = sorted(digits_base(x) + digits_base(y))
            if mv == mxy:
                # Check if multisets (with multiplicity) also match
                if digit_multiset(v) != digit_multiset(x) + digit_multiset(y):
                    spectral_found += 1
                    print(f"  SPECTRAL: {v} = {x} × {y}")

    print(f"  Checked {checked} factorizations")
    print(f"  Spectral numbers found: {spectral_found}")
    print(f"  Theorem confirmed: {'✓' if spectral_found == 0 else '✗'}")


if __name__ == "__main__":
    print("╔" + "═" * 68 + "╗")
    print("║  DIGIT-MORPHIC FACTORIZATIONS: A BESTIARY OF ARITHMETIC CREATURES  ║")
    print("╚" + "═" * 68 + "╝")

    demo_casting_out_theorem()
    demo_digit_defect_parity()
    demo_fang_residue_analysis()
    demo_creature_classification()
    demo_density_obstruction()
    demo_spectral_vacuity()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


"""
Visualization: Digit Defect Spectrum for Arithmetic Factorizations

Creates a heatmap of digit defects across the (x, y) fang space,
showing how rare digit-morphic (vampire) factorizations are.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import Counter


def digits_base(n, b=10):
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_multiset(n, b=10):
    return Counter(digits_base(n, b))


def num_digits(n, b=10):
    return len(digits_base(n, b))


def digit_defect(v, x, y, b=10):
    mv = digit_multiset(v, b)
    mxy = digit_multiset(x, b) + digit_multiset(y, b)
    excess = sum((mv - mxy).values())
    deficit = sum((mxy - mv).values())
    return excess + deficit


def main():
    # Create figure with 2x2 subplots
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Digit Defect Spectrum of Arithmetic Factorizations",
                 fontsize=16, fontweight='bold')

    # Plot 1: Heatmap of digit defects for 2-digit × 2-digit products
    ax = axes[0, 0]
    xs = range(10, 100)
    ys = range(10, 100)
    defect_map = np.full((90, 90), np.nan)
    for i, x in enumerate(xs):
        for j, y in enumerate(ys):
            if y >= x:
                v = x * y
                if num_digits(v) == 4:
                    defect_map[i, j] = digit_defect(v, x, y)

    cmap = plt.cm.RdYlGn_r.copy()
    cmap.set_bad('white')
    im = ax.imshow(defect_map, cmap=cmap, origin='lower',
                   extent=[10, 99, 10, 99], aspect='auto',
                   vmin=0, vmax=8)
    ax.set_xlabel('First fang (x)')
    ax.set_ylabel('Second fang (y)')
    ax.set_title('Digit Defect: 2-digit × 2-digit')
    plt.colorbar(im, ax=ax, label='Digit Defect')

    # Mark vampire numbers
    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            if num_digits(v) == 4 and digit_defect(v, x, y) == 0:
                ax.plot(x, y, 'k*', markersize=12)

    # Plot 2: Defect distribution histogram
    ax = axes[0, 1]
    defects = []
    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            if num_digits(v) == 4:
                defects.append(digit_defect(v, x, y))

    hist_data = Counter(defects)
    bars = sorted(hist_data.keys())
    counts = [hist_data[b] for b in bars]
    colors = ['#2ecc71' if b == 0 else '#f39c12' if b == 2 else '#e74c3c' for b in bars]
    ax.bar(bars, counts, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('Digit Defect')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Digit Defects')
    ax.annotate('Vampire\n(defect 0)', xy=(0, hist_data.get(0, 0)),
                xytext=(1.5, max(counts) * 0.8),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green', fontweight='bold')

    # Plot 3: Fang residue constraint density across bases
    ax = axes[1, 0]
    bases = list(range(2, 51))
    densities = []
    for b in bases:
        m = b - 1
        if m <= 1:
            densities.append(1.0)
            continue
        count = 0
        for rx in range(m):
            for ry in range(m):
                if ((rx - 1) * (ry - 1)) % m == 1 % m:
                    count += 1
        densities.append(count / (m * m))

    ax.plot(bases, densities, 'bo-', markersize=4, linewidth=1)
    ax.set_xlabel('Base b')
    ax.set_ylabel('Valid pair density φ(b-1)/(b-1)²')
    ax.set_title('Fang Constraint Density vs Base')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1/9, color='r', linestyle='--', alpha=0.5, label='Base 10: 6/81')
    ax.legend()

    # Plot 4: Valid residue pairs for base 10 (mod 9)
    ax = axes[1, 1]
    m = 9
    grid = np.zeros((m, m))
    for rx in range(m):
        for ry in range(m):
            if ((rx - 1) * (ry - 1)) % m == 1 % m:
                grid[rx, ry] = 1

    ax.imshow(grid, cmap='Greens', origin='lower', extent=[-0.5, 8.5, -0.5, 8.5])
    ax.set_xlabel('x mod 9')
    ax.set_ylabel('y mod 9')
    ax.set_title('Valid Fang Residue Pairs (Base 10)')
    ax.set_xticks(range(9))
    ax.set_yticks(range(9))

    for rx in range(m):
        for ry in range(m):
            if grid[rx, ry] == 1:
                ax.text(rx, ry, '✓', ha='center', va='center',
                       fontsize=12, fontweight='bold', color='darkgreen')

    plt.tight_layout()
    plt.savefig('digit_defect_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: digit_defect_spectrum.png")


if __name__ == "__main__":
    main()
