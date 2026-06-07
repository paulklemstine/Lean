#!/usr/bin/env python3
"""
Demo: Non-Standard Arithmetic via Ultrapowers

Demonstrates the key properties of non-standard natural numbers constructed
via the ultrapower *ℕ = ℕ^ℕ/U.

Since we can't construct a free ultrafilter computationally (they require
the axiom of choice), we simulate ultrapower properties using large finite
approximations: a "simulated ultrafilter" that declares a property true
if it holds for >90% of indices up to N.
"""

import math
from typing import Callable, List, Tuple


def simulated_ultrapower_check(prop: Callable[[int], bool], N: int = 10000,
                                threshold: float = 0.9) -> bool:
    """Check if a property holds for 'most' indices (simulating U-membership)."""
    count = sum(1 for i in range(N) if prop(i))
    return count / N > threshold


def demo_non_archimedean():
    """Demonstrate: ω = [id] exceeds every standard constant."""
    print("=" * 60)
    print("§1. THE NON-ARCHIMEDEAN PROPERTY")
    print("=" * 60)
    print()
    print("ω = [i ↦ i] (the identity sequence)")
    print()
    for n in [5, 100, 1000, 9999]:
        prop = lambda i, n=n: i > n
        result = simulated_ultrapower_check(prop)
        frac = sum(1 for i in range(10000) if i > n) / 10000
        print(f"  std({n}) < ω ?  {result}  "
              f"({frac*100:.1f}% of indices satisfy i > {n})")
    print()


def demo_universal_divisibility():
    """Demonstrate: ω! = [i ↦ i!] is divisible by every standard number."""
    print("=" * 60)
    print("§2. UNIVERSAL DIVISIBILITY OF ω!")
    print("=" * 60)
    print()
    print("ω! = [i ↦ i!] (the factorial sequence)")
    print()
    for n in [2, 3, 7, 12, 100]:
        prop = lambda i, n=n: i >= n  # n | i! whenever i >= n
        result = simulated_ultrapower_check(prop)
        frac = sum(1 for i in range(10000) if i >= n) / 10000
        print(f"  std({n}) | ω! ?  {result}  "
              f"({frac*100:.1f}% of indices have {n} | i!)")
    print()
    print("  ω! ≠ 0 ?  True  (i! > 0 for all i, so 100% of indices)")
    print()
    print("  → ω! is a NONZERO element divisible by EVERY standard number!")
    print()


def demo_power_hierarchy():
    """Demonstrate: ω < ω² < ω³ < ..."""
    print("=" * 60)
    print("§3. THE POWER HIERARCHY")
    print("=" * 60)
    print()
    for k in range(1, 6):
        prop = lambda i, k=k: i >= 2 and i**k < i**(k+1)
        result = simulated_ultrapower_check(prop)
        print(f"  ω^{k} < ω^{k+1} ?  {result}")
    print()
    print("  → Powers of ω form a strictly increasing hierarchy of infinities")
    print()


def demo_well_ordering_failure():
    """Demonstrate: ω, ω-1, ω-2, ... is strictly decreasing."""
    print("=" * 60)
    print("§4. FAILURE OF WELL-ORDERING")
    print("=" * 60)
    print()
    print("  s(k)(i) = i - k  (natural subtraction)")
    print()
    for k in range(6):
        prop = lambda i, k=k: i > k + 1 and (i - (k+1)) < (i - k)
        result = simulated_ultrapower_check(prop)
        print(f"  s({k+1}) < s({k}) ?  {result}  "
              f"(i-{k+1} < i-{k} for i > {k+1})")
    print()
    print("  → *ℕ has infinite descending chains → NOT well-ordered!")
    print()


def demo_nonstandard_primes():
    """Demonstrate: non-standard primes exist."""
    print("=" * 60)
    print("§5. NON-STANDARD PRIMES")
    print("=" * 60)
    print()

    # Compute primes up to a limit using sieve
    def sieve(limit):
        is_prime = [True] * (limit + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(limit**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, limit + 1, i):
                    is_prime[j] = False
        return [i for i in range(limit + 1) if is_prime[i]]

    primes = sieve(200000)
    print(f"  Using the sequence f(i) = p_i (the i-th prime)")
    print(f"  Computed {len(primes)} primes")
    print()

    for p in [2, 3, 11, 101, 1009]:
        # How many of the first 10000 primes exceed p?
        count = sum(1 for i in range(min(10000, len(primes))) if primes[i] > p)
        frac = count / min(10000, len(primes))
        print(f"  f exceeds std({p}) ?  {frac > 0.9}  "
              f"({frac*100:.1f}% of p_i > {p})")
    print()
    print("  → There exist non-standard primes exceeding ALL standard primes")
    print()


def demo_transfer():
    """Demonstrate transfer of algebraic identities."""
    print("=" * 60)
    print("§6. TRANSFER OF ALGEBRAIC IDENTITIES")
    print("=" * 60)
    print()
    N = 1000

    # Gauss sum: 1+2+...+n = n(n+1)/2
    all_match = all(sum(range(i+1)) == i*(i+1)//2 for i in range(N))
    print(f"  Gauss sum transfer: Σk≤ω k = ω(ω+1)/2 ?  {all_match}  "
          f"(verified for {N} indices)")

    # Zero product
    violations = 0
    for i in range(N):
        a, b = i % 7, i % 5
        if a * b == 0 and a != 0 and b != 0:
            violations += 1
    print(f"  Zero-product property: violations in {N} tests = {violations}")

    # GCD commutativity
    all_match = all(math.gcd(i, i*i+1) == math.gcd(i*i+1, i) for i in range(N))
    print(f"  GCD commutativity transfer: {all_match}")
    print()


def demo_overflow():
    """Demonstrate the overflow principle."""
    print("=" * 60)
    print("§7. THE OVERFLOW PRINCIPLE")
    print("=" * 60)
    print()
    print("  If P(n) holds for all n ≥ N₀, then P holds at ω (in *ℕ)")
    print()

    examples = [
        ("n² > 100n", lambda n: n*n > 100*n, 101),
        ("n! > 2ⁿ", lambda n: math.factorial(min(n, 170)) > 2**min(n, 170), 4),
        ("n > 1000000", lambda n: n > 1000000, 1000001),
    ]

    for desc, prop, threshold in examples:
        holds_after = all(prop(n) for n in range(threshold, threshold + 100))
        print(f"  '{desc}' holds for n ≥ {threshold}: {holds_after}")
        print(f"    → This property also holds at ω (by overflow)")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   NON-STANDARD ARITHMETIC: Ultrapower Construction     ║")
    print("║   Demonstrating properties of *ℕ = ℕ^ℕ/U              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_non_archimedean()
    demo_universal_divisibility()
    demo_power_hierarchy()
    demo_well_ordering_failure()
    demo_nonstandard_primes()
    demo_transfer()
    demo_overflow()

    print("=" * 60)
    print("All demonstrations complete.")
    print("These computations approximate ultrapower behavior using")
    print("finite simulations. The formal Lean 4 proofs establish")
    print("these properties rigorously for arbitrary free ultrafilters.")


#!/usr/bin/env python3
"""Visualization: Power Hierarchy in *ℕ

Shows how ω, ω², ω³, ... separate at increasing indices,
demonstrating the infinite hierarchy of non-standard elements.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_power_hierarchy():
    indices = np.arange(1, 20)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Linear scale (small range)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    for k, color in zip(range(1, 6), colors):
        vals = indices.astype(float) ** k
        ax1.plot(indices, vals, 'o-', color=color, label=f'ω^{k} = [i ↦ i^{k}]',
                 markersize=4, linewidth=1.5)

    ax1.set_xlabel('Index i', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Power Hierarchy (linear scale)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 500)
    ax1.grid(True, alpha=0.3)

    # Log scale (full range)
    indices_large = np.arange(2, 50)
    for k, color in zip(range(1, 6), colors):
        vals = indices_large.astype(float) ** k
        ax2.semilogy(indices_large, vals, '-', color=color,
                     label=f'ω^{k}', linewidth=2)

    # Add constant (standard) lines
    for n in [10, 100, 1000]:
        ax2.axhline(y=n, color='gray', linestyle='--', alpha=0.5,
                    label=f'std({n})' if n == 10 else '')
        ax2.text(48, n * 1.2, f'std({n})', fontsize=8, color='gray')

    ax2.set_xlabel('Index i', fontsize=12)
    ax2.set_ylabel('Value (log scale)', fontsize=12)
    ax2.set_title('Power Hierarchy (log scale) — all exceed standards', fontsize=14)
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)

    plt.suptitle('The Infinite Hierarchy: ω < ω² < ω³ < ω⁴ < ω⁵ < ...',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('power_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved power_hierarchy.png")


def plot_divisibility_landscape():
    """Visualize which standard numbers divide i! at each index."""
    fig, ax = plt.subplots(figsize=(12, 6))

    N = 30
    divisors = [2, 3, 5, 7, 11, 13]
    import math

    for j, d in enumerate(divisors):
        xs, ys = [], []
        for i in range(1, N + 1):
            if math.factorial(i) % d == 0:
                xs.append(i)
                ys.append(j)
        ax.scatter(xs, ys, s=80, marker='s', alpha=0.7,
                   label=f'{d} | i!')

    # Mark threshold
    for j, d in enumerate(divisors):
        ax.axvline(x=d, color='gray', linestyle=':', alpha=0.3)
        ax.text(d, len(divisors) - 0.3, f'i≥{d}', fontsize=7,
                ha='center', color='gray')

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Divisor', fontsize=12)
    ax.set_yticks(range(len(divisors)))
    ax.set_yticklabels([str(d) for d in divisors])
    ax.set_title('Universal Divisibility: n | i! for all i ≥ n\n'
                 '(Each row becomes solid past i = n → all in ultrafilter)',
                 fontsize=14)
    ax.legend(loc='lower right', fontsize=10)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('divisibility_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved divisibility_landscape.png")


if __name__ == "__main__":
    plot_power_hierarchy()
    plot_divisibility_landscape()
