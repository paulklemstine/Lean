#!/usr/bin/env python3
"""
Holographic Depth Algebra: Numerical Demonstrations

Demonstrates key results from the Holographic Depth Algebra framework:
1. Complete additivity of log (depth function)
2. Local partition function properties
3. Holographic entropy bound
4. RG semigroup law
5. Holographic reconstruction
"""

import math
from typing import Dict, List, Tuple


def prime_factorization(n: int) -> Dict[int, int]:
    """Return prime factorization as {prime: exponent} dict."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def holographic_depth(n: int) -> float:
    """Compute holographic depth = log(n) = sum v_p(n) * log(p)."""
    if n <= 0:
        raise ValueError("n must be positive")
    return math.log(n)


def holographic_depth_from_boundary(n: int) -> float:
    """Compute depth from boundary data (prime factorization)."""
    if n <= 0:
        raise ValueError("n must be positive")
    if n == 1:
        return 0.0
    factors = prime_factorization(n)
    return sum(exp * math.log(p) for p, exp in factors.items())


def local_partition_fn(p: int, beta: float) -> float:
    """Z_p(beta) = (1 - p^{-beta})^{-1}."""
    return 1.0 / (1.0 - p ** (-beta))


def local_free_energy(p: int, beta: float) -> float:
    """F_p(beta) = log(1 - p^{-beta})."""
    return math.log(1.0 - p ** (-beta))


def boltzmann_weight(p: int, beta: float) -> float:
    """b_p(beta) = p^{-beta}."""
    return p ** (-beta)


def entropy_bound_rhs(p: int, beta: float) -> float:
    """x/(1-x) where x = p^{-beta}."""
    x = p ** (-beta)
    return x / (1.0 - x)


def arithmetic_rg(beta: float, f, n: int) -> float:
    """(R_beta f)(n) = f(n) * n^{-beta}."""
    return f(n) * n ** (-beta)


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n+1, i):
                sieve[j] = False
    return [i for i in range(2, n+1) if sieve[i]]


# ============================================================
# DEMO 1: Complete Additivity of Log
# ============================================================
print("=" * 60)
print("DEMO 1: Complete Additivity — depth(mn) = depth(m) + depth(n)")
print("=" * 60)

test_pairs = [(2, 3), (6, 7), (12, 15), (100, 37), (2, 2), (7, 11)]
for m, n in test_pairs:
    d_mn = holographic_depth(m * n)
    d_m = holographic_depth(m)
    d_n = holographic_depth(n)
    print(f"  depth({m}×{n}) = {d_mn:.6f},  depth({m})+depth({n}) = {d_m+d_n:.6f},  "
          f"diff = {abs(d_mn - d_m - d_n):.2e}")

# ============================================================
# DEMO 2: Holographic Reconstruction — Boundary Determines Bulk
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Holographic Reconstruction — Boundary → Bulk")
print("=" * 60)

for n in [1, 2, 6, 12, 60, 360, 2520, 10080]:
    direct = holographic_depth(n)
    from_boundary = holographic_depth_from_boundary(n)
    factors = prime_factorization(n) if n > 1 else {}
    fstr = " × ".join(f"{p}^{e}" for p, e in sorted(factors.items())) if factors else "1"
    print(f"  n={n:>5} = {fstr:>20}  |  log(n)={direct:.4f}  |  Σ v_p·log(p)={from_boundary:.4f}")

# ============================================================
# DEMO 3: Local Partition Function Properties
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Local Partition Function Z_p(β)")
print("=" * 60)

primes = [2, 3, 5, 7, 11]
betas = [0.5, 1.0, 2.0, 5.0]

print(f"  {'p':>3} | " + " | ".join(f"β={b:.1f}" for b in betas))
print("  " + "-" * 50)
for p in primes:
    vals = [local_partition_fn(p, b) for b in betas]
    print(f"  {p:>3} | " + " | ".join(f"{v:>7.4f}" for v in vals))

print("\n  All Z_p(β) > 1 for β > 0: ✓" if all(
    local_partition_fn(p, b) > 1 for p in primes for b in betas
) else "  FAILED!")

# ============================================================
# DEMO 4: Holographic Entropy Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Holographic Entropy Bound: -F_p(β) ≤ p^{-β}/(1-p^{-β})")
print("=" * 60)

for p in [2, 3, 5, 7]:
    for beta in [0.5, 1.0, 2.0, 5.0]:
        lhs = -local_free_energy(p, beta)
        rhs = entropy_bound_rhs(p, beta)
        satisfied = lhs <= rhs + 1e-15  # numerical tolerance
        print(f"  p={p}, β={beta:.1f}: -F={lhs:.6f} ≤ {rhs:.6f} {'✓' if satisfied else '✗'}")

# ============================================================
# DEMO 5: RG Semigroup Law
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: RG Semigroup — R_α(R_β f) = R_{α+β} f")
print("=" * 60)

f = lambda n: float(n)  # test function f(n) = n

for alpha, beta in [(1.0, 2.0), (0.5, 1.5), (0.3, 0.7)]:
    for n in [2, 5, 10, 100]:
        lhs = arithmetic_rg(alpha, lambda m: arithmetic_rg(beta, f, m), n)
        rhs = arithmetic_rg(alpha + beta, f, n)
        print(f"  α={alpha}, β={beta}, n={n}: R_α∘R_β={lhs:.6f}, R_{{α+β}}={rhs:.6f}, "
              f"diff={abs(lhs-rhs):.2e}")

# ============================================================
# DEMO 6: Euler Product Approximation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Euler Product ζ(s) = Π_p (1-p^{-s})^{-1}")
print("=" * 60)

for s in [2.0, 3.0, 4.0]:
    # Exact values
    exact = {2.0: math.pi**2/6, 3.0: 1.2020569031595942, 4.0: math.pi**4/90}
    primes_list = primes_up_to(1000)
    product = 1.0
    for p in primes_list:
        product *= local_partition_fn(p, s)
    print(f"  ζ({s:.0f}): Euler product (primes≤1000) = {product:.10f}, "
          f"exact = {exact[s]:.10f}, error = {abs(product - exact[s]):.2e}")

# ============================================================
# DEMO 7: Spectral Gap
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Spectral Gap = log(2) ≈ {:.6f}".format(math.log(2)))
print("=" * 60)

print(f"  Minimum depth increment (multiplying by 2):")
for n in [1, 3, 5, 7, 100]:
    gap = holographic_depth(2*n) - holographic_depth(n)
    print(f"    depth(2·{n}) - depth({n}) = {gap:.6f} = log(2)? {'✓' if abs(gap - math.log(2)) < 1e-10 else '✗'}")

print(f"\n  Depth separation for consecutive integers:")
for n in range(1, 11):
    sep = holographic_depth(n+1) - holographic_depth(n)
    print(f"    depth({n+1}) - depth({n}) = {sep:.6f} > 0? {'✓' if sep > 0 else '✗'}")

# ============================================================
# DEMO 8: Conjecture — Prime Reciprocal Divergence
# ============================================================
print("\n" + "=" * 60)
print("DEMO 8: ∑ 1/p Diverges (Infinite Boundary Area)")
print("=" * 60)

cumulative = 0.0
for bound in [10, 100, 1000, 10000, 100000]:
    ps = primes_up_to(bound)
    cumulative = sum(1.0/p for p in ps)
    print(f"  ∑_{{p≤{bound:>6}}} 1/p = {cumulative:.6f}  ({len(ps)} primes)")

print("\n  Rate of growth ~ log(log(x)), confirming divergence.")
print(f"  log(log(100000)) = {math.log(math.log(100000)):.4f}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Euler product convergence and holographic factorization."""

import math

def sieve(n):
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n+1, i):
                s[j] = False
    return [i for i in range(2, n+1) if s[i]]

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy required")
        return

    primes = sieve(10000)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Euler product convergence
    ax = axes[0, 0]
    for s_val, color, label in [(2.0, '#e41a1c', 'ζ(2)'),
                                  (3.0, '#377eb8', 'ζ(3)'),
                                  (4.0, '#4daf4a', 'ζ(4)')]:
        exact = {2.0: math.pi**2/6, 3.0: 1.2020569031595942, 4.0: math.pi**4/90}[s_val]
        products = []
        prod_val = 1.0
        for p in primes[:200]:
            prod_val *= 1.0 / (1.0 - p ** (-s_val))
            products.append(prod_val)
        ax.plot(range(1, len(products)+1), products, color=color, label=label, linewidth=1.5)
        ax.axhline(y=exact, color=color, linestyle='--', alpha=0.4)

    ax.set_xlabel('Number of primes in product')
    ax.set_ylabel('Partial Euler product')
    ax.set_title('Euler Product Convergence')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Holographic depth spectrum
    ax = axes[0, 1]
    depths = [math.log(n) for n in range(1, 101)]
    colors_arr = []
    for n in range(1, 101):
        f = {}
        m = n
        d = 2
        while d * d <= m:
            while m % d == 0:
                f[d] = f.get(d, 0) + 1
                m //= d
            d += 1
        if m > 1:
            f[m] = f.get(m, 0) + 1
        colors_arr.append(len(f))  # number of distinct prime factors

    scatter = ax.scatter(range(1, 101), depths, c=colors_arr, cmap='viridis',
                          s=20, alpha=0.8)
    ax.set_xlabel('n')
    ax.set_ylabel('depth(n) = log(n)')
    ax.set_title('Holographic Depth Spectrum')
    plt.colorbar(scatter, ax=ax, label='ω(n) = distinct prime factors')
    ax.grid(True, alpha=0.3)

    # Plot 3: Spectral gaps
    ax = axes[1, 0]
    gaps = [math.log(n+1) - math.log(n) for n in range(1, 200)]
    ax.bar(range(1, 200), gaps, width=1.0, alpha=0.7, color='#377eb8')
    ax.axhline(y=math.log(2), color='red', linestyle='--', linewidth=2, label='log(2) = spectral gap')
    ax.set_xlabel('n')
    ax.set_ylabel('log(n+1) - log(n)')
    ax.set_title('Depth Gaps (Spectral Structure)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 0.8)

    # Plot 4: Prime reciprocal sum divergence
    ax = axes[1, 1]
    bounds = [10, 50, 100, 500, 1000, 5000, 10000]
    partial_sums = []
    for b in bounds:
        ps = sieve(b)
        partial_sums.append(sum(1.0/p for p in ps))

    ax.semilogx(bounds, partial_sums, 'o-', color='#e41a1c', linewidth=2, markersize=6)
    loglog_vals = [math.log(math.log(b)) for b in bounds]
    ax.semilogx(bounds, loglog_vals, '--', color='gray', linewidth=1, label='log(log(x))')
    ax.set_xlabel('x')
    ax.set_ylabel('∑_{p≤x} 1/p')
    ax.set_title('Divergence of Prime Reciprocals (Infinite Boundary)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('holographic_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved holographic_analysis.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Local Partition Functions Z_p(beta) for various primes."""

import math

def local_partition_fn(p, beta):
    return 1.0 / (1.0 - p ** (-beta))

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy required for visualization")
        return

    betas = np.linspace(0.1, 5.0, 500)
    primes = [2, 3, 5, 7, 11, 13]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Z_p(beta)
    for p, c in zip(primes, colors):
        zvals = [local_partition_fn(p, b) for b in betas]
        ax1.plot(betas, zvals, color=c, label=f'p={p}', linewidth=2)

    ax1.set_xlabel('β (inverse temperature)', fontsize=12)
    ax1.set_ylabel('Z_p(β)', fontsize=12)
    ax1.set_title('Local Partition Functions', fontsize=14)
    ax1.set_ylim(0, 10)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

    # Plot 2: Free energy -F_p(beta) vs entropy bound
    for p, c in zip(primes[:4], colors[:4]):
        free_energies = [-math.log(1.0 - p**(-b)) for b in betas]
        bounds = [p**(-b) / (1.0 - p**(-b)) for b in betas]
        ax2.plot(betas, free_energies, color=c, linewidth=2, label=f'-F_{p}(β)')
        ax2.plot(betas, bounds, color=c, linewidth=1, linestyle='--', alpha=0.6)

    ax2.set_xlabel('β (inverse temperature)', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Holographic Entropy Bound: -F_p(β) ≤ p⁻ᵝ/(1-p⁻ᵝ)', fontsize=14)
    ax2.set_ylim(0, 3)
    ax2.legend(fontsize=9, loc='upper right')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('holographic_partition_functions.png', dpi=150, bbox_inches='tight')
    print("Saved holographic_partition_functions.png")

if __name__ == "__main__":
    main()
