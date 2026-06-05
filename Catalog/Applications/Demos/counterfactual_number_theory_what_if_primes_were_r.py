#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Numerical demonstrations of key results from the Beurling generalized
prime systems framework. Shows how random subsets of N with prime-like
density almost never produce unique factorization.
"""

import random
import math
from collections import Counter

def prime_density_count(n):
    """Expected number of primes up to n: n/log(n)"""
    if n < 3:
        return 1
    return n / math.log(n)

def actual_primes_up_to(n):
    """Sieve of Eratosthenes"""
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]

def random_generators(n, seed=42):
    """Generate a random subset of {2,...,n} with density ~1/log(k) at each k"""
    rng = random.Random(seed)
    gens = []
    for k in range(2, n + 1):
        if k < 3:
            prob = 0.5
        else:
            prob = 1.0 / math.log(k)
        if rng.random() < prob:
            gens.append(k)
    return gens

def find_triple_collisions(gens):
    """Find all (a, b) pairs where a*b is also a generator"""
    gen_set = set(gens)
    collisions = []
    for a in gens:
        for b in gens:
            if a * b in gen_set:
                collisions.append((a, b, a*b))
    return collisions

def is_product_free(gens):
    """Check if a set of generators is product-free"""
    gen_set = set(gens)
    for a in gens:
        for b in gens:
            if a * b in gen_set:
                return False
    return True


def demo_density_comparison():
    """Compare actual prime density vs random subset density"""
    print("=" * 60)
    print("DEMO 1: Density Comparison — Primes vs Random Subsets")
    print("=" * 60)
    
    for n in [100, 1000, 10000]:
        primes = actual_primes_up_to(n)
        random_gens = random_generators(n)
        expected = prime_density_count(n)
        
        print(f"\n  n = {n:,}")
        print(f"    Actual primes:    {len(primes):>6} (PNT predicts {expected:.0f})")
        print(f"    Random generators: {len(random_gens):>6}")
        print(f"    Ratio actual/expected: {len(primes)/expected:.3f}")
        print(f"    Ratio random/expected: {len(random_gens)/expected:.3f}")


def demo_collision_analysis():
    """Demonstrate that random generators have collisions but primes don't"""
    print("\n" + "=" * 60)
    print("DEMO 2: Product Collisions — The UFD Collapse")
    print("=" * 60)
    
    n = 200
    primes = actual_primes_up_to(n)
    
    print(f"\n  Primes up to {n}: {len(primes)} generators")
    prime_collisions = find_triple_collisions(primes)
    print(f"  Triple collisions in primes: {len(prime_collisions)}")
    print(f"  Product-free: {is_product_free(primes)}")
    
    for seed in range(5):
        random_gens = random_generators(n, seed=seed)
        collisions = find_triple_collisions(random_gens)
        print(f"\n  Random set (seed={seed}): {len(random_gens)} generators")
        print(f"  Triple collisions: {len(collisions)}")
        if collisions:
            print(f"  First 5 collisions: {collisions[:5]}")
        print(f"  Product-free: {is_product_free(random_gens)}")


def demo_separation_theorem():
    """Demonstrate the density-independence separation theorem"""
    print("\n" + "=" * 60)
    print("DEMO 3: Density-Independence Separation")
    print("=" * 60)
    
    # Same cardinality, different factorization properties
    set_a = [2, 3, 5]  # Product-free (all primes)
    set_b = [2, 3, 6]  # NOT product-free (2*3=6)
    
    print(f"\n  Set A = {set_a}: |A| = {len(set_a)}, product-free = {is_product_free(set_a)}")
    print(f"  Set B = {set_b}: |B| = {len(set_b)}, product-free = {is_product_free(set_b)}")
    print(f"  → Same cardinality, opposite factorization properties!")
    
    # Larger example
    set_c = [2, 3, 5, 7, 11]  # All primes
    set_d = [2, 3, 5, 6, 10]  # Contains 2*3=6 and 2*5=10
    
    print(f"\n  Set C = {set_c}: |C| = {len(set_c)}, product-free = {is_product_free(set_c)}")
    collisions_c = find_triple_collisions(set_c)
    print(f"  Collisions: {len(collisions_c)}")
    
    print(f"\n  Set D = {set_d}: |D| = {len(set_d)}, product-free = {is_product_free(set_d)}")
    collisions_d = find_triple_collisions(set_d)
    print(f"  Collisions: {len(collisions_d)}")
    for c in collisions_d:
        print(f"    {c[0]} × {c[1]} = {c[2]}")


def demo_collision_probability():
    """Monte Carlo estimate of collision probability for random generators"""
    print("\n" + "=" * 60)
    print("DEMO 4: Collision Probability (Monte Carlo)")
    print("=" * 60)
    
    n = 100
    trials = 1000
    collision_count = 0
    
    for seed in range(trials):
        gens = random_generators(n, seed=seed)
        if not is_product_free(gens):
            collision_count += 1
    
    print(f"\n  n = {n}, trials = {trials}")
    print(f"  Random sets with collisions: {collision_count}/{trials} "
          f"({100*collision_count/trials:.1f}%)")
    print(f"  → Random generators almost ALWAYS have collisions")
    print(f"  → Unique factorization is a SPECIAL property of the primes")


def demo_contamination():
    """Show how adding one composite to primes destroys product-freeness"""
    print("\n" + "=" * 60)
    print("DEMO 5: Composite Contamination Cascade")
    print("=" * 60)
    
    primes_20 = actual_primes_up_to(20)
    print(f"\n  Primes up to 20: {primes_20}")
    print(f"  Product-free: {is_product_free(primes_20)}")
    
    composites = [4, 6, 9, 10, 15, 21]
    for c in composites:
        contaminated = sorted(set(primes_20 + [c]))
        collisions = find_triple_collisions(contaminated)
        print(f"\n  Add {c}: {contaminated}")
        print(f"  Product-free: {is_product_free(contaminated)}")
        print(f"  Collisions: {len(collisions)}")
        if collisions:
            for col in collisions[:3]:
                print(f"    {col[0]} × {col[1]} = {col[2]}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  COUNTERFACTUAL NUMBER THEORY: What If Primes Were      ║")
    print("║  Random?  — Numerical Demonstrations                    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_density_comparison()
    demo_collision_analysis()
    demo_separation_theorem()
    demo_collision_probability()
    demo_contamination()
    
    print("\n" + "=" * 60)
    print("KEY INSIGHT: The primes are product-free — no prime equals")
    print("the product of two primes. Random subsets with the same")
    print("density almost never have this property. This is WHY unique")
    print("factorization holds for the integers but fails for almost")
    print("every 'counterfactual' number system.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Collision probability heatmap for random Beurling systems.

Shows how collision probability varies with the number of generators
and the upper bound N.
"""

import math
import random

def random_beurling_generators(n, seed=42):
    rng = random.Random(seed)
    gens = []
    for k in range(2, n + 1):
        prob = 1.0 / max(math.log(k), 0.01)
        if rng.random() < min(prob, 1.0):
            gens.append(k)
    return gens

def is_product_free(generators):
    gen_set = set(generators)
    for a in generators:
        for b in generators:
            if a * b in gen_set:
                return False
    return True

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    # Compute collision probability for different N values
    N_values = [20, 40, 60, 80, 100, 150, 200, 300, 500]
    trials = 200
    
    collision_probs = []
    avg_gen_counts = []
    
    for N in N_values:
        collisions = 0
        gen_counts = []
        for seed in range(trials):
            gens = random_beurling_generators(N, seed=seed)
            gen_counts.append(len(gens))
            if not is_product_free(gens):
                collisions += 1
        collision_probs.append(collisions / trials)
        avg_gen_counts.append(sum(gen_counts) / len(gen_counts))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Collision probability vs N
    ax1.plot(N_values, collision_probs, 'ro-', linewidth=2, markersize=8)
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Upper bound N', fontsize=12)
    ax1.set_ylabel('P(collision exists)', fontsize=12)
    ax1.set_title('Collision Probability for Random Beurling Systems', fontsize=14)
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Generator count comparison
    expected_primes = [N / math.log(N) if N > 1 else 0 for N in N_values]
    
    ax2.plot(N_values, avg_gen_counts, 'bo-', label='Random generators (avg)', 
             linewidth=2, markersize=8)
    ax2.plot(N_values, expected_primes, 'g--', label='n/log(n) (PNT)', 
             linewidth=2)
    ax2.set_xlabel('Upper bound N', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Generator Density: Random vs PNT Prediction', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collision_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved collision_heatmap.png")

if __name__ == "__main__":
    main()
