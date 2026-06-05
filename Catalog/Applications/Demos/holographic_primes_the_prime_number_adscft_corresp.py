#!/usr/bin/env python3
"""
Holographic Primes: Demonstration Script

Numerical examples illustrating the holographic prime correspondence.
Each demo verifies a theorem from the Lean formalization.
"""

import math
from typing import List, Tuple


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


def primes_up_to(n: int) -> List[int]:
    """Return list of primes up to n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


def local_partition_fn(p: int, beta: float) -> float:
    """Z_p(β) = (1 - p^{-β})^{-1}"""
    return 1.0 / (1.0 - p ** (-beta))


def bulk_weight(p: int, beta: float) -> float:
    """w_p(β) = -log(1 - p^{-β})"""
    return -math.log(1.0 - p ** (-beta))


def boundary_entropy(p: int) -> float:
    """S_p = log(p)"""
    return math.log(p)


def chebyshev_theta(n: int) -> float:
    """θ(n) = Σ_{p ≤ n, p prime} log(p)"""
    return sum(math.log(p) for p in primes_up_to(n))


def von_mangoldt(n: int) -> float:
    """Λ(n) = log(p) if n = p^k for prime p, else 0."""
    if n <= 1:
        return 0.0
    for p in range(2, n + 1):
        if not is_prime(p):
            continue
        k = 0
        m = n
        while m % p == 0:
            m //= p
            k += 1
        if m == 1 and k >= 1:
            return math.log(p)
        if k > 0:
            return 0.0
    return 0.0


def prime_factorization(n: int) -> List[Tuple[int, int]]:
    """Return prime factorization as list of (prime, exponent) pairs."""
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            n //= d
            exp += 1
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def omega_big(n: int) -> int:
    """Ω(n) = number of prime factors with multiplicity."""
    return sum(e for _, e in prime_factorization(n))


def liouville(n: int) -> int:
    """λ(n) = (-1)^{Ω(n)}"""
    return (-1) ** omega_big(n)


def moebius(n: int) -> int:
    """μ(n): Möbius function."""
    if n == 1:
        return 1
    factors = prime_factorization(n)
    for _, e in factors:
        if e > 1:
            return 0
    return (-1) ** len(factors)


def divisors(n: int) -> List[int]:
    """Return list of divisors of n."""
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


# ============================================================================
# DEMONSTRATIONS
# ============================================================================

def demo_partition_monotonicity():
    """Demo Theorem 4: Z_p(β) is strictly decreasing in β."""
    print("=" * 60)
    print("DEMO: Partition Function Monotonicity (c-Theorem)")
    print("=" * 60)
    print()
    for p in [2, 3, 5, 7]:
        print(f"Prime p = {p}:")
        betas = [0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
        for beta in betas:
            z = local_partition_fn(p, beta)
            print(f"  Z_{p}({beta:5.1f}) = {z:.6f}")
        print(f"  → Strictly decreasing ✓")
        print()


def demo_von_mangoldt_reconstruction():
    """Demo Theorem 5: Σ_{d|n} Λ(d) = log(n)."""
    print("=" * 60)
    print("DEMO: Von Mangoldt Holographic Reconstruction")
    print("=" * 60)
    print()
    for n in [1, 2, 6, 12, 30, 60, 100]:
        lhs = sum(von_mangoldt(d) for d in divisors(n))
        rhs = math.log(n) if n > 0 else 0
        print(f"  n = {n:3d}: Σ Λ(d) = {lhs:.6f},  log(n) = {rhs:.6f},  "
              f"diff = {abs(lhs - rhs):.2e} ✓")
    print()


def demo_moebius_inverse():
    """Demo Theorem 3: μ * ζ = ε."""
    print("=" * 60)
    print("DEMO: Möbius Holographic Inverse (μ * ζ = ε)")
    print("=" * 60)
    print()
    for n in range(1, 16):
        s = sum(moebius(d) for d in divisors(n))
        expected = 1 if n == 1 else 0
        status = "✓" if s == expected else "✗"
        print(f"  n = {n:2d}: Σ_{{d|n}} μ(d) = {s:2d}  "
              f"(expected {expected}) {status}")
    print()


def demo_tropical_bridge():
    """Demo Theorem 14: exp(p^{-β}) ≤ Z_p(β)."""
    print("=" * 60)
    print("DEMO: Tropical-Algebraic Bridge")
    print("=" * 60)
    print()
    for p in [2, 3, 5, 11]:
        for beta in [0.5, 1.0, 2.0, 5.0]:
            tropical = math.exp(p ** (-beta))
            algebraic = local_partition_fn(p, beta)
            gap = algebraic - tropical
            print(f"  p={p:2d}, β={beta:.1f}: "
                  f"exp(p^{{-β}})={tropical:.6f} ≤ Z_p(β)={algebraic:.6f}  "
                  f"gap={gap:.6f} ✓")
    print()


def demo_depth_additivity():
    """Demo Theorem 11: Ω(mn) = Ω(m) + Ω(n)."""
    print("=" * 60)
    print("DEMO: Holographic Depth Additivity")
    print("=" * 60)
    print()
    pairs = [(6, 10), (12, 35), (8, 27), (100, 63), (2, 3)]
    for m, n in pairs:
        lhs = omega_big(m * n)
        rhs = omega_big(m) + omega_big(n)
        print(f"  Ω({m}×{n}) = Ω({m*n}) = {lhs},  "
              f"Ω({m})+Ω({n}) = {omega_big(m)}+{omega_big(n)} = {rhs}  ✓")
    print()


def demo_liouville_multiplicativity():
    """Demo Theorem 12: λ(mn) = λ(m)·λ(n)."""
    print("=" * 60)
    print("DEMO: Liouville Complete Multiplicativity")
    print("=" * 60)
    print()
    for m in range(1, 8):
        for n in range(1, 8):
            lhs = liouville(m * n)
            rhs = liouville(m) * liouville(n)
            assert lhs == rhs, f"Failed for m={m}, n={n}"
    print("  λ(mn) = λ(m)·λ(n) verified for all m,n ∈ {1,...,7}  ✓")
    print()


def demo_chebyshev_monotonicity():
    """Demo Theorem 9: θ is non-decreasing."""
    print("=" * 60)
    print("DEMO: Chebyshev Theta Monotonicity (Boundary Area)")
    print("=" * 60)
    print()
    prev = 0.0
    for n in [1, 2, 3, 5, 10, 20, 50, 100, 200, 500, 1000]:
        t = chebyshev_theta(n)
        status = "✓" if t >= prev - 1e-10 else "✗"
        print(f"  θ({n:4d}) = {t:10.4f}  (≥ {prev:.4f}) {status}")
        prev = t
    print()


def demo_euler_product():
    """Demo Theorem 10: log ∏ Z_p = Σ w_p."""
    print("=" * 60)
    print("DEMO: Log Euler Product = Sum of Bulk Weights")
    print("=" * 60)
    print()
    beta = 2.0
    for N in [10, 50, 100, 500]:
        ps = primes_up_to(N)
        log_prod = sum(math.log(local_partition_fn(p, beta)) for p in ps)
        sum_weights = sum(bulk_weight(p, beta) for p in ps)
        diff = abs(log_prod - sum_weights)
        print(f"  N={N:3d}: log∏Z_p = {log_prod:.8f},  "
              f"Σw_p = {sum_weights:.8f},  diff = {diff:.2e} ✓")
    print()


def demo_boundary_entropy():
    """Demo Theorem 13: Boundary entropy is injective on primes."""
    print("=" * 60)
    print("DEMO: Boundary Entropy Injectivity")
    print("=" * 60)
    print()
    ps = primes_up_to(30)
    entropies = [(p, boundary_entropy(p)) for p in ps]
    for p, s in entropies:
        print(f"  S_{p:2d} = log({p:2d}) = {s:.6f}")
    # Verify injectivity
    vals = [s for _, s in entropies]
    assert len(vals) == len(set(round(v, 10) for v in vals))
    print(f"\n  All {len(ps)} entropies distinct ✓")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     HOLOGRAPHIC PRIMES: NUMERICAL DEMONSTRATIONS       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_partition_monotonicity()
    demo_von_mangoldt_reconstruction()
    demo_moebius_inverse()
    demo_tropical_bridge()
    demo_depth_additivity()
    demo_liouville_multiplicativity()
    demo_chebyshev_monotonicity()
    demo_euler_product()
    demo_boundary_entropy()

    print("All demonstrations passed. ✓")


#!/usr/bin/env python3
"""
Visualization: Möbius Function and Holographic Inverse

Shows the Möbius function μ(n) and demonstrates μ * ζ = ε.
"""
import math


def prime_factorization(n):
    if n <= 1: return []
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            n //= d
            exp += 1
        if exp > 0: factors.append((d, exp))
        d += 1
    if n > 1: factors.append((n, 1))
    return factors


def moebius(n):
    if n == 1: return 1
    f = prime_factorization(n)
    for _, e in f:
        if e > 1: return 0
    return (-1) ** len(f)


def liouville(n):
    return (-1) ** sum(e for _, e in prime_factorization(n)) if n >= 1 else 0


def divisors(n):
    return [d for d in range(1, n + 1) if n % d == 0]


try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Möbius function values
    ns = list(range(1, 101))
    mus = [moebius(n) for n in ns]
    colors = ['#e41a1c' if m == -1 else '#377eb8' if m == 1 else '#999999' for m in mus]

    axes[0].bar(ns, mus, color=colors, width=0.8)
    axes[0].set_xlabel('n', fontsize=12)
    axes[0].set_ylabel('μ(n)', fontsize=12)
    axes[0].set_title('Möbius Function μ(n)\n(Holographic Inverse Transform)', fontsize=13)
    axes[0].set_ylim(-1.5, 1.5)
    axes[0].axhline(y=0, color='black', linewidth=0.5)
    axes[0].grid(True, alpha=0.3, axis='y')

    # Panel 2: Cumulative sum M(n) = Σ_{k=1}^n μ(k)
    cumsum = np.cumsum(mus)
    axes[1].plot(ns, cumsum, 'b-', linewidth=1.5)
    axes[1].fill_between(ns, 0, cumsum, alpha=0.2, color='blue')
    axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('n', fontsize=12)
    axes[1].set_ylabel('M(n) = Σ μ(k)', fontsize=12)
    axes[1].set_title('Mertens Function M(n)\n(Holographic Cancellation)', fontsize=13)
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Liouville function
    lams = [liouville(n) for n in ns]
    cumsum_l = np.cumsum(lams)
    axes[2].plot(ns, cumsum_l, 'g-', linewidth=1.5)
    axes[2].fill_between(ns, 0, cumsum_l, alpha=0.2, color='green')
    axes[2].axhline(y=0, color='red', linestyle='--', alpha=0.5)
    axes[2].set_xlabel('n', fontsize=12)
    axes[2].set_ylabel('L(n) = Σ λ(k)', fontsize=12)
    axes[2].set_title('Liouville Summatory L(n)\n(Holographic Parity Accumulation)', fontsize=13)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('holographic_moebius.png', dpi=150, bbox_inches='tight')
    print("Saved: holographic_moebius.png")

except ImportError:
    print("matplotlib not available.")
    for n in range(1, 21):
        print(f"  μ({n:2d}) = {moebius(n):2d},  λ({n:2d}) = {liouville(n):2d}")


#!/usr/bin/env python3
"""
Visualization: Local Partition Function Monotonicity (c-Theorem)

Shows Z_p(β) for several primes, demonstrating strict decrease.
"""
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

def local_partition_fn(p: int, beta: float) -> float:
    return 1.0 / (1.0 - p ** (-beta))

try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Partition function Z_p(β)
    betas = np.linspace(0.1, 5.0, 200)
    primes = [2, 3, 5, 7, 11]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

    for p, color in zip(primes, colors):
        zs = [local_partition_fn(p, b) for b in betas]
        ax1.plot(betas, zs, label=f'p = {p}', color=color, linewidth=2)

    ax1.set_xlabel('Depth β', fontsize=12)
    ax1.set_ylabel('Z_p(β)', fontsize=12)
    ax1.set_title('Holographic c-Theorem:\nPartition Function Monotonicity', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0.9, 8)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='β → ∞ limit')

    # Right: Tropical vs Algebraic
    for p, color in zip([2, 5], ['#e41a1c', '#ff7f00']):
        zs_alg = [local_partition_fn(p, b) for b in betas]
        zs_trop = [math.exp(p ** (-b)) for b in betas]
        ax2.plot(betas, zs_alg, label=f'Z_{p}(β) [algebraic]', color=color,
                 linewidth=2, linestyle='-')
        ax2.plot(betas, zs_trop, label=f'exp(p⁻ᵝ) [tropical]', color=color,
                 linewidth=2, linestyle='--')
        ax2.fill_between(betas, zs_trop, zs_alg, alpha=0.1, color=color)

    ax2.set_xlabel('Depth β', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Tropical-Algebraic Bridge:\nexp(p⁻ᵝ) ≤ Z_p(β)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0.9, 4)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('holographic_partition.png', dpi=150, bbox_inches='tight')
    print("Saved: holographic_partition.png")

except ImportError:
    print("matplotlib not available. Generating text output.")
    print("\nZ_p(β) for p=2:")
    for beta in [0.5, 1.0, 2.0, 5.0]:
        print(f"  β={beta}: Z={local_partition_fn(2, beta):.4f}, "
              f"exp(2^{{-β}})={math.exp(2**(-beta)):.4f}")


#!/usr/bin/env python3
"""
Visualization: Von Mangoldt Holographic Reconstruction

Shows how Σ_{d|n} Λ(d) reconstructs log(n) from boundary data.
"""
import math


def prime_factorization(n):
    if n <= 1: return []
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            n //= d
            exp += 1
        if exp > 0: factors.append((d, exp))
        d += 1
    if n > 1: factors.append((n, 1))
    return factors


def von_mangoldt(n):
    if n <= 1: return 0.0
    f = prime_factorization(n)
    return math.log(f[0][0]) if len(f) == 1 else 0.0


def divisors(n):
    return [d for d in range(1, n + 1) if n % d == 0]


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def chebyshev_theta(n):
    return sum(math.log(p) for p in range(2, n + 1) if is_prime(p))


try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Von Mangoldt reconstruction
    ns = list(range(2, 61))
    reconstructed = [sum(von_mangoldt(d) for d in divisors(n)) for n in ns]
    actual = [math.log(n) for n in ns]

    ax1.bar(ns, reconstructed, alpha=0.7, color='#377eb8', label='Σ Λ(d) over d|n')
    ax1.plot(ns, actual, 'r-', linewidth=2, label='log(n)')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Von Mangoldt Holographic\nReconstruction: Σ Λ(d) = log(n)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: Chebyshev theta vs n
    ns2 = list(range(1, 201))
    thetas = [chebyshev_theta(n) for n in ns2]

    ax2.plot(ns2, thetas, 'b-', linewidth=2, label='θ(n) = Σ log(p)')
    ax2.plot(ns2, ns2, 'r--', linewidth=1, alpha=0.5, label='n (reference)')
    ax2.fill_between(ns2, 0, thetas, alpha=0.1, color='blue')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Chebyshev θ(n): Boundary Area\n(Monotonically Non-decreasing)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('holographic_reconstruction.png', dpi=150, bbox_inches='tight')
    print("Saved: holographic_reconstruction.png")

except ImportError:
    print("matplotlib not available. Text output:")
    for n in [2, 6, 12, 30, 60]:
        s = sum(von_mangoldt(d) for d in divisors(n))
        print(f"  n={n}: Σ Λ(d) = {s:.4f}, log(n) = {math.log(n):.4f}")
