#!/usr/bin/env python3
"""
Diophantine Approximation of π by ReLU Networks: Numerical Demonstrations

This script demonstrates the key results from the formalized theory:
1. Leibniz series convergence to π/4
2. ReLU network approximation quality
3. Comparison of rational approximations (22/7, 355/113, Leibniz partial sums)
4. The Diophantine approximation spectrum
"""

import math
from typing import List, Tuple


def relu(x: float) -> float:
    """ReLU activation: max(0, x)"""
    return max(0.0, x)


def leibniz_term(k: int) -> float:
    """k-th term of the Leibniz series: (-1)^k / (2k+1)"""
    return (-1)**k / (2*k + 1)


def leibniz_partial_sum(n: int) -> float:
    """n-th partial sum of the Leibniz series for π/4"""
    return sum(leibniz_term(k) for k in range(n))


def leibniz_pi_approx(n: int) -> float:
    """Approximate π using n terms of the Leibniz series"""
    return 4 * leibniz_partial_sum(n)


def leibniz_error_bound(n: int) -> float:
    """Theoretical error bound: 4/(2n+1)"""
    return 4.0 / (2*n + 1)


def diophantine_spectrum(alpha: float, D: int) -> float:
    """
    Compute the Diophantine approximation spectrum of alpha at denominator bound D.
    Returns min_{0 < q ≤ D, p ∈ Z} |alpha - p/q|
    """
    best = float('inf')
    for q in range(1, D + 1):
        p = round(alpha * q)
        err = abs(alpha - p / q)
        best = min(best, err)
    return best


def max_pieces(n: int) -> int:
    """Maximum number of linear pieces for n ReLU operations"""
    if n == 0:
        return 1
    return 2 * max_pieces(n - 1) + 1


# ============================================================
# Demo 1: Leibniz Series Convergence
# ============================================================
print("=" * 70)
print("DEMO 1: Leibniz Series Convergence to π")
print("=" * 70)
print(f"\nTrue π = {math.pi:.15f}\n")
print(f"{'n':>8} {'4·S_n':>20} {'|4·S_n - π|':>20} {'Bound 4/(2n+1)':>20}")
print("-" * 70)

for n in [1, 2, 5, 10, 20, 50, 100, 500, 1000, 5000]:
    approx = leibniz_pi_approx(n)
    actual_err = abs(approx - math.pi)
    bound = leibniz_error_bound(n)
    print(f"{n:>8} {approx:>20.15f} {actual_err:>20.2e} {bound:>20.2e}")
    assert actual_err <= bound, f"Error bound violated at n={n}!"

print("\n✓ All error bounds verified: |4·S_n - π| ≤ 4/(2n+1)")

# ============================================================
# Demo 2: Famous Rational Approximations to π
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Rational Approximations to π (Diophantine Complexity)")
print("=" * 70)

approximations = [
    ("3/1", 3, 1),
    ("22/7", 22, 7),
    ("333/106", 333, 106),
    ("355/113", 355, 113),
    ("103993/33102", 103993, 33102),
    ("104348/33215", 104348, 33215),
]

print(f"\n{'Fraction':>20} {'Value':>20} {'|error|':>15} {'1/q²':>15}")
print("-" * 70)

for name, p, q in approximations:
    val = p / q
    err = abs(math.pi - val)
    roth_bound = 1.0 / (q * q)
    print(f"{name:>20} {val:>20.15f} {err:>15.2e} {roth_bound:>15.2e}")

print("\nNote: By Roth's theorem (μ(π) ≤ 7.6063...), |π - p/q| > c/q^{7.61}")
print("The convergents of π's continued fraction achieve near-optimal approximation.")

# ============================================================
# Demo 3: ReLU Network Piece Count
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: ReLU Network Expressiveness (Piece Count Bounds)")
print("=" * 70)
print(f"\n{'Depth d':>10} {'maxPieces(d)':>15} {'2^d (lower)':>15} {'2^(d+1)-1 (upper)':>20}")
print("-" * 62)

for d in range(11):
    mp = max_pieces(d)
    lower = 2**d
    upper = 2**(d+1) - 1
    assert lower <= mp <= upper, f"Bounds violated at d={d}!"
    print(f"{d:>10} {mp:>15} {lower:>15} {upper:>20}")

print("\n✓ Verified: 2^d ≤ maxPieces(d) ≤ 2^(d+1) - 1 for all d shown")

# ============================================================
# Demo 4: Diophantine Spectrum
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Diophantine Approximation Spectrum of π")
print("=" * 70)
print(f"\n{'D':>10} {'Spectrum(π, D)':>20} {'Best p/q':>20}")
print("-" * 52)

for D in [1, 2, 3, 5, 7, 10, 20, 50, 100, 113, 500, 1000]:
    spec = diophantine_spectrum(math.pi, D)
    # Find the best approximation
    best_p, best_q = 3, 1
    best_err = abs(math.pi - 3)
    for q in range(1, D + 1):
        p = round(math.pi * q)
        err = abs(math.pi - p / q)
        if err < best_err:
            best_p, best_q, best_err = p, q, err
    print(f"{D:>10} {spec:>20.2e} {best_p:>10}/{best_q:<10}")

# ============================================================
# Demo 5: Convergence Rate Comparison
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: How Many Leibniz Terms to Match Famous Approximations?")
print("=" * 70)

targets = [
    ("22/7 precision", abs(math.pi - 22/7)),
    ("355/113 precision", abs(math.pi - 355/113)),
    ("6 decimal places", 1e-6),
    ("10 decimal places", 1e-10),
]

for name, target_err in targets:
    # Find minimum n such that leibniz achieves this error
    for n in range(1, 100001):
        if abs(leibniz_pi_approx(n) - math.pi) < target_err:
            break
    else:
        n = ">100000"
    print(f"  To match {name:25s} (ε = {target_err:.2e}): n = {n}")

print("\n" + "=" * 70)
print("KEY INSIGHT: The Leibniz series converges as O(1/n),")
print("so achieving ε-approximation requires n = O(1/ε) terms.")
print("A ReLU network with constant parameters can represent any")
print("partial sum, giving O(1/ε) parameter complexity for π.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Leibniz Series Convergence to π
Shows the approximation error as a function of the number of terms,
compared to the theoretical bound 4/(2n+1).
"""
import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    ns = np.arange(1, 501)
    errors = np.array([abs(4 * sum((-1)**k / (2*k+1) for k in range(n)) - math.pi) for n in ns])
    bounds = 4.0 / (2 * ns + 1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: log-log plot
    ax1.loglog(ns, errors, 'b-', alpha=0.7, label='Actual error |4·Sₙ - π|', linewidth=0.8)
    ax1.loglog(ns, bounds, 'r--', alpha=0.8, label='Bound 4/(2n+1)', linewidth=1.5)
    ax1.loglog(ns, 2.0/ns, 'g:', alpha=0.6, label='2/n (proved bound)', linewidth=1.5)
    ax1.set_xlabel('Number of terms n', fontsize=12)
    ax1.set_ylabel('Approximation error', fontsize=12)
    ax1.set_title('Leibniz Series: Convergence Rate', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Famous approximations comparison
    famous = {
        '3': (3, 1),
        '22/7': (22, 7),
        '333/106': (333, 106),
        '355/113': (355, 113),
    }

    ax2.loglog(ns, errors, 'b-', alpha=0.5, label='Leibniz', linewidth=0.8)
    for name, (p, q) in famous.items():
        err = abs(math.pi - p/q)
        # Find equivalent n
        for n_eq in range(1, 10000):
            if abs(4 * sum((-1)**k / (2*k+1) for k in range(n_eq)) - math.pi) < err:
                break
        ax2.axhline(y=err, color='gray', linestyle=':', alpha=0.3)
        ax2.annotate(f'{name}\n(q={q}, n≈{n_eq})', xy=(n_eq, err),
                    fontsize=8, ha='center', va='bottom',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))
        ax2.plot(n_eq, err, 'ro', markersize=6)

    ax2.set_xlabel('Equivalent Leibniz terms n', fontsize=12)
    ax2.set_ylabel('Approximation error', fontsize=12)
    ax2.set_title('Leibniz vs. Famous Rational Approximations', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/viz_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved viz_convergence.png")

except ImportError:
    print("matplotlib not available, skipping visualization")


#!/usr/bin/env python3
"""
Visualization: ReLU Network Piece Count and Expressiveness
Shows the exponential growth of piecewise linear complexity with depth.
"""

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    def max_pieces(n):
        if n == 0:
            return 1
        return 2 * max_pieces(n - 1) + 1

    depths = list(range(0, 16))
    pieces = [max_pieces(d) for d in depths]
    lower = [2**d for d in depths]
    upper = [2**(d+1) - 1 for d in depths]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Piece count growth
    ax1.semilogy(depths, pieces, 'bo-', label='maxPieces(d)', markersize=6)
    ax1.semilogy(depths, lower, 'g^--', label='2^d (lower bound)', markersize=5, alpha=0.7)
    ax1.semilogy(depths, upper, 'rv--', label='2^(d+1)-1 (upper bound)', markersize=5, alpha=0.7)
    ax1.fill_between(depths, lower, upper, alpha=0.1, color='blue')
    ax1.set_xlabel('Depth d (number of ReLU layers)', fontsize=12)
    ax1.set_ylabel('Maximum linear pieces', fontsize=12)
    ax1.set_title('Exponential Growth of Network Expressiveness', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: What this means for approximation
    # To approximate π within ε, need enough pieces to represent the Leibniz sum
    epsilons = np.logspace(-1, -10, 100)
    terms_needed = np.ceil(2.0 / epsilons)  # n ≈ 2/ε from Leibniz

    # Depth needed: 2^d ≥ n, so d ≥ log2(n)
    depth_needed = np.ceil(np.log2(terms_needed))

    ax2.loglog(epsilons, terms_needed, 'b-', label='Leibniz terms n = O(1/ε)', linewidth=2)
    ax2.loglog(epsilons, depth_needed, 'r-', label='Depth d = O(log(1/ε))', linewidth=2)
    ax2.loglog(epsilons, np.log2(np.log2(terms_needed + 1) + 1), 'g-',
               label='Layers L = O(log log(1/ε))', linewidth=2)
    ax2.set_xlabel('Approximation error ε', fontsize=12)
    ax2.set_ylabel('Network complexity', fontsize=12)
    ax2.set_title('ReLU Network Resources for π Approximation', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.invert_xaxis()

    plt.tight_layout()
    plt.savefig('/workspace/request-project/viz_pieces.png', dpi=150, bbox_inches='tight')
    print("Saved viz_pieces.png")

except ImportError:
    print("matplotlib not available, skipping visualization")


#!/usr/bin/env python3
"""
Visualization: Diophantine Approximation Spectrum
Shows how the best rational approximation quality varies with denominator bound.
"""
import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    def spectrum(alpha, D):
        best = float('inf')
        best_p, best_q = 0, 1
        for q in range(1, D + 1):
            p = round(alpha * q)
            err = abs(alpha - p / q)
            if err < best:
                best = err
                best_p, best_q = p, q
        return best, best_p, best_q

    Ds = list(range(1, 500))
    pi_spectrum = [spectrum(math.pi, D)[0] for D in Ds]
    e_spectrum = [spectrum(math.e, D)[0] for D in Ds]
    sqrt2_spectrum = [spectrum(math.sqrt(2), D)[0] for D in Ds]
    phi_spectrum = [spectrum((1 + math.sqrt(5))/2, D)[0] for D in Ds]

    fig, ax = plt.subplots(figsize=(12, 7))

    ax.semilogy(Ds, pi_spectrum, 'b-', alpha=0.6, label='π', linewidth=0.8)
    ax.semilogy(Ds, e_spectrum, 'r-', alpha=0.6, label='e', linewidth=0.8)
    ax.semilogy(Ds, sqrt2_spectrum, 'g-', alpha=0.6, label='√2', linewidth=0.8)
    ax.semilogy(Ds, phi_spectrum, 'm-', alpha=0.6, label='φ = (1+√5)/2', linewidth=0.8)

    # Add 1/D^2 reference line (Roth's theorem bound for algebraic numbers)
    roth_line = [1.0 / (D * D) for D in Ds]
    ax.semilogy(Ds, roth_line, 'k--', alpha=0.4, label='1/D² (Roth bound)', linewidth=1.5)

    # Highlight famous convergents
    convergents_pi = [(22, 7), (333, 106), (355, 113)]
    for p, q in convergents_pi:
        err = abs(math.pi - p/q)
        ax.plot(q, err, 'bo', markersize=8)
        ax.annotate(f'{p}/{q}', xy=(q, err), fontsize=8, ha='left',
                   bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.7))

    ax.set_xlabel('Denominator bound D', fontsize=12)
    ax.set_ylabel('Best approximation error', fontsize=12)
    ax.set_title('Diophantine Approximation Spectrum of Irrational Constants', fontsize=14)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 500)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/viz_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved viz_spectrum.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
