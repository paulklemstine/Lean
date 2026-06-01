#!/usr/bin/env python3
"""
Visualization: Eichler-Shimura for X₀(11)

Plots point counts #E(F_p) vs the Hasse-Weil bounds for the
elliptic curve y² + y = x³ - x² (Cremona 11a1).
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

def point_count_11a1(p):
    """Count points on y² + y = x³ - x² over F_p."""
    count = 1  # point at infinity
    for x in range(p):
        for y in range(p):
            if (y * y + y - x * x * x + x * x) % p == 0:
                count += 1
    return count

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    primes = [p for p in range(2, 80) if is_prime(p) and p != 11]
    counts = [point_count_11a1(p) for p in primes]
    a_ps = [p + 1 - c for p, c in zip(primes, counts)]
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))
    
    # Top: Point counts with Hasse bounds
    p_cont = np.linspace(2, 80, 200)
    upper = p_cont + 1 + 2 * np.sqrt(p_cont)
    lower = p_cont + 1 - 2 * np.sqrt(p_cont)
    
    ax1.fill_between(p_cont, lower, upper, alpha=0.15, color='red', label='Hasse-Weil band')
    ax1.plot(p_cont, p_cont + 1, 'k--', alpha=0.4, label='p + 1')
    ax1.scatter(primes, counts, color='steelblue', zorder=5, s=30, label='#E(𝔽_p)')
    
    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('#E(𝔽_p)', fontsize=12)
    ax1.set_title('Point Counts on y² + y = x³ - x² (Cremona 11a1)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(alpha=0.3)
    
    # Bottom: a_p values with Hasse bound
    hasse_upper = [2 * math.sqrt(p) for p in primes]
    hasse_lower = [-2 * math.sqrt(p) for p in primes]
    
    ax2.fill_between(primes, hasse_lower, hasse_upper, alpha=0.15, color='red',
                     label='|a_p| ≤ 2√p')
    ax2.scatter(primes, a_ps, color='coral', zorder=5, s=30, label='a_p = p+1-#E')
    ax2.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    
    ax2.set_xlabel('Prime p', fontsize=12)
    ax2.set_ylabel('a_p', fontsize=12)
    ax2.set_title('Hecke Eigenvalues (= Frobenius Traces) for 11a1', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_eichler_shimura.png', dpi=150, bbox_inches='tight')
    print("Saved viz_eichler_shimura.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
