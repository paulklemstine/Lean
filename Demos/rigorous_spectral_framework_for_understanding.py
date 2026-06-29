#!/usr/bin/env python3
"""
Prime Spectral Framework — Demonstration
=========================================

Demonstrates the key concepts and results of the prime spectral framework:
1. Prime spectral lines (frequency, amplitude) for the first N primes
2. Amplitude-frequency duality
3. Spectral resonance defect computation
4. Spectral gap regularity conjecture verification
5. Spectral entropy computation
"""

import math
from typing import List, Tuple


def sieve_primes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def spectral_line(p: int) -> Tuple[float, float]:
    """Compute the spectral line (frequency, amplitude) for prime p."""
    freq = math.log(p) / (2 * math.pi)
    amp = 1.0 / math.sqrt(p)
    return (freq, amp)


def spectral_resonance_defect(p: int, q: int, N: int) -> float:
    """Compute the spectral resonance defect D_N(p, q)."""
    r = math.log(p) / math.log(q)
    min_defect = float('inf')
    for b in range(1, N + 1):
        a = round(r * b)
        defect = abs(r - a / b)
        min_defect = min(min_defect, defect)
    return min_defect


def spectral_entropy(primes: List[int]) -> float:
    """Compute the spectral entropy of a list of primes."""
    weights = [1.0 / math.sqrt(p) for p in primes]
    total = sum(weights)
    normalized = [w / total for w in weights]
    return -sum(w * math.log(w) for w in normalized if w > 0)


def verify_gap_conjecture(primes: List[int]) -> Tuple[bool, int, float, float]:
    """
    Verify the Spectral Gap Regularity Conjecture for a list of primes.
    Returns (all_hold, first_failure_index, max_ratio, bound_at_max).
    """
    max_ratio = 0.0
    max_idx = 0
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        ratio = math.log(q) / math.log(p)
        n = i + 1  # 1-indexed
        bound = 1 + 1.0 / n
        if ratio > bound:
            return (False, n, ratio, bound)
        if ratio > max_ratio:
            max_ratio = ratio
            max_idx = n
    bound_at_max = 1 + 1.0 / max_idx if max_idx > 0 else float('inf')
    return (True, max_idx, max_ratio, bound_at_max)


def main():
    print("=" * 70)
    print("PRIME SPECTRAL FRAMEWORK — DEMONSTRATION")
    print("=" * 70)

    # 1. Display first 20 prime spectral lines
    primes = sieve_primes(100)
    print("\n1. PRIME SPECTRAL LINES (first 20 primes)")
    print("-" * 55)
    print(f"{'Prime':>6} {'Frequency':>12} {'Amplitude':>12} {'Energy':>12}")
    print("-" * 55)
    for p in primes[:20]:
        freq, amp = spectral_line(p)
        energy = 1.0 / p
        print(f"{p:>6} {freq:>12.6f} {amp:>12.6f} {energy:>12.6f}")

    # 2. Amplitude-frequency duality
    print("\n2. AMPLITUDE-FREQUENCY DUALITY")
    print("-" * 50)
    print("Verifying: for p < q (both prime), amp(p) > amp(q)")
    all_hold = True
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        _, amp_p = spectral_line(p)
        _, amp_q = spectral_line(q)
        if amp_p <= amp_q:
            print(f"  FAILURE: amp({p}) = {amp_p:.6f} <= amp({q}) = {amp_q:.6f}")
            all_hold = False
    print(f"  Result: {'ALL VERIFIED' if all_hold else 'FAILURES FOUND'} "
          f"for {len(primes)} primes up to {primes[-1]}")

    # 3. Prime power independence examples
    print("\n3. PRIME POWER INDEPENDENCE")
    print("-" * 50)
    print("Verifying p^m ≠ q^n for small distinct primes and exponents:")
    test_primes = [2, 3, 5, 7, 11]
    violations = 0
    tests = 0
    for i, p in enumerate(test_primes):
        for q in test_primes[i+1:]:
            for m in range(1, 20):
                for n in range(1, 20):
                    tests += 1
                    if p**m == q**n:
                        print(f"  VIOLATION: {p}^{m} = {q}^{n} = {p**m}")
                        violations += 1
    print(f"  Tested {tests} cases, found {violations} violations")

    # 4. Spectral resonance defect
    print("\n4. SPECTRAL RESONANCE DEFECT D_N(p, q)")
    print("-" * 60)
    pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7)]
    for p, q in pairs:
        r = math.log(p) / math.log(q)
        print(f"\n  Primes ({p}, {q}): log({p})/log({q}) = {r:.10f}")
        for N in [1, 5, 10, 50, 100]:
            d = spectral_resonance_defect(p, q, N)
            print(f"    D_{N:>3}({p},{q}) = {d:.10f}")

    # 5. Spectral Gap Regularity Conjecture
    print("\n5. SPECTRAL GAP REGULARITY CONJECTURE")
    print("-" * 50)
    large_primes = sieve_primes(10**6)
    holds, idx, max_r, bound = verify_gap_conjecture(large_primes)
    print(f"  Tested {len(large_primes)} primes up to {large_primes[-1]}")
    print(f"  Conjecture holds: {holds}")
    print(f"  Maximum ratio log(p_{{n+1}})/log(p_n) = {max_r:.8f} at n={idx}")
    print(f"  Bound 1 + 1/n at that point: {bound:.8f}")
    print(f"  Margin: {bound - max_r:.8f}")

    # 6. Spectral entropy
    print("\n6. SPECTRAL ENTROPY")
    print("-" * 50)
    for N in [10, 100, 1000, 10000]:
        p_list = sieve_primes(10 * N)[:N]  # rough overestimate to get N primes
        if len(p_list) < N:
            p_list = sieve_primes(20 * N)[:N]
        H = spectral_entropy(p_list[:N])
        log_N = math.log(N)
        half_log_log_N = 0.5 * math.log(math.log(N)) if N > 2 else 0
        correction = H - log_N + half_log_log_N
        print(f"  H_{N:>5} = {H:.6f}, log(N) = {log_N:.6f}, "
              f"H_N - log(N) + ½log(log(N)) = {correction:.6f}")

    # 7. Spectral counting function vs PNT prediction
    print("\n7. SPECTRAL DENSITY vs PNT PREDICTION")
    print("-" * 60)
    print(f"{'f':>6} {'π_S(f)':>10} {'PNT pred':>12} {'ratio':>10}")
    print("-" * 45)
    all_p = sieve_primes(10**7)
    for f_val in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]:
        count = sum(1 for p in all_p if math.log(p) / (2 * math.pi) <= f_val)
        x = math.exp(2 * math.pi * f_val)
        pnt_pred = x / (2 * math.pi * f_val)
        ratio = count / pnt_pred if pnt_pred > 0 else float('inf')
        print(f"{f_val:>6.1f} {count:>10} {pnt_pred:>12.1f} {ratio:>10.4f}")

    print("\n" + "=" * 70)
    print("DEMONSTRATION COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Resonance Defect
==========================================
Shows how the resonance defect D_N(p,q) decays with resolution N,
demonstrating the irrationality of log(p)/log(q) for distinct primes.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def spectral_resonance_defect(p: int, q: int, N: int) -> float:
    r = math.log(p) / math.log(q)
    min_defect = float('inf')
    for b in range(1, N + 1):
        a = round(r * b)
        defect = abs(r - a / b)
        min_defect = min(min_defect, defect)
    return min_defect


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: D_N(2,3) vs N
    ax1 = axes[0]
    pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7)]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    Ns = list(range(1, 501))

    for (p, q), color in zip(pairs, colors):
        defects = [spectral_resonance_defect(p, q, N) for N in Ns]
        ax1.semilogy(Ns, defects, color=color, linewidth=1.2, alpha=0.8,
                     label=f'D_N({p},{q})')

    # Reference line: 1/N^2
    ref = [1.0 / (N * N) for N in Ns]
    ax1.semilogy(Ns, ref, 'k--', alpha=0.4, linewidth=1, label=r'$1/N^2$ reference')

    ax1.set_xlabel('Resolution N', fontsize=13)
    ax1.set_ylabel('Resonance Defect D_N(p,q)', fontsize=13)
    ax1.set_title('Spectral Resonance Defect Decay', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, which='both')

    # Right: Heatmap of D_100(p,q) for first 10 primes
    ax2 = axes[1]
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    n = len(small_primes)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                matrix[i][j] = spectral_resonance_defect(small_primes[i], small_primes[j], 100)
            else:
                matrix[i][j] = 0

    im = ax2.imshow(matrix, cmap='hot_r', interpolation='nearest')
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(small_primes, fontsize=10)
    ax2.set_yticklabels(small_primes, fontsize=10)
    ax2.set_xlabel('Prime q', fontsize=13)
    ax2.set_ylabel('Prime p', fontsize=13)
    ax2.set_title('D₁₀₀(p,q) Heatmap', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax2, label='Resonance Defect')

    plt.tight_layout()
    plt.savefig('resonance_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: resonance_defect.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Regularity
========================================
Tests and visualizes the Spectral Gap Regularity Conjecture:
log(p_{n+1})/log(p_n) ≤ 1 + 1/n for consecutive primes.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def main():
    primes = sieve_primes(100000)

    fig, axes = plt.subplots(2, 1, figsize=(14, 10))

    # Compute ratios
    ns = list(range(1, len(primes)))
    ratios = [math.log(primes[i]) / math.log(primes[i-1]) for i in range(1, len(primes))]
    bounds = [1 + 1.0 / n for n in ns]

    # Top: ratios and bound
    ax1 = axes[0]
    ax1.scatter(ns[:200], ratios[:200], s=8, alpha=0.7, color='#377eb8', label='log(p_{n+1})/log(p_n)')
    ax1.plot(ns[:200], bounds[:200], 'r-', linewidth=2, alpha=0.8, label='1 + 1/n bound')
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('n (prime index)', fontsize=13)
    ax1.set_ylabel('Frequency ratio', fontsize=13)
    ax1.set_title('Spectral Gap Regularity Conjecture (first 200 primes)', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0.95, 2.1)

    # Bottom: margin (bound - ratio)
    ax2 = axes[1]
    margins = [b - r for b, r in zip(bounds, ratios)]
    ax2.semilogy(ns[:2000], margins[:2000], '.', markersize=2, alpha=0.5, color='#4daf4a')
    ax2.set_xlabel('n (prime index)', fontsize=13)
    ax2.set_ylabel('Margin (1 + 1/n - ratio)', fontsize=13)
    ax2.set_title('Conjecture Margin (all positive ⟹ conjecture holds)', fontsize=13)
    ax2.grid(True, alpha=0.3, which='both')

    # Check and annotate
    all_positive = all(m > 0 for m in margins)
    min_margin = min(margins)
    min_idx = margins.index(min_margin) + 1
    ax2.annotate(f'Min margin = {min_margin:.6f} at n={min_idx}',
                xy=(min_idx, min_margin), fontsize=11,
                arrowprops=dict(arrowstyle='->', color='red'),
                xytext=(min_idx + 500, min_margin * 5),
                color='red', fontweight='bold')

    status = "VERIFIED ✓" if all_positive else "VIOLATED ✗"
    fig.suptitle(f'Status: {status} for {len(primes)} primes', fontsize=12,
                 color='green' if all_positive else 'red', y=0.02)

    plt.tight_layout()
    plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: spectral_gaps.png (conjecture {status})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Spectral Lines
====================================
Displays the prime spectral lines as a frequency-amplitude plot,
showing how each prime contributes to the zeta function on the critical line.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def main():
    primes = sieve_primes(200)
    freqs = [math.log(p) / (2 * math.pi) for p in primes]
    amps = [1.0 / math.sqrt(p) for p in primes]

    fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [3, 1]})

    # Top: spectral lines as vertical bars
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(primes)))
    for i, (f, a) in enumerate(zip(freqs, amps)):
        ax1.vlines(f, 0, a, colors=[colors[i]], linewidth=2, alpha=0.8)
        if primes[i] <= 19:
            ax1.annotate(f'p={primes[i]}', (f, a), textcoords="offset points",
                        xytext=(5, 5), fontsize=9, fontweight='bold')

    # Envelope curve: 1/sqrt(e^{2πf}) = e^{-πf}
    f_cont = np.linspace(0.05, max(freqs) + 0.1, 500)
    envelope = np.exp(-np.pi * f_cont)
    ax1.plot(f_cont, envelope, 'r--', alpha=0.5, linewidth=1.5,
             label=r'Envelope: $e^{-\pi f}$')

    ax1.set_xlabel('Spectral Frequency  ν = log(p)/(2π)', fontsize=13)
    ax1.set_ylabel('Amplitude  A = 1/√p', fontsize=13)
    ax1.set_title('Prime Spectral Lines: The Music of the Primes', fontsize=15, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 0.8)
    ax1.grid(True, alpha=0.3)

    # Bottom: spectral energy (1/p)
    ax2 = axes[1]
    energies = [1.0 / p for p in primes]
    ax2.bar(freqs, energies, width=0.003, color=colors, alpha=0.7)
    ax2.set_xlabel('Spectral Frequency  ν = log(p)/(2π)', fontsize=13)
    ax2.set_ylabel('Energy  E = 1/p', fontsize=13)
    ax2.set_title('Spectral Energy Distribution', fontsize=13)
    ax2.set_ylim(0, 0.55)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('prime_spectral_lines.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: prime_spectral_lines.png")


if __name__ == "__main__":
    main()
