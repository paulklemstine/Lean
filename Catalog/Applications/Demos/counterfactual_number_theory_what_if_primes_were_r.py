#!/usr/bin/env python3
"""
Counterfactual Number Theory: Demonstration Script

Shows key results from the theory of generative sets and
multiplicative independence.
"""

import math
from algorithms import (
    is_multiplicatively_independent,
    find_product_triples,
    max_product_triple_free_subset,
    sieve_of_eratosthenes,
    random_generative_set,
    factorization_count,
    analyze_generative_set,
    density_ratio,
)


def demo_basic_examples():
    """Demonstrate the {2,3} vs {2,4} dichotomy."""
    print("=" * 60)
    print("DEMO 1: The Fundamental Dichotomy")
    print("=" * 60)
    print()

    S1 = {2, 3}
    S2 = {2, 4}

    print(f"Set {{2, 3}}: MI = {is_multiplicatively_independent(S1)}")
    print(f"  Product triples: {find_product_triples(S1)}")
    print(f"  Factorizations of 8: {factorization_count(S1, 8)}")
    print(f"  Factorizations of 12: {factorization_count(S1, 12)}")
    print()

    print(f"Set {{2, 4}}: MI = {is_multiplicatively_independent(S2)}")
    print(f"  Product triples: {find_product_triples(S2)}")
    print(f"  Factorizations of 8: {factorization_count(S2, 8)}")
    print(f"  Factorizations of 16: {factorization_count(S2, 16)}")
    print()

    print("Key insight: Same cardinality, opposite factorization behavior!")
    print()


def demo_product_triples():
    """Show product triple detection in random sets."""
    print("=" * 60)
    print("DEMO 2: Product Triple Detection in Random Sets")
    print("=" * 60)
    print()

    for n in [50, 100, 200, 500, 1000]:
        primes = sieve_of_eratosthenes(n)
        triple_counts = []
        mi_counts = 0
        trials = 100

        for seed in range(trials):
            S = random_generative_set(n, seed=seed)
            triples = find_product_triples(S)
            triple_counts.append(len(triples))
            if is_multiplicatively_independent(S):
                mi_counts += 1

        avg_triples = sum(triple_counts) / len(triple_counts)
        prime_triples = len(find_product_triples(primes))

        print(f"n = {n:5d}:")
        print(f"  Primes up to n: {len(primes):4d}, product triples: {prime_triples}")
        print(f"  Random sets (avg size ~{n/math.log(n):.0f}):")
        print(f"    Avg product triples: {avg_triples:.1f}")
        print(f"    MI fraction: {mi_counts}/{trials}")
        print()


def demo_extremal_sets():
    """Find maximal product-triple-free sets and compare to primes."""
    print("=" * 60)
    print("DEMO 3: Extremal Product-Triple-Free Sets")
    print("=" * 60)
    print()

    for n in [50, 100, 200, 500]:
        primes = sieve_of_eratosthenes(n)
        ptf_set = max_product_triple_free_subset(n)

        # Check which non-primes are in the PTF set
        non_prime_in_ptf = ptf_set - primes
        primes_missing = primes - ptf_set

        print(f"n = {n}:")
        print(f"  π(n) = {len(primes)}")
        print(f"  Max PTF subset size = {len(ptf_set)}")
        print(f"  Ratio |PTF|/π(n) = {len(ptf_set)/len(primes):.3f}")
        if non_prime_in_ptf and len(non_prime_in_ptf) <= 20:
            print(f"  Non-primes in PTF set: {sorted(non_prime_in_ptf)}")
        elif non_prime_in_ptf:
            print(f"  Non-primes in PTF set: {len(non_prime_in_ptf)} elements")
        print()


def demo_density_analysis():
    """Compare density ratios of various generative sets."""
    print("=" * 60)
    print("DEMO 4: Density Analysis")
    print("=" * 60)
    print()

    n = 10000
    primes = sieve_of_eratosthenes(n)

    checkpoints = [100, 500, 1000, 5000, 10000]

    print("Density ratios (should → 1 for prime-like sets):")
    print()
    print(f"{'n':>6s} | {'Primes':>8s} | {'Random1':>8s} | {'Random2':>8s} | {'Random3':>8s}")
    print("-" * 50)

    random_sets = [random_generative_set(n, seed=i) for i in range(3)]

    for cp in checkpoints:
        p_ratio = density_ratio(primes, cp)
        r_ratios = [density_ratio(rs, cp) for rs in random_sets]
        print(f"{cp:6d} | {p_ratio:8.4f} | " +
              " | ".join(f"{r:8.4f}" for r in r_ratios))
    print()


def demo_factorization_explosion():
    """Show how non-MI sets lead to factorization explosion."""
    print("=" * 60)
    print("DEMO 5: Factorization Explosion")
    print("=" * 60)
    print()

    # Compare {2,3,5} (primes, MI) vs {2,3,6} (non-MI)
    primes_set = {2, 3, 5}
    non_mi_set = {2, 3, 6}

    print(f"Set {{2, 3, 5}} (MI={is_multiplicatively_independent(primes_set)}):")
    for n in [12, 24, 30, 60, 120]:
        count = factorization_count(primes_set, n)
        print(f"  Factorizations of {n:4d}: {count}")
    print()

    print(f"Set {{2, 3, 6}} (MI={is_multiplicatively_independent(non_mi_set)}):")
    for n in [12, 24, 36, 72, 108]:
        count = factorization_count(non_mi_set, n)
        print(f"  Factorizations of {n:4d}: {count}")
    print()

    print("Non-MI sets have MORE factorizations — uniqueness collapses!")
    print()


def demo_conjecture_test():
    """Test the Product Triple Density Conjecture."""
    print("=" * 60)
    print("DEMO 6: Testing the Product Triple Density Conjecture")
    print("=" * 60)
    print()
    print("Conjecture: For n ≥ 100, any S ⊆ [2,n] with |S| ≥ n/(2·log(n))")
    print("contains a product triple.")
    print()

    for n in [100, 200, 500, 1000]:
        threshold = n / (2 * math.log(n))
        ptf = max_product_triple_free_subset(n)

        if len(ptf) >= threshold:
            print(f"n = {n}: |PTF| = {len(ptf)}, threshold = {threshold:.1f}"
                  f" → COUNTEREXAMPLE (|PTF| ≥ threshold)")
        else:
            print(f"n = {n}: |PTF| = {len(ptf)}, threshold = {threshold:.1f}"
                  f" → Consistent (|PTF| < threshold)")
    print()


if __name__ == "__main__":
    demo_basic_examples()
    demo_product_triples()
    demo_extremal_sets()
    demo_density_analysis()
    demo_factorization_explosion()
    demo_conjecture_test()


#!/usr/bin/env python3
"""
Visualization: Density comparison of primes vs random generative sets.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(n):
    if n < 2:
        return set()
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return {i for i in range(2, n + 1) if is_prime[i]}


def random_generative_set(n, seed=None):
    if seed is not None:
        random.seed(seed)
    return {k for k in range(2, n + 1) if random.random() < 1.0 / math.log(k)}


def counting_function(S, xs):
    S_sorted = sorted(S)
    counts = []
    idx = 0
    for x in xs:
        while idx < len(S_sorted) and S_sorted[idx] <= x:
            idx += 1
        counts.append(idx)
        idx_save = idx
        idx = idx_save
    # Recompute properly
    return [sum(1 for s in S if s <= x) for x in xs]


def main():
    N = 10000
    primes = sieve_of_eratosthenes(N)

    xs = np.arange(10, N + 1, 10)
    li = np.array([x / math.log(x) for x in xs])

    prime_counts = np.array([sum(1 for p in primes if p <= x) for x in xs])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Counting functions
    ax1 = axes[0]
    ax1.plot(xs, prime_counts, 'b-', linewidth=2, label='π(x) [Primes]', alpha=0.8)
    ax1.plot(xs, li, 'k--', linewidth=1.5, label='x/log(x) [PNT]', alpha=0.7)

    colors = ['#e74c3c', '#2ecc71', '#f39c12']
    for i, color in enumerate(colors):
        rset = random_generative_set(N, seed=42 + i)
        rcounts = np.array([sum(1 for r in rset if r <= x) for x in xs])
        ax1.plot(xs, rcounts, color=color, linewidth=1, alpha=0.6,
                 label=f'Random set {i+1}')

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Counting function', fontsize=12)
    ax1.set_title('Counting Functions: Primes vs Random Sets', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Density ratios
    ax2 = axes[1]
    prime_ratio = prime_counts / li
    ax2.plot(xs, prime_ratio, 'b-', linewidth=2, label='Primes', alpha=0.8)

    for i, color in enumerate(colors):
        rset = random_generative_set(N, seed=42 + i)
        rcounts = np.array([sum(1 for r in rset if r <= x) for x in xs])
        rratio = rcounts / li
        ax2.plot(xs, rratio, color=color, linewidth=1, alpha=0.6,
                 label=f'Random set {i+1}')

    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('π(x) / (x/log x)', fontsize=12)
    ax2.set_title('Density Ratios: Convergence to 1', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0.5, 1.8)

    plt.tight_layout()
    plt.savefig('density_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved density_comparison.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Factorization count explosion in non-MI vs MI sets.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def factorization_count(G_sorted, n, max_depth=30):
    """Count ordered factorizations of n over generating set G."""
    def _count(remaining, min_idx, depth):
        if remaining == 1:
            return 1
        if depth <= 0:
            return 0
        total = 0
        for i in range(min_idx, len(G_sorted)):
            g = G_sorted[i]
            if g > remaining:
                break
            if remaining % g == 0:
                total += _count(remaining // g, i, depth - 1)
        return total
    return _count(n, 0, max_depth)


def main():
    # MI set (primes)
    mi_set = [2, 3, 5, 7]
    # Non-MI set (contains 4 = 2*2 and 6 = 2*3)
    non_mi_set = [2, 3, 4, 6]

    # Numbers to test
    test_numbers = list(range(2, 201))

    mi_counts = []
    non_mi_counts = []

    for n in test_numbers:
        mc = factorization_count(mi_set, n)
        nmc = factorization_count(non_mi_set, n)
        mi_counts.append(mc)
        non_mi_counts.append(nmc)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Raw factorization counts
    ax1 = axes[0]
    # Only plot numbers that have at least 1 factorization in either set
    mi_pos = [(n, c) for n, c in zip(test_numbers, mi_counts) if c > 0]
    nmi_pos = [(n, c) for n, c in zip(test_numbers, non_mi_counts) if c > 0]

    if mi_pos:
        ax1.scatter([x[0] for x in mi_pos], [x[1] for x in mi_pos],
                    c='blue', s=10, alpha=0.6, label='{2,3,5,7} (MI)')
    if nmi_pos:
        ax1.scatter([x[0] for x in nmi_pos], [x[1] for x in nmi_pos],
                    c='red', s=10, alpha=0.6, label='{2,3,4,6} (non-MI)')

    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Number of factorizations', fontsize=12)
    ax1.set_title('Factorization Counts: MI vs Non-MI', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')

    # Right: Ratio of factorization counts
    ax2 = axes[1]
    ratios = []
    ratio_ns = []
    for n, mc, nmc in zip(test_numbers, mi_counts, non_mi_counts):
        if mc > 0 and nmc > 0:
            ratios.append(nmc / mc)
            ratio_ns.append(n)

    if ratios:
        ax2.scatter(ratio_ns, ratios, c='purple', s=15, alpha=0.6)
        ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5,
                     label='Equal factorizations')

        # Moving average
        window = 10
        if len(ratios) > window:
            moving_avg = np.convolve(ratios, np.ones(window)/window, mode='valid')
            ax2.plot(ratio_ns[window-1:], moving_avg, 'r-', linewidth=2,
                     alpha=0.8, label=f'Moving avg (window={window})')

    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Ratio: non-MI / MI factorizations', fontsize=12)
    ax2.set_title('Factorization Explosion Ratio', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('factorization_explosion.png', dpi=150, bbox_inches='tight')
    print("Saved factorization_explosion.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Product triple frequency in random vs prime sets.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(n):
    if n < 2:
        return set()
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return {i for i in range(2, n + 1) if is_prime[i]}


def random_generative_set(n, seed=None):
    if seed is not None:
        random.seed(seed)
    return {k for k in range(2, n + 1) if random.random() < 1.0 / math.log(k)}


def count_product_triples(S):
    S_list = sorted(S)
    count = 0
    for i, a in enumerate(S_list):
        if a < 2:
            continue
        for b in S_list[i:]:
            if b < 2:
                continue
            if a * b in S:
                count += 1
    return count


def main():
    ns = [50, 100, 200, 300, 500, 750, 1000]
    trials = 50

    avg_triples = []
    max_triples = []
    min_triples = []
    prime_triples = []
    set_sizes_avg = []
    prime_sizes = []

    for n in ns:
        primes = sieve_of_eratosthenes(n)
        pt_prime = count_product_triples(primes)
        prime_triples.append(pt_prime)
        prime_sizes.append(len(primes))

        trial_triples = []
        trial_sizes = []
        for seed in range(trials):
            S = random_generative_set(n, seed=seed)
            pt = count_product_triples(S)
            trial_triples.append(pt)
            trial_sizes.append(len(S))

        avg_triples.append(np.mean(trial_triples))
        max_triples.append(np.max(trial_triples))
        min_triples.append(np.min(trial_triples))
        set_sizes_avg.append(np.mean(trial_sizes))

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Product triple counts
    ax1 = axes[0]
    ax1.fill_between(ns, min_triples, max_triples, alpha=0.2, color='red',
                     label='Random range')
    ax1.plot(ns, avg_triples, 'r-o', linewidth=2, markersize=6,
             label='Random avg')
    ax1.plot(ns, prime_triples, 'b-s', linewidth=2, markersize=6,
             label='Primes (always 0)')

    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Number of product triples', fontsize=12)
    ax1.set_title('Product Triples: Primes vs Random Sets', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: Normalized by set size
    ax2 = axes[1]
    norm_avg = [t / s**2 if s > 0 else 0 for t, s in zip(avg_triples, set_sizes_avg)]
    ax2.plot(ns, norm_avg, 'r-o', linewidth=2, markersize=6,
             label='Random (triples/|S|²)')

    # Theoretical prediction: ~ 1/log(n)
    theoretical = [1.0 / (math.log(n) * 2) for n in ns]
    ax2.plot(ns, theoretical, 'k--', linewidth=1.5, alpha=0.7,
             label='~1/(2·log n) prediction')

    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Product triples / |S|²', fontsize=12)
    ax2.set_title('Normalized Triple Frequency', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('product_triples.png', dpi=150, bbox_inches='tight')
    print("Saved product_triples.png")


if __name__ == "__main__":
    main()
