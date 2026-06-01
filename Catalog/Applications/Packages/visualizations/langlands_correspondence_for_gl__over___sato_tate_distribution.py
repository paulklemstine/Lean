#!/usr/bin/env python3
"""
Visualization: Sato-Tate Distribution for the Ramanujan Δ Function

Plots the empirical distribution of Satake angles θ_p = arccos(τ(p)/(2p^(11/2)))
against the Sato-Tate prediction (2/π)sin²θ.
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

    max_p = 200
    primes = [p for p in range(2, max_p + 1) if is_prime(p)]
    
    thetas = []
    for p in primes:
        tau_p = ramanujan_tau(p)
        bound = 2 * p**(11/2)
        cos_t = max(-1.0, min(1.0, tau_p / bound))
        thetas.append(math.acos(cos_t))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Histogram vs Sato-Tate density
    num_bins = 15
    ax1.hist(thetas, bins=num_bins, range=(0, math.pi), density=True,
             alpha=0.7, color='steelblue', edgecolor='white', label='Empirical')
    
    t_range = np.linspace(0.01, math.pi - 0.01, 200)
    st_density = (2/math.pi) * np.sin(t_range)**2
    ax1.plot(t_range, st_density, 'r-', linewidth=2.5, label='Sato-Tate: (2/π)sin²θ')
    
    ax1.set_xlabel('Satake angle θ_p', fontsize=12)
    ax1.set_ylabel('Density', fontsize=12)
    ax1.set_title(f'Sato-Tate Distribution (primes ≤ {max_p})', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(alpha=0.3)
    
    # Right: Cumulative distribution
    sorted_thetas = sorted(thetas)
    n = len(sorted_thetas)
    empirical_cdf = [(i + 1) / n for i in range(n)]
    
    ax2.step(sorted_thetas, empirical_cdf, where='post', color='steelblue',
             linewidth=1.5, label='Empirical CDF')
    
    # Sato-Tate CDF: F(θ) = (1/π)(θ - sin(2θ)/2)
    t_cdf = np.linspace(0, math.pi, 200)
    st_cdf = (1/math.pi) * (t_cdf - 0.5 * np.sin(2 * t_cdf))
    ax2.plot(t_cdf, st_cdf, 'r-', linewidth=2.5, label='Sato-Tate CDF')
    
    ax2.set_xlabel('θ', fontsize=12)
    ax2.set_ylabel('Cumulative probability', fontsize=12)
    ax2.set_title('CDF Comparison', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_sato_tate.png', dpi=150, bbox_inches='tight')
    print("Saved viz_sato_tate.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
