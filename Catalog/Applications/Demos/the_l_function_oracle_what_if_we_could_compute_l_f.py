#!/usr/bin/env python3
"""
Oracle Spectral Algebra — Demonstration Script

Demonstrates the key concepts from the L-Function Oracle research:
1. Dirichlet convolution of arithmetic functions
2. The oracle hierarchy and query complexity
3. Spectral factoring via Euler factor oracles
4. Vanishing order detection
"""

import math
from typing import Callable, List, Tuple

# ============================================================
# 1. Dirichlet Convolution
# ============================================================

def divisors(n: int) -> List[int]:
    """Return all positive divisors of n."""
    if n <= 0:
        return []
    divs = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def dirichlet_conv(f: Callable[[int], complex], g: Callable[[int], complex], n: int) -> complex:
    """Compute (f * g)(n) = sum_{d | n} f(d) g(n/d)."""
    return sum(f(d) * g(n // d) for d in divisors(n))


def dirichlet_id(n: int) -> complex:
    """The Dirichlet identity: ε(1) = 1, ε(n) = 0 for n > 1."""
    return 1.0 if n == 1 else 0.0


def zeta_coeff(n: int) -> complex:
    """Coefficients of the Riemann zeta function: a(n) = 1 for all n ≥ 1."""
    return 1.0 if n >= 1 else 0.0


print("=" * 60)
print("DEMONSTRATION 1: Dirichlet Convolution Identity")
print("=" * 60)
print("\nVerifying: (ε * f)(n) = f(n) for f = zeta coefficients")
for n in range(1, 11):
    conv_val = dirichlet_conv(dirichlet_id, zeta_coeff, n)
    direct_val = zeta_coeff(n)
    print(f"  n={n:2d}: (ε * ζ)(n) = {conv_val:.0f}, ζ(n) = {direct_val:.0f}, "
          f"match: {abs(conv_val - direct_val) < 1e-10}")


# ============================================================
# 2. Oracle Hierarchy & Query Complexity
# ============================================================

print("\n" + "=" * 60)
print("DEMONSTRATION 2: Oracle Hierarchy Query Complexity")
print("=" * 60)

def simulate_vanishing_order_detection(derivatives: List[complex]) -> int:
    """
    Given a list of derivative values [f(s₀), f'(s₀), f''(s₀), ...],
    detect the vanishing order (first nonzero index).
    """
    for k, val in enumerate(derivatives):
        if abs(val) > 1e-12:
            return k
    return len(derivatives)  # All zero up to this point


# Example: f(z) = z^3 at z=0 → vanishing order 3
# Derivatives: f(0)=0, f'(0)=0, f''(0)=0, f'''(0)=6
derivatives_z3 = [0.0, 0.0, 0.0, 6.0, 0.0]
order = simulate_vanishing_order_detection(derivatives_z3)
print(f"\nFor f(z) = z³ at z=0:")
print(f"  Derivatives: {derivatives_z3}")
print(f"  Detected vanishing order: {order}")
print(f"  Queries needed: {order + 1}")

# Example: f(z) = z^5 at z=0 → vanishing order 5
derivatives_z5 = [0.0, 0.0, 0.0, 0.0, 0.0, 120.0]
order5 = simulate_vanishing_order_detection(derivatives_z5)
print(f"\nFor f(z) = z⁵ at z=0:")
print(f"  Derivatives: {derivatives_z5}")
print(f"  Detected vanishing order: {order5}")
print(f"  Queries needed: {order5 + 1}")

print("\n→ Query complexity gap: detecting order r requires exactly r+1 queries")
print("  (The first r queries return 0 and are uninformative)")


# ============================================================
# 3. Spectral Factoring via Euler Factor Oracle
# ============================================================

print("\n" + "=" * 60)
print("DEMONSTRATION 3: Spectral Factoring from Euler Oracle")
print("=" * 60)


def euler_factor_oracle(p: int, n: int) -> int:
    """
    Simulated Euler factor oracle: returns p if p | n, else 0.
    In the real theory, this encodes the local factor of an L-function.
    """
    return p if n % p == 0 else 0


def spectral_factor(n: int) -> Tuple[int, int]:
    """
    Factor n using the Euler factor oracle.
    Query primes until we find one that divides n.
    """
    queries = 0
    for p in range(2, n):
        if not is_prime(p):
            continue
        queries += 1
        result = euler_factor_oracle(p, n)
        if result > 0:
            factor = math.gcd(result, n)
            print(f"  Query {queries}: oracle(p={p}, n={n}) = {result}")
            print(f"  gcd({result}, {n}) = {factor}")
            return (factor, n // factor)
    return (n, 1)


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


print("\nFactoring semiprimes using Euler factor oracle:")
for (p, q) in [(7, 13), (101, 103), (1009, 2003), (7919, 7927)]:
    n = p * q
    print(f"\n  n = {n} = {p} × {q}")
    result = spectral_factor(n)
    print(f"  Result: {result[0]} × {result[1]}")


# ============================================================
# 4. Multiplicative Function Reconstruction
# ============================================================

print("\n" + "=" * 60)
print("DEMONSTRATION 4: Spectral Reconstruction from Prime Powers")
print("=" * 60)


def reconstruct_multiplicative(prime_power_values: dict, n: int) -> complex:
    """
    Reconstruct f(n) from values at prime powers using multiplicativity.
    f(p₁^k₁ · p₂^k₂ · ... ) = f(p₁^k₁) · f(p₂^k₂) · ...
    """
    if n <= 0:
        return 0
    if n == 1:
        return 1

    result = 1.0
    temp = n
    for p in range(2, n + 1):
        if temp <= 1:
            break
        if temp % p == 0:
            pk = 1
            while temp % p == 0:
                pk *= p
                temp //= p
            result *= prime_power_values.get(pk, 0)
    return result


# The Liouville function λ(n) = (-1)^Ω(n)
# At prime powers: λ(p^k) = (-1)^k
liouville_pp = {}
for p in [2, 3, 5, 7, 11, 13]:
    pk = 1
    for k in range(1, 20):
        pk *= p
        if pk > 100:
            break
        liouville_pp[pk] = (-1) ** k

print("\nReconstructing the Liouville function from prime power values:")
print("λ(p^k) = (-1)^k")
for n in range(1, 21):
    reconstructed = reconstruct_multiplicative(liouville_pp, n)
    # Direct computation
    temp, omega = n, 0
    for p in range(2, n + 1):
        while temp % p == 0:
            omega += 1
            temp //= p
    direct = (-1) ** omega
    print(f"  λ({n:2d}) = {int(reconstructed):+d}  (direct: {direct:+d})  {'✓' if reconstructed == direct else '✗'}")


# ============================================================
# 5. Point Oracle Barrier Demonstration
# ============================================================

print("\n" + "=" * 60)
print("DEMONSTRATION 5: Point Oracle Barrier")
print("=" * 60)

print("\nThe barrier theorem: finitely many point evaluations CANNOT")
print("determine the vanishing order at a point not in the query set.")
print()

query_points = [0.5, 1.5, 2.0, 2.5, 3.0]
print(f"Query set Q = {query_points}")
print(f"Target point: z₀ = 1.0 (not in Q)")

# Two functions agreeing on Q but differing at z₀
F = lambda z: 0 if z in query_points else 1
G = lambda z: 0

print("\nFunction F(z) = 0 if z ∈ Q, else 1:")
for z in query_points:
    print(f"  F({z}) = {F(z)}")
print(f"  F(1.0) = {F(1.0)}  ← NONZERO (vanishing order 0)")

print("\nFunction G(z) = 0:")
for z in query_points:
    print(f"  G({z}) = {G(z)}")
print(f"  G(1.0) = {G(1.0)}  ← ZERO (different vanishing behavior)")

print("\n→ Point oracle CANNOT distinguish F from G!")
print("  This is why the derivative oracle is strictly more powerful.")


print("\n" + "=" * 60)
print("SUMMARY: Oracle Power Hierarchy")
print("=" * 60)
print("""
  Level 0: No Oracle
     |  (can compute nothing about L-functions)
     v
  Level 1: Point Evaluation Oracle
     |  (can evaluate L(s) but CANNOT detect zeros)
     |  Barrier: finitely many point queries cannot determine
     |           vanishing order (our barrier theorem)
     v
  Level 2: Derivative Oracle
     |  (can detect vanishing order = analytic rank)
     |  Enables: BSD analytic rank computation
     |  Query complexity: exactly r+1 queries for order r
     v
  Level 3: Zero-Certificate Oracle
     (can verify RH up to any finite height)
     Enables: Decidability of RH_T for all T

Each level is STRICTLY more powerful than the previous.
""")


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy and Query Complexity

Produces three plots:
1. Oracle hierarchy as a directed graph
2. Query complexity gap (derivative queries vs vanishing order)
3. Spectral reconstruction accuracy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def plot_query_complexity_gap():
    """Plot the derivative query gap: order r requires r+1 queries."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Query results for different vanishing orders
    max_order = 6
    for r in range(max_order + 1):
        queries = list(range(max_order + 2))
        results = [0.0] * r + [math.factorial(r)] + [0.0] * (max_order + 1 - r)
        ax1.scatter(queries, [r] * len(queries),
                   c=['red' if i < r else ('green' if i == r else 'gray') for i in queries],
                   s=100, zorder=5)
        ax1.plot([r, r], [-0.5, max_order + 0.5], 'k--', alpha=0.2)

    ax1.set_xlabel('Query index k (derivative order)', fontsize=12)
    ax1.set_ylabel('True vanishing order r', fontsize=12)
    ax1.set_title('Derivative Query Gap\n(Red = uninformative zero, Green = first nonzero)', fontsize=13)
    ax1.set_xlim(-0.5, max_order + 1.5)
    ax1.set_ylim(-0.5, max_order + 0.5)

    red_patch = mpatches.Patch(color='red', label='Query returns 0 (uninformative)')
    green_patch = mpatches.Patch(color='green', label='First nonzero (determines order)')
    gray_patch = mpatches.Patch(color='gray', label='Subsequent queries')
    ax1.legend(handles=[red_patch, green_patch, gray_patch], loc='upper left', fontsize=9)

    # Right: Query complexity function
    orders = list(range(0, 12))
    query_counts = [r + 1 for r in orders]

    ax2.bar(orders, query_counts, color='steelblue', alpha=0.8, edgecolor='navy')
    ax2.plot(orders, query_counts, 'ro-', markersize=6)
    ax2.set_xlabel('Vanishing order r', fontsize=12)
    ax2.set_ylabel('Queries needed (r + 1)', fontsize=12)
    ax2.set_title('Sharp Query Complexity Bound\n(Exactly r+1 derivative queries needed)', fontsize=13)

    plt.tight_layout()
    plt.savefig('query_complexity_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: query_complexity_gap.png")


def plot_spectral_reconstruction():
    """Plot spectral reconstruction of the Liouville function."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Compute Liouville function
    N = 50

    def omega(n):
        """Number of prime factors with multiplicity."""
        if n <= 1:
            return 0
        count = 0
        temp = n
        for p in range(2, n + 1):
            while temp % p == 0:
                count += 1
                temp //= p
        return count

    liouville = [(-1)**omega(n) for n in range(N + 1)]

    # Reconstruct from prime powers
    def reconstruct(n):
        if n <= 0:
            return 0
        if n == 1:
            return 1
        result = 1
        temp = n
        for p in range(2, n + 1):
            if temp <= 1:
                break
            k = 0
            while temp % p == 0:
                k += 1
                temp //= p
            if k > 0:
                result *= (-1)**k  # Liouville at prime power
        return result

    reconstructed = [reconstruct(n) for n in range(N + 1)]

    ns = list(range(1, N + 1))
    ax1.bar(ns, liouville[1:], color='steelblue', alpha=0.7, label='Direct λ(n)')
    ax1.scatter(ns, reconstructed[1:], color='red', s=20, zorder=5,
               label='Reconstructed from prime powers')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('λ(n)', fontsize=12)
    ax1.set_title('Spectral Reconstruction: Liouville Function\nRecovered from prime power values', fontsize=13)
    ax1.legend()

    # Cumulative sum (summatory Liouville)
    cumsum = np.cumsum(liouville[1:])
    ax2.plot(ns, cumsum, 'b-', linewidth=1.5, label='L(x) = Σ_{n≤x} λ(n)')
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.fill_between(ns, cumsum, 0, alpha=0.2, color='steelblue')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('L(x)', fontsize=12)
    ax2.set_title('Summatory Liouville Function\n(Related to RH: L(x) = O(x^{1/2+ε}) ⟺ RH)', fontsize=13)
    ax2.legend()

    plt.tight_layout()
    plt.savefig('spectral_reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_reconstruction.png")


def plot_oracle_hierarchy():
    """Plot the oracle hierarchy as a visual diagram."""
    fig, ax = plt.subplots(figsize=(10, 8))

    levels = [
        (0, 'No Oracle', 'Cannot access\nL-function data', '#e0e0e0'),
        (1, 'Point Evaluation', 'Evaluates L(s)\nCannot detect zeros', '#ffcdd2'),
        (2, 'Derivative Oracle', 'Detects vanishing order\nBSD analytic rank', '#c8e6c9'),
        (3, 'Zero Certificate', 'Decides RH up to height T\nComplete zero lists', '#bbdefb'),
    ]

    barriers = [
        (0.5, 'Cannot even evaluate', '#999'),
        (1.5, 'BARRIER: Point queries\ncannot detect vanishing order', '#d32f2f'),
        (2.5, 'BARRIER: Local derivatives\ncannot determine global zeros', '#d32f2f'),
    ]

    for y, name, desc, color in levels:
        rect = mpatches.FancyBboxPatch((1, y - 0.35), 6, 0.7,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(4, y + 0.1, f'Level {y}: {name}', ha='center', va='center',
               fontsize=14, fontweight='bold')
        ax.text(4, y - 0.15, desc, ha='center', va='center',
               fontsize=10, style='italic')

    for y, desc, color in barriers:
        ax.annotate('', xy=(4, y + 0.35), xytext=(4, y - 0.35),
                   arrowprops=dict(arrowstyle='->', color='green', lw=2))
        ax.text(8.5, y, desc, ha='center', va='center',
               fontsize=9, color=color, fontweight='bold',
               bbox=dict(boxstyle='round', facecolor='#fff3e0', edgecolor=color, alpha=0.8))

    ax.set_xlim(-0.5, 12)
    ax.set_ylim(-0.8, 3.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Oracle Spectral Algebra: The Oracle Hierarchy\n'
                '(Each level is strictly more powerful than the previous)',
                fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy.png")


if __name__ == "__main__":
    plot_oracle_hierarchy()
    plot_query_complexity_gap()
    plot_spectral_reconstruction()
    print("\nAll visualizations generated!")
