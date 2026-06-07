#!/usr/bin/env python3
"""
Demo: Non-Standard Arithmetic via Ultraproducts

Demonstrates the key ideas from the formalization:
1. Ultrafilter equivalence classes
2. Non-standard elements exceeding all standard naturals
3. The overspill principle in action
4. Transfer of arithmetic properties
"""

import random
from typing import Callable, List, Set


def simulate_ultrafilter_membership(
    subset: Set[int], universe_size: int = 1000, threshold: float = 0.9
) -> bool:
    """Simulate whether a subset is 'ultrafilter-large' using density heuristic.
    
    In the formal theory, an ultrafilter U on ℕ partitions all subsets into
    'large' (∈ U) and 'small' (∉ U). Free ultrafilters make all cofinite sets large.
    We simulate this with a density threshold.
    """
    density = len(subset) / universe_size if universe_size > 0 else 0
    return density > threshold


def demonstrate_nonstandard_element():
    """The identity function id: ℕ → ℕ represents a non-standard element.
    
    For any standard n, {i | n < id(i)} = {n+1, n+2, ...} is cofinite,
    hence in any free ultrafilter. So [id] > [n] for all standard n.
    """
    print("=" * 60)
    print("DEMO 1: Non-Standard Elements")
    print("=" * 60)
    print()
    print("The identity function f(i) = i represents an 'infinite' number")
    print("in the ultrapower ℕ*/U.")
    print()
    
    N = 100  # universe size for simulation
    for standard_n in [5, 10, 50, 99]:
        exceeding_set = {i for i in range(N) if standard_n < i}
        cofinite_ratio = len(exceeding_set) / N
        print(f"  Standard n = {standard_n}:")
        print(f"    {{i | {standard_n} < i}} has {len(exceeding_set)}/{N} = {cofinite_ratio:.0%} of indices")
        print(f"    → This set is {'U-large (cofinite)' if cofinite_ratio > 0.5 else 'NOT U-large'}")
    
    print()
    print("Since {i | n < i} is cofinite for ALL n, [id] exceeds every standard number.")
    print("This element is NON-STANDARD — it lives 'beyond infinity'.")
    print()


def demonstrate_overspill():
    """The Overspill Principle: properties holding for all standard n overflow.
    
    If P(i, n) holds for all standard n on U-large sets,
    then P(i, f(i)) holds for some non-standard f.
    """
    print("=" * 60)
    print("DEMO 2: The Overspill Principle")
    print("=" * 60)
    print()
    print("Property: P(i, n) = 'i > n²'")
    print("For each standard n, {i | i > n²} is cofinite, hence U-large.")
    print()
    
    N = 200
    for n in [1, 3, 5, 10, 14]:
        large_set = {i for i in range(N) if i > n * n}
        ratio = len(large_set) / N
        print(f"  n = {n}: {{i ∈ [0,{N}) | i > {n}²={n*n}}} has {len(large_set)} elements ({ratio:.0%})")
    
    print()
    print("Overspill constructs f(i) = max{n ≤ i | ∀k≤n, i > k²} = ⌊√i⌋")
    print("This f is non-standard (f(i) → ∞) and P(i, f(i)) holds 'U-often'.")
    print()
    
    for i in [10, 100, 1000, 10000]:
        f_i = int(i ** 0.5)
        holds = i > f_i * f_i
        print(f"  i = {i}: f(i) = ⌊√{i}⌋ = {f_i}, P({i}, {f_i}) = ({i} > {f_i*f_i}) = {holds}")
    print()


def demonstrate_transfer():
    """Transfer principles: first-order properties of ℕ hold in ℕ*/U.
    
    Examples:
    - Division algorithm: a = bq + r, 0 ≤ r < b
    - GCD properties: gcd(a,b) | a and gcd(a,b) | b
    - Compositeness: if n = ab with a,b > 1, we can extract a, b
    """
    print("=" * 60)
    print("DEMO 3: Transfer Principles")
    print("=" * 60)
    print()
    
    # Division algorithm transfer
    print("Division Algorithm Transfer:")
    print("If a(i) and b(i) > 0 for U-many i, then")
    print("a(i) = b(i)·q(i) + r(i) with r(i) < b(i) for U-many i.")
    print()
    
    random.seed(42)
    for _ in range(5):
        a, b = random.randint(1, 1000), random.randint(1, 100)
        q, r = divmod(a, b)
        print(f"  a={a}, b={b}: {a} = {b}·{q} + {r}, r={r} < b={b} ✓")
    
    print()
    
    # GCD transfer
    print("GCD Transfer:")
    print("gcd(a(i), b(i)) divides both a(i) and b(i) for ALL i (universal truth).")
    print()
    
    import math
    for a, b in [(12, 18), (35, 49), (100, 75), (17, 13)]:
        g = math.gcd(a, b)
        print(f"  gcd({a}, {b}) = {g}: {a}/{g}={a//g}, {b}/{g}={b//g} ✓")
    
    print()
    
    # Non-Archimedean property
    print("Non-Archimedean Property:")
    print("The ultrapower contains elements exceeding n·k for ALL standard n, k.")
    print("f(i) = i·(i+1) works: for any n·k, {i | n·k < i·(i+1)} is cofinite.")
    print()
    
    for n, k in [(10, 100), (1000, 1000), (10**6, 10**6)]:
        threshold = n * k
        # Find smallest i where i*(i+1) > threshold
        i = int(threshold ** 0.5)
        while i * (i + 1) <= threshold:
            i += 1
        print(f"  n·k = {n}·{k} = {threshold}: f(i) = i·(i+1) > {threshold} for all i ≥ {i}")


def demonstrate_dichotomy():
    """Ultrapower Dichotomy: every element is standard or non-standard.
    
    For any g: ℕ → ℕ, either:
    (a) g is non-standard: {i | n < g(i)} ∈ U for all n, or
    (b) g is bounded: {i | g(i) ≤ n} ∈ U for some n
    """
    print()
    print("=" * 60)
    print("DEMO 4: Ultrapower Dichotomy")
    print("=" * 60)
    print()
    
    N = 100
    
    # Non-standard example
    g1 = lambda i: i * i
    print(f"g₁(i) = i²: NON-STANDARD")
    for n in [10, 100, 1000]:
        large = sum(1 for i in range(N) if g1(i) > n)
        print(f"  {{i < {N} | g₁(i) > {n}}} has {large} elements ({large/N:.0%})")
    
    print()
    
    # Standard (bounded) example
    g2 = lambda i: i % 7
    print(f"g₂(i) = i mod 7: BOUNDED by 6")
    bounded = sum(1 for i in range(N) if g2(i) <= 6)
    print(f"  {{i < {N} | g₂(i) ≤ 6}} has {bounded} elements ({bounded/N:.0%})")
    print(f"  → g₂ is U-equivalent to a standard element")


if __name__ == "__main__":
    demonstrate_nonstandard_element()
    demonstrate_overspill()
    demonstrate_transfer()
    demonstrate_dichotomy()
    
    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("Key results formalized in Lean 4:")
    print("  1. Ultrapower construction ℕ*/U with ordering")
    print("  2. Complete logical transfer system (¬, →, ↔)")
    print("  3. Non-standard elements exist (id is non-standard)")
    print("  4. Overspill principle with Decidable predicates")
    print("  5. Underspill principle (dual)")
    print("  6. Arithmetic transfer (division, GCD, composites)")
    print("  7. Non-Archimedean characterization via ultrapowers")
    print("  8. Ultrapower dichotomy (standard vs non-standard)")
    print("  9. Euclid's theorem on primes transfers")
    print(" 10. Archimedean property fails in ultrapowers")


#!/usr/bin/env python3
"""
Visualization: The Overspill Principle

Shows how the overspill witness function f(i) grows beyond all standard bounds,
demonstrating that properties holding for all standard n must 'overflow' to non-standard.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def overspill_witness(P, i_max):
    """Compute the overspill witness f(i) = max{n ≤ i | ∀k≤n, P(i,k)}."""
    results = []
    for i in range(i_max):
        best = 0
        for n in range(i + 1):
            if all(P(i, k) for k in range(n + 1)):
                best = n
            else:
                break
        results.append(best)
    return results


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("The Overspill Principle: Properties Overflow from Standard to Non-Standard",
                 fontsize=14, fontweight='bold')

    N = 500
    x = np.arange(N)

    # Example 1: P(i,n) = i > n²
    P1 = lambda i, n: i > n * n
    f1 = overspill_witness(P1, N)
    ax = axes[0, 0]
    ax.plot(x, f1, color='#2196F3', linewidth=1.5, label='f(i) = ⌊√i⌋')
    ax.plot(x, np.sqrt(x), '--', color='#FF5722', linewidth=1, alpha=0.7, label='√i (reference)')
    for n in [5, 10, 15]:
        ax.axhline(y=n, color='gray', linestyle=':', alpha=0.3)
        ax.text(N - 10, n + 0.5, f'n={n}', fontsize=8, ha='right', color='gray')
    ax.set_title('P(i,n) = "i > n²"', fontsize=11)
    ax.set_xlabel('Index i')
    ax.set_ylabel('f(i)')
    ax.legend(fontsize=9)
    ax.set_ylim(0, 25)

    # Example 2: P(i,n) = i > 2^n
    P2 = lambda i, n: i > (2 ** n) if n < 30 else False
    f2 = overspill_witness(P2, N)
    ax = axes[0, 1]
    ax.plot(x, f2, color='#4CAF50', linewidth=1.5, label='f(i) = ⌊log₂ i⌋')
    ax.plot(x[1:], np.log2(x[1:]), '--', color='#FF5722', linewidth=1, alpha=0.7, label='log₂ i')
    ax.set_title('P(i,n) = "i > 2ⁿ"', fontsize=11)
    ax.set_xlabel('Index i')
    ax.set_ylabel('f(i)')
    ax.legend(fontsize=9)

    # Example 3: U-large sets shrink but never vanish
    ax = axes[1, 0]
    for n in [2, 5, 10, 15, 20]:
        S_n = [i for i in range(N) if all(P1(i, k) for k in range(n + 1))]
        density = [sum(1 for j in S_n if j <= i) / (i + 1) for i in range(N)]
        ax.plot(x, density, linewidth=1.2, label=f'S_{n} density')
    ax.set_title('Density of {i | ∀k≤n, i > k²}', fontsize=11)
    ax.set_xlabel('Index i')
    ax.set_ylabel('Cumulative density')
    ax.legend(fontsize=8, loc='lower right')
    ax.set_ylim(0, 1.05)

    # Example 4: The dichotomy
    ax = axes[1, 1]
    g_standard = [i % 7 for i in range(N)]
    g_nonstandard = [i * i for i in range(N)]
    ax.plot(x, g_standard, '.', color='#2196F3', markersize=1, label='g(i) = i mod 7 (bounded)')
    ax.plot(x[:50], [i * i for i in range(50)], '-', color='#F44336', linewidth=1.5,
            label='g(i) = i² (non-standard)')
    ax.axhline(y=6, color='#2196F3', linestyle='--', alpha=0.5, label='Bound = 6')
    ax.set_title('Dichotomy: Bounded vs Non-Standard', fontsize=11)
    ax.set_xlabel('Index i')
    ax.set_ylabel('g(i)')
    ax.legend(fontsize=9)
    ax.set_ylim(-1, 50)

    plt.tight_layout()
    plt.savefig('overspill_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to overspill_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Transfer Principles in Non-Standard Arithmetic

Shows how arithmetic properties (division algorithm, GCD, primality)
transfer through ultraproducts.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Transfer Principles: Classical Arithmetic in Non-Standard Models",
                 fontsize=14, fontweight='bold')

    N = 200

    # 1. Division algorithm transfer
    ax = axes[0, 0]
    a_vals = np.arange(0, N)
    b = 7  # fixed divisor
    quotients = a_vals // b
    remainders = a_vals % b
    ax.scatter(a_vals, remainders, c=remainders, cmap='tab10', s=3, alpha=0.7)
    ax.set_title(f'Division Algorithm: a mod {b}', fontsize=11)
    ax.set_xlabel('a')
    ax.set_ylabel('a mod 7')
    ax.text(0.95, 0.95, 'Transfers: a = 7q + r, 0 ≤ r < 7\nfor ALL ultrapower elements',
            transform=ax.transAxes, fontsize=8, va='top', ha='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # 2. GCD transfer
    ax = axes[0, 1]
    gcd_matrix = np.zeros((30, 30))
    for i in range(1, 31):
        for j in range(1, 31):
            gcd_matrix[i-1, j-1] = math.gcd(i, j)
    im = ax.imshow(gcd_matrix, cmap='YlOrRd', aspect='equal')
    ax.set_title('GCD Transfer: gcd(a,b) divides both', fontsize=11)
    ax.set_xlabel('b')
    ax.set_ylabel('a')
    plt.colorbar(im, ax=ax, label='gcd(a,b)')
    ax.text(0.5, -0.15, 'gcd(a,b) | a ∧ gcd(a,b) | b\nUniversal truth → transfers to ultrapower',
            transform=ax.transAxes, fontsize=8, ha='center',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # 3. Primality transfer
    ax = axes[1, 0]
    def is_prime(n):
        if n < 2:
            return False
        return all(n % k != 0 for k in range(2, int(n**0.5) + 1))

    primes = [n for n in range(2, N) if is_prime(n)]
    composites = [n for n in range(4, N) if not is_prime(n)]

    ax.scatter(primes, [1] * len(primes), c='#4CAF50', s=5, label='Primes', alpha=0.7)
    ax.scatter(composites, [0] * len(composites), c='#F44336', s=3, label='Composites', alpha=0.5)

    # Show prime gaps
    prime_gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]
    ax2 = ax.twinx()
    ax2.bar(primes[:-1], prime_gaps, width=1, alpha=0.2, color='blue', label='Prime gaps')
    ax2.set_ylabel('Gap size', color='blue', fontsize=9)

    ax.set_title('Primality: Primes & Composites Transfer', fontsize=11)
    ax.set_xlabel('n')
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['Composite', 'Prime'])
    ax.legend(fontsize=8, loc='upper right')
    ax.text(0.5, -0.15, 'Euclid transfer: ∃ prime q ∉ S\nfor any finite set S of primes',
            transform=ax.transAxes, fontsize=8, ha='center',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # 4. Non-Archimedean property
    ax = axes[1, 1]
    x = np.arange(1, 100)
    std_multiples = {(n, k): n * k for n in [1, 2, 5, 10] for k in range(1, 20)}
    f_values = x * (x + 1)  # non-standard element f(i) = i(i+1)

    ax.plot(x, f_values, 'r-', linewidth=2, label='f(i) = i·(i+1) [non-standard]')
    for n in [1, 2, 5, 10]:
        multiples = [n * k for k in range(1, 20)]
        ax.axhline(y=max(multiples), color='gray', linestyle=':', alpha=0.3)
        ax.text(95, n * 19 + 20, f'{n}·k ≤ {n*19}', fontsize=7, ha='right', color='gray')

    ax.set_title('Non-Archimedean: f exceeds n·k for all n,k', fontsize=11)
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.legend(fontsize=9)
    ax.set_ylim(0, 500)

    plt.tight_layout()
    plt.savefig('transfer_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to transfer_visualization.png")


if __name__ == "__main__":
    main()
