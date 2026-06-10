#!/usr/bin/env python3
"""
Knuth Semifield Classification: Demonstrations

Numerical examples illustrating nucleus theory, Knuth S₃ action,
defect-rank duality, and semifield code parameters.
"""

from itertools import product as cartesian_product
from collections import Counter
from math import gcd

def divisors(n: int) -> list[int]:
    """All positive divisors of n, sorted."""
    return sorted(d for d in range(1, n + 1) if n % d == 0)

def nucleus_product(p: int, dl: int, dm: int, dr: int) -> int:
    """Compute the nucleus product p^dl * p^dm * p^dr."""
    return p**dl * p**dm * p**dr

def knuth_transpose(triple: tuple[int, int, int]) -> tuple[int, int, int]:
    """Knuth transpose: swap left and right nuclei."""
    dl, dm, dr = triple
    return (dr, dm, dl)

def knuth_dual(triple: tuple[int, int, int]) -> tuple[int, int, int]:
    """Knuth dual: swap left and middle nuclei."""
    dl, dm, dr = triple
    return (dm, dl, dr)

def knuth_orbit(triple: tuple[int, int, int]) -> set[tuple[int, int, int]]:
    """Compute the full Knuth S₃ orbit of a nucleus triple."""
    orbit = set()
    current = triple
    for _ in range(6):
        orbit.add(current)
        orbit.add(knuth_transpose(current))
        current = knuth_dual(knuth_transpose(current))
    return orbit

def valid_nucleus_triples(n: int) -> list[tuple[int, int, int]]:
    """All valid ordered nucleus triples (dl, dm, dr) with each dividing n."""
    divs = divisors(n)
    return [(dl, dm, dr) for dl in divs for dm in divs for dr in divs]

def s3_orbits(triples: list[tuple[int, int, int]]) -> list[frozenset]:
    """Compute S₃ orbits on a list of triples."""
    seen = set()
    orbits = []
    for t in triples:
        if t not in seen:
            orb = knuth_orbit(t)
            seen |= orb
            orbits.append(frozenset(orb))
    return orbits


def demo_knuth_action():
    """Demonstrate the Knuth S₃ action on nucleus triples."""
    print("=" * 60)
    print("DEMO 1: Knuth S₃ Action on Nucleus Triples")
    print("=" * 60)

    # Example: p=2, n=6
    n = 6
    divs = divisors(n)
    print(f"\nDivisors of {n}: {divs}")
    print(f"Number of divisors: {len(divs)}")
    print(f"Total ordered triples: {len(divs)**3}")

    # Compute orbits
    triples = valid_nucleus_triples(n)
    orbits = s3_orbits(triples)
    print(f"S₃ orbits (isotopy classes): {len(orbits)}")

    # Show some orbits
    print("\nSelected orbits:")
    for i, orb in enumerate(sorted(orbits, key=lambda o: min(o))[:10]):
        rep = min(orb)
        print(f"  Orbit {i+1}: representative {rep}, size {len(orb)}")

    # Field case: (n, n, n)
    field_triple = (n, n, n)
    field_orbit = knuth_orbit(field_triple)
    print(f"\nField triple {field_triple}: orbit size {len(field_orbit)} (all Knuth ops trivial)")

    # Twisted field: (n/2, 1, n/2)
    twisted = (n // 2, 1, n // 2)
    twisted_orbit = knuth_orbit(twisted)
    print(f"Twisted field {twisted}: orbit size {len(twisted_orbit)}")

    # Asymmetric: (1, 2, 3)
    asym = (1, 2, 3)
    asym_orbit = knuth_orbit(asym)
    print(f"Asymmetric {asym}: orbit size {len(asym_orbit)}")
    print(f"  Full orbit: {sorted(asym_orbit)}")


def demo_nucleus_product_bound():
    """Demonstrate the nucleus product bound."""
    print("\n" + "=" * 60)
    print("DEMO 2: Nucleus Product Bound")
    print("=" * 60)

    p = 2
    for n in [4, 6, 8]:
        order = p ** n
        order_cubed = order ** 3
        triples = valid_nucleus_triples(n)

        print(f"\np = {p}, n = {n}, order = {order}")
        print(f"  order³ = {order_cubed}")

        # Non-field triples
        non_field = [t for t in triples if t != (n, n, n)]
        if non_field:
            max_product = max(nucleus_product(p, *t) for t in non_field)
            min_product = min(nucleus_product(p, *t) for t in non_field)
            print(f"  Non-field nucleus products: min = {min_product}, max = {max_product}")
            print(f"  Max non-field product < order³? {max_product < order_cubed}")

        # Field product
        field_product = nucleus_product(p, n, n, n)
        print(f"  Field product = {field_product} = order³? {field_product == order_cubed}")


def demo_defect_rank():
    """Demonstrate defect-rank duality."""
    print("\n" + "=" * 60)
    print("DEMO 3: Defect-Rank Duality")
    print("=" * 60)

    p = 2
    print(f"\nBase prime p = {p}")
    print(f"{'k':>4} {'n':>4} {'rank':>5} {'defect':>10} {'p^k(p^k-1)':>12} {'bound ok':>10}")
    print("-" * 50)

    for k in [1, 2, 3]:
        for mult in [1, 2, 3, 4]:
            n = k * mult
            rank = n // k
            defect = p**n - p**k
            min_defect = p**k * (p**k - 1) if rank >= 2 else 0
            bound_ok = defect >= min_defect if rank >= 2 else "N/A"
            print(f"{k:>4} {n:>4} {rank:>5} {defect:>10} {min_defect:>12} {str(bound_ok):>10}")


def demo_code_parameters():
    """Demonstrate semifield code parameters."""
    print("\n" + "=" * 60)
    print("DEMO 4: Semifield Code Parameters")
    print("=" * 60)

    print("\nSemifield of order 2^6 = 64:")
    print(f"{'d_l':>4} {'rank':>5} {'rate':>8} {'min_dist':>10} {'MRD?':>6}")
    print("-" * 40)

    n = 6
    for dl in divisors(n):
        rank = n // dl
        rate = f"{dl}/{n}"
        min_dist = rank
        # MRD check: min_dist = n - dl + 1?
        is_mrd = (min_dist == n - dl + 1)
        print(f"{dl:>4} {rank:>5} {rate:>8} {min_dist:>10} {'Yes' if is_mrd else 'No':>6}")


def demo_twisted_fields():
    """Demonstrate twisted field construction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Generalized Twisted Fields")
    print("=" * 60)

    print("\nTwisted fields from automorphisms of GF(2^n):")
    print(f"{'n':>4} {'σ-order':>8} {'d_l':>4} {'d_m':>4} {'d_r':>4} {'orbit size':>11}")
    print("-" * 45)

    for n in [4, 6, 8, 10, 12]:
        divs = [d for d in divisors(n) if d > 1]
        for s in divs:
            dl = n // s
            dm = 1
            dr = n // s
            triple = (dl, dm, dr)
            orbit = knuth_orbit(triple)
            print(f"{n:>4} {s:>8} {dl:>4} {dm:>4} {dr:>4} {len(orbit):>11}")


def demo_counting():
    """Count semifield isotopy classes by nucleus triple."""
    print("\n" + "=" * 60)
    print("DEMO 6: Counting Isotopy Classes by Nucleus Triple")
    print("=" * 60)

    for n in [4, 6, 8, 10, 12]:
        triples = valid_nucleus_triples(n)
        non_field = [t for t in triples if t != (n, n, n)]
        orbits = s3_orbits(non_field)
        orbit_sizes = Counter(len(orb) for orb in orbits)
        print(f"\nn = {n}: {len(divisors(n))} divisors, "
              f"{len(triples)} ordered triples, "
              f"{len(orbits)} non-field S₃ orbits (+1 field)")
        print(f"  Orbit size distribution: {dict(sorted(orbit_sizes.items()))}")


if __name__ == "__main__":
    demo_knuth_action()
    demo_nucleus_product_bound()
    demo_defect_rank()
    demo_code_parameters()
    demo_twisted_fields()
    demo_counting()


#!/usr/bin/env python3
"""
Visualization: Nucleus Landscape of Semifields

Plots the nucleus product vs order for all valid NucleiConfigs,
showing the field characterization and product bound.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def divisors(n):
    return sorted(d for d in range(1, n + 1) if n % d == 0)


def plot_nucleus_landscape():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    p = 2

    for idx, n in enumerate([4, 6, 8]):
        ax = axes[idx]
        divs = divisors(n)
        order = p ** n

        # Collect all nucleus triples and their products
        triples = []
        products = []
        is_field_list = []
        exp_sums = []

        for dl in divs:
            for dm in divs:
                for dr in divs:
                    prod = p**dl * p**dm * p**dr
                    triples.append((dl, dm, dr))
                    products.append(prod)
                    is_field_list.append(dl == n and dm == n and dr == n)
                    exp_sums.append(dl + dm + dr)

        exp_sums = np.array(exp_sums)
        products = np.array(products)
        is_field = np.array(is_field_list)

        # Plot non-field points
        mask_nf = ~is_field
        ax.scatter(exp_sums[mask_nf], np.log2(products[mask_nf]),
                   c='steelblue', alpha=0.5, s=20, label='Non-field')

        # Plot field point
        if np.any(is_field):
            ax.scatter(exp_sums[is_field], np.log2(products[is_field]),
                       c='red', s=100, marker='*', zorder=5, label='Field')

        # Plot bounds
        x_range = np.linspace(0, 3 * n + 1, 100)
        ax.plot(x_range, x_range, 'k--', alpha=0.3, label='y = exp_sum (log₂)')
        ax.axhline(y=np.log2(order**3), color='red', linestyle=':', alpha=0.5,
                   label=f'order³ = 2^{3*n}')
        ax.axvline(x=3*n, color='red', linestyle=':', alpha=0.3)

        ax.set_xlabel('Nucleus exponent sum (d_l + d_m + d_r)')
        ax.set_ylabel('log₂(nucleus product)')
        ax.set_title(f'p = {p}, n = {n}, order = {order}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Nucleus Product Landscape: Product < Order³ for Non-Fields',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('nucleus_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved nucleus_landscape.png")


def plot_defect_rank():
    fig, ax = plt.subplots(figsize=(10, 6))
    p = 2

    for k in [1, 2, 3, 4]:
        ranks = list(range(1, 9))
        defects = [p**(k * r) - p**k for r in ranks]
        min_bounds = [p**k * (p**k - 1) if r >= 2 else 0 for r in ranks]

        ax.plot(ranks, defects, 'o-', label=f'k = {k} (nucleus = 2^{k})')
        ax.plot(ranks, min_bounds, 's--', alpha=0.5,
                label=f'min bound k={k}')

    ax.set_xlabel('Rank (n/k)')
    ax.set_ylabel('Defect (p^n - p^k)')
    ax.set_title('Defect-Rank Duality: Defect grows exponentially with rank')
    ax.set_yscale('log')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('defect_rank.png', dpi=150, bbox_inches='tight')
    print("Saved defect_rank.png")


def plot_orbit_sizes():
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(2, 25))
    orbit_counts = []
    max_orbits = []

    for n in ns:
        divs = divisors(n)
        seen = set()
        count = 0
        for dl in divs:
            for dm in divs:
                for dr in divs:
                    key = tuple(sorted([dl, dm, dr]))
                    if key not in seen:
                        seen.add(key)
                        count += 1
        orbit_counts.append(count)
        max_orbits.append(len(divs) ** 3)

    ax.bar(ns, orbit_counts, color='steelblue', alpha=0.7, label='S₃ orbits')
    ax.plot(ns, [len(divisors(n))**3 for n in ns], 'r--',
            label='Ordered triples (τ(n)³)')
    ax.set_xlabel('n')
    ax.set_ylabel('Count')
    ax.set_title('Number of Distinct Nucleus Isotopy Classes vs n')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('orbit_sizes.png', dpi=150, bbox_inches='tight')
    print("Saved orbit_sizes.png")


if __name__ == "__main__":
    plot_nucleus_landscape()
    plot_defect_rank()
    plot_orbit_sizes()
