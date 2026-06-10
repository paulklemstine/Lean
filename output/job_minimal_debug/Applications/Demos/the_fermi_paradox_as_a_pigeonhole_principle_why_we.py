#!/usr/bin/env python3
"""
Demo: The Fermi Paradox as a Pigeonhole Principle

Numerical demonstrations of the filter cascade model for cosmic silence.
Each demo corresponds to a formally verified theorem.
"""

import math

def drake_expected(num_planets: float, filter_probs: list[float]) -> float:
    """Compute the expected number of civilizations: N * prod(p_i)."""
    prod = 1.0
    for p in filter_probs:
        prod *= p
    return num_planets * prod


def demo_pessimistic_drake():
    """Demo 1: Pessimistic Drake equation gives E << 1."""
    print("=" * 60)
    print("DEMO 1: Pessimistic Drake Equation")
    print("=" * 60)
    
    # Conservative estimates for each filter step
    filters = {
        "Star formation rate (per year)": 1.5,
        "Fraction with planets": 0.5,
        "Habitable planets per star": 0.01,
        "Fraction developing life": 0.01,
        "Fraction developing intelligence": 0.01,
        "Fraction developing technology": 0.01,
        "Civilizational lifetime (years)": 100,
    }
    
    N = 1.0  # Normalize: compute per-year-of-observation
    result = N
    for name, val in filters.items():
        result *= val
        print(f"  {name}: {val}")
    
    print(f"\n  Expected civilizations: {result:.2e}")
    print(f"  This is {'<< 1' if result < 1 else '>= 1'}: "
          f"{'silence expected' if result < 1 else 'contact expected'}")
    
    # With 10^10 habitable planets
    N_planets = 1e10
    per_planet = 0.01 * 0.01 * 0.01 * 0.01  # product of biological filters
    E = N_planets * per_planet
    print(f"\n  With 10^10 planets and per-planet prob = {per_planet:.2e}:")
    print(f"  E = {E:.2e}")
    print()


def demo_filter_concentration():
    """Demo 2: Filter concentration — the Great Filter must be somewhere."""
    print("=" * 60)
    print("DEMO 2: Filter Concentration (Multiplicative Pigeonhole)")
    print("=" * 60)
    
    epsilon = 1e-12  # total filter probability
    k = 7  # number of filter steps
    
    min_factor = epsilon ** (1.0 / k)
    print(f"  Total filter probability: {epsilon:.2e}")
    print(f"  Number of filter steps: {k}")
    print(f"  At least one step must have probability ≤ ε^(1/k) = {min_factor:.6f}")
    print(f"  This means at least one step passes with prob ≤ {min_factor*100:.4f}%")
    print()
    
    # Show that distributing the filter equally gives each step this probability
    equal_prob = epsilon ** (1.0 / k)
    print(f"  If all steps have equal probability: p = {equal_prob:.6f}")
    print(f"  Verification: p^{k} = {equal_prob**k:.2e} ≈ {epsilon:.2e}")
    print()


def demo_exponential_decay():
    """Demo 3: Exponential filter decay."""
    print("=" * 60)
    print("DEMO 3: Exponential Filter Decay")
    print("=" * 60)
    
    p = 0.1  # each step passes with 10% probability
    N = 1e10  # 10 billion habitable planets
    
    print(f"  Per-step probability: p = {p}")
    print(f"  Number of planets: N = {N:.2e}")
    print(f"  {'k':>4s} {'p^k':>15s} {'N * p^k':>15s} {'E < 1?':>8s}")
    print(f"  {'-'*4} {'-'*15} {'-'*15} {'-'*8}")
    
    for k in range(1, 15):
        pk = p ** k
        E = N * pk
        print(f"  {k:4d} {pk:15.2e} {E:15.2e} {'Yes' if E < 1 else 'No':>8s}")
    
    # Find critical k
    k_crit = math.ceil(math.log(1/N) / math.log(p))
    print(f"\n  Critical k (E < 1 when k ≥ {k_crit}): {k_crit} filter steps needed")
    print()


def demo_temporal_pigeonhole():
    """Demo 4: Temporal non-overlap."""
    print("=" * 60)
    print("DEMO 4: Temporal Pigeonhole")
    print("=" * 60)
    
    T = 13.8e9  # age of universe in years
    
    scenarios = [
        ("Optimistic", 100, 1e6),
        ("Moderate", 10, 1e4),
        ("Pessimistic", 3, 1e3),
    ]
    
    for name, n, L in scenarios:
        frac = n * L / T
        print(f"  {name}: n={n} civilizations, L={L:.0e} yr lifetime")
        print(f"    Occupied fraction: {frac:.2e}")
        print(f"    Temporal overlap: {'likely' if frac > 0.01 else 'extremely unlikely'}")
    print()


def demo_pigeonhole_poisson_bridge():
    """Demo 5: Comparing linear (pigeonhole) and exponential (Poisson) bounds."""
    print("=" * 60)
    print("DEMO 5: Pigeonhole-Poisson Bridge")
    print("=" * 60)
    
    print(f"  {'λ':>8s} {'1-λ (linear)':>14s} {'e^(-λ) (Poisson)':>18s} {'Gap':>10s}")
    print(f"  {'-'*8} {'-'*14} {'-'*18} {'-'*10}")
    
    for lam in [0.001, 0.01, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99, 1.0]:
        linear = 1 - lam
        poisson = math.exp(-lam)
        gap = poisson - linear
        print(f"  {lam:8.3f} {linear:14.6f} {poisson:18.6f} {gap:10.6f}")
    
    print(f"\n  Key insight: 1 - λ ≤ e^(-λ) always holds (proved in Lean).")
    print(f"  The pigeonhole bound is conservative; Poisson gives tighter silence probability.")
    print()


def demo_spatial_isolation():
    """Demo 6: Spatial isolation via volume fractions."""
    print("=" * 60)
    print("DEMO 6: Spatial Isolation")
    print("=" * 60)
    
    R = 4.4e10  # observable universe radius in light-years
    
    comm_ranges = [100, 1000, 1e4, 1e5, 1e6]
    n_civs = 100  # optimistic: 100 civilizations
    
    print(f"  Universe radius: {R:.2e} ly")
    print(f"  Assumed civilizations: {n_civs}")
    print(f"\n  {'Range (ly)':>12s} {'(r/R)^3':>15s} {'n*(r/R)^3':>12s} {'Detectable?':>12s}")
    print(f"  {'-'*12} {'-'*15} {'-'*12} {'-'*12}")
    
    for r in comm_ranges:
        frac = (r / R) ** 3
        expected = n_civs * frac
        print(f"  {r:12.0e} {frac:15.2e} {expected:12.2e} "
              f"{'Possible' if expected > 0.01 else 'No':>12s}")
    print()


def demo_fermi_silence_theorem():
    """Demo 7: The Grand Synthesis."""
    print("=" * 60)
    print("DEMO 7: Fermi Silence Theorem — Grand Synthesis")
    print("=" * 60)
    
    N = 1e10
    p = 0.1
    
    print(f"  N = {N:.2e} habitable planets")
    print(f"  Per-step filter probability: p = {p}")
    
    for k in [5, 7, 10, 15, 20]:
        E = N * p**k
        silence_prob = max(0, 1 - E)
        print(f"\n  k = {k} filter steps:")
        print(f"    E[civilizations] = {E:.2e}")
        print(f"    P(silence) ≥ 1 - E = {silence_prob:.10f}")
        print(f"    Next step: E[k+1] = {N * p**(k+1):.2e} (factor {p}x smaller)")
    print()


if __name__ == "__main__":
    demo_pessimistic_drake()
    demo_filter_concentration()
    demo_exponential_decay()
    demo_temporal_pigeonhole()
    demo_pigeonhole_poisson_bridge()
    demo_spatial_isolation()
    demo_fermi_silence_theorem()


#!/usr/bin/env python3
"""
Visualization: Filter Cascade Decay

Shows how the expected number of civilizations decays exponentially
with each additional filter step, for various per-step probabilities.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def plot_filter_cascade():
    """Plot exponential decay of E[N] with filter steps."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    N = 1e10  # 10 billion habitable planets
    k_values = np.arange(0, 25)
    
    # Left panel: E[N] vs k for various p
    ax = axes[0]
    for p in [0.5, 0.3, 0.1, 0.05, 0.01]:
        E_values = [N * p**k for k in k_values]
        ax.semilogy(k_values, E_values, 'o-', label=f'p = {p}', markersize=3)
    
    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='E = 1 (silence threshold)')
    ax.set_xlabel('Number of Filter Steps (k)', fontsize=12)
    ax.set_ylabel('Expected Civilizations E[N]', fontsize=12)
    ax.set_title('Exponential Filter Decay', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_ylim(1e-20, 1e15)
    ax.grid(True, alpha=0.3)
    
    # Right panel: Silence probability vs lambda
    ax = axes[1]
    lam_values = np.linspace(0.001, 2, 200)
    linear = 1 - lam_values
    poisson = np.exp(-lam_values)
    
    ax.plot(lam_values, poisson, 'b-', linewidth=2, label='Poisson: $e^{-\\lambda}$')
    ax.plot(lam_values, np.maximum(linear, 0), 'r--', linewidth=2, 
            label='Pigeonhole: $1 - \\lambda$')
    ax.fill_between(lam_values, np.maximum(linear, 0), poisson, 
                     alpha=0.2, color='green', label='Gap (Poisson tighter)')
    
    ax.axvline(x=1, color='gray', linestyle=':', linewidth=1)
    ax.set_xlabel('Expected Count (λ)', fontsize=12)
    ax.set_ylabel('P(silence)', fontsize=12)
    ax.set_title('Pigeonhole–Poisson Bridge', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 2)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('filter_cascade_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: filter_cascade_visualization.png")


def plot_temporal_pigeonhole():
    """Plot temporal coverage fraction."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    T = 13.8e9  # cosmic time in years
    n_values = np.arange(1, 101)
    
    for L in [1e3, 1e4, 1e5, 1e6, 1e7]:
        fractions = [n * L / T for n in n_values]
        ax.plot(n_values, fractions, '-', linewidth=2, label=f'L = {L:.0e} yr')
    
    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Full coverage')
    ax.set_xlabel('Number of Civilizations (n)', fontsize=12)
    ax.set_ylabel('Temporal Coverage Fraction (nL/T)', fontsize=12)
    ax.set_title('Temporal Pigeonhole: When Do Civilizations Overlap?', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.set_ylim(1e-8, 10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('temporal_pigeonhole_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: temporal_pigeonhole_visualization.png")


def plot_filter_concentration():
    """Plot the Great Filter concentration bound."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    k_values = range(2, 21)
    
    for eps in [1e-6, 1e-9, 1e-12, 1e-15, 1e-20]:
        bounds = [eps ** (1.0 / k) for k in k_values]
        ax.plot(list(k_values), bounds, 'o-', markersize=4,
                label=f'ε = {eps:.0e}')
    
    ax.set_xlabel('Number of Filter Steps (k)', fontsize=12)
    ax.set_ylabel('Min Single-Step Probability (ε^{1/k})', fontsize=12)
    ax.set_title('Filter Concentration: How Severe Must the Great Filter Be?', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('filter_concentration_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: filter_concentration_visualization.png")


if __name__ == "__main__":
    plot_filter_cascade()
    plot_temporal_pigeonhole()
    plot_filter_concentration()
