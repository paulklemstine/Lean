#!/usr/bin/env python3
"""
Visualization: Frobenius Discriminant for the Ramanujan Δ Function

Plots the Frobenius discriminant Δ_p = τ(p)² - 4·p¹¹ for primes p,
showing that all values are negative (confirming Deligne's theorem).
"""
import math

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def ramanujan_tau(n):
    coeffs = [0] * (n + 1)
    coeffs[0] = 1
    for m in range(1, n + 1):
        for _ in range(24):
            for k in range(n, m - 1, -1):
                coeffs[k] -= coeffs[k - m]
    return coeffs[n - 1] if n >= 1 else 0

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    primes = [p for p in range(2, 60) if is_prime(p)]
    taus = [ramanujan_tau(p) for p in primes]
    discs = [t**2 - 4 * p**11 for t, p in zip(taus, primes)]
    ratios = [t**2 / (4 * p**11) for t, p in zip(taus, primes)]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Top: Discriminant (log scale of |Δ|)
    ax1.bar(range(len(primes)), [-d for d in discs], color='steelblue', alpha=0.8)
    ax1.set_yscale('log')
    ax1.set_xticks(range(len(primes)))
    ax1.set_xticklabels([str(p) for p in primes], fontsize=8)
    ax1.set_xlabel('Prime p')
    ax1.set_ylabel('|Δ_p| = |τ(p)² - 4·p¹¹|')
    ax1.set_title('Frobenius Discriminant for Ramanujan Δ (all negative → Deligne\'s theorem)')
    ax1.grid(axis='y', alpha=0.3)

    # Bottom: Ramanujan ratio |τ(p)| / (2·p^(11/2))
    ax2.bar(range(len(primes)), ratios, color='coral', alpha=0.8)
    ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Ramanujan bound')
    ax2.set_xticks(range(len(primes)))
    ax2.set_xticklabels([str(p) for p in primes], fontsize=8)
    ax2.set_xlabel('Prime p')
    ax2.set_ylabel('τ(p)² / (4·p¹¹)')
    ax2.set_title('Ramanujan Ratio: τ(p)² / (4·p¹¹) < 1 for all primes')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_discriminant.png', dpi=150, bbox_inches='tight')
    print("Saved viz_discriminant.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
