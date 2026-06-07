#!/usr/bin/env python3
"""
Counterfactual Number Theory: Numerical Demonstrations

Explores what happens when primes are replaced by random subsets of N
with prime-like density, demonstrating the key theorems from the
Lean 4 formalization.
"""

import random
import math
from collections import defaultdict


def prime_sieve(n):
    """Sieve of Eratosthenes up to n."""
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def cramer_random_model(n, seed=42):
    """Generate a Cramér random model: each integer k >= 2 is included
    independently with probability 1/ln(k), mimicking prime density."""
    rng = random.Random(seed)
    S = set()
    for k in range(2, n + 1):
        if rng.random() < 1.0 / math.log(k):
            S.add(k)
    return sorted(S)


def is_product_free(S):
    """Check if set S is product-free: no a*b in S for a,b in S."""
    S_set = set(S)
    for a in S:
        for b in S:
            if a * b in S_set:
                return False
    return True


def find_collisions(S, max_product=10000):
    """Find product collisions: distinct pairs (a,b), (c,d) with a*b = c*d."""
    S_set = set(S)
    products = defaultdict(list)
    for i, a in enumerate(S):
        for b in S[i:]:
            if a * b <= max_product:
                products[a * b].append((a, b))
    collisions = []
    for prod, pairs in products.items():
        if len(pairs) > 1:
            collisions.append((prod, pairs))
    return collisions


def big_omega(n):
    """Count prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            count += 1
            n //= d
        d += 1
    if n > 1:
        count += 1
    return count


def demo_prime_saturation():
    """Demonstrate the Prime Saturation Theorem."""
    print("=" * 60)
    print("DEMO 1: Prime Saturation Theorem")
    print("=" * 60)
    print()
    print("Theorem: A generator set is product-free AND divisor-closed")
    print("if and only if it consists entirely of primes.")
    print()

    primes = set(prime_sieve(100))
    # Test product-free
    pf = is_product_free(list(primes))
    print(f"Primes up to 100: product-free = {pf}")

    # Test divisor-closed
    dc = True
    for p in primes:
        for d in range(2, p):
            if p % d == 0 and d not in primes:
                dc = False
                break
    print(f"Primes up to 100: divisor-closed = {dc}")

    # Counterexample: {4, 6, 9}
    S = {4, 6, 9}
    pf_469 = is_product_free(list(S))
    dc_469 = all(d in S for n in S for d in range(2, n) if n % d == 0)
    print(f"\n{{4, 6, 9}}: product-free = {pf_469}, divisor-closed = {dc_469}")
    print("→ Not all elements are prime, confirming the theorem.")


def demo_cramer_collapse():
    """Demonstrate the Cramér Collapse Theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Cramér Collapse — Random Models vs Primes")
    print("=" * 60)
    print()

    N = 500
    primes = prime_sieve(N)

    print(f"Primes up to {N}: {len(primes)} elements")
    print(f"Product-free: {is_product_free(primes)}")
    print(f"Collisions: {len(find_collisions(primes, N**2))}")

    for seed in range(1, 4):
        model = cramer_random_model(N, seed=seed)
        pf = is_product_free(model)
        colls = find_collisions(model, N)
        print(f"\nCramér model (seed={seed}): {len(model)} elements")
        print(f"  Product-free: {pf}")
        print(f"  Collisions (products ≤ {N}): {len(colls)}")
        if colls:
            c = colls[0]
            print(f"  Example: {c[0]} = {c[1][0][0]}×{c[1][0][1]} = {c[1][1][0]}×{c[1][1][1]}")


def demo_factorization_length():
    """Demonstrate the Factorization Length Bound."""
    print("\n" + "=" * 60)
    print("DEMO 3: Factorization Length Bound (2^k ≤ n)")
    print("=" * 60)
    print()

    for n in [12, 30, 64, 100, 1000, 2**20]:
        max_factors = int(math.log2(n))
        # Count actual prime factors with multiplicity
        omega = big_omega(n)
        print(f"n = {n:>8}: Ω(n) = {omega}, log₂(n) = {math.log2(n):.1f}, bound = {max_factors}")


def demo_k_almost_primes():
    """Demonstrate k-almost primes are product-free."""
    print("\n" + "=" * 60)
    print("DEMO 4: k-Almost Primes are Product-Free")
    print("=" * 60)
    print()

    N = 200
    for k in range(1, 5):
        S_k = [n for n in range(2, N + 1) if big_omega(n) == k]
        pf = is_product_free(S_k)
        print(f"k={k}: {len(S_k)} elements in [2,{N}], product-free = {pf}")
        if k <= 2:
            print(f"  First 10: {S_k[:10]}")


def demo_coprime_ufd():
    """Demonstrate coprime generators give unique factorization."""
    print("\n" + "=" * 60)
    print("DEMO 5: Coprime Generators → Unique Factorization")
    print("=" * 60)
    print()

    # Coprime set: {2, 3, 5, 7, 11}
    S_coprime = [2, 3, 5, 7, 11]
    print(f"Pairwise coprime generators: {S_coprime}")
    colls = find_collisions(S_coprime, 10000)
    print(f"Collisions up to 10000: {len(colls)} (should be 0)")

    # Non-coprime set: {4, 6, 9}
    S_non = [4, 6, 9]
    print(f"\nNon-coprime generators: {S_non}")
    print(f"gcd(4,6) = {math.gcd(4,6)}, gcd(4,9) = {math.gcd(4,9)}, gcd(6,9) = {math.gcd(6,9)}")
    colls2 = find_collisions(S_non, 10000)
    print(f"Collisions up to 10000: {len(colls2)}")
    for c in colls2[:3]:
        print(f"  {c[0]} = {' = '.join(f'{a}×{b}' for a,b in c[1])}")


def demo_separation_hierarchy():
    """Demonstrate the full factorization hierarchy."""
    print("\n" + "=" * 60)
    print("DEMO 6: Factorization Hierarchy")
    print("=" * 60)
    print()
    print("UF ⟹ Collision-Free ⟹ Product-Free")
    print("(Neither reverse implication holds)")
    print()

    examples = [
        ("Primes {2,3,5,7,...}", prime_sieve(50)),
        ("{4, 6, 9} — PF but ¬UF", [4, 6, 9]),
        ("{6,10,21,35} — PF but collision", [6, 10, 21, 35]),
        ("{2,3,6} — ¬PF", [2, 3, 6]),
    ]

    for name, S in examples:
        pf = is_product_free(S)
        colls = find_collisions(S, max(S)**2 if S else 100)
        print(f"{name}:")
        print(f"  Product-free: {pf}")
        print(f"  Collision-free: {len(colls) == 0}")
        if colls:
            c = colls[0]
            print(f"  First collision: {c[0]} = {c[1][0][0]}×{c[1][0][1]} = {c[1][1][0]}×{c[1][1][1]}")
        print()


if __name__ == "__main__":
    demo_prime_saturation()
    demo_cramer_collapse()
    demo_factorization_length()
    demo_k_almost_primes()
    demo_coprime_ufd()
    demo_separation_hierarchy()


#!/usr/bin/env python3
"""
Visualization: Factorization Hierarchy and Cramér Collapse

Shows the strict chain UF ⟹ Collision-Free ⟹ Product-Free
and how random models compare to primes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import random
from collections import defaultdict


def prime_sieve(n):
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def big_omega(n):
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            count += 1
            n //= d
        d += 1
    if n > 1:
        count += 1
    return count


def count_collisions(S, max_prod):
    S_sorted = sorted(S)
    products = defaultdict(int)
    for i, a in enumerate(S_sorted):
        for b in S_sorted[i:]:
            p = a * b
            if p <= max_prod:
                products[p] += 1
    return sum(c - 1 for c in products.values() if c > 1)


def cramer_model(n, seed):
    rng = random.Random(seed)
    return sorted(k for k in range(2, n + 1) if rng.random() < 1.0 / math.log(k))


def fig1_hierarchy_venn():
    """Venn-like diagram of the factorization hierarchy."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Draw nested ellipses
    colors = ['#FFE0E0', '#E0FFE0', '#E0E0FF']
    labels = ['Product-Free', 'Collision-Free', 'Unique Factorization']
    widths = [4.5, 3.2, 2.0]
    heights = [3.0, 2.1, 1.3]

    for i, (w, h, c, l) in enumerate(zip(widths, heights, colors, labels)):
        ellipse = mpatches.Ellipse((0, 0), w, h, alpha=0.4, facecolor=c, edgecolor='black', linewidth=2)
        ax.add_patch(ellipse)
        y_pos = h/2 - 0.15
        ax.text(0, y_pos, l, ha='center', va='top', fontsize=12, fontweight='bold')

    # Add examples
    ax.plot(0, 0, 'r*', markersize=15)
    ax.text(0.15, 0.05, 'Primes', fontsize=10, color='red', fontweight='bold')

    ax.plot(-1.5, 0.5, 'bs', markersize=10)
    ax.text(-1.35, 0.55, '{4,6,9}', fontsize=9, color='blue')
    ax.text(-1.35, 0.35, '(PF, ¬CF, ¬UF)', fontsize=7, color='blue')

    ax.plot(1.5, -0.5, 'g^', markersize=10)
    ax.text(1.15, -0.45, '{6,10,21,35}', fontsize=9, color='green')
    ax.text(1.15, -0.65, '(PF, ¬CF)', fontsize=7, color='green')

    ax.set_xlim(-3, 3)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Factorization Hierarchy\nUF ⟹ Collision-Free ⟹ Product-Free\n(strict implications)',
                 fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('Novelty/fig1_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig1_hierarchy.png")


def fig2_cramer_collapse():
    """Compare primes vs Cramér random models: collision counts."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    Ns = list(range(50, 501, 50))

    # Left: Density comparison
    ax = axes[0]
    prime_counts = [len(prime_sieve(N)) for N in Ns]
    cramer_counts = [len(cramer_model(N, seed=42)) for N in Ns]
    theory = [N / math.log(N) for N in Ns]

    ax.plot(Ns, prime_counts, 'ro-', label='Primes π(N)', markersize=5)
    ax.plot(Ns, cramer_counts, 'bs-', label='Cramér model', markersize=5)
    ax.plot(Ns, theory, 'g--', label='N/ln(N)', linewidth=2)
    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Density: Primes vs Cramér Model', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: Collision counts
    ax = axes[1]
    prime_colls = []
    cramer_colls = []
    for N in Ns:
        primes = prime_sieve(N)
        cm = cramer_model(N, seed=42)
        prime_colls.append(count_collisions(primes, N))
        cramer_colls.append(count_collisions(cm, N))

    ax.plot(Ns, prime_colls, 'ro-', label='Primes (always 0)', markersize=5)
    ax.plot(Ns, cramer_colls, 'bs-', label='Cramér model', markersize=5)
    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Collision count', fontsize=12)
    ax.set_title('Cramér Collapse: Collisions Grow', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Novelty/fig2_cramer_collapse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig2_cramer_collapse.png")


def fig3_k_almost_primes():
    """k-almost prime density vs primes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    N = 1000
    Ns = list(range(10, N + 1, 10))

    for k in range(1, 5):
        counts = []
        for n in Ns:
            c = sum(1 for m in range(2, n + 1) if big_omega(m) == k)
            counts.append(c)
        label = {1: 'Primes (k=1)', 2: 'Semiprimes (k=2)',
                 3: '3-almost (k=3)', 4: '4-almost (k=4)'}[k]
        ax.plot(Ns, counts, label=label, linewidth=2)

    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Count of k-almost primes ≤ N', fontsize=12)
    ax.set_title('k-Almost Primes: All Product-Free, Semiprimes Denser than Primes',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Novelty/fig3_k_almost_primes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig3_k_almost_primes.png")


if __name__ == '__main__':
    fig1_hierarchy_venn()
    fig2_cramer_collapse()
    fig3_k_almost_primes()
    print("\nAll figures saved.")
