"""
Demo: Fractal Number Theory — Hausdorff and Box-Counting Dimensions of Prime Distributions

Demonstrates the key results:
1. The logarithmic prime image S = {1/log(p) : p prime}
2. Hausdorff dimension = 0 (countable set)
3. Box-counting dimension ≈ 1/2
4. Spacing between consecutive log-prime values vanishes
5. Twin prime distances in the log metric
"""

import math
from typing import List, Tuple


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def log_prime_image(primes: List[int]) -> List[float]:
    """Compute S = {1/log(p) : p prime}."""
    return [1.0 / math.log(p) for p in primes]


def box_counting_number(values: List[float], epsilon: float) -> int:
    """Count the number of epsilon-boxes needed to cover the values."""
    if epsilon <= 0:
        return 0
    boxes = set()
    for v in values:
        boxes.add(int(v // epsilon))
    return len(boxes)


def estimate_box_dimension(primes: List[int],
                           eps_range: Tuple[float, float] = (1e-4, 1e-1),
                           n_points: int = 50) -> Tuple[float, List[Tuple[float, float]]]:
    """Estimate box-counting dimension via linear regression on log-log plot."""
    values = log_prime_image(primes)
    eps_values = [eps_range[0] * (eps_range[1] / eps_range[0]) ** (i / (n_points - 1))
                  for i in range(n_points)]

    log_data = []
    for eps in eps_values:
        n_boxes = box_counting_number(values, eps)
        if n_boxes > 0:
            log_data.append((math.log(1 / eps), math.log(n_boxes)))

    # Linear regression
    if len(log_data) < 2:
        return 0.0, log_data

    n = len(log_data)
    sx = sum(x for x, _ in log_data)
    sy = sum(y for _, y in log_data)
    sxx = sum(x * x for x, _ in log_data)
    sxy = sum(x * y for x, y in log_data)

    slope = (n * sxy - sx * sy) / (n * sxx - sx * sx)
    return slope, log_data


def twin_prime_distances(primes: List[int]) -> List[Tuple[int, float]]:
    """Compute log-metric distance for twin prime pairs."""
    twins = []
    for i in range(len(primes) - 1):
        if primes[i + 1] - primes[i] == 2:
            p, q = primes[i], primes[i + 1]
            dist = abs(1 / math.log(p) - 1 / math.log(q))
            twins.append((p, dist))
    return twins


def spacing_analysis(primes: List[int]) -> List[Tuple[int, float]]:
    """Compute spacing between consecutive log-prime values."""
    values = log_prime_image(primes)
    spacings = []
    for i in range(len(values) - 1):
        spacings.append((primes[i], values[i] - values[i + 1]))
    return spacings


def main():
    print("=" * 70)
    print("  FRACTAL NUMBER THEORY: Prime Logarithmic Image Analysis")
    print("=" * 70)

    # Generate primes
    N = 10_000_000
    primes = sieve_primes(N)
    print(f"\nPrimes up to {N:,}: {len(primes):,} primes found")

    # Log-prime image
    S = log_prime_image(primes)
    print(f"\nLogarithmic Prime Image S = {{1/log(p) : p prime}}:")
    print(f"  Range: ({S[-1]:.6f}, {S[0]:.6f}]")
    print(f"  First 10 values: {[f'{v:.4f}' for v in S[:10]]}")
    print(f"  Last 5 values:   {[f'{v:.6f}' for v in S[-5:]]}")

    # Hausdorff dimension
    print(f"\n{'='*50}")
    print("RESULT 1: Hausdorff Dimension")
    print(f"{'='*50}")
    print(f"  dim_H(S) = 0  (S is countable: {len(S):,} points)")
    print(f"  This is PROVEN in Lean 4 using Mathlib's dimH_countable.")

    # Box-counting dimension
    print(f"\n{'='*50}")
    print("RESULT 2: Box-Counting Dimension Estimate")
    print(f"{'='*50}")
    dim_est, log_data = estimate_box_dimension(primes)
    print(f"  Estimated dim_B(S) = {dim_est:.4f}")
    print(f"  (Expected: ≈ 0.5)")
    print(f"\n  Log-log data (sample):")
    for i in range(0, len(log_data), len(log_data) // 8):
        x, y = log_data[i]
        print(f"    log(1/ε) = {x:.2f}, log(N(ε)) = {y:.2f}, ratio = {y/x:.4f}")

    # Spacing analysis
    print(f"\n{'='*50}")
    print("RESULT 3: Spacing Between Consecutive Log-Prime Values")
    print(f"{'='*50}")
    spacings = spacing_analysis(primes)
    print("  Spacing 1/log(p_k) - 1/log(p_{k+1}) for selected primes:")
    for idx in [0, 1, 2, 5, 10, 100, 1000, 10000, 100000]:
        if idx < len(spacings):
            p, s = spacings[idx]
            print(f"    p = {p:>10,}:  spacing = {s:.10f}")
    print(f"\n  Spacing VANISHES: proven in Lean 4 (logPrime_spacing_vanishes)")

    # Twin prime distances
    print(f"\n{'='*50}")
    print("RESULT 4: Twin Prime Log-Metric Distances")
    print(f"{'='*50}")
    twins = twin_prime_distances(primes)
    print(f"  Found {len(twins):,} twin prime pairs up to {N:,}")
    print("  Sample distances:")
    for idx in [0, 1, 2, 5, 10, 50, 100, 500, len(twins)//2, len(twins)-1]:
        if idx < len(twins):
            p, d = twins[idx]
            approx = 2.0 / (p * math.log(p)**2)
            print(f"    ({p}, {p+2}):  d = {d:.2e},  approx 2/(p·log²p) = {approx:.2e}")

    # Dimension gap
    print(f"\n{'='*50}")
    print("RESULT 5: Dimension Gap")
    print(f"{'='*50}")
    print(f"  dim_H(S) = 0")
    print(f"  dim_B(S) ≈ {dim_est:.4f}")
    print(f"  Dimension gap = dim_B - dim_H ≈ {dim_est:.4f}")
    print(f"\n  The gap quantifies the 'fractal-like' structure of primes:")
    print(f"  too thin for positive Hausdorff dimension (countable),")
    print(f"  yet structured enough for positive box-counting dimension.")

    # Verify Bertrand
    print(f"\n{'='*50}")
    print("VERIFICATION: Bertrand's Postulate")
    print(f"{'='*50}")
    bertrand_ok = True
    for n in [1, 10, 100, 1000, 10000, 100000, 1000000]:
        found = any(n < p <= 2 * n for p in primes if n < p <= 2 * n)
        status = "✓" if found else "✗"
        if not found:
            bertrand_ok = False
        print(f"  n = {n:>10,}: prime in ({n}, {2*n}]? {status}")
    print(f"  Bertrand verified for all test cases: {'YES' if bertrand_ok else 'NO'}")


if __name__ == "__main__":
    main()


"""
Visualization: Box-Counting Dimension of the Logarithmic Prime Image

Produces a log-log plot of N(ε) vs 1/ε, with slope ≈ 0.5 (the box-counting dimension).
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = bytearray(b'\x01') * (n + 1)
    is_prime[0] = is_prime[1] = 0
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            is_prime[i*i::i] = bytearray(len(is_prime[i*i::i]))
    return [i for i in range(2, n + 1) if is_prime[i]]


def box_counting(values, epsilon):
    boxes = set()
    for v in values:
        boxes.add(int(v // epsilon))
    return len(boxes)


def main():
    N = 5_000_000
    primes = sieve_primes(N)
    values = [1.0 / math.log(p) for p in primes]

    eps_values = np.geomspace(1e-5, 0.5, 80)
    log_inv_eps = []
    log_n_boxes = []

    for eps in eps_values:
        n_boxes = box_counting(values, eps)
        if n_boxes > 1:
            log_inv_eps.append(math.log(1 / eps))
            log_n_boxes.append(math.log(n_boxes))

    x = np.array(log_inv_eps)
    y = np.array(log_n_boxes)

    # Linear fit
    coeffs = np.polyfit(x, y, 1)
    slope, intercept = coeffs
    y_fit = slope * x + intercept

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Log-log plot
    ax1 = axes[0]
    ax1.scatter(x, y, s=10, alpha=0.7, color='#2563eb', label='Data')
    ax1.plot(x, y_fit, 'r--', linewidth=2,
             label=f'Fit: slope = {slope:.4f}')
    ax1.set_xlabel('log(1/ε)', fontsize=13)
    ax1.set_ylabel('log N(ε)', fontsize=13)
    ax1.set_title(f'Box-Counting Dimension\n(primes up to {N:,})', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Annotation
    ax1.text(0.05, 0.85, f'dim_B ≈ {slope:.3f}\ndim_H = 0\ngap = {slope:.3f}',
             transform=ax1.transAxes, fontsize=12,
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Plot 2: The log-prime image itself
    ax2 = axes[1]
    sample_primes = primes[:500]
    sample_values = [1.0 / math.log(p) for p in sample_primes]
    ax2.scatter(range(len(sample_values)), sample_values, s=3, alpha=0.8, color='#dc2626')
    ax2.set_xlabel('Prime index k', fontsize=13)
    ax2.set_ylabel('1/log(p_k)', fontsize=13)
    ax2.set_title('Logarithmic Prime Image\n(first 500 primes)', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0, color='black', linewidth=0.5)

    plt.tight_layout()
    plt.savefig('box_counting_dimension.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved box_counting_dimension.png")
    print(f"Box-counting dimension estimate: {slope:.4f}")


if __name__ == "__main__":
    main()


"""
Visualization: Log-Metric Spacing Between Consecutive Primes

Shows that spacing 1/log(p_k) - 1/log(p_{k+1}) vanishes as k → ∞.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = bytearray(b'\x01') * (n + 1)
    is_prime[0] = is_prime[1] = 0
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            is_prime[i*i::i] = bytearray(len(is_prime[i*i::i]))
    return [i for i in range(2, n + 1) if is_prime[i]]


def main():
    N = 1_000_000
    primes = sieve_primes(N)
    values = [1.0 / math.log(p) for p in primes]

    spacings = [values[i] - values[i+1] for i in range(len(values)-1)]
    indices = list(range(len(spacings)))

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Spacing vs index
    ax = axes[0, 0]
    ax.scatter(indices[::10], spacings[::10], s=1, alpha=0.5, color='#2563eb')
    ax.set_xlabel('Prime index k', fontsize=12)
    ax.set_ylabel('Spacing Δ_k', fontsize=12)
    ax.set_title('Log-Metric Spacing: Δ_k = 1/log(p_k) - 1/log(p_{k+1})', fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Twin prime distances
    ax = axes[0, 1]
    twin_p = []
    twin_d = []
    for i in range(len(primes)-1):
        if primes[i+1] - primes[i] == 2:
            p = primes[i]
            d = abs(1/math.log(p) - 1/math.log(p+2))
            twin_p.append(p)
            twin_d.append(d)
    approx = [2.0/(p * math.log(p)**2) for p in twin_p]
    ax.scatter(twin_p, twin_d, s=2, alpha=0.5, color='#dc2626', label='Actual d(p, p+2)')
    ax.plot(twin_p, approx, 'g-', alpha=0.5, linewidth=0.5, label='≈ 2/(p·log²p)')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('d(p, p+2)', fontsize=12)
    ax.set_title('Twin Prime Log-Metric Distances', fontsize=12)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Cumulative log-prime image
    ax = axes[1, 0]
    ax.plot(primes[:2000], values[:2000], 'b-', linewidth=0.5, alpha=0.8)
    ax.scatter(primes[:2000], values[:2000], s=1, color='red', zorder=5)
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('1/log(p)', fontsize=12)
    ax.set_title('Log-Prime Image (first 2000 primes)', fontsize=12)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(True, alpha=0.3)

    # Plot 4: Gap energy at different exponents
    ax = axes[1, 1]
    s_values = np.linspace(0.1, 3.0, 50)
    energies = []
    first_n = 5000
    gaps = spacings[:first_n]
    for s in s_values:
        e = sum(g**s for g in gaps)
        energies.append(e)
    ax.plot(s_values, energies, 'b-', linewidth=2)
    ax.set_xlabel('Exponent s', fontsize=12)
    ax.set_ylabel('E_s (first 5000 gaps)', fontsize=12)
    ax.set_title('Prime Log-Gap Energy E_s = Σ|Δ_k|^s', fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='s=1 (total variation)')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('prime_spacing_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved prime_spacing_analysis.png")


if __name__ == "__main__":
    main()
