#!/usr/bin/env python3
"""
Product Collisions Demo: Numerical examples illustrating the factorization hierarchy.

This script demonstrates:
1. The separation example {6, 10, 21, 35}: product-free but has collisions
2. Collision detection for arbitrary generator sets
3. The collision spectrum computation
4. Comparison of primes vs random sets
"""

from itertools import combinations_with_replacement
from collections import defaultdict
from math import gcd, log
import random


def is_product_free(S: set[int]) -> bool:
    """Check if S is product-free: no product of two elements (≥2) lies in S."""
    for a in S:
        for b in S:
            if a >= 2 and b >= 2 and a * b in S:
                return False
    return True


def find_collisions(S: set[int]) -> list[tuple[int, int, int, int]]:
    """Find all product collisions in S: quadruples (a,b,c,d) with a*b=c*d, {a,b}≠{c,d}."""
    products = defaultdict(list)
    elems = sorted(e for e in S if e >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            products[a * b].append((a, b))

    collisions = []
    for prod_val, pairs in products.items():
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                a, b = pairs[i]
                c, d = pairs[j]
                if sorted([a, b]) != sorted([c, d]):
                    collisions.append((a, b, c, d))
    return collisions


def collision_spectrum(S: set[int], k: int, max_n: int = 10000) -> set[int]:
    """Compute the collision spectrum at level k for finite S, up to max_n."""
    elems = sorted(e for e in S if e >= 2)
    factorizations = defaultdict(list)

    def gen_multisets(remaining, min_idx, current):
        if remaining == 0:
            prod = 1
            for x in current:
                prod *= x
            if prod <= max_n:
                factorizations[prod].append(tuple(sorted(current)))
            return
        for i in range(min_idx, len(elems)):
            current.append(elems[i])
            gen_multisets(remaining - 1, i, current)
            current.pop()

    gen_multisets(k, 0, [])

    spectrum = set()
    for n, facts in factorizations.items():
        unique_facts = set(facts)
        if len(unique_facts) >= 2:
            spectrum.add(n)
    return spectrum


def is_pairwise_coprime(S: set[int]) -> bool:
    """Check if all pairs of distinct elements in S are coprime."""
    elems = list(S)
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            if gcd(elems[i], elems[j]) > 1:
                return False
    return True


def random_prime_like_set(N: int) -> set[int]:
    """Generate a random subset of {2,...,N} with prime-like density ~N/ln(N)."""
    size = max(1, int(N / log(N)))
    return set(random.sample(range(2, N + 1), min(size, N - 1)))


def sieve_primes(N: int) -> set[int]:
    """Sieve of Eratosthenes up to N."""
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return {i for i in range(2, N + 1) if is_prime[i]}


def main():
    print("=" * 70)
    print("PRODUCT COLLISIONS AND THE FACTORIZATION HIERARCHY")
    print("=" * 70)

    # Example 1: The separation set {6, 10, 21, 35}
    print("\n--- Example 1: Separation Set {6, 10, 21, 35} ---")
    S1 = {6, 10, 21, 35}
    print(f"Set: {sorted(S1)}")
    print(f"Product-free: {is_product_free(S1)}")
    collisions = find_collisions(S1)
    print(f"Collisions found: {len(collisions)}")
    for a, b, c, d in collisions:
        print(f"  {a} × {b} = {c} × {d} = {a * b}")
    print(f"Pairwise coprime: {is_pairwise_coprime(S1)}")

    # Example 2: The classic counterexample {4, 6, 9}
    print("\n--- Example 2: Classic Counterexample {4, 6, 9} ---")
    S2 = {4, 6, 9}
    print(f"Set: {sorted(S2)}")
    print(f"Product-free: {is_product_free(S2)}")
    collisions2 = find_collisions(S2)
    print(f"Collisions found: {len(collisions2)}")
    for a, b, c, d in collisions2:
        print(f"  {a} × {b} = {c} × {d} = {a * b}")

    # Example 3: A coprime set (hence collision-free)
    print("\n--- Example 3: Coprime Set {2, 3, 5, 7, 11} ---")
    S3 = {2, 3, 5, 7, 11}
    print(f"Set: {sorted(S3)}")
    print(f"Product-free: {is_product_free(S3)}")
    print(f"Pairwise coprime: {is_pairwise_coprime(S3)}")
    print(f"Collisions: {len(find_collisions(S3))}")

    # Example 4: Collision spectrum
    print("\n--- Example 4: Collision Spectrum ---")
    for S_name, S in [("{6,10,21,35}", S1), ("{4,6,9}", S2), ("{2,3,5,7}", {2, 3, 5, 7})]:
        print(f"\n  Set: {S_name}")
        for k in range(1, 5):
            spec = collision_spectrum(S, k, max_n=5000)
            if spec:
                print(f"    Σ_{k}: {sorted(spec)[:10]}{'...' if len(spec) > 10 else ''} ({len(spec)} elements)")
            else:
                print(f"    Σ_{k}: ∅")

    # Example 5: Primes vs random sets
    print("\n--- Example 5: Primes vs Random Sets (N=100) ---")
    N = 100
    primes = sieve_primes(N)
    print(f"Primes up to {N}: {len(primes)} elements")
    print(f"Prime collisions: {len(find_collisions(primes))}")

    random.seed(42)
    total_collisions = 0
    n_trials = 20
    for _ in range(n_trials):
        S_rand = random_prime_like_set(N)
        total_collisions += len(find_collisions(S_rand))
    print(f"Average collisions in {n_trials} random prime-like sets: {total_collisions / n_trials:.1f}")

    # Example 6: Collision census for small sets
    print("\n--- Example 6: Collision Census (subsets of {2,...,20}) ---")
    universe = list(range(2, 21))
    for k in range(3, 8):
        total = 0
        with_collision = 0
        for combo in combinations_with_replacement([], 0):
            pass
        # Sample random subsets for larger k
        if k <= 5:
            from itertools import combinations
            for combo in combinations(universe, k):
                S = set(combo)
                total += 1
                if find_collisions(S):
                    with_collision += 1
            print(f"  Size {k}: {with_collision}/{total} have collisions ({100*with_collision/total:.1f}%)")
        else:
            n_samples = 5000
            for _ in range(n_samples):
                S = set(random.sample(universe, k))
                total += 1
                if find_collisions(S):
                    with_collision += 1
            print(f"  Size {k}: ~{100*with_collision/total:.1f}% have collisions (sampled {n_samples})")

    print("\n" + "=" * 70)
    print("KEY FINDINGS:")
    print("  1. {6,10,21,35} is product-free but has collision 6×35 = 10×21 = 210")
    print("  2. Primes have zero collisions (FTA)")
    print("  3. Random prime-like sets have many collisions")
    print("  4. Collision probability increases rapidly with set size")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Product collision heatmap for the set {6, 10, 21, 35}.

Shows the multiplication table of the generator set, highlighting
collisions where different pairs produce the same product.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def main():
    S = [6, 10, 21, 35]
    n = len(S)

    # Build multiplication table
    table = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            table[i, j] = S[i] * S[j]

    # Find collisions
    products = defaultdict(list)
    for i in range(n):
        for j in range(i, n):
            products[S[i] * S[j]].append((i, j))

    collision_mask = np.zeros((n, n), dtype=bool)
    for prod_val, pairs in products.items():
        if len(pairs) > 1:
            for i, j in pairs:
                collision_mask[i, j] = True
                collision_mask[j, i] = True

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Full multiplication table
    im1 = ax1.imshow(table, cmap='YlOrRd', aspect='equal')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(S, fontsize=14)
    ax1.set_yticklabels(S, fontsize=14)
    ax1.set_title('Multiplication Table', fontsize=16)
    for i in range(n):
        for j in range(n):
            color = 'white' if table[i, j] > 400 else 'black'
            ax1.text(j, i, str(table[i, j]), ha='center', va='center',
                     fontsize=12, color=color, fontweight='bold')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Right: Collision highlights
    display = np.where(collision_mask, table, 0).astype(float)
    display[display == 0] = np.nan

    ax2.imshow(np.ones((n, n)) * 0.9, cmap='Greys', vmin=0, vmax=1, aspect='equal')
    im2 = ax2.imshow(display, cmap='RdYlGn_r', aspect='equal', vmin=100, vmax=300)

    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(S, fontsize=14)
    ax2.set_yticklabels(S, fontsize=14)
    ax2.set_title('Product Collisions (6×35 = 10×21 = 210)', fontsize=16)

    for i in range(n):
        for j in range(n):
            if collision_mask[i, j]:
                ax2.text(j, i, str(table[i, j]), ha='center', va='center',
                         fontsize=14, color='white', fontweight='bold',
                         bbox=dict(boxstyle='round,pad=0.3', facecolor='red', alpha=0.8))
            else:
                ax2.text(j, i, str(table[i, j]), ha='center', va='center',
                         fontsize=11, color='gray', alpha=0.5)

    plt.suptitle('Product Collisions in {6, 10, 21, 35}', fontsize=18, y=1.02)
    plt.tight_layout()
    plt.savefig('collision_heatmap.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved collision_heatmap.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The factorization hierarchy diagram.

Shows the strict inclusion chain:
  UF ⊂ Collision-Free ⊂ Product-Free
with example sets at each level.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Draw nested regions (Venn-like, but nested)
    # Product-Free (outermost)
    pf_ellipse = mpatches.FancyBboxPatch(
        (0.5, 0.8), 10, 6.5, boxstyle="round,pad=0.5",
        facecolor='#FFE0B2', edgecolor='#E65100', linewidth=3, alpha=0.7)
    ax.add_patch(pf_ellipse)

    # Collision-Free (middle)
    cf_ellipse = mpatches.FancyBboxPatch(
        (1.2, 1.3), 8.5, 5, boxstyle="round,pad=0.5",
        facecolor='#C8E6C9', edgecolor='#2E7D32', linewidth=3, alpha=0.7)
    ax.add_patch(cf_ellipse)

    # UF (innermost)
    uf_ellipse = mpatches.FancyBboxPatch(
        (2, 2), 7, 3.2, boxstyle="round,pad=0.5",
        facecolor='#BBDEFB', edgecolor='#1565C0', linewidth=3, alpha=0.7)
    ax.add_patch(uf_ellipse)

    # Labels for regions
    ax.text(5.5, 7.8, 'Product-Free', fontsize=18, fontweight='bold',
            ha='center', color='#E65100')
    ax.text(5.5, 6.6, 'Collision-Free', fontsize=18, fontweight='bold',
            ha='center', color='#2E7D32')
    ax.text(5.5, 5.4, 'Unique Factorization', fontsize=18, fontweight='bold',
            ha='center', color='#1565C0')

    # Example sets
    # UF region: Primes
    ax.text(5.5, 4.2, '● Primes {2, 3, 5, 7, 11, ...}', fontsize=13,
            ha='center', color='#0D47A1', style='italic')
    ax.text(5.5, 3.5, '● {2, 3, 5, 7} (coprime)', fontsize=13,
            ha='center', color='#0D47A1', style='italic')

    # Collision-Free but not UF
    # (Hard to find natural examples — most collision-free sets do have UF)
    ax.text(5.5, 2.0, '● {4, 9, 25} (prime powers)', fontsize=13,
            ha='center', color='#1B5E20', style='italic')

    # Product-Free but not Collision-Free
    ax.text(5.5, 1.1, '● {6, 10, 21, 35}', fontsize=14,
            ha='center', color='#BF360C', fontweight='bold')
    ax.text(5.5, 0.5, '  6×35 = 10×21 = 210 (COLLISION!)', fontsize=12,
            ha='center', color='#BF360C')

    # Arrows showing strict implications
    ax.annotate('', xy=(10.5, 3.5), xytext=(10.5, 5.5),
                arrowprops=dict(arrowstyle='->', color='#616161', lw=2))
    ax.text(11.2, 4.5, '⟹', fontsize=20, ha='center', va='center', color='#616161')

    ax.annotate('', xy=(10.5, 5.8), xytext=(10.5, 7.2),
                arrowprops=dict(arrowstyle='->', color='#616161', lw=2))
    ax.text(11.2, 6.5, '⟹', fontsize=20, ha='center', va='center', color='#616161')

    # "NOT reverse" markers
    ax.text(12.0, 4.5, '⇍', fontsize=20, ha='center', va='center', color='red')
    ax.text(12.0, 6.5, '⇍', fontsize=20, ha='center', va='center', color='red')

    ax.set_xlim(-0.5, 13)
    ax.set_ylim(-0.5, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Factorization Hierarchy\nUF ⟹ Collision-Free ⟹ Product-Free (strict)',
                 fontsize=20, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('hierarchy_diagram.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved hierarchy_diagram.png")


if __name__ == "__main__":
    main()
