#!/usr/bin/env python3
"""
Discriminant Uniformity Theorem — Numerical Demonstrations

Demonstrates that for a prime p, the discriminant map (b,c) -> b^2 - 4c
from F_p^2 to F_p has every fiber of cardinality exactly p.
"""


def quad_disc(b: int, c: int, p: int) -> int:
    """Compute the discriminant b^2 - 4c mod p."""
    return (b * b - 4 * c) % p


def fiber_sizes(p: int) -> dict[int, int]:
    """Compute the size of each fiber of the discriminant map over F_p."""
    counts: dict[int, int] = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = quad_disc(b, c, p)
            counts[d] += 1
    return counts


def verify_uniformity(p: int) -> bool:
    """Verify that every fiber has size exactly p."""
    sizes = fiber_sizes(p)
    return all(size == p for size in sizes.values())


def separability_density(p: int) -> float:
    """Compute the fraction of separable quadratics over F_p."""
    total = p * p
    inseparable = p  # fiber over 0
    return (total - inseparable) / total


def nonsquare_count(p: int) -> int:
    """Count non-squares in Z/pZ for an odd prime p."""
    squares = set()
    for x in range(p):
        squares.add((x * x) % p)
    return p - len(squares)


def splitting_type_distribution(p: int) -> dict[str, int]:
    """Compute the distribution of splitting types for quadratics over F_p."""
    squares = set()
    for x in range(p):
        squares.add((x * x) % p)

    counts = {"split": 0, "ramified": 0, "inert": 0}
    for b in range(p):
        for c in range(p):
            d = quad_disc(b, c, p)
            if d == 0:
                counts["ramified"] += 1
            elif d in squares:
                counts["split"] += 1
            else:
                counts["inert"] += 1
    return counts


def cubic_disc(b: int, c: int, p: int) -> int:
    """Compute the cubic discriminant -(4b^3 + 27c^2) mod p."""
    return (-(4 * b**3 + 27 * c**2)) % p


def cubic_fiber_sizes(p: int) -> dict[int, int]:
    """Compute fiber sizes for the cubic discriminant map over F_p."""
    counts: dict[int, int] = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = cubic_disc(b, c, p)
            counts[d] += 1
    return counts


if __name__ == "__main__":
    print("=" * 60)
    print("DISCRIMINANT UNIFORMITY THEOREM — DEMONSTRATIONS")
    print("=" * 60)

    # Verify uniformity for several primes
    print("\n1. FIBER UNIFORMITY VERIFICATION")
    print("-" * 40)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        sizes = fiber_sizes(p)
        uniform = verify_uniformity(p)
        print(f"  p = {p:2d}: all fibers size {p}? {uniform}  "
              f"(sizes: {list(sizes.values())[:5]}{'...' if p > 5 else ''})")

    # Separability density
    print("\n2. SEPARABILITY DENSITY")
    print("-" * 40)
    for p in [2, 3, 5, 7, 11, 13, 101, 997]:
        density = separability_density(p)
        expected = 1 - 1/p
        print(f"  p = {p:4d}: density = {density:.6f} = 1 - 1/{p} = {expected:.6f}")

    # Non-square counts
    print("\n3. NON-SQUARE COUNTS")
    print("-" * 40)
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        ns = nonsquare_count(p)
        expected = (p - 1) // 2
        print(f"  p = {p:2d}: non-squares = {ns}, expected (p-1)/2 = {expected}")

    # Splitting type distribution
    print("\n4. SPLITTING TYPE DISTRIBUTION")
    print("-" * 40)
    for p in [3, 5, 7, 11, 13]:
        dist = splitting_type_distribution(p)
        total = p * p
        print(f"  p = {p:2d}: split={dist['split']:3d} ({dist['split']/total:.3f}), "
              f"ramified={dist['ramified']:2d} ({dist['ramified']/total:.3f}), "
              f"inert={dist['inert']:3d} ({dist['inert']/total:.3f})")
        print(f"         Expected: split={(p-1)*(p-1)//(2*p)}, "  # rough
              f"ramified={p}, inert approx {(p-1)*p//2//p}")

    # Cubic discriminant fiber sizes (conjecture test)
    print("\n5. CUBIC DISCRIMINANT FIBER SIZES (CONJECTURE)")
    print("-" * 40)
    for p in [5, 7, 11, 13, 17]:
        sizes = cubic_fiber_sizes(p)
        values = list(sizes.values())
        uniform = all(v == p for v in values)
        print(f"  p = {p:2d}: all fibers size {p}? {uniform}")
        if not uniform:
            print(f"         sizes: {values}")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Fiber Uniformity of the Discriminant Map

Creates a heatmap showing the discriminant values for all (b,c) pairs
over F_p, visually demonstrating the uniform distribution.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def quad_disc(b: int, c: int, p: int) -> int:
    return (b * b - 4 * c) % p


def plot_discriminant_heatmap(p: int, ax: plt.Axes) -> None:
    """Plot the discriminant map as a heatmap over (b,c) space."""
    grid = np.zeros((p, p), dtype=int)
    for b in range(p):
        for c in range(p):
            grid[c, b] = quad_disc(b, c, p)
    im = ax.imshow(grid, cmap='viridis', origin='lower', aspect='equal')
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('c', fontsize=12)
    ax.set_title(f'Discriminant b² − 4c over F_{p}', fontsize=14)
    plt.colorbar(im, ax=ax, label='Discriminant value')


def plot_fiber_sizes(primes: list, ax: plt.Axes) -> None:
    """Bar chart showing fiber sizes for each value, confirming uniformity."""
    for p in primes:
        sizes = [0] * p
        for b in range(p):
            for c in range(p):
                d = quad_disc(b, c, p)
                sizes[d] += 1
        ax.bar([x + primes.index(p) * 0.15 for x in range(p)],
               sizes, width=0.15, alpha=0.7, label=f'p={p}')
    ax.set_xlabel('Discriminant value d', fontsize=12)
    ax.set_ylabel('Fiber size |{(b,c): b²−4c=d}|', fontsize=12)
    ax.set_title('Fiber sizes (all equal to p)', fontsize=14)
    ax.legend()


def plot_splitting_fractions(ax: plt.Axes) -> None:
    """Plot the splitting type fractions as p grows."""
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    split_frac = []
    ramified_frac = []
    inert_frac = []

    for p in primes:
        total = p * p
        split_frac.append(p * (p - 1) // 2 / total)
        ramified_frac.append(p / total)
        inert_frac.append(p * (p - 1) // 2 / total)

    ax.plot(primes, split_frac, 'go-', label='Split (two roots)', markersize=6)
    ax.plot(primes, ramified_frac, 'rs-', label='Ramified (repeated root)', markersize=6)
    ax.plot(primes, inert_frac, 'b^-', label='Inert (irreducible)', markersize=6)
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='y = 1/2')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Fraction of quadratics', fontsize=12)
    ax.set_title('Splitting Type Distribution as p → ∞', fontsize=14)
    ax.legend()
    ax.set_ylim(-0.05, 0.6)


if __name__ == "__main__":
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Heatmap for p=11
    plot_discriminant_heatmap(11, axes[0])

    # Panel 2: Fiber sizes for small primes
    plot_fiber_sizes([3, 5, 7], axes[1])

    # Panel 3: Splitting fractions converging to 1/2
    plot_splitting_fractions(axes[2])

    plt.tight_layout()
    plt.savefig('discriminant_uniformity.png', dpi=150, bbox_inches='tight')
    print("Saved discriminant_uniformity.png")
