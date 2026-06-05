#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of non-standard arithmetic concepts.

Demonstrates the ultrapower construction for finite approximations,
showing how "infinite" elements emerge as the index set grows.
"""

import math
from typing import List, Tuple, Callable


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


def nth_prime(n: int) -> int:
    """Return the n-th prime (0-indexed: 0→2, 1→3, 2→5, ...)."""
    count = 0
    candidate = 2
    while True:
        if is_prime(candidate):
            if count == n:
                return candidate
            count += 1
        candidate += 1


def demo_ultrapower_finite_approximation():
    """Demonstrate the ultrapower construction with finite index sets.
    
    For I = {0, 1, ..., N-1}, show how the identity sequence [0,1,2,...,N-1]
    exceeds every constant sequence [n, n, ..., n] on "most" indices.
    """
    print("=" * 60)
    print("DEMO 1: Finite approximation of ℕ*")
    print("=" * 60)
    
    for N in [10, 100, 1000]:
        print(f"\nIndex set I = {{0, 1, ..., {N-1}}}")
        print(f"  ω = [id] = [0, 1, 2, ..., {N-1}]")
        
        for n in [5, 10, 50]:
            if n >= N:
                continue
            # Fraction of indices where id(i) > n
            count_exceeding = sum(1 for i in range(N) if i > n)
            frac = count_exceeding / N
            print(f"  Fraction where ω > d({n}): {count_exceeding}/{N} = {frac:.4f}")
        
        print(f"  → As N → ∞, these fractions → 1 (cofinite sets)")


def demo_nonstandard_primes():
    """Demonstrate the non-standard prime construction.
    
    The sequence [p_0, p_1, p_2, ...] = [2, 3, 5, 7, 11, ...]
    is (1) prime at every index and (2) exceeds every constant sequence.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Non-standard primes")
    print("=" * 60)
    
    N = 20
    primes = [nth_prime(i) for i in range(N)]
    print(f"\nFirst {N} primes: {primes}")
    
    print("\nVerification that p_n > n for all n:")
    for i in range(N):
        p = primes[i]
        print(f"  p_{i} = {p} > {i} ✓" if p > i else f"  p_{i} = {p} ≤ {i} ✗")
    
    print(f"\nThe ultrapower element [p_0, p_1, ...] is:")
    print(f"  - Internally prime (every entry is prime)")
    print(f"  - Larger than every d(n) (p_n > n for all n)")
    print(f"  - A 'prime number beyond infinity'")


def demo_overspill_failure():
    """Demonstrate the countable intersection failure.
    
    Property P(i, n) = "n < i":
    - For each n, {i | n < i} is cofinite (hence U-large)
    - But {i | ∀n, n < i} = ∅ (no natural exceeds all naturals)
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Overspill / Countable intersection failure")
    print("=" * 60)
    
    N = 20
    print(f"\nProperty P(i, n) = 'n < i' for i ∈ {{0, ..., {N-1}}}")
    
    for n in [0, 5, 10, 15]:
        if n >= N:
            continue
        satisfying = [i for i in range(N) if n < i]
        print(f"  {{i | {n} < i}} = {satisfying} ({len(satisfying)}/{N} indices)")
    
    all_satisfy = [i for i in range(N) if all(n < i for n in range(N))]
    print(f"\n  {{i | ∀n<{N}, n < i}} = {all_satisfy} (EMPTY for any finite N!)")
    print(f"  → This is why ℕ* has infinite elements but ℕ doesn't")


def demo_transfer_boundary():
    """Demonstrate which properties transfer and which don't."""
    print("\n" + "=" * 60)
    print("DEMO 4: Transfer boundary")
    print("=" * 60)
    
    N = 100
    id_seq = list(range(N))
    
    print(f"\nIn ℕ* (approximated with N={N}):")
    print(f"  ω = [0, 1, 2, ..., {N-1}]")
    
    # First-order properties that transfer
    print("\n  Properties that TRANSFER (first-order):")
    
    # Commutativity: a + b = b + a
    a, b = 7, 13
    all_commute = all(id_seq[i] + a == a + id_seq[i] for i in range(N) if i + a < N)
    print(f"    ω + d({a}) = d({a}) + ω: {all_commute}")
    
    # Primality of specific values
    p = 7
    print(f"    d({p}) is prime: {is_prime(p)}")
    
    # Divisibility
    print(f"    d(6) | d(42): {42 % 6 == 0}")
    print(f"    d(7) | d(42): {42 % 7 == 0}")
    print(f"    d(5) | d(42): {42 % 5 == 0}")
    
    # Zero-product property
    print(f"    d(0) · ω = d(0): True (zero-product transfers)")
    
    # Second-order properties that DON'T transfer
    print("\n  Properties that DON'T TRANSFER (second-order):")
    print(f"    Archimedean property: ∃n, ω ≤ d(n) → FALSE in ℕ*")
    print(f"    Well-ordering: every nonempty subset has minimum → FAILS")
    print(f"    (The set of infinite elements {{ω, ω-1, ω-2, ...}} has no minimum)")


def demo_compactness():
    """Demonstrate the compactness bridge.
    
    The axiom set {"x > 0", "x > 1", ..., "x > n", ...} is finitely
    satisfiable in ℕ (take x = max+1) but not satisfiable in ℕ.
    It IS satisfiable in ℕ* (take x = ω).
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Compactness bridge")
    print("=" * 60)
    
    print("\nAxiom set: {\"x > 0\", \"x > 1\", \"x > 2\", ...}")
    
    for k in [3, 10, 100]:
        # Any finite subset {x > 0, ..., x > k-1} is satisfiable
        witness = k  # x = k satisfies all of them
        print(f"\n  Finite subset {{x > 0, ..., x > {k-1}}}:")
        print(f"    Satisfiable in ℕ: witness x = {witness}")
        all_satisfied = all(witness > n for n in range(k))
        print(f"    All satisfied: {all_satisfied}")
    
    print(f"\n  Full set {{x > n | n ∈ ℕ}}:")
    print(f"    NOT satisfiable in ℕ (no natural exceeds all naturals)")
    print(f"    SATISFIABLE in ℕ* (take x = ω = [id])")
    print(f"    → This IS the compactness theorem in action!")


if __name__ == "__main__":
    demo_ultrapower_finite_approximation()
    demo_nonstandard_primes()
    demo_overspill_failure()
    demo_transfer_boundary()
    demo_compactness()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
viz_ultrapower.py — Visualization of ultrapower elements and the non-Archimedean gap.

Standalone matplotlib script showing:
1. The identity sequence [0,1,2,...] vs constant sequences [n,n,n,...]
2. The non-standard prime sequence [2,3,5,7,11,...]
3. The overspill phenomenon
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def nth_prime(n: int) -> int:
    count, candidate = 0, 2
    while True:
        if is_prime(candidate):
            if count == n: return candidate
            count += 1
        candidate += 1

def plot_ultrapower_elements():
    N = 50
    indices = np.arange(N)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Identity vs constants
    ax = axes[0]
    ax.plot(indices, indices, 'b-', linewidth=2, label='ω = [id]')
    for n in [5, 15, 30, 45]:
        ax.axhline(y=n, color='red', linestyle='--', alpha=0.5, label=f'd({n})')
    ax.fill_between(indices, indices, 0, alpha=0.1, color='blue')
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.set_title('ω = [id] exceeds every d(n)')
    ax.legend(fontsize=8)
    ax.set_xlim(0, N-1)
    ax.set_ylim(0, N)
    
    # Plot 2: Non-standard prime
    ax = axes[1]
    primes = [nth_prime(i) for i in range(N)]
    ax.plot(indices, primes, 'g-', linewidth=2, label='π = [p₀, p₁, ...]')
    ax.plot(indices, indices, 'b--', alpha=0.5, label='ω = [id]')
    ax.fill_between(indices, primes, indices, alpha=0.1, color='green')
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.set_title('Non-standard prime π exceeds ω')
    ax.legend(fontsize=8)
    ax.set_xlim(0, N-1)
    
    # Plot 3: Overspill
    ax = axes[2]
    max_n_vals = list(range(1, N+1))
    fractions = []
    for max_n in max_n_vals:
        count = sum(1 for i in range(N) if all(n < i for n in range(max_n)))
        fractions.append(count / N)
    
    ax.plot(max_n_vals, fractions, 'r-', linewidth=2)
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='U-threshold (majority)')
    ax.fill_between(max_n_vals, fractions, 0, alpha=0.1, color='red')
    ax.set_xlabel('Number of conjuncts (max_n)')
    ax.set_ylabel('Fraction satisfying all')
    ax.set_title('Overspill: finite OK, infinite fails')
    ax.legend(fontsize=8)
    ax.set_xlim(1, N)
    ax.set_ylim(-0.05, 1.05)
    
    plt.tight_layout()
    plt.savefig('ultrapower_elements.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved ultrapower_elements.png")


def plot_transfer_boundary():
    N = 200
    indices = np.arange(N)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Individual sets {i | n < i} for various n
    ax = axes[0]
    for n in [0, 10, 50, 100, 150]:
        membership = [1 if i > n else 0 for i in range(N)]
        frac = sum(membership) / N
        ax.bar(n, frac, width=8, alpha=0.7, label=f'n={n}: {frac:.2f}')
    
    ax.axhline(y=0.5, color='red', linestyle='--', label='Majority threshold')
    ax.set_xlabel('Standard bound n')
    ax.set_ylabel('Fraction of indices where i > n')
    ax.set_title('Each {i | n < i} is "large"')
    ax.legend(fontsize=8)
    
    # Plot 2: Simultaneous satisfaction
    ax = axes[1]
    max_ns = list(range(1, N, 5))
    simultaneous = [sum(1 for i in range(N) if all(n < i for n in range(mn))) / N 
                    for mn in max_ns]
    individual_min = [(N - mn) / N for mn in max_ns]
    
    ax.plot(max_ns, individual_min, 'b-', linewidth=2, label='min individual')
    ax.plot(max_ns, simultaneous, 'r-', linewidth=2, label='simultaneous ∀ n < k')
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
    ax.fill_between(max_ns, individual_min, simultaneous, alpha=0.15, color='purple')
    ax.set_xlabel('Bound k')
    ax.set_ylabel('Fraction satisfying')
    ax.set_title('Transfer gap: individual vs simultaneous')
    ax.legend(fontsize=8)
    ax.annotate('Overspill gap', xy=(N//2, 0.3), fontsize=12, ha='center',
                color='purple', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('transfer_boundary.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved transfer_boundary.png")


if __name__ == "__main__":
    plot_ultrapower_elements()
    plot_transfer_boundary()
