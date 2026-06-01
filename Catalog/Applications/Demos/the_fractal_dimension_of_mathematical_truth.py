#!/usr/bin/env python3
"""
Demo: The Fractal Dimension of Mathematical Truth

Demonstrates the growth exponent framework by computing truth densities
and growth exponents for concrete binary growth functions.
"""

import math
from typing import Callable


def growth_exponent(count: int, n: int) -> float:
    """Compute the growth exponent α(n) = log(count) / (n · log 2)."""
    if n == 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))


def truth_density(count: int, n: int) -> float:
    """Compute the truth density d(n) = count / 2^n."""
    return count / (2 ** n)


def density_exponent_duality_check(count: int, n: int) -> tuple[float, float]:
    """
    Verify the density-exponent duality:
    log(density) should equal n · (exponent - 1) · log 2
    
    Returns (LHS, RHS) for comparison.
    """
    d = truth_density(count, n)
    alpha = growth_exponent(count, n)
    lhs = math.log(d) if d > 0 else float('-inf')
    rhs = n * (alpha - 1) * math.log(2)
    return lhs, rhs


def spectral_bounds(count_fn: Callable[[int], int], max_n: int) -> tuple[float, float]:
    """Compute spectral bounds (α_L, α_U) over levels 1..max_n."""
    exponents = [growth_exponent(count_fn(n), n) for n in range(1, max_n + 1)]
    return min(exponents), max(exponents)


# === Example Growth Functions ===

def maximal_growth(n: int) -> int:
    """N(n) = 2^n: every string is true."""
    return 2 ** n

def minimal_growth(n: int) -> int:
    """N(n) = 1: exactly one true string at each level."""
    return max(1, 1)

def geometric_growth(r: float) -> Callable[[int], int]:
    """N(n) = max(1, floor(r^n)): geometric growth with ratio r."""
    def count(n: int) -> int:
        return max(1, int(r ** n))
    return count

def oscillating_growth(n: int) -> int:
    """N(n) with oscillating exponent: demonstrates spectral gap."""
    if n == 0:
        return 1
    # Oscillates between ~1.3^n and ~1.7^n
    r = 1.5 + 0.2 * math.sin(n * 0.7)
    return max(1, min(int(r ** n), 2 ** n))


def main():
    print("=" * 70)
    print("THE FRACTAL DIMENSION OF MATHEMATICAL TRUTH")
    print("Numerical Demonstrations")
    print("=" * 70)
    
    # Demo 1: Growth exponent bounds
    print("\n--- Demo 1: Growth Exponent Bounds ---")
    print("Verifying α(n) ∈ [0, 1] for geometric growth with r = 1.5")
    print(f"{'n':>4} {'N(n)':>12} {'α(n)':>10} {'d(n)':>12} {'∈ [0,1]?':>10}")
    print("-" * 52)
    geo_15 = geometric_growth(1.5)
    for n in range(1, 21):
        count = geo_15(n)
        alpha = growth_exponent(count, n)
        density = truth_density(count, n)
        in_range = "✓" if 0 <= alpha <= 1 else "✗"
        print(f"{n:>4} {count:>12} {alpha:>10.6f} {density:>12.8f} {in_range:>10}")
    
    # Demo 2: Density-exponent duality
    print("\n--- Demo 2: Density-Exponent Duality ---")
    print("Verifying log(d(n)) = n·(α(n)-1)·log(2)")
    print(f"{'n':>4} {'LHS':>14} {'RHS':>14} {'|diff|':>14}")
    print("-" * 50)
    for n in range(1, 16):
        count = geo_15(n)
        lhs, rhs = density_exponent_duality_check(count, n)
        diff = abs(lhs - rhs)
        print(f"{n:>4} {lhs:>14.8f} {rhs:>14.8f} {diff:>14.2e}")
    
    # Demo 3: Extreme cases
    print("\n--- Demo 3: Extreme Growth Functions ---")
    print("Maximal growth (N(n) = 2^n): α(n) should be 1")
    for n in [1, 5, 10, 20]:
        alpha = growth_exponent(maximal_growth(n), n)
        print(f"  n={n:>3}: α(n) = {alpha:.10f}")
    
    print("\nMinimal growth (N(n) = 1): α(n) should be 0")
    for n in [1, 5, 10, 20]:
        alpha = growth_exponent(minimal_growth(n), n)
        print(f"  n={n:>3}: α(n) = {alpha:.10f}")
    
    # Demo 4: Spectral gap
    print("\n--- Demo 4: Spectral Gap (Oscillating Growth) ---")
    print(f"{'n':>4} {'N(n)':>12} {'α(n)':>10}")
    print("-" * 30)
    for n in range(1, 31):
        count = oscillating_growth(n)
        alpha = growth_exponent(count, n)
        print(f"{n:>4} {count:>12} {alpha:>10.6f}")
    
    alpha_L, alpha_U = spectral_bounds(oscillating_growth, 30)
    gap = alpha_U - alpha_L
    print(f"\nSpectral bounds: [{alpha_L:.6f}, {alpha_U:.6f}]")
    print(f"Spectral gap: {gap:.6f}")
    print(f"Gap positive? {'YES ✓' if gap > 0 else 'NO ✗'}")
    
    # Demo 5: Partial enumeration approximation
    print("\n--- Demo 5: Partial Enumeration (Chaitin Approximation) ---")
    print("True count N(20) for r=1.5 growth:", geo_15(20))
    n = 20
    true_count = geo_15(n)
    true_alpha = growth_exponent(true_count, n)
    print(f"True exponent: {true_alpha:.6f}")
    print(f"{'k verified':>12} {'lower bound':>14} {'gap to true':>14}")
    print("-" * 44)
    for fraction in [0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]:
        k = max(1, int(true_count * fraction))
        lb = growth_exponent(k, n)
        print(f"{k:>12} {lb:>14.6f} {true_alpha - lb:>14.6f}")
    
    # Demo 6: Multiple growth rates
    print("\n--- Demo 6: Dimension Spectrum for Various Growth Rates ---")
    print(f"{'r':>6} {'expected dim':>14} {'computed dim':>14} {'match?':>8}")
    print("-" * 46)
    for r in [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]:
        expected = math.log(r) / math.log(2)
        geo_r = geometric_growth(r)
        # Average exponent over large n
        computed = sum(growth_exponent(geo_r(n), n) for n in range(50, 101)) / 51
        match = "✓" if abs(expected - computed) < 0.01 else "~"
        print(f"{r:>6.1f} {expected:>14.6f} {computed:>14.6f} {match:>8}")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("Key insight: the growth exponent α captures the fractal dimension")
    print("of truth — always in [0,1], with the duality identity linking")
    print("density to dimension exactly.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Density-Exponent Duality

Shows the fundamental identity: log(d(n)) = n · (α(n) - 1) · log 2
"""

import math

def compute_growth_exponent(count: int, n: int) -> float:
    if n <= 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))

def geometric_count(r: float, n: int) -> int:
    if n == 0:
        return 1
    return max(1, min(int(r ** n), 2 ** n))

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Density-Exponent Duality: log(d) = n·(α−1)·log 2', fontsize=14, fontweight='bold')

    ns = list(range(1, 41))

    # Plot 1: LHS vs RHS verification
    ax = axes[0]
    for r in [1.3, 1.5, 1.7]:
        lhs_vals = []
        rhs_vals = []
        for n in ns:
            c = geometric_count(r, n)
            d = c / (2 ** n)
            alpha = compute_growth_exponent(c, n)
            lhs = math.log(d) if d > 0 else -100
            rhs = n * (alpha - 1) * math.log(2)
            lhs_vals.append(lhs)
            rhs_vals.append(rhs)
        ax.plot(ns, lhs_vals, 'o', markersize=3, label=f'LHS (r={r})')
        ax.plot(ns, rhs_vals, '-', linewidth=1, label=f'RHS (r={r})')
    ax.set_xlabel('n')
    ax.set_ylabel('Value')
    ax.set_title('LHS = RHS (exact match)')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    # Plot 2: The duality surface
    ax = axes[1]
    rates = [1.1 + i * 0.1 for i in range(9)]
    for r in rates:
        alphas = [compute_growth_exponent(geometric_count(r, n), n) for n in ns]
        densities = [geometric_count(r, n) / (2 ** n) for n in ns]
        log_densities = [math.log(d) if d > 0 else -100 for d in densities]
        color_val = (r - 1.1) / 0.8
        ax.scatter(alphas, log_densities, s=5, alpha=0.6, 
                   c=[[color_val, 0, 1 - color_val]])
    ax.set_xlabel('Growth exponent α(n)')
    ax.set_ylabel('log(density)')
    ax.set_title('Density vs. Exponent (colored by r)')
    ax.grid(True, alpha=0.3)

    # Plot 3: Partial enumeration convergence
    ax = axes[2]
    r = 1.5
    n = 30
    true_count = geometric_count(r, n)
    true_alpha = compute_growth_exponent(true_count, n)
    fractions = [i / 100 for i in range(1, 101)]
    lower_bounds = []
    for f in fractions:
        k = max(1, int(true_count * f))
        lb = compute_growth_exponent(k, n)
        lower_bounds.append(lb)
    ax.plot([f * 100 for f in fractions], lower_bounds, 'b-', linewidth=2)
    ax.axhline(y=true_alpha, color='red', linestyle='--', label=f'True α = {true_alpha:.4f}')
    ax.set_xlabel('% of truths enumerated')
    ax.set_ylabel('Lower bound on α')
    ax.set_title(f'Chaitin Approximation (n={n}, r={r})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('duality_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved duality_visualization.png")

except ImportError:
    print("matplotlib not available; skipping plot generation")


#!/usr/bin/env python3
"""
Visualization: Growth Exponent and Truth Density Spectrum

Generates plots showing:
1. Growth exponents for different growth rates
2. The density-exponent duality
3. Spectral gap visualization
"""

import math

def compute_growth_exponent(count: int, n: int) -> float:
    if n <= 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))

def geometric_count(r: float, n: int) -> int:
    if n == 0:
        return 1
    return max(1, min(int(r ** n), 2 ** n))

def oscillating_count(n: int) -> int:
    if n == 0:
        return 1
    r = 1.5 + 0.2 * math.sin(n * 0.7)
    return max(1, min(int(r ** n), 2 ** n))

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('The Fractal Dimension of Mathematical Truth', fontsize=16, fontweight='bold')

    # Plot 1: Growth exponents for various rates
    ax = axes[0, 0]
    ns = list(range(1, 51))
    for r in [1.2, 1.4, 1.6, 1.8]:
        exponents = [compute_growth_exponent(geometric_count(r, n), n) for n in ns]
        expected = math.log(r) / math.log(2)
        ax.plot(ns, exponents, label=f'r={r:.1f} (dim≈{expected:.2f})')
        ax.axhline(y=expected, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('String length n')
    ax.set_ylabel('Growth exponent α(n)')
    ax.set_title('Growth Exponents for Geometric Growth')
    ax.legend(fontsize=8)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # Plot 2: Truth density decay
    ax = axes[0, 1]
    for r in [1.2, 1.5, 1.8]:
        densities = [geometric_count(r, n) / (2 ** n) for n in ns]
        ax.semilogy(ns, densities, label=f'r={r:.1f}')
    ax.set_xlabel('String length n')
    ax.set_ylabel('Truth density d(n) [log scale]')
    ax.set_title('Exponential Decay of Truth Density')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Spectral gap (oscillating growth)
    ax = axes[1, 0]
    ns_long = list(range(1, 81))
    osc_exponents = [compute_growth_exponent(oscillating_count(n), n) for n in ns_long]
    ax.plot(ns_long, osc_exponents, 'b-', alpha=0.7, label='α(n)')
    alpha_min = min(osc_exponents)
    alpha_max = max(osc_exponents)
    ax.axhline(y=alpha_min, color='red', linestyle='--', label=f'α_L = {alpha_min:.3f}')
    ax.axhline(y=alpha_max, color='green', linestyle='--', label=f'α_U = {alpha_max:.3f}')
    ax.fill_between(ns_long, alpha_min, alpha_max, alpha=0.1, color='yellow')
    ax.set_xlabel('String length n')
    ax.set_ylabel('Growth exponent α(n)')
    ax.set_title(f'Spectral Gap = {alpha_max - alpha_min:.4f}')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 4: Dimension spectrum
    ax = axes[1, 1]
    rates = [1.0 + i * 0.05 for i in range(21)]
    expected_dims = [math.log(r) / math.log(2) for r in rates]
    computed_dims = []
    for r in rates:
        exps = [compute_growth_exponent(geometric_count(r, n), n) for n in range(30, 51)]
        computed_dims.append(sum(exps) / len(exps))
    ax.plot(rates, expected_dims, 'r-', linewidth=2, label='Expected: log(r)/log(2)')
    ax.plot(rates, computed_dims, 'bo', markersize=4, label='Computed (avg n=30..50)')
    ax.set_xlabel('Growth rate r')
    ax.set_ylabel('Fractal dimension')
    ax.set_title('Dimension Spectrum: All Values in (0,1) Achievable')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fractal_dimension_plots.png', dpi=150, bbox_inches='tight')
    print("Saved fractal_dimension_plots.png")

except ImportError:
    print("matplotlib not available; skipping plot generation")
    print("Install with: pip install matplotlib numpy")


#!/usr/bin/env python3
"""
Visualization: Truth Density Spectrum and Spectral Gap

Shows how the spectral gap measures dimensional irregularity.
"""

import math

def compute_growth_exponent(count: int, n: int) -> float:
    if n <= 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))

def oscillating_count(freq: float, amp: float, base: float, n: int) -> int:
    if n == 0:
        return 1
    r = base + amp * math.sin(freq * n)
    return max(1, min(int(r ** n), 2 ** n))

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Truth Density Spectrum: Spectral Gap Analysis', fontsize=14, fontweight='bold')

    ns = list(range(1, 101))

    configs = [
        (0.3, 0.05, 1.5, 'Low oscillation (amp=0.05)'),
        (0.3, 0.15, 1.5, 'Medium oscillation (amp=0.15)'),
        (0.3, 0.3, 1.5, 'High oscillation (amp=0.30)'),
        (0.7, 0.2, 1.5, 'Fast oscillation (freq=0.7)'),
    ]

    for idx, (freq, amp, base, title) in enumerate(configs):
        ax = axes[idx // 2, idx % 2]
        exponents = [compute_growth_exponent(
            oscillating_count(freq, amp, base, n), n) for n in ns]
        
        alpha_min = min(exponents)
        alpha_max = max(exponents)
        gap = alpha_max - alpha_min
        
        ax.plot(ns, exponents, 'b-', alpha=0.7, linewidth=0.8)
        ax.axhline(y=alpha_min, color='red', linestyle='--', alpha=0.7,
                   label=f'α_L = {alpha_min:.4f}')
        ax.axhline(y=alpha_max, color='green', linestyle='--', alpha=0.7,
                   label=f'α_U = {alpha_max:.4f}')
        ax.fill_between(ns, alpha_min, alpha_max, alpha=0.1, color='yellow')
        
        # Running average
        running_avg = []
        s = 0
        for i, a in enumerate(exponents):
            s += a
            running_avg.append(s / (i + 1))
        ax.plot(ns, running_avg, 'r-', linewidth=2, alpha=0.5, label='Cesaro mean')
        
        ax.set_xlabel('n')
        ax.set_ylabel('α(n)')
        ax.set_title(f'{title}\nΔ = {gap:.4f}')
        ax.legend(fontsize=7, loc='lower right')
        ax.set_ylim(0, 1)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spectrum_analysis.png")

except ImportError:
    print("matplotlib not available; skipping plot generation")
