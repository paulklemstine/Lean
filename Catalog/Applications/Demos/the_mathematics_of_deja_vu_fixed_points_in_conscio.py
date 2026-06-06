#!/usr/bin/env python3
"""
Dynamical Spectrum Theory: Numerical Demonstrations

Demonstrates the key mathematical concepts:
1. Logistic map fixed points and period-2 orbits
2. Period-3 windows and their implications
3. Cognitive dynamics simulation showing deja vu states
4. Orbit classification: periodic, pre-periodic, chaotic
"""

import math
from typing import List, Tuple, Set


def logistic_map(r: float, x: float) -> float:
    """The logistic map f(x) = r·x·(1-x)."""
    return r * x * (1 - x)


def iterate(f, x: float, n: int) -> float:
    """Compute f^[n](x)."""
    for _ in range(n):
        x = f(x)
    return x


def orbit(f, x: float, n: int) -> List[float]:
    """Compute the orbit [x, f(x), f²(x), ..., f^n(x)]."""
    result = [x]
    for _ in range(n):
        x = f(x)
        result.append(x)
    return result


def find_fixed_points(r: float, tol: float = 1e-10) -> List[float]:
    """Find fixed points of the logistic map analytically.
    
    f(x) = x ⟺ r·x·(1-x) = x ⟺ x·(r(1-x) - 1) = 0
    Solutions: x = 0 and x = (r-1)/r
    """
    points = [0.0]
    if abs(r) > tol:
        points.append((r - 1) / r)
    return points


def find_period2_orbit(r: float) -> Tuple[float, float]:
    """Find the period-2 orbit of the logistic map.
    
    For r > 3, the fixed point (r-1)/r becomes unstable and
    a period-2 orbit appears. The period-2 points satisfy:
    x = r·(r·x·(1-x))·(1 - r·x·(1-x))
    
    Solutions (besides fixed points): 
    x = ((r+1) ± √((r+1)(r-3))) / (2r)
    """
    if r <= 3:
        return (float('nan'), float('nan'))
    
    discriminant = (r + 1) * (r - 3)
    if discriminant < 0:
        return (float('nan'), float('nan'))
    
    sqrt_disc = math.sqrt(discriminant)
    x1 = ((r + 1) + sqrt_disc) / (2 * r)
    x2 = ((r + 1) - sqrt_disc) / (2 * r)
    return (x1, x2)


def detect_period(f, x0: float, max_iter: int = 10000, 
                  settle: int = 5000, tol: float = 1e-8) -> int:
    """Detect the period of the orbit starting at x0.
    
    Let the orbit settle, then look for the smallest period.
    """
    # Settle
    x = x0
    for _ in range(settle):
        x = f(x)
    
    # Record the settled point
    anchor = x
    x = f(x)
    
    for period in range(1, max_iter - settle):
        if abs(x - anchor) < tol:
            return period
        x = f(x)
    
    return -1  # Aperiodic (likely chaotic)


def sharkovsky_classify(n: int) -> str:
    """Classify a positive integer by its Sharkovsky class."""
    if n <= 0:
        return "invalid"
    if n == 1:
        return "power_of_two(0)"
    
    # Check if power of 2
    if n & (n - 1) == 0:
        k = n.bit_length() - 1
        return f"power_of_two({k})"
    
    # Find 2-adic valuation
    v = 0
    m = n
    while m % 2 == 0:
        v += 1
        m //= 2
    
    if v == 0:
        return f"odd_large({n})"
    else:
        return f"mixed(v={v}, odd={m})"


def spectrum_analysis(r: float, x0: float = 0.3) -> dict:
    """Analyze the dynamical spectrum of the logistic map at parameter r."""
    f = lambda x: logistic_map(r, x)
    
    # Find fixed points
    fps = find_fixed_points(r)
    
    # Detect period
    period = detect_period(f, x0)
    
    # Find period-2 orbit if applicable
    p2 = find_period2_orbit(r) if r > 3 else None
    
    # Compute Lyapunov exponent (indicates chaos)
    x = x0
    lyap = 0.0
    N = 10000
    for _ in range(N):
        deriv = abs(r * (1 - 2*x))
        if deriv > 0:
            lyap += math.log(deriv)
        x = f(x)
    lyap /= N
    
    return {
        'r': r,
        'fixed_points': fps,
        'detected_period': period,
        'period2_orbit': p2,
        'lyapunov_exponent': lyap,
        'is_chaotic': lyap > 0,
        'sharkovsky_class': sharkovsky_classify(period) if period > 0 else 'chaotic'
    }


def cognitive_dynamics_demo():
    """Simulate cognitive dynamics as logistic map and find deja vu states."""
    print("=" * 70)
    print("COGNITIVE DYNAMICS: DEJA VU AS FIXED POINTS")
    print("=" * 70)
    print()
    
    # Demo 1: Fixed point regime (r = 2.5)
    print("--- Regime 1: Stable cognition (r = 2.5) ---")
    r = 2.5
    info = spectrum_analysis(r)
    print(f"  Fixed points: {info['fixed_points']}")
    print(f"  Nontrivial fixed point: {(r-1)/r:.6f}")
    print(f"  Orbit period: {info['detected_period']}")
    print(f"  Lyapunov exponent: {info['lyapunov_exponent']:.4f}")
    print(f"  Interpretation: Cognitive state converges to a single attractor.")
    print(f"  Deja vu frequency: Every thought eventually feels familiar.")
    print()
    
    # Demo 2: Period-2 regime (r = 3.2)
    print("--- Regime 2: Oscillating cognition (r = 3.2) ---")
    r = 3.2
    info = spectrum_analysis(r)
    p2 = find_period2_orbit(r)
    print(f"  Fixed points: {info['fixed_points']}")
    print(f"  Period-2 orbit: ({p2[0]:.6f}, {p2[1]:.6f})")
    print(f"  Orbit period: {info['detected_period']}")
    print(f"  Lyapunov exponent: {info['lyapunov_exponent']:.4f}")
    print(f"  Interpretation: Mind oscillates between two states.")
    print()
    
    # Demo 3: Period-3 window (r ≈ 3.83)
    print("--- Regime 3: Period-3 window (r = 3.83) ---")
    r = 3.83
    info = spectrum_analysis(r, x0=0.5)
    print(f"  Fixed points: {info['fixed_points']}")
    print(f"  Orbit period: {info['detected_period']}")
    print(f"  Sharkovsky class: {info['sharkovsky_class']}")
    print(f"  Lyapunov exponent: {info['lyapunov_exponent']:.4f}")
    print(f"  Interpretation: Period 3 implies chaos (Li-Yorke).")
    print(f"  By Sharkovsky's theorem, all periods exist!")
    print()
    
    # Demo 4: Full chaos (r = 3.99)
    print("--- Regime 4: Chaotic cognition (r = 3.99) ---")
    r = 3.99
    info = spectrum_analysis(r)
    print(f"  Fixed points: {info['fixed_points']}")
    print(f"  Orbit period: {info['detected_period']} (likely aperiodic)")
    print(f"  Lyapunov exponent: {info['lyapunov_exponent']:.4f}")
    print(f"  Is chaotic: {info['is_chaotic']}")
    print(f"  Interpretation: Unpredictable cognitive trajectory.")
    print(f"  Deja vu states are dense but measure-zero.")
    print()
    
    # IVT Fixed Point Theorem demonstration
    print("=" * 70)
    print("IVT FIXED POINT THEOREM DEMONSTRATION")
    print("=" * 70)
    print()
    print("Theorem: Any continuous f: [0,1] → [0,1] has a fixed point.")
    print()
    for r_val in [1.5, 2.0, 2.5, 3.0, 3.5, 4.0]:
        fp = (r_val - 1) / r_val
        f_fp = logistic_map(r_val, fp)
        print(f"  r = {r_val}: fixed point at x = {fp:.6f}, "
              f"f(x) = {f_fp:.6f}, |f(x)-x| = {abs(f_fp - fp):.2e}")
    
    print()
    print("=" * 70)
    print("SHARKOVSKY ORDERING CLASSIFICATION")
    print("=" * 70)
    print()
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 16, 32]:
        print(f"  n = {n:3d}: {sharkovsky_classify(n)}")
    
    print()
    print("=" * 70)
    print("ORBIT BIFURCATION ANALYSIS")
    print("=" * 70)
    print()
    print("  r    | Period | Lyapunov | Class")
    print("  " + "-" * 50)
    for r_val in [x * 0.1 for x in range(10, 41)]:
        info = spectrum_analysis(r_val, x0=0.3)
        p = info['detected_period']
        ly = info['lyapunov_exponent']
        cl = info['sharkovsky_class']
        print(f"  {r_val:.1f}  | {p:5d}  | {ly:+.4f}  | {cl}")


if __name__ == '__main__':
    cognitive_dynamics_demo()


#!/usr/bin/env python3
"""
Bifurcation Diagram and Orbit Analysis Visualization

Generates publication-quality plots of:
1. The logistic map bifurcation diagram
2. Orbit portraits at key parameter values
3. Lyapunov exponent vs parameter
"""

import numpy as np

def logistic_map(r, x):
    return r * x * (1 - x)

def generate_bifurcation_data(r_min=2.5, r_max=4.0, r_steps=2000,
                               n_settle=500, n_plot=200, x0=0.3):
    """Generate bifurcation diagram data."""
    r_values = np.linspace(r_min, r_max, r_steps)
    r_data = []
    x_data = []
    
    for r in r_values:
        x = x0
        for _ in range(n_settle):
            x = logistic_map(r, x)
        for _ in range(n_plot):
            x = logistic_map(r, x)
            r_data.append(r)
            x_data.append(x)
    
    return np.array(r_data), np.array(x_data)

def compute_lyapunov(r_values, n_iter=5000, x0=0.3):
    """Compute Lyapunov exponent for each r value."""
    lyap = np.zeros_like(r_values)
    for i, r in enumerate(r_values):
        x = x0
        total = 0.0
        for _ in range(n_iter):
            deriv = abs(r * (1 - 2*x))
            if deriv > 1e-15:
                total += np.log(deriv)
            x = logistic_map(r, x)
        lyap[i] = total / n_iter
    return lyap

def plot_all():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, generating data only")
        return
    
    fig, axes = plt.subplots(3, 1, figsize=(12, 14))
    
    # Plot 1: Bifurcation diagram
    ax1 = axes[0]
    r_data, x_data = generate_bifurcation_data()
    ax1.scatter(r_data, x_data, s=0.01, c='black', alpha=0.3)
    ax1.set_xlabel('r (bifurcation parameter)', fontsize=12)
    ax1.set_ylabel('x (attractor)', fontsize=12)
    ax1.set_title('Logistic Map Bifurcation Diagram: The Road to Chaos', fontsize=14)
    
    # Mark key regions
    ax1.axvline(x=3.0, color='blue', linestyle='--', alpha=0.5, label='Period doubling (r=3)')
    ax1.axvline(x=3.83, color='red', linestyle='--', alpha=0.5, label='Period-3 window (r≈3.83)')
    ax1.legend(fontsize=10)
    
    # Plot 2: Lyapunov exponent
    ax2 = axes[1]
    r_lyap = np.linspace(2.5, 4.0, 1000)
    lyap = compute_lyapunov(r_lyap)
    ax2.plot(r_lyap, lyap, 'k-', linewidth=0.5)
    ax2.axhline(y=0, color='red', linestyle='-', alpha=0.5)
    ax2.fill_between(r_lyap, lyap, 0, where=(lyap > 0), alpha=0.3, color='red', label='Chaotic (λ > 0)')
    ax2.fill_between(r_lyap, lyap, 0, where=(lyap <= 0), alpha=0.3, color='blue', label='Periodic (λ ≤ 0)')
    ax2.set_xlabel('r', fontsize=12)
    ax2.set_ylabel('Lyapunov exponent λ', fontsize=12)
    ax2.set_title('Lyapunov Exponent: Quantifying Chaos', fontsize=14)
    ax2.legend(fontsize=10)
    
    # Plot 3: Orbit portraits
    ax3 = axes[2]
    r_values = [2.8, 3.2, 3.83, 3.99]
    colors = ['blue', 'green', 'red', 'purple']
    labels = ['Fixed point\n(r=2.8)', 'Period-2\n(r=3.2)', 
              'Period-3\n(r=3.83)', 'Chaos\n(r=3.99)']
    
    for r, color, label in zip(r_values, colors, labels):
        x = 0.3
        orbit = []
        for i in range(200):
            x = logistic_map(r, x)
            if i >= 150:
                orbit.append(x)
        
        ax3.plot(range(len(orbit)), orbit, '-o', color=color, 
                markersize=2, linewidth=0.5, label=label, alpha=0.8)
    
    ax3.set_xlabel('Iteration (after settling)', fontsize=12)
    ax3.set_ylabel('x', fontsize=12)
    ax3.set_title('Orbit Portraits at Key Parameter Values', fontsize=14)
    ax3.legend(fontsize=9, ncol=2)
    
    plt.tight_layout()
    plt.savefig('bifurcation_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved bifurcation_analysis.png")

if __name__ == '__main__':
    plot_all()
