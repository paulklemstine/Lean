#!/usr/bin/env python3
"""
Self-Avoiding Walk Demo: Numerical Exploration

Demonstrates key results from the SAW theory formalization:
1. SAW counting on ℤ² for small n
2. Convergence of c(n)^{1/n} to the connective constant
3. Properties of the Nienhuis constant √(2+√2)
4. Tropical phase transition visualization
"""

import math
from itertools import product


def enumerate_saws(n: int) -> list:
    """Enumerate all n-step self-avoiding walks on ℤ² from the origin."""
    directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]  # N, S, E, W
    
    if n == 0:
        return [[(0, 0)]]
    
    saws = []
    stack = [[(0, 0)]]
    
    while stack:
        path = stack.pop()
        if len(path) == n + 1:
            saws.append(path)
            continue
        
        x, y = path[-1]
        visited = set(path)
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                stack.append(path + [(nx, ny)])
    
    return saws


def saw_count(n: int) -> int:
    """Count n-step self-avoiding walks from the origin."""
    return len(enumerate_saws(n))


def main():
    print("=" * 60)
    print("SELF-AVOIDING WALKS ON ℤ²: NUMERICAL EXPLORATION")
    print("=" * 60)
    
    # 1. SAW Counts
    print("\n1. SAW COUNTS c(n)")
    print("-" * 40)
    counts = {}
    for n in range(11):
        c = saw_count(n)
        counts[n] = c
        ratio = c ** (1/n) if n > 0 else float('inf')
        print(f"  c({n:2d}) = {c:>10d}   c(n)^(1/n) = {ratio:.6f}" 
              if n > 0 else f"  c({n:2d}) = {c:>10d}")
    
    # 2. Submultiplicativity verification
    print("\n2. SUBMULTIPLICATIVITY: c(m+n) ≤ c(m)·c(n)")
    print("-" * 40)
    for m in range(1, 6):
        for n in range(1, 6):
            if m + n <= 10:
                lhs = counts[m + n]
                rhs = counts[m] * counts[n]
                ok = "✓" if lhs <= rhs else "✗"
                print(f"  c({m}+{n}) = {lhs:>8d} ≤ c({m})·c({n}) = {rhs:>8d}  {ok}")
    
    # 3. Nienhuis constant
    print("\n3. NIENHUIS CONSTANT: μ_hex = √(2+√2)")
    print("-" * 40)
    sqrt2 = math.sqrt(2)
    nienhuis = math.sqrt(2 + sqrt2)
    xc = 1 / nienhuis
    
    print(f"  √2 = {sqrt2:.10f}")
    print(f"  2 + √2 = {2 + sqrt2:.10f}")
    print(f"  μ_hex = √(2+√2) = {nienhuis:.10f}")
    print(f"  x_c = 1/μ_hex = {xc:.10f}")
    print()
    print(f"  Minimal polynomial: μ⁴ - 4μ² + 2 = {nienhuis**4 - 4*nienhuis**2 + 2:.2e}")
    print(f"  Fugacity polynomial: 2x_c⁴ - 4x_c² + 1 = {2*xc**4 - 4*xc**2 + 1:.2e}")
    print(f"  Conjugate product: (2+√2)(2-√2) = {(2+sqrt2)*(2-sqrt2):.10f}")
    print(f"  1 < μ_hex < 2: {1 < nienhuis < 2}")
    
    # 4. Connective constant bounds
    print("\n4. CONNECTIVE CONSTANT BOUNDS")
    print("-" * 40)
    mu_approx = counts[10] ** (1/10)
    print(f"  Lower bound: μ ≥ 2 (walks using only N,E)")
    print(f"  Upper bound: μ ≤ 4 (at most 4^n walks)")
    print(f"  Estimate from c(10): c(10)^(1/10) = {mu_approx:.6f}")
    print(f"  Known value: μ ≈ 2.6381585...")
    
    # 5. Tropical phase transition
    print("\n5. TROPICAL PHASE TRANSITION")
    print("-" * 40)
    log_mu = math.log(mu_approx)
    print(f"  log(μ) ≈ {log_mu:.6f}")
    print(f"  Subcritical (β < log μ): tropical partition unbounded")
    print(f"  Supercritical (β > log μ): tropical partition bounded ≤ 0")
    for beta in [0.5, 0.8, 0.97, 1.0, 1.1, 1.5]:
        vals = [n * log_mu - beta * n for n in range(20)]
        sup_val = max(vals)
        phase = "subcritical" if beta < log_mu else "supercritical"
        print(f"    β = {beta:.2f} ({phase:>13s}): sup_n(n·log μ - β·n) = {sup_val:.4f}")
    
    # 6. Bridge-like walks
    print("\n6. BRIDGE WALKS (y-coordinate monotone)")
    print("-" * 40)
    for n in range(1, 8):
        saws = enumerate_saws(n)
        bridges = []
        for path in saws:
            # Check if y-coordinate is strictly increasing
            ys = [p[1] for p in path]
            if all(ys[i] < ys[i+1] for i in range(len(ys)-1)):
                bridges.append(path)
        print(f"  n={n}: {len(bridges):>5d} bridges out of {len(saws):>8d} SAWs "
              f"(ratio = {len(bridges)/len(saws):.4f})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Self-Avoiding Walks and Connective Constant

Generates plots showing:
1. Sample self-avoiding walks on ℤ²
2. Convergence of c(n)^{1/n} to the connective constant
3. The Nienhuis constant and its minimal polynomial
"""

import math
from typing import List, Tuple, Set

# Inline SAW enumeration
def enumerate_saws(n: int) -> list:
    if n == 0:
        return [[(0, 0)]]
    result = []
    def bt(path, visited):
        if len(path) == n + 1:
            result.append(list(path))
            return
        x, y = path[-1]
        for dx, dy in [(0,1),(0,-1),(1,0),(-1,0)]:
            nx, ny = x+dx, y+dy
            if (nx,ny) not in visited:
                path.append((nx,ny))
                visited.add((nx,ny))
                bt(path, visited)
                path.pop()
                visited.discard((nx,ny))
    bt([(0,0)], {(0,0)})
    return result

def saw_count(n: int) -> int:
    return len(enumerate_saws(n))


try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping plots")


def plot_sample_walks():
    """Plot sample self-avoiding walks of various lengths."""
    if not HAS_MPL:
        return
    
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Sample Self-Avoiding Walks on ℤ²', fontsize=16, fontweight='bold')
    
    import random
    random.seed(42)
    
    for idx, n in enumerate([5, 8, 10, 12, 15, 18]):
        ax = axes[idx // 3][idx % 3]
        
        # Generate a random SAW using pivot algorithm (simplified)
        walk = [(0, 0)]
        visited = {(0, 0)}
        attempts = 0
        while len(walk) <= n and attempts < 100000:
            x, y = walk[-1]
            dirs = [(0,1),(0,-1),(1,0),(-1,0)]
            random.shuffle(dirs)
            moved = False
            for dx, dy in dirs:
                nx, ny = x+dx, y+dy
                if (nx,ny) not in visited:
                    walk.append((nx,ny))
                    visited.add((nx,ny))
                    moved = True
                    break
            if not moved:
                walk = [(0,0)]
                visited = {(0,0)}
                attempts += 1
        
        xs = [p[0] for p in walk]
        ys = [p[1] for p in walk]
        
        ax.plot(xs, ys, 'b-', linewidth=2, alpha=0.7)
        ax.plot(xs[0], ys[0], 'go', markersize=10, label='Start')
        ax.plot(xs[-1], ys[-1], 'ro', markersize=10, label='End')
        ax.set_title(f'n = {n} steps', fontsize=12)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('saw_samples.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved saw_samples.png")


def plot_connective_constant():
    """Plot convergence of c(n)^{1/n} to μ."""
    if not HAS_MPL:
        return
    
    ns = list(range(1, 15))
    counts = [saw_count(n) for n in ns]
    estimates = [c ** (1.0/n) for c, n in zip(counts, ns)]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: c(n) on log scale
    ax1.semilogy(ns, counts, 'bo-', markersize=8, linewidth=2)
    mu_approx = 2.6381585
    ax1.semilogy(ns, [mu_approx**n for n in ns], 'r--', alpha=0.7, 
                 label=f'μⁿ (μ ≈ {mu_approx})')
    ax1.set_xlabel('Walk length n', fontsize=12)
    ax1.set_ylabel('c(n) (log scale)', fontsize=12)
    ax1.set_title('SAW Count Growth', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: c(n)^{1/n} convergence
    ax2.plot(ns, estimates, 'bo-', markersize=8, linewidth=2, label='c(n)^{1/n}')
    ax2.axhline(y=mu_approx, color='r', linestyle='--', alpha=0.7, 
                label=f'μ ≈ {mu_approx}')
    ax2.axhline(y=2, color='g', linestyle=':', alpha=0.5, label='Lower bound = 2')
    ax2.axhline(y=4, color='orange', linestyle=':', alpha=0.5, label='Upper bound = 4')
    ax2.set_xlabel('Walk length n', fontsize=12)
    ax2.set_ylabel('c(n)^{1/n}', fontsize=12)
    ax2.set_title('Connective Constant Convergence', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(1.5, 4.5)
    
    plt.tight_layout()
    plt.savefig('connective_constant.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved connective_constant.png")


def plot_nienhuis():
    """Plot the Nienhuis minimal polynomial and related functions."""
    if not HAS_MPL:
        return
    
    x = np.linspace(0, 2.5, 500)
    poly = x**4 - 4*x**2 + 2
    
    nienhuis = math.sqrt(2 + math.sqrt(2))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Minimal polynomial
    ax1.plot(x, poly, 'b-', linewidth=2, label='p(x) = x⁴ - 4x² + 2')
    ax1.axhline(y=0, color='k', linewidth=0.5)
    ax1.axvline(x=nienhuis, color='r', linestyle='--', alpha=0.7,
                label=f'μ_hex = √(2+√2) ≈ {nienhuis:.4f}')
    ax1.plot(nienhuis, 0, 'ro', markersize=10)
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('p(x)', fontsize=12)
    ax1.set_title('Minimal Polynomial of the Nienhuis Constant', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-3, 5)
    
    # Plot 2: Critical fugacity polynomial
    xc_range = np.linspace(0, 1, 500)
    fug_poly = 2*xc_range**4 - 4*xc_range**2 + 1
    xc = 1/nienhuis
    
    ax2.plot(xc_range, fug_poly, 'b-', linewidth=2, label='q(x) = 2x⁴ - 4x² + 1')
    ax2.axhline(y=0, color='k', linewidth=0.5)
    ax2.axvline(x=xc, color='r', linestyle='--', alpha=0.7,
                label=f'x_c = 1/μ_hex ≈ {xc:.4f}')
    ax2.plot(xc, 0, 'ro', markersize=10)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('q(x)', fontsize=12)
    ax2.set_title('Critical Fugacity Polynomial', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('nienhuis_polynomial.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved nienhuis_polynomial.png")


if __name__ == "__main__":
    plot_sample_walks()
    plot_connective_constant()
    plot_nienhuis()
    print("\nAll visualizations generated!")
