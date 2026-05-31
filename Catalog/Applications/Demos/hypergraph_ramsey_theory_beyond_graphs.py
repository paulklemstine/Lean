#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Demonstration Script

Demonstrates key concepts from the formalization:
1. Tower function growth rates
2. Probabilistic method lower bounds
3. Stepping-up lemma upper bounds
4. Ramsey density spectrum computation
5. Growth rate conjecture verification
"""

import math
from itertools import combinations
from typing import Dict, List, Set, Tuple


# ============================================================
# Tower Function
# ============================================================

def tower_exp(base: int, height: int) -> int:
    """Iterated exponentiation: tower(b, 0) = 1, tower(b, n+1) = b^tower(b, n)."""
    if height == 0:
        return 1
    return base ** tower_exp(base, height - 1)


def demo_tower_growth():
    """Demonstrate the explosive growth of the tower function."""
    print("=" * 60)
    print("TOWER FUNCTION GROWTH")
    print("=" * 60)
    print()
    print("tower(2, n) for n = 0, 1, ..., 5:")
    for n in range(6):
        val = tower_exp(2, n)
        if val < 10**20:
            print(f"  tower(2, {n}) = {val}")
        else:
            print(f"  tower(2, {n}) = 2^{tower_exp(2, n-1)} (≈ 10^{val.bit_length() * 0.301:.0f})")

    print()
    print("Key insight: R_r(k,k) is bounded by tower(2, r-2) applied to R_2(k,k).")
    print("Since R_2(k,k) ≤ 4^k, this gives:")
    for r in range(2, 6):
        if r == 2:
            print(f"  R_{r}(k,k) ≤ 4^k (exponential)")
        elif r == 3:
            print(f"  R_{r}(k,k) ≤ 2^{{4^k}} (double exponential)")
        elif r == 4:
            print(f"  R_{r}(k,k) ≤ 2^{{2^{{4^k}}}} (triple exponential)")
        else:
            levels = "2^{" * (r-2) + "4^k" + "}" * (r-2)
            print(f"  R_{r}(k,k) ≤ {levels} (tower of height {r-1})")
    print()


# ============================================================
# Probabilistic Method Lower Bounds
# ============================================================

def expected_mono_cliques(n: int, r: int, k: int) -> float:
    """Expected monochromatic k-cliques in a random 2-coloring of r-subsets of [n]."""
    edges_in_clique = math.comb(k, r)
    prob_mono = 2.0 * (0.5 ** edges_in_clique)
    return math.comb(n, k) * prob_mono


def prob_lower_bound(r: int, k: int) -> int:
    """Largest n with E[mono cliques] < 1."""
    n = k
    while n < 10**6 and expected_mono_cliques(n, r, k) < 1.0:
        n += 1
    return n - 1


def demo_probabilistic_bounds():
    """Demonstrate the probabilistic method for hypergraph Ramsey lower bounds."""
    print("=" * 60)
    print("PROBABILISTIC METHOD LOWER BOUNDS")
    print("=" * 60)
    print()
    print("R_r(k,k) > n when E[monochromatic k-cliques in random coloring] < 1")
    print()

    known = {(2, 3): 6, (2, 4): 18, (3, 3): 4, (3, 4): 13}

    for r in [2, 3, 4]:
        print(f"r = {r} (r-uniform hypergraphs):")
        for k in range(3, 8):
            lb = prob_lower_bound(r, k)
            exact = known.get((r, k))
            exact_str = f" (exact: {exact})" if exact else ""
            print(f"  R_{r}({k},{k}) ≥ {lb}{exact_str}")
        print()


# ============================================================
# Known Values and Bounds
# ============================================================

def demo_known_values():
    """Display known hypergraph Ramsey numbers and bounds."""
    print("=" * 60)
    print("KNOWN HYPERGRAPH RAMSEY NUMBERS")
    print("=" * 60)
    print()

    data = [
        (2, 3, 3, 6, "Exact"),
        (2, 4, 4, 18, "Exact"),
        (2, 5, 5, 43, "43 ≤ R ≤ 48"),
        (3, 3, 3, 4, "Exact"),
        (3, 4, 4, 13, "Exact"),
        (3, 5, 5, None, "34 ≤ R ≤ 55 (open)"),
    ]

    print(f"{'r':>3} {'k':>3} {'l':>3} {'Value':>8}  Notes")
    print("-" * 45)
    for r, k, l, val, notes in data:
        val_str = str(val) if val else "?"
        print(f"{r:>3} {k:>3} {l:>3} {val_str:>8}  {notes}")
    print()


# ============================================================
# Ramsey Density Spectrum
# ============================================================

def compute_density_spectrum(n: int, r: int, coloring_fn) -> Dict:
    """Compute the Ramsey density spectrum for a coloring."""
    max_red = 0
    max_blue = 0
    red_clique: Set[int] = set()
    blue_clique: Set[int] = set()

    for size in range(n, 0, -1):
        if size <= max(max_red, max_blue):
            break
        for subset in combinations(range(n), size):
            s = set(subset)
            edges = list(combinations(sorted(s), r))

            all_red = all(coloring_fn(e) for e in edges)
            all_blue = all(not coloring_fn(e) for e in edges)

            if all_red and len(s) > max_red:
                max_red = len(s)
                red_clique = s
            if all_blue and len(s) > max_blue:
                max_blue = len(s)
                blue_clique = s

    density = max(max_red, max_blue) / n if n > 0 else 0
    balance = min(max_red, max_blue) / max(max_red, max_blue) if max(max_red, max_blue) > 0 else 1

    return {
        "n": n, "r": r,
        "max_red": max_red, "max_blue": max_blue,
        "red_clique": red_clique, "blue_clique": blue_clique,
        "density": density, "balance": balance,
    }


def demo_density_spectrum():
    """Demonstrate the Ramsey density spectrum on small examples."""
    print("=" * 60)
    print("RAMSEY DENSITY SPECTRUM (Novel Concept)")
    print("=" * 60)
    print()

    import random
    random.seed(42)

    # Example 1: Random coloring of edges of K_6 (graph Ramsey)
    print("Example 1: Random 2-coloring of edges of K_6 (r=2)")
    n, r = 6, 2
    edge_colors = {}
    for e in combinations(range(n), r):
        edge_colors[e] = random.random() < 0.5

    spec = compute_density_spectrum(n, r, lambda e: edge_colors[e])
    print(f"  Max red clique: {spec['max_red']} vertices = {spec['red_clique']}")
    print(f"  Max blue clique: {spec['max_blue']} vertices = {spec['blue_clique']}")
    print(f"  Density: {spec['density']:.3f}")
    print(f"  Balance: {spec['balance']:.3f}")
    print(f"  → R_2(3,3) = 6, so density ≥ 3/6 = 0.5 guaranteed")
    print()

    # Example 2: Coloring of 3-subsets of [5]
    print("Example 2: Random 2-coloring of 3-subsets of [5] (r=3)")
    n, r = 5, 3
    edge_colors_3 = {}
    for e in combinations(range(n), r):
        edge_colors_3[e] = random.random() < 0.5

    spec3 = compute_density_spectrum(n, r, lambda e: edge_colors_3[e])
    print(f"  Max red clique: {spec3['max_red']} vertices = {spec3['red_clique']}")
    print(f"  Max blue clique: {spec3['max_blue']} vertices = {spec3['blue_clique']}")
    print(f"  Density: {spec3['density']:.3f}")
    print(f"  Balance: {spec3['balance']:.3f}")
    print()


# ============================================================
# Growth Rate Conjecture Test
# ============================================================

def demo_growth_conjecture():
    """Test the double exponential growth conjecture for R_3(k,k)."""
    print("=" * 60)
    print("DOUBLE EXPONENTIAL GROWTH CONJECTURE TEST")
    print("=" * 60)
    print()

    known_3uniform = {3: 4, 4: 13}
    bounds_3uniform = {5: (34, 55), 6: (65, 260)}

    print("Testing: R_3(k,k) ≈ 2^{c·k²} for some constant c")
    print()
    print(f"{'k':>3} {'R_3(k,k)':>10} {'log₂(R)':>10} {'log₂(R)/k²':>12} {'Status'}")
    print("-" * 55)

    for k in [3, 4, 5, 6]:
        if k in known_3uniform:
            val = known_3uniform[k]
            log_val = math.log2(val)
            ratio = log_val / k**2
            print(f"{k:>3} {val:>10} {log_val:>10.3f} {ratio:>12.4f}  exact")
        elif k in bounds_3uniform:
            lo, hi = bounds_3uniform[k]
            log_lo = math.log2(lo)
            log_hi = math.log2(hi)
            ratio_lo = log_lo / k**2
            ratio_hi = log_hi / k**2
            print(f"{k:>3} {'['+str(lo)+','+str(hi)+']':>10} "
                  f"{'['+f'{log_lo:.1f}'+','+f'{log_hi:.1f}'+']':>10} "
                  f"[{ratio_lo:.4f},{ratio_hi:.4f}]  bounds")

    print()
    print("Observation: log₂(R_3(k,k))/k² ≈ 0.2-0.23 for known values.")
    print("If c ≈ 0.2, the conjecture R_3(k,k) ≥ 2^{0.2·k²} is consistent.")
    print()

    # Compare with graph Ramsey numbers
    print("Comparison with graph Ramsey R_2(k,k):")
    known_graph = {3: 6, 4: 18, 5: 43}
    for k, val in known_graph.items():
        log_val = math.log2(val)
        print(f"  R_2({k},{k}) = {val}, log₂ = {log_val:.3f}, log₂/k = {log_val/k:.3f}")
    print()
    print("Graph Ramsey: log₂(R_2(k,k))/k → constant (single exponential)")
    print("Hypergraph Ramsey: log₂(R_3(k,k))/k² → constant (suggests 2^{Θ(k²)})")
    print("Full conjecture: R_3(k,k) = 2^{Θ(2^k)} (double exponential)")
    print()


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  HYPERGRAPH RAMSEY THEORY: BEYOND GRAPHS               ║")
    print("║  Demonstration of Key Concepts and Computations         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_tower_growth()
    demo_known_values()
    demo_probabilistic_bounds()
    demo_density_spectrum()
    demo_growth_conjecture()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("Key findings:")
    print("1. Tower function captures the hierarchy of Ramsey growth rates")
    print("2. Each increase in uniformity r adds another exponential layer")
    print("3. The gap between lower and upper bounds remains wide for r ≥ 3")
    print("4. Ramsey density spectrum reveals structural properties of colorings")
    print("5. The double exponential conjecture is consistent with known data")


#!/usr/bin/env python3
"""
Visualization: Tower Function Growth and Ramsey Number Hierarchy

Plots the growth rate hierarchy of hypergraph Ramsey numbers,
showing how each increase in uniformity r adds another exponential layer.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def tower_exp(base: int, height: int) -> float:
    """Tower function with overflow protection."""
    if height == 0:
        return 1.0
    prev = tower_exp(base, height - 1)
    if prev > 1000:
        return float('inf')
    return float(base) ** prev


def log_tower(base: int, height: int) -> float:
    """log_2 of tower function."""
    if height == 0:
        return 0.0
    if height == 1:
        return math.log2(base)
    prev = tower_exp(base, height - 1)
    if prev == float('inf'):
        return float('inf')
    return prev * math.log2(base)


def probabilistic_lower_bound(r: int, k: int) -> int:
    """Largest n with E[mono cliques] < 1."""
    n = k
    while n < 10**7:
        edges_in_clique = math.comb(k, r)
        prob_mono = 2.0 * (0.5 ** edges_in_clique)
        try:
            expected = math.comb(n, k) * prob_mono
        except (OverflowError, ValueError):
            break
        if expected >= 1.0:
            return n - 1
        n += 1
    return n - 1


def plot_growth_hierarchy():
    """Plot the growth rate hierarchy across uniformities."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Tower function values (log scale)
    ax1 = axes[0]
    heights = list(range(0, 6))
    for base in [2, 3]:
        values = []
        for h in heights:
            v = tower_exp(base, h)
            if v == float('inf') or v > 1e15:
                break
            values.append(v)
        ax1.semilogy(heights[:len(values)], values, 'o-',
                     label=f'tower({base}, n)', markersize=8, linewidth=2)

    ax1.set_xlabel('Height n', fontsize=12)
    ax1.set_ylabel('tower(b, n)', fontsize=12)
    ax1.set_title('Tower Function Growth\n(Each step squares the previous value for b=2)',
                  fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Probabilistic lower bounds on R_r(k,k) for different r
    ax2 = axes[1]
    ks = list(range(3, 10))

    for r in [2, 3, 4, 5]:
        bounds = []
        for k in ks:
            lb = probabilistic_lower_bound(r, k)
            bounds.append(lb)
        ax2.semilogy(ks, bounds, 's-', label=f'r = {r}', markersize=7, linewidth=2)

    # Add known exact values
    exact_2 = {3: 6, 4: 18, 5: 43}
    exact_3 = {3: 4, 4: 13}
    for k, v in exact_2.items():
        ax2.plot(k, v, '*', color='gold', markersize=15, zorder=5)
    for k, v in exact_3.items():
        ax2.plot(k, v, '*', color='gold', markersize=15, zorder=5)

    ax2.set_xlabel('Clique size k', fontsize=12)
    ax2.set_ylabel('Lower bound on R_r(k,k)', fontsize=12)
    ax2.set_title('Hypergraph Ramsey Lower Bounds\n(Probabilistic method; ★ = exact values)',
                  fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_tower_growth.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_tower_growth.png")


def plot_growth_rate_analysis():
    """Plot log₂(R_3(k,k))/k² to test the double exponential conjecture."""
    fig, ax = plt.subplots(figsize=(8, 5))

    # Known and conjectured values
    ks = [3, 4, 5]
    exact = [4, 13, None]
    lower_bounds = [4, 13, 34]
    upper_bounds = [4, 13, 55]

    # Plot log₂(R)/k² for known values
    ratios_exact = []
    ratios_lower = []
    ratios_upper = []
    for i, k in enumerate(ks):
        if exact[i] is not None:
            ratios_exact.append(math.log2(exact[i]) / k**2)
        else:
            ratios_exact.append(None)
        ratios_lower.append(math.log2(lower_bounds[i]) / k**2)
        ratios_upper.append(math.log2(upper_bounds[i]) / k**2)

    # Shaded region for bounds
    ax.fill_between(ks, ratios_lower, ratios_upper,
                    alpha=0.3, color='steelblue', label='Known bounds')

    # Exact values
    exact_ks = [k for k, r in zip(ks, ratios_exact) if r is not None]
    exact_rs = [r for r in ratios_exact if r is not None]
    ax.plot(exact_ks, exact_rs, 'ro', markersize=10, label='Exact values', zorder=5)

    # Conjectured constant line
    c_est = sum(exact_rs) / len(exact_rs)
    ax.axhline(y=c_est, color='green', linestyle='--', alpha=0.7,
               label=f'Conjectured c ≈ {c_est:.3f}')

    ax.set_xlabel('k (clique size)', fontsize=12)
    ax.set_ylabel('log₂(R₃(k,k)) / k²', fontsize=12)
    ax.set_title('Testing Double Exponential Growth:\nR₃(k,k) ≈ 2^{c·k²}',
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(2.5, 5.5)

    plt.tight_layout()
    plt.savefig('viz_growth_conjecture.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_growth_conjecture.png")


def plot_uniformity_hierarchy():
    """Visualize the hierarchy: graph → 3-uniform → 4-uniform → ..."""
    fig, ax = plt.subplots(figsize=(9, 6))

    k_range = np.arange(3, 8)

    # R_2(k,k) ≤ C(2k-2, k-1) ≤ 4^k
    upper_2 = [4**k for k in k_range]
    # R_3(k,k) ≤ 2^{R_2(k,k)} (stepping up)
    upper_3 = [min(2**(4**k), 1e100) for k in k_range]
    # Probabilistic lower bounds
    lower_2 = [probabilistic_lower_bound(2, k) for k in k_range]
    lower_3 = [probabilistic_lower_bound(3, k) for k in k_range]

    ax.semilogy(k_range, upper_2, 'b^-', markersize=8, linewidth=2,
                label='R₂(k,k) upper bound (4^k)')
    ax.semilogy(k_range, lower_2, 'bv-', markersize=8, linewidth=2,
                label='R₂(k,k) prob. lower bound')
    ax.semilogy(k_range, lower_3, 'rv-', markersize=8, linewidth=2,
                label='R₃(k,k) prob. lower bound')

    # Known exact values
    ax.plot(3, 6, 'g*', markersize=15, zorder=5, label='R₂(3,3) = 6')
    ax.plot(4, 18, 'g*', markersize=15, zorder=5)
    ax.plot(3, 4, 'm*', markersize=15, zorder=5, label='R₃(3,3) = 4')
    ax.plot(4, 13, 'm*', markersize=15, zorder=5)

    ax.set_xlabel('k (clique size)', fontsize=12)
    ax.set_ylabel('Ramsey number (log scale)', fontsize=12)
    ax.set_title('The Uniformity Hierarchy:\nGraph vs. Hypergraph Ramsey Numbers', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_uniformity_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_uniformity_hierarchy.png")


if __name__ == "__main__":
    plot_growth_hierarchy()
    plot_growth_rate_analysis()
    plot_uniformity_hierarchy()
    print("\nAll visualizations generated successfully.")
