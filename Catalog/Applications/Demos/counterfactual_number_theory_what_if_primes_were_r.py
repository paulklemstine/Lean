#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Numerical demonstrations of product collisions, UFD collapse, and
the density threshold in generalized prime systems.
"""

import math
from itertools import combinations_with_replacement
from collections import defaultdict


def find_product_collisions(S: set[int]) -> list[tuple]:
    """Find all product collisions in a generalized prime system S.
    A collision is (a, b, c, d) where a*b = c*d and {a,b} ≠ {c,d}."""
    pairs = list(combinations_with_replacement(sorted(S), 2))
    products = defaultdict(list)
    for a, b in pairs:
        products[a * b].append((a, b))

    collisions = []
    for prod_val, pair_list in products.items():
        if len(pair_list) > 1:
            for i in range(len(pair_list)):
                for j in range(i + 1, len(pair_list)):
                    collisions.append((*pair_list[i], *pair_list[j], prod_val))
    return collisions


def collision_density(N: int) -> float:
    """Fraction of products in [2,N] system that have collisions."""
    S = set(range(2, N + 1))
    pairs = list(combinations_with_replacement(sorted(S), 2))
    products = defaultdict(int)
    for a, b in pairs:
        products[a * b] += 1
    total = len(products)
    colliding = sum(1 for v in products.values() if v > 1)
    return colliding / total if total > 0 else 0.0


def prime_density_vs_sqrt(N: int) -> dict:
    """Compare π(N) ~ N/ln(N) with √N to show primes exceed collision threshold."""
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    pi_N = sum(sieve)
    return {
        "N": N,
        "pi(N)": pi_N,
        "N/ln(N)": N / math.log(N) if N > 1 else 0,
        "sqrt(N)": math.sqrt(N),
        "ratio_pi_sqrt": pi_N / math.sqrt(N) if N > 0 else 0,
        "primes_exceed_sqrt": pi_N > math.sqrt(N),
    }


def check_system_ufd(S: set[int]) -> dict:
    """Check whether a generalized prime system has unique factorization
    by searching for product collisions."""
    collisions = find_product_collisions(S)
    return {
        "system": sorted(S),
        "has_ufd": len(collisions) == 0,
        "num_collisions": len(collisions),
        "first_collision": collisions[0] if collisions else None,
    }


def dirichlet_pigeonhole_demo(S: list[int], d: int) -> dict:
    """Demonstrate the pigeonhole principle: among |S| > d elements,
    two share a residue class mod d."""
    residues = defaultdict(list)
    for x in S:
        residues[x % d].append(x)
    shared = {r: elems for r, elems in residues.items() if len(elems) > 1}
    return {
        "S": S,
        "d": d,
        "|S|": len(S),
        "residues_mod_d": dict(residues),
        "shared_classes": shared,
        "pigeonhole_applies": len(S) > d,
    }


def collision_spectrum(S: set[int], max_product: int = 100) -> dict[int, int]:
    """Compute the collision spectrum: for each product n, count distinct
    ordered pairs from S with that product."""
    spectrum = defaultdict(int)
    for a in sorted(S):
        for b in sorted(S):
            if a <= b and a * b <= max_product:
                spectrum[a * b] += 1
    return {k: v for k, v in sorted(spectrum.items()) if v > 1}


if __name__ == "__main__":
    print("=" * 70)
    print("COUNTERFACTUAL NUMBER THEORY: WHAT IF PRIMES WERE RANDOM?")
    print("=" * 70)

    # Demo 1: Concrete collision in {2, 3, 4, 6}
    print("\n--- Demo 1: Concrete Collision ---")
    result = check_system_ufd({2, 3, 4, 6})
    print(f"System: {result['system']}")
    print(f"Has UFD: {result['has_ufd']}")
    print(f"Number of collisions: {result['num_collisions']}")
    if result["first_collision"]:
        a, b, c, d, prod = result["first_collision"]
        print(f"First collision: {a}×{b} = {c}×{d} = {prod}")

    # Demo 2: Actual primes have no collisions
    print("\n--- Demo 2: Actual Primes ---")
    primes_20 = {2, 3, 5, 7, 11, 13, 17, 19}
    result = check_system_ufd(primes_20)
    print(f"System (primes ≤ 20): {result['system']}")
    print(f"Has UFD: {result['has_ufd']}")
    print(f"Number of collisions: {result['num_collisions']}")

    # Demo 3: Interval system [2, N]
    print("\n--- Demo 3: Interval Systems ---")
    for N in [5, 6, 10, 20, 50]:
        S = set(range(2, N + 1))
        collisions = find_product_collisions(S)
        print(f"[2, {N}]: {len(collisions)} collisions, UFD = {len(collisions) == 0}")

    # Demo 4: Collision density growth
    print("\n--- Demo 4: Collision Density Growth ---")
    for N in [6, 10, 20, 50, 100]:
        density = collision_density(N)
        print(f"[2, {N}]: {density:.1%} of products have multiple representations")

    # Demo 5: Prime density vs √N
    print("\n--- Demo 5: π(N) vs √N ---")
    for N in [10, 100, 1000, 10000]:
        stats = prime_density_vs_sqrt(N)
        print(
            f"N={N}: π(N)={stats['pi(N)']}, N/ln(N)={stats['N/ln(N)']:.1f}, "
            f"√N={stats['sqrt(N)']:.1f}, π(N)/√N={stats['ratio_pi_sqrt']:.2f}"
        )

    # Demo 6: Dirichlet pigeonhole
    print("\n--- Demo 6: Dirichlet Pigeonhole ---")
    result = dirichlet_pigeonhole_demo([3, 7, 11, 15, 19, 23, 27], d=5)
    print(f"S = {result['S']}, d = {result['d']}")
    print(f"|S| = {result['|S|']} > d = {result['d']}: {result['pigeonhole_applies']}")
    print(f"Shared residue classes: {result['shared_classes']}")

    # Demo 7: Boundary - coprime vs non-coprime pairs
    print("\n--- Demo 7: UFD Boundary ---")
    for p, q, label in [(2, 3, "coprime"), (2, 5, "coprime"), (2, 4, "divisible"), (3, 6, "divisible"), (4, 6, "non-coprime")]:
        result = check_system_ufd({p, q})
        print(f"{{{p}, {q}}} ({label}): UFD = {result['has_ufd']}, collisions = {result['num_collisions']}")

    # Demo 8: Collision spectrum
    print("\n--- Demo 8: Collision Spectrum of {2,3,4,5,6} ---")
    spec = collision_spectrum({2, 3, 4, 5, 6}, max_product=50)
    for prod, count in spec.items():
        print(f"  Product {prod}: {count} representations")


#!/usr/bin/env python3
"""
Visualization: The Collision Landscape of Generalized Prime Systems.

Shows how collision density grows with system size, comparing
interval systems, prime systems, and random systems.
"""

import math
from collections import defaultdict
from itertools import combinations_with_replacement
import random


def sieve(n):
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def count_collisions(S):
    products = defaultdict(int)
    sorted_S = sorted(S)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            products[a * b] += 1
    return sum(1 for v in products.values() if v > 1)


def total_products(S):
    products = set()
    sorted_S = sorted(S)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            products.add(a * b)
    return len(products)


def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
        matplotlib.use("Agg")
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    max_N = 80
    all_primes = set(sieve(max_N))

    # Data for three system types
    Ns = list(range(6, max_N + 1, 2))
    interval_density = []
    prime_density = []
    random_density = []

    for N in Ns:
        # Interval system [2, N]
        S_int = set(range(2, N + 1))
        tp = total_products(S_int)
        interval_density.append(count_collisions(S_int) / tp if tp else 0)

        # Prime system (primes ≤ N)
        S_prime = {p for p in all_primes if p <= N}
        tp = total_products(S_prime) if S_prime else 1
        prime_density.append(count_collisions(S_prime) / tp if tp else 0)

        # Random system with prime-like density
        k = max(2, int(N / math.log(N)))
        candidates = list(range(2, N + 1))
        S_rand = set(random.sample(candidates, min(k, len(candidates))))
        tp = total_products(S_rand) if S_rand else 1
        random_density.append(count_collisions(S_rand) / tp if tp else 0)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Collision density comparison
    ax1 = axes[0]
    ax1.plot(Ns, interval_density, "r-o", markersize=3, label="Interval [2,N]")
    ax1.plot(Ns, random_density, "b-s", markersize=3, label="Random (density N/ln N)")
    ax1.plot(Ns, prime_density, "g-^", markersize=3, label="Actual primes ≤ N")
    ax1.set_xlabel("N", fontsize=12)
    ax1.set_ylabel("Collision density", fontsize=12)
    ax1.set_title("Collision Density: Primes vs Random vs Interval", fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.annotate(
        "Primes: ZERO collisions\n(UFD preserved)",
        xy=(Ns[-1], 0),
        xytext=(Ns[-1] - 25, 0.15),
        arrowprops=dict(arrowstyle="->", color="green"),
        fontsize=9,
        color="green",
    )

    # Plot 2: System size vs collision count
    ax2 = axes[1]
    sizes = list(range(2, 40))
    collision_counts = []
    for size in sizes:
        S = set(range(2, size + 2))
        collision_counts.append(count_collisions(S))

    ax2.bar(sizes, collision_counts, color="coral", alpha=0.7)
    ax2.set_xlabel("|S| (system size)", fontsize=12)
    ax2.set_ylabel("Number of collisions", fontsize=12)
    ax2.set_title("Collision Count Growth with System Size", fontsize=13)
    ax2.grid(True, alpha=0.3, axis="y")

    # Mark the threshold
    threshold = next((s for s, c in zip(sizes, collision_counts) if c > 0), None)
    if threshold:
        ax2.axvline(x=threshold, color="red", linestyle="--", alpha=0.7)
        ax2.annotate(
            f"First collision at |S|={threshold}",
            xy=(threshold, collision_counts[sizes.index(threshold)]),
            xytext=(threshold + 5, max(collision_counts) * 0.7),
            arrowprops=dict(arrowstyle="->", color="red"),
            fontsize=9,
            color="red",
        )

    plt.tight_layout()
    plt.savefig("collision_landscape.png", dpi=150, bbox_inches="tight")
    print("Saved collision_landscape.png")


if __name__ == "__main__":
    random.seed(42)
    main()
