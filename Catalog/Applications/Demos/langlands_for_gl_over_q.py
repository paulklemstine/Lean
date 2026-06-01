#!/usr/bin/env python3
"""
Langlands GL₂/ℚ Correspondence: Numerical Demonstrations

Demonstrates the key structures: Hecke eigenvalue recursion, Ramanujan discriminant,
Hasse-Weil bounds, and Sato-Tate distribution for the Ramanujan Δ function
and the elliptic curve X₀(11).
"""

import math
from typing import List, Tuple, Dict


def is_prime(n: int) -> bool:
    """Simple primality test."""
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
    """Return all primes up to n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


# ============================================================
# Part 1: Ramanujan tau function via the product formula
# ============================================================

def ramanujan_tau(n: int, num_terms: int = 200) -> int:
    """
    Compute Ramanujan's tau function τ(n) via the q-expansion of
    Δ(q) = q * prod_{m=1}^∞ (1 - q^m)^24
    
    We work with exact integer arithmetic on coefficients.
    """
    # Compute coefficients of prod (1 - q^m)^24 up to q^n
    coeffs = [0] * (n + 1)
    coeffs[0] = 1
    
    for m in range(1, n + 1):
        # Multiply by (1 - q^m)^24
        # We need to expand (1 - q^m)^24 using binomial theorem
        for _ in range(24):
            for k in range(n, m - 1, -1):
                coeffs[k] -= coeffs[k - m]
    
    # Δ(q) = q * prod, so τ(n) = coeffs[n-1]
    if n >= 1:
        return coeffs[n - 1]
    return 0


def demo_ramanujan_tau():
    """Demonstrate Ramanujan tau computation and verification."""
    print("=" * 60)
    print("RAMANUJAN TAU FUNCTION τ(n)")
    print("Weight 12, Level 1 eigenform")
    print("=" * 60)
    
    # Known values
    known = {1: 1, 2: -24, 3: 252, 4: -1472, 5: 4830,
             6: -6048, 7: -16744, 8: 84480, 9: -113643, 10: -115920}
    
    print(f"\n{'n':>4} | {'τ(n) computed':>15} | {'τ(n) known':>15} | {'Match':>5}")
    print("-" * 55)
    for n in range(1, 11):
        computed = ramanujan_tau(n)
        expected = known[n]
        match = "✓" if computed == expected else "✗"
        print(f"{n:4d} | {computed:15d} | {expected:15d} | {match:>5}")
    
    # Hecke recursion check: τ(4) = τ(2)² - 2¹¹
    tau2, tau4 = ramanujan_tau(2), ramanujan_tau(4)
    hecke_val = tau2**2 - 2**11
    print(f"\nHecke recursion: τ(2)² - 2¹¹ = {tau2}² - {2**11} = {hecke_val}")
    print(f"τ(4) = {tau4}")
    print(f"Match: {'✓' if hecke_val == tau4 else '✗'}")
    
    # Multiplicativity check: τ(6) = τ(2)·τ(3)
    tau3, tau6 = ramanujan_tau(3), ramanujan_tau(6)
    mult_val = tau2 * tau3
    print(f"\nMultiplicativity: τ(2)·τ(3) = ({tau2})·({tau3}) = {mult_val}")
    print(f"τ(6) = {tau6}")
    print(f"Match: {'✓' if mult_val == tau6 else '✗'}")


# ============================================================
# Part 2: Frobenius discriminant and Ramanujan bound
# ============================================================

def frobenius_discriminant(a_p: float, p: int, k: int) -> float:
    """Compute the Frobenius discriminant Δ_p = a_p² - 4·p^(k-1)."""
    return a_p**2 - 4 * p**(k - 1)


def demo_discriminant():
    """Demonstrate Frobenius discriminant analysis."""
    print("\n" + "=" * 60)
    print("FROBENIUS DISCRIMINANT ANALYSIS")
    print("Δ_p = τ(p)² - 4·p¹¹  (weight 12)")
    print("=" * 60)
    
    print(f"\n{'p':>4} | {'τ(p)':>10} | {'τ(p)²':>15} | {'4·p¹¹':>15} | {'Δ_p':>15} | {'< 0?':>5}")
    print("-" * 75)
    
    for p in primes_up_to(30):
        tau_p = ramanujan_tau(p)
        disc = frobenius_discriminant(tau_p, p, 12)
        sign = "✓" if disc < 0 else "✗"
        print(f"{p:4d} | {tau_p:10d} | {tau_p**2:15d} | {4*p**11:15d} | {disc:15.0f} | {sign:>5}")
    
    print("\nNegative discriminant ⟹ Frobenius eigenvalues are complex conjugates")
    print("This confirms Deligne's theorem (Ramanujan conjecture) at these primes.")


# ============================================================
# Part 3: Ramanujan bound verification
# ============================================================

def demo_ramanujan_bound():
    """Verify the Ramanujan-Petersson bound |τ(p)| ≤ 2p^(11/2)."""
    print("\n" + "=" * 60)
    print("RAMANUJAN-PETERSSON BOUND: |τ(p)| ≤ 2·p^(11/2)")
    print("=" * 60)
    
    print(f"\n{'p':>4} | {'|τ(p)|':>12} | {'2·p^(11/2)':>15} | {'ratio':>8} | {'bound':>5}")
    print("-" * 55)
    
    for p in primes_up_to(50):
        tau_p = abs(ramanujan_tau(p))
        bound = 2 * p**(11/2)
        ratio = tau_p / bound
        holds = "✓" if tau_p <= bound else "✗"
        print(f"{p:4d} | {tau_p:12d} | {bound:15.1f} | {ratio:8.4f} | {holds:>5}")


# ============================================================
# Part 4: Eichler-Shimura for X₀(11)
# ============================================================

def elliptic_curve_11a1_ap(p: int) -> int:
    """
    Compute a_p for the elliptic curve E: y² + y = x³ - x²
    by direct point counting over F_p.
    """
    count = 0
    for x in range(p):
        for y in range(p):
            if (y * y + y - x * x * x + x * x) % p == 0:
                count += 1
    # #E(F_p) = count + 1 (for point at infinity)
    # a_p = p + 1 - #E(F_p)
    return p + 1 - (count + 1)


def demo_eichler_shimura():
    """Demonstrate Eichler-Shimura for X₀(11)."""
    print("\n" + "=" * 60)
    print("EICHLER-SHIMURA FOR X₀(11)")
    print("E: y² + y = x³ - x² (Cremona 11a1)")
    print("=" * 60)
    
    print(f"\n{'p':>4} | {'a_p':>6} | {'#E(F_p)':>8} | {'|a_p|≤2√p':>10} | {'Hasse':>5}")
    print("-" * 45)
    
    for p in primes_up_to(50):
        if p == 11:  # skip bad prime
            continue
        a_p = elliptic_curve_11a1_ap(p)
        point_count = p + 1 - a_p
        hasse_bound = 2 * math.sqrt(p)
        holds = "✓" if abs(a_p) <= hasse_bound else "✗"
        print(f"{p:4d} | {a_p:6d} | {point_count:8d} | {hasse_bound:10.3f} | {holds:>5}")


# ============================================================
# Part 5: Sato-Tate distribution
# ============================================================

def demo_sato_tate():
    """Demonstrate Sato-Tate distribution for the Ramanujan Δ function."""
    print("\n" + "=" * 60)
    print("SATO-TATE DISTRIBUTION FOR Δ")
    print("θ_p = arccos(τ(p) / (2·p^(11/2)))")
    print("Expected: (2/π)sin²θ distribution")
    print("=" * 60)
    
    thetas = []
    for p in primes_up_to(100):
        tau_p = ramanujan_tau(p)
        bound = 2 * p**(11/2)
        if bound > 0:
            cos_theta = tau_p / bound
            cos_theta = max(-1.0, min(1.0, cos_theta))
            theta = math.acos(cos_theta)
            thetas.append((p, tau_p, theta))
    
    # Histogram
    num_bins = 6
    bin_size = math.pi / num_bins
    bins = [0] * num_bins
    
    for _, _, theta in thetas:
        idx = min(int(theta / bin_size), num_bins - 1)
        bins[idx] += 1
    
    total = len(thetas)
    print(f"\nDistribution of θ_p over {total} primes ≤ 100:")
    print(f"\n{'Bin':>15} | {'Count':>5} | {'Observed':>8} | {'ST pred':>8}")
    print("-" * 45)
    
    for i in range(num_bins):
        lo = i * bin_size
        hi = (i + 1) * bin_size
        observed = bins[i] / total if total > 0 else 0
        # Sato-Tate prediction: (2/π) ∫_lo^hi sin²θ dθ
        st_pred = (1/math.pi) * ((hi - lo) - 0.5*(math.sin(2*hi) - math.sin(2*lo)))
        print(f"[{lo:.2f}, {hi:.2f}] | {bins[i]:5d} | {observed:8.3f} | {st_pred:8.3f}")
    
    # Test: proportion with θ ≤ π/2
    count_lower = sum(1 for _, _, t in thetas if t <= math.pi / 2)
    prop = count_lower / total if total > 0 else 0
    expected = 0.5 - 1/math.pi
    print(f"\nProportion with θ ≤ π/2: {prop:.3f}")
    print(f"Sato-Tate prediction:    {expected:.3f}")


# ============================================================
# Part 6: Hecke polynomial and local packets
# ============================================================

def demo_hecke_polynomial():
    """Demonstrate Hecke polynomial structure."""
    print("\n" + "=" * 60)
    print("HECKE POLYNOMIAL: X² - τ(p)X + p¹¹")
    print("= Characteristic polynomial of Frobenius")
    print("=" * 60)
    
    for p in [2, 3, 5, 7]:
        tau_p = ramanujan_tau(p)
        det_val = p**11
        disc = tau_p**2 - 4 * det_val
        
        print(f"\np = {p}:")
        print(f"  Hecke poly: X² - ({tau_p})X + {det_val}")
        print(f"  = X² + {-tau_p}X + {det_val}")
        print(f"  Discriminant: {disc}")
        
        if disc < 0:
            # Complex roots
            real_part = tau_p / 2
            imag_part = math.sqrt(-disc) / 2
            abs_val = math.sqrt(real_part**2 + imag_part**2)
            print(f"  Frobenius eigenvalues: {real_part} ± {imag_part:.2f}i")
            print(f"  |eigenvalue| = {abs_val:.4f}")
            print(f"  p^(11/2) = {p**(11/2):.4f}")
            print(f"  Match: {'✓' if abs(abs_val - p**(11/2)) < 0.01 else '✗'}")


if __name__ == "__main__":
    demo_ramanujan_tau()
    demo_discriminant()
    demo_ramanujan_bound()
    demo_eichler_shimura()
    demo_sato_tate()
    demo_hecke_polynomial()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


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
