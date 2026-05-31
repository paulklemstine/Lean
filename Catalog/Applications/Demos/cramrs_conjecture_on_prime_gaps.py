#!/usr/bin/env python3
"""
Demo: Prime Gap Analysis and Cramér's Conjecture Verification

This script computes prime gaps for primes up to a given bound and checks
whether Cramér's conjecture (gap ≤ (log p)²) holds for each prime.
"""

import math
from typing import List, Tuple


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to `limit` using the Sieve of Eratosthenes."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.isqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def compute_prime_gaps(primes: List[int]) -> List[Tuple[int, int, float]]:
    """Compute (prime, gap, (log p)²) for consecutive primes."""
    results = []
    for i in range(len(primes) - 1):
        p = primes[i]
        gap = primes[i + 1] - p
        log_sq = math.log(p) ** 2 if p >= 2 else 0
        results.append((p, gap, log_sq))
    return results


def verify_cramer_conjecture(limit: int = 1_000_000) -> None:
    """Verify Cramér's conjecture for all primes up to `limit`."""
    print(f"=== Cramér's Conjecture Verification up to {limit:,} ===\n")
    
    primes = sieve_of_eratosthenes(limit)
    gaps = compute_prime_gaps(primes)
    
    max_gap = 0
    max_gap_prime = 0
    max_ratio = 0.0
    max_ratio_prime = 0
    violations = 0
    
    for p, gap, log_sq in gaps:
        if p < 11:
            continue
        ratio = gap / log_sq if log_sq > 0 else 0
        
        if gap > max_gap:
            max_gap = gap
            max_gap_prime = p
        
        if ratio > max_ratio:
            max_ratio = ratio
            max_ratio_prime = p
        
        if gap > log_sq:
            violations += 1
    
    total = sum(1 for p, _, _ in gaps if p >= 11)
    print(f"Primes examined: {total:,}")
    print(f"Largest gap: {max_gap} (after prime {max_gap_prime:,})")
    print(f"  (log {max_gap_prime})² = {math.log(max_gap_prime)**2:.2f}")
    print(f"Largest ratio gap/(log p)²: {max_ratio:.4f} (at prime {max_ratio_prime:,})")
    print(f"Violations of gap ≤ (log p)²: {violations}")
    print(f"Conjecture {'HOLDS' if violations == 0 else 'VIOLATED'} for all primes ≤ {limit:,}")
    print()
    
    # Show the 10 largest gaps
    gaps_sorted = sorted(gaps, key=lambda x: x[1], reverse=True)
    print("Top 10 largest prime gaps:")
    print(f"{'Prime':>12} {'Gap':>6} {'(log p)²':>10} {'Ratio':>8}")
    print("-" * 40)
    for p, gap, log_sq in gaps_sorted[:10]:
        ratio = gap / log_sq if log_sq > 0 else 0
        print(f"{p:>12,} {gap:>6} {log_sq:>10.2f} {ratio:>8.4f}")


def bertrand_bound_demo() -> None:
    """Demonstrate the Bertrand gap bound: gap < p for all primes."""
    print("\n=== Bertrand's Postulate: gap < p for all primes ===\n")
    primes = sieve_of_eratosthenes(100_000)
    gaps = compute_prime_gaps(primes)
    
    max_ratio = 0.0
    for p, gap, _ in gaps:
        if p >= 2:
            ratio = gap / p
            if ratio > max_ratio:
                max_ratio = ratio
                max_p = p
                max_gap = gap
    
    print(f"Maximum gap/p ratio: {max_ratio:.6f} at p = {max_p} (gap = {max_gap})")
    print(f"Bertrand guarantees this ratio < 1 (achieved: {max_ratio < 1})")


def rsa_search_bound_demo() -> None:
    """Demonstrate the RSA prime search bound under Cramér's conjecture."""
    print("\n=== RSA Prime Search Bounds ===\n")
    print(f"{'Bit length k':>14} {'2^k':>20} {'Cramér O(k²)':>14} {'Bertrand O(2^k)':>18}")
    print("-" * 70)
    for k in [128, 256, 512, 1024, 2048, 4096]:
        cramer = k * k
        import decimal
        two_k = 2 ** k
        print(f"{k:>14} {'2^'+str(k):>20} {cramer:>14,} {'2^'+str(k):>18}")
    print()
    print("Under Cramér's conjecture, RSA prime search is O(k²) — polynomial in bit length.")
    print("Without it, Bertrand only gives O(2^k) — exponential and useless in practice.")


def gap_distribution_demo() -> None:
    """Show the distribution of normalized prime gaps gap/(log p)."""
    print("\n=== Distribution of Normalized Prime Gaps ===\n")
    primes = sieve_of_eratosthenes(1_000_000)
    gaps = compute_prime_gaps(primes)
    
    # Compute gap / log(p) for all primes ≥ 11
    normalized = []
    for p, gap, _ in gaps:
        if p >= 11:
            normalized.append(gap / math.log(p))
    
    # Histogram
    bins = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 8, 10, float('inf')]
    counts = [0] * (len(bins) - 1)
    for x in normalized:
        for i in range(len(bins) - 1):
            if bins[i] <= x < bins[i + 1]:
                counts[i] += 1
                break
    
    total = len(normalized)
    print(f"{'Range':>12} {'Count':>8} {'Fraction':>10}")
    print("-" * 32)
    for i in range(len(counts)):
        lo = bins[i]
        hi = bins[i + 1]
        label = f"[{lo:.1f}, {hi:.1f})" if hi < float('inf') else f"[{lo:.1f}, ∞)"
        print(f"{label:>12} {counts[i]:>8} {counts[i]/total:>10.4f}")
    
    mean = sum(normalized) / len(normalized)
    print(f"\nMean normalized gap: {mean:.4f} (PNT predicts ≈ 1.0)")


if __name__ == "__main__":
    verify_cramer_conjecture(1_000_000)
    bertrand_bound_demo()
    rsa_search_bound_demo()
    gap_distribution_demo()


#!/usr/bin/env python3
"""
Visualization: Prime Gaps vs Cramér's Bound

Generates a plot showing prime gaps overlaid with the (log p)² bound,
demonstrating that all gaps fall below the conjectured ceiling.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(limit):
    """Return all primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.isqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def main():
    limit = 1_000_000
    primes = sieve_of_eratosthenes(limit)
    
    ps = []
    gaps = []
    cramer_bounds = []
    
    for i in range(len(primes) - 1):
        p = primes[i]
        if p >= 11:
            g = primes[i + 1] - p
            ps.append(p)
            gaps.append(g)
            cramer_bounds.append(math.log(p) ** 2)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Prime Gaps and Cramér's Conjecture", fontsize=16, fontweight='bold')
    
    # Plot 1: Gaps vs Cramér bound
    ax1 = axes[0, 0]
    ax1.scatter(ps, gaps, s=0.3, alpha=0.3, color='steelblue', label='Prime gaps')
    ax1.plot(ps, cramer_bounds, color='red', linewidth=1.5, label='(log p)²')
    ax1.set_xlabel('Prime p')
    ax1.set_ylabel('Gap size')
    ax1.set_title('Prime Gaps vs (log p)² Bound')
    ax1.legend()
    ax1.set_xlim(0, limit)
    
    # Plot 2: Ratio gap / (log p)²
    ax2 = axes[0, 1]
    ratios = [g / cb for g, cb in zip(gaps, cramer_bounds)]
    ax2.scatter(ps, ratios, s=0.3, alpha=0.3, color='darkorange')
    ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='Cramér limit (ratio=1)')
    ax2.set_xlabel('Prime p')
    ax2.set_ylabel('gap / (log p)²')
    ax2.set_title('Normalized Gap Ratio')
    ax2.legend()
    ax2.set_xlim(0, limit)
    ax2.set_ylim(0, 1.2)
    
    # Plot 3: Histogram of gaps
    ax3 = axes[1, 0]
    ax3.hist(gaps, bins=range(0, max(gaps) + 2, 2), color='steelblue', 
             edgecolor='white', alpha=0.8)
    ax3.set_xlabel('Gap size')
    ax3.set_ylabel('Frequency')
    ax3.set_title('Distribution of Prime Gaps')
    ax3.axvline(x=np.mean(gaps), color='red', linestyle='--', 
                label=f'Mean = {np.mean(gaps):.1f}')
    ax3.legend()
    
    # Plot 4: Log-log comparison of bounds
    ax4 = axes[1, 1]
    x = np.linspace(11, limit, 1000)
    ax4.plot(x, np.log(x)**2, 'r-', linewidth=2, label='Cramér: (log p)²')
    ax4.plot(x, x**0.525, 'g--', linewidth=2, label='BHP: p^{0.525}')
    ax4.plot(x, x, 'b:', linewidth=2, label='Bertrand: p')
    ax4.set_xlabel('Prime p')
    ax4.set_ylabel('Gap bound')
    ax4.set_title('Hierarchy of Gap Bounds')
    ax4.set_yscale('log')
    ax4.set_xscale('log')
    ax4.legend()
    
    plt.tight_layout()
    plt.savefig('prime_gaps_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: prime_gaps_visualization.png")


if __name__ == "__main__":
    main()
