#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstrates the key findings of the research:
1. Random dense subsets of N almost always contain multiplicative collisions
2. Unique factorization collapses for non-product-free sets
3. The primes are exceptional: product-free despite high density
"""

import random
import math
from collections import Counter

def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def cramer_random_set(N: int, seed: int = 42) -> set:
    """
    Generate a Cramér random prime set: each integer n >= 2
    is included independently with probability 1/log(n).
    """
    rng = random.Random(seed)
    S = set()
    for n in range(2, N + 1):
        if rng.random() < 1.0 / math.log(n):
            S.add(n)
    return S

def check_product_free(S: set) -> tuple:
    """
    Check if S is product-free. Returns (is_free, counterexample).
    A counterexample is (a, b) such that a*b is also in S.
    """
    sorted_S = sorted(S)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            if a * b in S:
                return False, (a, b, a * b)
    return True, None

def count_factorizations(S: set, n: int, max_depth: int = 10) -> list:
    """
    Find all S-factorizations of n (multisets of elements from S with product n).
    """
    sorted_S = sorted(s for s in S if s <= n)
    results = []

    def backtrack(remaining: int, min_factor: int, current: list):
        if remaining == 1:
            results.append(tuple(current))
            return
        if len(current) >= max_depth:
            return
        for s in sorted_S:
            if s < min_factor:
                continue
            if s > remaining:
                break
            if remaining % s == 0:
                backtrack(remaining // s, s, current + [s])

    backtrack(n, 2, [])
    return results

def demo_product_free_collapse():
    """Demonstrate that random dense sets fail product-freeness."""
    print("=" * 70)
    print("DEMO 1: Product-Free Collapse in Random Sets")
    print("=" * 70)
    print()

    N = 1000
    primes = {n for n in range(2, N + 1) if is_prime(n)}
    print(f"Primes up to {N}: {len(primes)} elements")
    is_free, _ = check_product_free(primes)
    print(f"Primes are product-free: {is_free}")
    print()

    print("Cramér random sets (density ~ 1/log n):")
    for seed in range(1, 6):
        S = cramer_random_set(N, seed=seed)
        is_free, counter = check_product_free(S)
        print(f"  Seed {seed}: |S| = {len(S)}, product-free: {is_free}", end="")
        if counter:
            print(f"  (collision: {counter[0]} × {counter[1]} = {counter[2]})")
        else:
            print()
    print()
    print("→ Random sets with prime-like density are NEVER product-free!")
    print()

def demo_factorization_explosion():
    """Demonstrate factorization multiplicity in perturbed systems."""
    print("=" * 70)
    print("DEMO 2: Factorization Explosion")
    print("=" * 70)
    print()

    primes = {n for n in range(2, 50) if is_prime(n)}
    print("Standard primes: each composite has unique prime factorization")
    for n in [12, 30, 36]:
        facts = count_factorizations(primes, n)
        print(f"  {n}: {len(facts)} factorization(s) → {facts}")
    print()

    # Perturbed system: primes + {6}
    perturbed = primes | {6}
    print("Perturbed system (primes ∪ {6}):")
    for n in [6, 12, 30, 36]:
        facts = count_factorizations(perturbed, n)
        print(f"  {n}: {len(facts)} factorization(s) → {facts}")
    print()

    # Dense interval system
    interval = set(range(2, 13))
    print("Interval system [2, 12]:")
    for n in [6, 8, 12, 24]:
        facts = count_factorizations(interval, n, max_depth=6)
        print(f"  {n}: {len(facts)} factorization(s)")
        for f in facts[:5]:
            print(f"    {'×'.join(map(str, f))} = {n}")
        if len(facts) > 5:
            print(f"    ... and {len(facts) - 5} more")
    print()

def demo_density_threshold():
    """Explore the density threshold for product-freeness."""
    print("=" * 70)
    print("DEMO 3: Density Threshold for Product-Freeness")
    print("=" * 70)
    print()

    N = 500
    trials = 100

    print(f"For N = {N}, testing random subsets of [2,N] at various densities:")
    print(f"{'Density':>10} {'|S| (avg)':>10} {'Product-free %':>15}")
    print("-" * 40)

    for density_factor in [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0]:
        free_count = 0
        total_size = 0
        for trial in range(trials):
            rng = random.Random(trial * 1000 + int(density_factor * 100))
            S = set()
            for n in range(2, N + 1):
                target_density = density_factor / math.log(n)
                if rng.random() < target_density:
                    S.add(n)
            total_size += len(S)
            is_free, _ = check_product_free(S)
            if is_free:
                free_count += 1
        avg_size = total_size / trials
        pct_free = 100 * free_count / trials
        print(f"{density_factor:>10.2f} {avg_size:>10.1f} {pct_free:>14.1f}%")

    print()
    print("→ As density increases, product-freeness probability drops to 0!")
    print("  The primes achieve density factor ~1.0 while staying product-free.")
    print("  This is the 'prime miracle': density AND structure simultaneously.")
    print()

def demo_collision_chains():
    """Show how a single collision propagates."""
    print("=" * 70)
    print("DEMO 4: Collision Chain Propagation")
    print("=" * 70)
    print()

    # Start with primes and add 6
    primes = {n for n in range(2, 100) if is_prime(n)}
    additions = [6, 15, 35, 77]  # 2*3, 3*5, 5*7, 7*11

    S = set(primes)
    for a in additions:
        S.add(a)
        _, counter = check_product_free(S)
        facts_for_a = count_factorizations(S, a)
        print(f"Add {a} to primes: {len(facts_for_a)} factorizations of {a}")
        for f in facts_for_a:
            print(f"  {'×'.join(map(str, f))} = {a}")

    print()
    print("→ Each added composite creates new factorizations,")
    print("  demonstrating the 'fragility' of unique factorization.")

if __name__ == "__main__":
    demo_product_free_collapse()
    demo_factorization_explosion()
    demo_density_threshold()
    demo_collision_chains()


#!/usr/bin/env python3
"""
Visualization: Collision Probability vs Density

Shows how the probability of a multiplicative collision increases
with the density of the generator set, demonstrating the tension
between density and product-freeness.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_product_free_fast(s_sorted, s_set, max_val):
    """Fast product-free check."""
    for i, a in enumerate(s_sorted):
        for b in s_sorted[i:]:
            p = a * b
            if p > max_val:
                break
            if p in s_set:
                return False
    return True


def compute_collision_data(N=200, trials=200):
    """Compute collision probability for various density factors."""
    density_factors = np.linspace(0.05, 2.0, 30)
    collision_probs = []
    avg_sizes = []

    for df in density_factors:
        collisions = 0
        total_size = 0
        for trial in range(trials):
            rng = random.Random(trial * 10000 + int(df * 1000))
            s_set = set()
            for k in range(2, N + 1):
                if rng.random() < df / math.log(k):
                    s_set.add(k)
            total_size += len(s_set)
            if s_set:
                s_sorted = sorted(s_set)
                if not is_product_free_fast(s_sorted, s_set, max(s_set)):
                    collisions += 1
        collision_probs.append(collisions / trials)
        avg_sizes.append(total_size / trials)

    return density_factors, collision_probs, avg_sizes


def compute_prime_density(N=200):
    """Compute the density factor of actual primes."""
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0: return False
            i += 6
        return True

    prime_count = sum(1 for n in range(2, N + 1) if is_prime(n))
    target = N / math.log(N)
    return prime_count / target


def main():
    N = 200
    print("Computing collision probabilities...")
    density_factors, collision_probs, avg_sizes = compute_collision_data(N)
    prime_df = compute_prime_density(N)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Collision probability vs density factor
    ax1.plot(density_factors, collision_probs, 'b-o', markersize=4, linewidth=2)
    ax1.axvline(x=prime_df, color='red', linestyle='--', linewidth=2,
                label=f'Prime density factor ≈ {prime_df:.2f}')
    ax1.axhline(y=0, color='green', linestyle=':', alpha=0.5,
                label='Primes: 0% collision (product-free)')
    ax1.set_xlabel('Density Factor (relative to 1/log n)', fontsize=12)
    ax1.set_ylabel('P(collision)', fontsize=12)
    ax1.set_title(f'Collision Probability vs Density (N={N})', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)

    # Annotate the prime miracle
    ax1.annotate('THE PRIME MIRACLE\nDensity ~1.0 but\n0% collisions',
                xy=(prime_df, 0), xytext=(prime_df + 0.3, 0.3),
                arrowprops=dict(arrowstyle='->', color='red', lw=2),
                fontsize=10, color='red', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    # Plot 2: Average set size vs density factor
    ax2.plot(density_factors, avg_sizes, 'g-s', markersize=4, linewidth=2)
    ax2.axvline(x=prime_df, color='red', linestyle='--', linewidth=2,
                label=f'Prime count ≈ {sum(1 for n in range(2, N+1) if all(n%i for i in range(2, int(n**0.5)+1)) and n > 1)}')
    ax2.set_xlabel('Density Factor', fontsize=12)
    ax2.set_ylabel('Average Set Size', fontsize=12)
    ax2.set_title('Set Size vs Density Factor', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('collision_probability.png', dpi=150, bbox_inches='tight')
    print("Saved: collision_probability.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Factorization Count Explosion

Shows how the number of distinct factorizations grows as a generator system
becomes denser, compared to the constant 1 for prime factorization.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def count_factorizations(s_set, n, max_depth=15):
    """Count S-factorizations of n."""
    candidates = sorted(x for x in s_set if 2 <= x <= n)
    count = 0

    def backtrack(remaining, min_factor, depth):
        nonlocal count
        if remaining == 1:
            count += 1
            return
        if depth >= max_depth:
            return
        for c in candidates:
            if c < min_factor:
                continue
            if c > remaining:
                break
            if remaining % c == 0:
                backtrack(remaining // c, c, depth + 1)

    backtrack(n, 2, 0)
    return count


def main():
    N = 60

    # Systems to compare
    primes = {n for n in range(2, N + 1) if is_prime(n)}
    perturbed = primes | {6, 10, 15}  # Add some composites
    interval_small = set(range(2, 8))  # [2, 7]
    interval_large = set(range(2, 16))  # [2, 15]

    systems = [
        ("Primes (standard)", primes, 'blue'),
        ("Primes ∪ {6,10,15}", perturbed, 'orange'),
        ("[2, 7]", interval_small, 'green'),
        ("[2, 15]", interval_large, 'red'),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    numbers = list(range(2, N + 1))

    for ax, (name, s_set, color) in zip(axes.flat, systems):
        counts = [count_factorizations(s_set, n) for n in numbers]
        ax.bar(numbers, counts, color=color, alpha=0.7, width=0.8)
        ax.set_xlabel('n', fontsize=11)
        ax.set_ylabel('# of S-factorizations', fontsize=11)
        ax.set_title(f'{name} (|S|={len(s_set)})', fontsize=13)
        ax.set_yscale('symlog', linthresh=1)
        avg_count = np.mean([c for c in counts if c > 0])
        max_count = max(counts) if counts else 0
        ax.text(0.95, 0.95,
                f'max: {max_count}\navg: {avg_count:.1f}',
                transform=ax.transAxes, fontsize=10,
                verticalalignment='top', horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.suptitle('Factorization Count: Primes vs Counterfactual Systems',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('factorization_explosion.png', dpi=150, bbox_inches='tight')
    print("Saved: factorization_explosion.png")


if __name__ == "__main__":
    main()
