#!/usr/bin/env python3
"""
Vampire Numbers and Arithmetic Creatures: Demonstration
======================================================
Enumerates and classifies vampire, werewolf, and ghost numbers,
illustrating the key theorems from the Digit Factorization Algebra.
"""

from collections import Counter
from typing import List, Tuple, Optional


def digits(n: int) -> List[int]:
    """Return the list of decimal digits of n."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n: int) -> Counter:
    """Return the multiset (Counter) of decimal digits of n."""
    return Counter(digits(n))


def digit_set(n: int) -> set:
    """Return the set of distinct digits appearing in n."""
    return set(digits(n))


def num_digits(n: int) -> int:
    """Number of decimal digits."""
    if n == 0:
        return 1
    count = 0
    while n > 0:
        count += 1
        n //= 10
    return count


def is_vampire(v: int) -> Optional[Tuple[int, int]]:
    """Check if v is a vampire number. Returns (x, y) fangs if so, else None."""
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return None
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if num_digits(y) != n:
            continue
        # Check trailing zeros constraint
        if x % 10 == 0 and y % 10 == 0:
            continue
        # Check digit multiset
        if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
            return (x, y)
    return None


def is_resonant(n: int) -> Optional[Tuple[int, int]]:
    """Check if n has a resonant factorization (digits of product = combined digits of factors)."""
    for x in range(2, int(n**0.5) + 1):
        if n % x == 0:
            y = n // x
            if digit_multiset(n) == digit_multiset(x) + digit_multiset(y):
                return (x, y)
    return None


def is_ghost(v: int) -> Optional[Tuple[int, int]]:
    """Check if v is a ghost number (some factorization with disjoint digit sets)."""
    ds_v = digit_set(v)
    for x in range(2, int(v**0.5) + 1):
        if v % x == 0:
            y = v // x
            if y <= 1:
                continue
            if ds_v.isdisjoint(digit_set(x)) and ds_v.isdisjoint(digit_set(y)):
                return (x, y)
    return None


def is_werewolf(v: int) -> Optional[Tuple[int, int]]:
    """Check if v is a werewolf number (exactly one shared digit type with factors)."""
    ds_v = digit_set(v)
    for x in range(2, int(v**0.5) + 1):
        if v % x == 0:
            y = v // x
            if y <= 1:
                continue
            shared = ds_v & (digit_set(x) | digit_set(y))
            if len(shared) == 1:
                return (x, y)
    return None


def mod9_fang_pairs():
    """Enumerate all valid fang pairs mod 9 satisfying (a-1)(b-1) ≡ 1 (mod 9)."""
    pairs = []
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1:
                pairs.append((a, b))
    return pairs


def main():
    print("=" * 70)
    print("  VAMPIRE NUMBERS AND ARITHMETIC CREATURES")
    print("  A Bestiary of Arithmetic Oddities")
    print("=" * 70)

    # 1. Enumerate vampire numbers up to 1,000,000
    print("\n--- VAMPIRE NUMBERS (4-digit) ---")
    vampires_4 = []
    for v in range(1000, 10000):
        result = is_vampire(v)
        if result:
            vampires_4.append((v, result))
    print(f"Found {len(vampires_4)} vampire numbers with 4 digits:")
    for v, (x, y) in vampires_4:
        print(f"  {v} = {x} × {y}")

    print("\n--- VAMPIRE NUMBERS (6-digit) ---")
    vampires_6 = []
    for v in range(100000, 1000000):
        result = is_vampire(v)
        if result:
            vampires_6.append((v, result))
    print(f"Found {len(vampires_6)} vampire numbers with 6 digits")
    for v, (x, y) in vampires_6[:10]:
        print(f"  {v} = {x} × {y}")
    if len(vampires_6) > 10:
        print(f"  ... and {len(vampires_6) - 10} more")

    # 2. Mod-9 constraint verification
    print("\n--- MOD-9 FANG CONSTRAINT ---")
    pairs = mod9_fang_pairs()
    print(f"Valid fang pairs (a, b) mod 9 with (a-1)(b-1) ≡ 1 (mod 9):")
    for a, b in pairs:
        print(f"  ({a}, {b})")
    print(f"Total: {len(pairs)} pairs (= φ(9) = 6)")

    # Verify against actual vampire numbers
    print("\nVerification against actual vampire numbers:")
    for v, (x, y) in vampires_4:
        xm, ym = x % 9, y % 9
        constraint = ((xm - 1) * (ym - 1)) % 9
        status = "✓" if constraint == 1 else "✗"
        print(f"  {v} = {x} × {y}: x≡{xm}, y≡{ym} mod 9, "
              f"(x-1)(y-1)≡{constraint} mod 9 {status}")

    # 3. Ghost numbers
    print("\n--- GHOST NUMBERS (up to 10000) ---")
    ghosts = []
    for v in range(4, 10000):
        result = is_ghost(v)
        if result:
            ghosts.append((v, result))
    print(f"Found {len(ghosts)} ghost numbers up to 10000:")
    for v, (x, y) in ghosts[:20]:
        ds_v = digit_set(v)
        ds_x = digit_set(x)
        ds_y = digit_set(y)
        print(f"  {v} = {x} × {y}  (digits v={ds_v}, x={ds_x}, y={ds_y})")
    if len(ghosts) > 20:
        print(f"  ... and {len(ghosts) - 20} more")

    # 4. Werewolf numbers
    print("\n--- WEREWOLF NUMBERS (up to 10000) ---")
    werewolves = []
    for v in range(4, 10000):
        result = is_werewolf(v)
        if result:
            werewolves.append((v, result))
    print(f"Found {len(werewolves)} werewolf numbers up to 10000:")
    for v, (x, y) in werewolves[:15]:
        ds_v = digit_set(v)
        shared = ds_v & (digit_set(x) | digit_set(y))
        print(f"  {v} = {x} × {y}  (shared digit: {shared})")
    if len(werewolves) > 15:
        print(f"  ... and {len(werewolves) - 15} more")

    # 5. Resonant numbers
    print("\n--- RESONANT NUMBERS (up to 10000) ---")
    resonants = []
    for n in range(4, 10000):
        result = is_resonant(n)
        if result:
            resonants.append((n, result))
    print(f"Found {len(resonants)} resonant numbers up to 10000")
    for n, (x, y) in resonants[:15]:
        print(f"  {n} = {x} × {y}")

    # 6. Density analysis
    print("\n--- DENSITY ANALYSIS ---")
    for k in range(2, 5):
        lo = 10 ** (2 * k - 1)
        hi = 10 ** (2 * k)
        count = sum(1 for v in range(lo, min(hi, lo + 100000))
                    if is_vampire(v) is not None)
        sampled = min(hi - lo, 100000)
        density = count / sampled if sampled > 0 else 0
        print(f"  {2*k}-digit: {count} vampires in first {sampled} numbers "
              f"(density ≈ {density:.6f})")

    # 7. Creature overlap analysis
    print("\n--- CREATURE OVERLAP ANALYSIS ---")
    v_set = set(v for v, _ in vampires_4)
    g_set = set(v for v, _ in ghosts if 1000 <= v < 10000)
    w_set = set(v for v, _ in werewolves if 1000 <= v < 10000)
    print(f"  4-digit vampires: {len(v_set)}")
    print(f"  4-digit ghosts: {len(g_set)}")
    print(f"  4-digit werewolves: {len(w_set)}")
    print(f"  Vampire ∩ Ghost: {v_set & g_set}")
    print(f"  Vampire ∩ Werewolf: {v_set & w_set}")
    print(f"  Ghost ∩ Werewolf: {len(g_set & w_set)} numbers")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Density of Arithmetic Creatures by Digit Count
=============================================================
Plots the density of vampire, ghost, and werewolf numbers as a
function of the number of digits, illustrating their asymptotic behavior.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from math import isqrt, comb, sqrt, pi


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


def digit_set(n):
    return set(digits_of(n))


def num_digits(n):
    if n == 0:
        return 1
    return len(digits_of(n))


def is_vampire(v):
    d = num_digits(v)
    if d < 4 or d % 2 != 0:
        return False
    n = d // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    target = digit_multiset(v)
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi or num_digits(y) != n:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == target:
            return True
    return False


def is_ghost(v):
    dv = digit_set(v)
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        if dv.isdisjoint(digit_set(x)) and dv.isdisjoint(digit_set(y)):
            return True
    return False


def is_werewolf(v):
    dv = digit_set(v)
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        shared = dv & (digit_set(x) | digit_set(y))
        if len(shared) == 1:
            return True
    return False


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Creature counts by digit range
    ranges = [
        (2, 10, 100),
        (3, 100, 1000),
        (4, 1000, 10000),
    ]

    digit_counts = []
    vampire_counts = []
    ghost_counts = []
    werewolf_counts = []

    for d, lo, hi in ranges:
        vc = gc = wc = 0
        for v in range(lo, hi):
            if d % 2 == 0 and is_vampire(v):
                vc += 1
            if is_ghost(v):
                gc += 1
            if is_werewolf(v):
                wc += 1
        digit_counts.append(d)
        vampire_counts.append(vc)
        ghost_counts.append(gc)
        werewolf_counts.append(wc)

    x_pos = np.arange(len(digit_counts))
    width = 0.25

    axes[0].bar(x_pos - width, vampire_counts, width, label='Vampire', color='#8B0000')
    axes[0].bar(x_pos, ghost_counts, width, label='Ghost', color='#4169E1')
    axes[0].bar(x_pos + width, werewolf_counts, width, label='Werewolf', color='#556B2F')
    axes[0].set_xlabel('Number of Digits')
    axes[0].set_ylabel('Count')
    axes[0].set_title('Arithmetic Creatures by Digit Count')
    axes[0].set_xticks(x_pos)
    axes[0].set_xticklabels(digit_counts)
    axes[0].legend()
    axes[0].set_yscale('log')

    # Panel 2: Mod-9 constraint visualization
    grid = np.zeros((9, 9))
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1:
                grid[a][b] = 1

    axes[1].imshow(grid, cmap='RdYlGn', interpolation='nearest', origin='lower')
    axes[1].set_xlabel('b mod 9')
    axes[1].set_ylabel('a mod 9')
    axes[1].set_title('Valid Fang Pairs (a,b) mod 9\n(a-1)(b-1) ≡ 1 (mod 9)')
    axes[1].set_xticks(range(9))
    axes[1].set_yticks(range(9))
    for i in range(9):
        for j in range(9):
            color = 'white' if grid[i][j] > 0 else 'gray'
            axes[1].text(j, i, f'({i},{j})', ha='center', va='center',
                        fontsize=6, color=color)

    # Panel 3: Theoretical density vs observed
    ns = list(range(2, 7))
    theoretical = [comb(2*n, n) / 10**n for n in ns]

    axes[2].semilogy(ns, theoretical, 'o-', color='#8B0000', label='C(2n,n)/10^n')
    axes[2].semilogy(ns, [1/sqrt(pi*n) for n in ns], 's--', color='#4169E1',
                     label='1/√(πn) (Stirling)')
    axes[2].set_xlabel('n (half-digit count)')
    axes[2].set_ylabel('Expected fang density')
    axes[2].set_title('Vampire Number Density Bound\n(Multinomial Counting)')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('creature_density.png', dpi=150, bbox_inches='tight')
    print("Saved creature_density.png")


if __name__ == "__main__":
    main()
