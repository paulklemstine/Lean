#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstration of key results from the Cramér random model analysis.
Shows how random subsets of ℕ with prime-like density differ structurally
from actual primes.
"""

import random
import math
from collections import defaultdict


def is_product_free(S: set[int]) -> bool:
    """Check if a set S ⊆ ℕ is product-free (no a*b ∈ S for a,b ∈ S, a,b ≥ 2)."""
    elems = sorted(s for s in S if s >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a * b in S:
                return False
    return True


def find_duplicate_factorizations(S: set[int], max_n: int = 1000) -> dict[int, list]:
    """Find numbers with multiple S-factorizations."""
    S_sorted = sorted(s for s in S if s >= 2)
    # Find all products of pairs
    products: dict[int, list] = defaultdict(list)
    for i, a in enumerate(S_sorted):
        for b in S_sorted[i:]:
            p = a * b
            if p <= max_n:
                products[p].append((a, b))
    # Also count singletons
    for s in S_sorted:
        if s <= max_n:
            products[s].append((s,))
    
    return {n: facts for n, facts in products.items() if len(facts) >= 2}


def cramer_random_model(N: int, seed: int = 42) -> set[int]:
    """Generate a Cramér random model: each n ∈ {2,...,N} is included
    independently with probability 1/ln(n)."""
    rng = random.Random(seed)
    S = set()
    for n in range(2, N + 1):
        if rng.random() < 1.0 / math.log(n):
            S.add(n)
    return S


def demo_product_free():
    """Demonstrate that primes are product-free but random sets aren't."""
    print("=" * 60)
    print("DEMO 1: Product-Free Property")
    print("=" * 60)
    
    # Actual primes up to 100
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return {i for i in range(2, n+1) if is_prime[i]}
    
    primes = sieve(100)
    print(f"\nPrimes up to 100: {len(primes)} elements")
    print(f"Product-free: {is_product_free(primes)}")
    
    # Random sets with same density
    for seed in range(5):
        S = cramer_random_model(100, seed=seed)
        pf = is_product_free(S)
        dups = find_duplicate_factorizations(S, max_n=10000)
        print(f"\nRandom model (seed={seed}): {len(S)} elements, "
              f"product-free: {pf}, "
              f"duplicate factorizations: {len(dups)}")
        if dups and not pf:
            example = next(iter(dups.items()))
            print(f"  Example: {example[0]} = {example[1]}")


def demo_counterexample():
    """Demonstrate the {4,6,9} counterexample."""
    print("\n" + "=" * 60)
    print("DEMO 2: Product-Free ≠ Unique Factorization")
    print("=" * 60)
    
    S = {4, 6, 9}
    print(f"\nS = {S}")
    print(f"Product-free: {is_product_free(S)}")
    
    dups = find_duplicate_factorizations(S, max_n=1000)
    print(f"Numbers with multiple S-factorizations:")
    for n, facts in sorted(dups.items()):
        print(f"  {n} = {' = '.join('×'.join(str(x) for x in f) for f in facts)}")


def demo_dirichlet_survival():
    """Demonstrate that dense sets cover all residue classes."""
    print("\n" + "=" * 60)
    print("DEMO 3: Dirichlet Survival Theorem")
    print("=" * 60)
    
    q = 7  # modulus
    N = 1000
    
    for seed in range(3):
        S = cramer_random_model(N, seed=seed)
        # Check which residue classes mod q are covered
        covered = set()
        for x in S:
            covered.add(x % q)
        
        print(f"\nRandom model (N={N}, seed={seed}): {len(S)} elements")
        print(f"  Residue classes mod {q} covered: {sorted(covered)}")
        print(f"  All covered: {len(covered) == q}")
        print(f"  Density: {len(S)}/{N} = {len(S)/N:.3f}")
        print(f"  Threshold (q-1)*m/qm = {(q-1)/q:.3f}")


def demo_k_product_free_hierarchy():
    """Demonstrate the k-product-free hierarchy."""
    print("\n" + "=" * 60)
    print("DEMO 4: k-Product-Free Hierarchy")
    print("=" * 60)
    
    N = 200
    
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return {i for i in range(2, n+1) if is_prime[i]}
    
    primes = sieve(N)
    
    for k in range(2, 6):
        # Check if any product of k primes is itself prime
        # (Sample random k-tuples for efficiency)
        prime_list = sorted(primes)
        violations = 0
        trials = 10000
        rng = random.Random(42)
        for _ in range(trials):
            chosen = [rng.choice(prime_list) for _ in range(k)]
            prod = 1
            for p in chosen:
                prod *= p
            if prod in primes:
                violations += 1
        print(f"  k={k}: {violations}/{trials} violations "
              f"(primes are {k}-product-free: {violations == 0})")
    
    # Now check random model
    print("\n  For Cramér random model:")
    S = cramer_random_model(N, seed=0)
    S_list = sorted(s for s in S if s >= 2)
    for k in range(2, 6):
        violations = 0
        trials = 10000
        rng = random.Random(42)
        for _ in range(trials):
            if len(S_list) < k:
                break
            chosen = [rng.choice(S_list) for _ in range(k)]
            prod = 1
            for p in chosen:
                prod *= p
            if prod in S:
                violations += 1
        print(f"  k={k}: {violations}/{trials} violations")


def demo_product_free_probability():
    """Estimate probability that random model is product-free."""
    print("\n" + "=" * 60)
    print("DEMO 5: Product-Free Probability vs N")
    print("=" * 60)
    
    for N in [50, 100, 200, 500, 1000]:
        pf_count = 0
        trials = 100
        for seed in range(trials):
            S = cramer_random_model(N, seed=seed)
            if is_product_free(S):
                pf_count += 1
        print(f"  N={N:5d}: P(product-free) ≈ {pf_count/trials:.2f} "
              f"(avg size: {sum(len(cramer_random_model(N, s)) for s in range(trials))/trials:.1f})")


if __name__ == "__main__":
    demo_product_free()
    demo_counterexample()
    demo_dirichlet_survival()
    demo_k_product_free_hierarchy()
    demo_product_free_probability()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key findings:
1. Actual primes are product-free; random models almost never are.
2. Product-freeness is necessary but NOT sufficient for unique factorization
   (counterexample: {4, 6, 9}).
3. Dense random sets automatically satisfy Dirichlet-type coverage.
4. Primes satisfy an infinite hierarchy of k-product-free conditions;
   random models fail at k=2.
5. The probability of a Cramér model being product-free → 0 as N → ∞.
""")


#!/usr/bin/env python3
"""
Visualization: Cramér Random Model vs Actual Primes

Generates plots comparing the structural properties of actual primes
with Cramér random models of the same density.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(n: int) -> list[int]:
    """Return list of primes up to n."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n+1, i):
                is_prime[j] = False
    return [i for i in range(2, n+1) if is_prime[i]]


def cramer_model(N: int, seed: int = 42) -> set[int]:
    """Generate Cramér random model."""
    rng = random.Random(seed)
    return {n for n in range(2, N + 1) if rng.random() < 1.0 / math.log(n)}


def is_product_free(S: set[int]) -> bool:
    """Check product-free property."""
    elems = sorted(s for s in S if s >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a * b in S:
                return False
    return True


def plot_density_comparison():
    """Plot counting functions of primes vs random models."""
    N = 2000
    primes = set(sieve_of_eratosthenes(N))
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Counting functions
    ax = axes[0]
    xs = list(range(2, N+1))
    prime_count = np.cumsum([1 if x in primes else 0 for x in xs])
    ax.plot(xs, prime_count, 'b-', linewidth=2, label='π(x) [actual primes]')
    
    for seed in range(3):
        S = cramer_model(N, seed=seed)
        random_count = np.cumsum([1 if x in S else 0 for x in xs])
        ax.plot(xs, random_count, '--', alpha=0.6, linewidth=1,
                label=f'Cramér model (seed={seed})')
    
    # x/ln(x) reference
    ref = [x / math.log(x) for x in xs]
    ax.plot(xs, ref, 'k:', linewidth=1.5, label='x/ln(x)')
    
    ax.set_xlabel('x')
    ax.set_ylabel('Count')
    ax.set_title('Counting Function: Primes vs Random Models')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Right: Product-free probability
    ax = axes[1]
    Ns = [20, 30, 50, 75, 100, 150, 200, 300, 500]
    probs = []
    for n in Ns:
        count = sum(1 for s in range(200) if is_product_free(cramer_model(n, seed=s)))
        probs.append(count / 200)
    
    ax.semilogy(Ns, [max(p, 0.001) for p in probs], 'ro-', linewidth=2, markersize=6)
    ax.axhline(y=1.0, color='blue', linestyle='--', alpha=0.5, label='Primes (always 1.0)')
    ax.set_xlabel('N')
    ax.set_ylabel('P(product-free)')
    ax.set_title('Probability Random Model is Product-Free')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0.001)
    
    plt.tight_layout()
    plt.savefig('cramer_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cramer_comparison.png")


def plot_factorization_landscape():
    """Plot the factorization multiplicity landscape."""
    N = 500
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Cramér model factorization counts
    ax = axes[0]
    S = cramer_model(N, seed=42)
    S_sorted = sorted(s for s in S if s >= 2)
    
    # Count factorizations for numbers up to N
    fact_counts = {}
    for i, a in enumerate(S_sorted):
        for b in S_sorted[i:]:
            p = a * b
            if p <= N:
                if p not in fact_counts:
                    fact_counts[p] = 0
                fact_counts[p] += 1
                if p in S:  # also has singleton factorization
                    pass
    
    # Add singleton factorizations
    for s in S_sorted:
        if s not in fact_counts:
            fact_counts[s] = 0
        fact_counts[s] += 1  # singleton {s}
    
    multi = {n: c for n, c in fact_counts.items() if c >= 2}
    
    if multi:
        ns = sorted(multi.keys())
        counts = [multi[n] for n in ns]
        ax.bar(ns, counts, width=2, color='red', alpha=0.7)
        ax.set_title(f'Multiple Factorizations in Cramér Model (N={N})')
    else:
        ax.text(0.5, 0.5, 'No multiple factorizations found',
                transform=ax.transAxes, ha='center')
        ax.set_title(f'Factorizations in Cramér Model (N={N})')
    
    ax.set_xlabel('n')
    ax.set_ylabel('Number of S-factorizations')
    ax.grid(True, alpha=0.3)
    
    # Cramér defect by level
    ax = axes[1]
    Ns = [50, 100, 200, 500]
    for N_val in Ns:
        S = cramer_model(N_val, seed=42)
        defects = []
        for k in range(2, 6):
            elems = sorted(s for s in S if s >= 2)
            count = 0
            if k == 2:
                for i, a in enumerate(elems):
                    for b in elems[i:]:
                        if a * b in S:
                            count += 1
            defects.append(count if k == 2 else 0)
        ax.plot(range(2, 6), defects, 'o-', label=f'N={N_val}')
    
    ax.set_xlabel('k (product arity)')
    ax.set_ylabel('Cramér defect')
    ax.set_title('Cramér Defect at Level k=2')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('factorization_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved factorization_landscape.png")


def plot_residue_coverage():
    """Plot residue class coverage for random models."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    qs = [3, 5, 7, 11, 13]
    N = 1000
    
    for q in qs:
        Ns = list(range(q, N+1, 10))
        coverage_rates = []
        for n in Ns:
            covered_total = 0
            trials = 50
            for seed in range(trials):
                S = cramer_model(n, seed=seed)
                covered = len({x % q for x in S})
                covered_total += covered
            coverage_rates.append(covered_total / (trials * q))
        ax.plot(Ns, coverage_rates, '-', linewidth=1.5, label=f'q={q}')
    
    ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5)
    ax.set_xlabel('N (model size)')
    ax.set_ylabel('Fraction of residue classes covered')
    ax.set_title('Dirichlet Coverage: Random Models Cover All Residue Classes')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.5, 1.05)
    
    plt.tight_layout()
    plt.savefig('residue_coverage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved residue_coverage.png")


if __name__ == "__main__":
    plot_density_comparison()
    plot_factorization_landscape()
    plot_residue_coverage()
