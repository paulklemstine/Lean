#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstrates the key results:
1. Product-free sets vs MI sets
2. Collision index computation
3. Upper interval product-freeness
4. Factorization spectrum examples
"""

from math import gcd, sqrt, log
from itertools import combinations_with_replacement, product
from collections import defaultdict


def is_product_free(S: set[int]) -> bool:
    """Check if S is product-free: no a*b in S for a,b in S with a,b >= 2."""
    for a in S:
        for b in S:
            if a >= 2 and b >= 2 and a * b in S:
                return False
    return True


def is_multiplicatively_independent(S: set[int], max_card: int = 6) -> tuple[bool, str]:
    """Check MI up to multisets of given max cardinality.
    Returns (is_mi, counterexample_or_empty)."""
    elements = sorted(s for s in S if s >= 2)
    if not elements:
        return True, ""
    
    # Build all multiset products up to max_card
    products: dict[int, list[tuple[int, ...]]] = defaultdict(list)
    for card in range(1, max_card + 1):
        for combo in combinations_with_replacement(elements, card):
            prod_val = 1
            for x in combo:
                prod_val *= x
            products[prod_val].append(combo)
    
    # Check for collisions
    for prod_val, factorizations in products.items():
        if len(factorizations) > 1:
            return False, f"{prod_val} = {'×'.join(map(str,factorizations[0]))} = {'×'.join(map(str,factorizations[1]))}"
    
    return True, ""


def collision_index(S: set[int]) -> int:
    """Count product triples: pairs (a,b) in S×S with a*b in S, a,b >= 2."""
    count = 0
    for a in S:
        for b in S:
            if a >= 2 and b >= 2 and a * b in S:
                count += 1
    return count


def factorization_spectrum(S: set[int], n: int, max_depth: int = 8) -> list[tuple[int, ...]]:
    """Find all S-factorizations of n (multisets of elements from S with product n)."""
    elements = sorted(s for s in S if 2 <= s <= n)
    results = []
    
    def search(remaining: int, min_element: int, current: list[int]):
        if remaining == 1:
            results.append(tuple(current))
            return
        for e in elements:
            if e < min_element:
                continue
            if e > remaining:
                break
            if remaining % e == 0 and len(current) < max_depth:
                current.append(e)
                search(remaining // e, e, current)
                current.pop()
    
    search(n, 2, [])
    return results


def prime_density_vs_random(N: int) -> dict:
    """Compare prime density with upper interval density and their MI properties."""
    primes = set()
    for n in range(2, N + 1):
        if all(n % i != 0 for i in range(2, int(sqrt(n)) + 1)):
            primes.add(n)
    
    upper_interval = {k for k in range(N // 2 + 1, N + 1)}
    
    prime_pf = is_product_free(primes)
    prime_mi, _ = is_multiplicatively_independent(primes, max_card=4)
    upper_pf = is_product_free(upper_interval)
    upper_mi, upper_counter = is_multiplicatively_independent(upper_interval, max_card=4)
    
    return {
        "N": N,
        "prime_count": len(primes),
        "prime_density": len(primes) / N,
        "upper_count": len(upper_interval),
        "upper_density": len(upper_interval) / N,
        "primes_product_free": prime_pf,
        "primes_MI": prime_mi,
        "upper_product_free": upper_pf,
        "upper_MI": upper_mi,
        "upper_MI_counter": upper_counter,
    }


def main():
    print("=" * 70)
    print("COUNTERFACTUAL NUMBER THEORY: What If Primes Were Random?")
    print("=" * 70)
    
    # Demo 1: Product-free vs MI
    print("\n--- Demo 1: Product-Free ≠ MI ---")
    examples = [
        ({2, 3}, "Two smallest primes"),
        ({2, 4}, "Contains divisibility pair"),
        ({4, 6, 9}, "Product-free but NOT MI"),
        ({2, 3, 5, 7}, "First four primes"),
    ]
    for S, desc in examples:
        pf = is_product_free(S)
        mi, counter = is_multiplicatively_independent(S)
        print(f"  {str(S):20s}  ({desc})")
        print(f"    Product-free: {pf}, MI: {mi}")
        if counter:
            print(f"    Counterexample: {counter}")
    
    # Demo 2: Factorization spectrum
    print("\n--- Demo 2: Factorization Spectrum ---")
    test_sets = [
        ({2, 3, 5, 7}, "Primes {2,3,5,7}"),
        ({2, 4, 8}, "Powers of 2"),
        ({4, 6, 9}, "Product-free non-MI"),
    ]
    for S, desc in test_sets:
        print(f"\n  Generating set: {S} ({desc})")
        for n in [8, 12, 16, 24, 36]:
            facts = factorization_spectrum(S, n)
            if facts:
                print(f"    σ({n}) = {len(facts)}: {facts}")
    
    # Demo 3: Collision index
    print("\n\n--- Demo 3: Collision Index ---")
    for N in [10, 20, 50]:
        primes_N = {p for p in range(2, N + 1) 
                    if all(p % i != 0 for i in range(2, int(sqrt(p)) + 1))}
        full_set = set(range(2, N + 1))
        upper = {k for k in range(N // 2 + 1, N + 1)}
        print(f"  N={N}:")
        print(f"    Primes up to {N}: collision index = {collision_index(primes_N)}")
        print(f"    Full set [2,{N}]:  collision index = {collision_index(full_set)}")
        print(f"    Upper ({N//2},{N}]: collision index = {collision_index(upper)}")
    
    # Demo 4: Prime density vs upper interval
    print("\n--- Demo 4: Density vs Structure ---")
    for N in [16, 32, 64, 100]:
        result = prime_density_vs_random(N)
        print(f"  N={N}:")
        print(f"    Primes: {result['prime_count']} elements ({result['prime_density']:.3f}), "
              f"PF={result['primes_product_free']}, MI={result['primes_MI']}")
        print(f"    Upper:  {result['upper_count']} elements ({result['upper_density']:.3f}), "
              f"PF={result['upper_product_free']}, MI={result['upper_MI']}")
        if result['upper_MI_counter']:
            print(f"    Upper MI failure: {result['upper_MI_counter']}")
    
    # Demo 5: The 9×16 = 12×12 counterexample
    print("\n--- Demo 5: The (8, 16] Counterexample ---")
    S = set(range(9, 17))
    print(f"  S = {sorted(S)}")
    print(f"  Product-free: {is_product_free(S)}")
    mi, counter = is_multiplicatively_independent(S)
    print(f"  MI: {mi}")
    print(f"  Counterexample: {counter}")
    print(f"  9 × 16 = {9*16} = 12 × 12 = {12*12}")
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: Primes are special not because of their density")
    print("(≈ N/log N) but because of their multiplicative independence.")
    print("Product-freeness is necessary but not sufficient for MI.")
    print("The gap between these properties is the 'Cramér gap'.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Collision Index Growth

Compares collision indices of primes, random Cramér models, and structured sets.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import sqrt, log
import random


def collision_index(S):
    count = 0
    S_ge2 = {s for s in S if s >= 2}
    for a in S_ge2:
        for b in S_ge2:
            if a * b in S_ge2:
                count += 1
    return count


def get_primes(N):
    primes = set()
    for n in range(2, N + 1):
        if all(n % i != 0 for i in range(2, int(sqrt(n)) + 1)):
            primes.add(n)
    return primes


def cramer_model(N, seed=0):
    rng = random.Random(seed)
    return {n for n in range(2, N + 1) if rng.random() < 1.0 / log(n)}


def main():
    Ns = list(range(10, 201, 10))
    
    prime_ci = []
    random_ci_mean = []
    random_ci_std = []
    full_ci = []
    upper_ci = []
    
    for N in Ns:
        primes = get_primes(N)
        prime_ci.append(collision_index(primes))
        
        rci = [collision_index(cramer_model(N, seed=s)) for s in range(20)]
        random_ci_mean.append(np.mean(rci))
        random_ci_std.append(np.std(rci))
        
        full_ci.append(collision_index(set(range(2, N + 1))))
        upper_ci.append(collision_index(set(range(N // 2 + 1, N + 1))))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Collision indices
    ax1.plot(Ns, prime_ci, 'g-o', label='Primes', markersize=4, linewidth=2)
    ax1.errorbar(Ns, random_ci_mean, yerr=random_ci_std, fmt='r-s', 
                label='Cramér Random (mean ± std)', markersize=3, capsize=3, linewidth=1.5)
    ax1.plot(Ns, upper_ci, 'b-^', label='Upper Interval (N/2, N]', markersize=3, linewidth=1.5)
    ax1.set_xlabel('N')
    ax1.set_ylabel('Collision Index')
    ax1.set_title('Collision Index: Primes vs Random vs Upper Interval')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Normalized collision index (per element squared)
    prime_counts = [len(get_primes(N)) for N in Ns]
    ax2.plot(Ns, [0] * len(Ns), 'g-o', label='Primes (always 0)', 
             markersize=4, linewidth=2)
    norm_random = [m / max(1, (N / log(N))**2) for m, N in zip(random_ci_mean, Ns)]
    ax2.plot(Ns, norm_random, 'r-s', label='Random / (N/ln N)²', 
             markersize=3, linewidth=1.5)
    ax2.set_xlabel('N')
    ax2.set_ylabel('Normalized Collision Index')
    ax2.set_title('Collision Density (Normalized)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('The Cramér Gap: Why Random ≠ Prime', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('collision_index.png', dpi=150, bbox_inches='tight')
    print("Saved collision_index.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Factorization Spectrum Heatmap

Shows how the factorization spectrum σ_S(n) varies for different generating sets.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import sqrt, log
from itertools import combinations_with_replacement
from collections import defaultdict


def factorization_count(S: set, n: int, max_depth: int = 10) -> int:
    elements = sorted(s for s in S if 2 <= s <= n)
    count = 0
    def search(remaining, min_elem, depth):
        nonlocal count
        if remaining == 1:
            count += 1
            return
        for e in elements:
            if e < min_elem: continue
            if e > remaining: break
            if remaining % e == 0 and depth < max_depth:
                search(remaining // e, e, depth + 1)
    search(n, 2, 0)
    return count


def get_primes(N):
    primes = set()
    for n in range(2, N + 1):
        if all(n % i != 0 for i in range(2, int(sqrt(n)) + 1)):
            primes.add(n)
    return primes


def main():
    N = 60
    ns = list(range(2, N + 1))
    
    sets = {
        "Primes ≤ 60": get_primes(N),
        "{2, 4, 8, 16, 32}": {2, 4, 8, 16, 32},
        "{4, 6, 9}": {4, 6, 9},
        "{2, 3, 5}": {2, 3, 5},
        "Upper (30, 60]": set(range(31, 61)),
    }
    
    fig, axes = plt.subplots(len(sets), 1, figsize=(14, 3 * len(sets)), sharex=True)
    
    for idx, (name, S) in enumerate(sets.items()):
        ax = axes[idx]
        spectrum = [factorization_count(S, n) for n in ns]
        
        colors = ['#2ecc71' if s <= 1 else '#e74c3c' if s > 1 else '#95a5a6' for s in spectrum]
        ax.bar(ns, spectrum, color=colors, width=0.8, alpha=0.8)
        ax.set_ylabel('σ_S(n)')
        ax.set_title(f'Factorization Spectrum: S = {name}', fontsize=11)
        ax.set_yscale('symlog', linthresh=1)
        max_s = max(spectrum) if spectrum else 1
        ax.set_ylim(0, max(max_s * 1.2, 2))
        
        # Annotate key points
        for i, (n, s) in enumerate(zip(ns, spectrum)):
            if s > 2:
                ax.annotate(f'{s}', (n, s), textcoords="offset points", 
                           xytext=(0, 5), ha='center', fontsize=7)
    
    axes[-1].set_xlabel('n')
    plt.suptitle('Factorization Spectrum: How Badly Does UFD Fail?', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('factorization_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved factorization_spectrum.png")


if __name__ == "__main__":
    main()
