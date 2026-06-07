#!/usr/bin/env python3
"""
Demo: Surreal Topology — Visualizing the Completeness-Connectedness Bridge

Demonstrates:
1. Gap detection in dyadic rational approximations
2. Connected component computation for finite ordered sets
3. The contrast between ℚ-like (totally disconnected) and ℝ-like (connected) spaces
"""

from fractions import Fraction
import math


def dyadic_rationals(n: int) -> list[Fraction]:
    """Generate dyadic rationals k/2^n for |k| ≤ 2^n, sorted."""
    bound = 2**n
    return sorted(set(Fraction(k, bound) for k in range(-bound, bound + 1)))


def find_gaps(points: list[Fraction], threshold: float = 0.1) -> list[tuple[Fraction, Fraction, float]]:
    """Find gaps in a finite ordered set exceeding a threshold."""
    gaps = []
    for i in range(len(points) - 1):
        gap_size = float(points[i + 1] - points[i])
        if gap_size > threshold:
            gaps.append((points[i], points[i + 1], gap_size))
    return sorted(gaps, key=lambda x: -x[2])


def connected_components_threshold(points: list[float], epsilon: float) -> list[list[float]]:
    """Compute approximate connected components using ε-threshold.
    
    Two points are in the same component if they can be connected
    by a chain of points each within ε of the next.
    """
    if not points:
        return []
    sorted_pts = sorted(points)
    components = [[sorted_pts[0]]]
    for p in sorted_pts[1:]:
        if p - components[-1][-1] <= epsilon:
            components[-1].append(p)
        else:
            components.append([p])
    return components


def contraction_homotopy(x: float, t: float) -> float:
    """H(x, t) = (1-t) * x — contracts ℝ to the origin."""
    return (1 - t) * x


def demonstrate_gap_bridge():
    """Demonstrate the Dedekind Gap Bridge: gaps ↔ disconnectedness."""
    print("=" * 60)
    print("THE DEDEKIND GAP BRIDGE")
    print("Gaps in the order ↔ Disconnectedness of the topology")
    print("=" * 60)
    
    # ℚ has gaps (at irrationals)
    print("\n--- ℚ-like spaces: gaps everywhere ---")
    rationals_approx = [Fraction(p, q) for q in range(1, 20) for p in range(-2*q, 2*q+1)]
    rationals_approx = sorted(set(rationals_approx))
    rationals_in_unit = [r for r in rationals_approx if 0 < r < 1]
    
    # Check for gap at √2/2 ≈ 0.7071
    sqrt2_over_2 = math.sqrt(2) / 2
    below = [float(r) for r in rationals_in_unit if float(r) < sqrt2_over_2]
    above = [float(r) for r in rationals_in_unit if float(r) > sqrt2_over_2]
    
    if below and above:
        gap = above[0] - below[-1]
        print(f"  Gap at √2/2 ≈ {sqrt2_over_2:.4f}")
        print(f"  Largest rational below: {below[-1]:.4f}")
        print(f"  Smallest rational above: {above[0]:.4f}")
        print(f"  Gap size: {gap:.6f}")
        print(f"  → This gap DISCONNECTS the rationals!")
    
    # ℝ has no gaps
    print("\n--- ℝ-like spaces: no gaps ---")
    reals_approx = sorted([i * 0.001 for i in range(1, 1000)])
    gaps = find_gaps([Fraction(r).limit_denominator(10000) for r in reals_approx], 0.002)
    print(f"  Approximation with 999 evenly-spaced points in (0,1)")
    print(f"  Gaps exceeding 0.002: {len(gaps)}")
    print(f"  → Dense approximation has NO significant gaps")
    
    # Connected components
    print("\n--- Connected Components ---")
    rat_points = [float(r) for r in rationals_in_unit[:30]]
    for eps in [0.001, 0.01, 0.05]:
        comps = connected_components_threshold(rat_points, eps)
        print(f"  ε = {eps}: {len(comps)} connected components "
              f"(max size: {max(len(c) for c in comps)})")
    
    print(f"\n  As ε → 0, every point becomes its own component")
    print(f"  → Total disconnectedness of ℚ!")


def demonstrate_contraction():
    """Demonstrate contractibility of ℝ."""
    print("\n" + "=" * 60)
    print("CONTRACTIBILITY OF ℝ")
    print("H(x, t) = (1-t)·x contracts ℝ to the origin")
    print("=" * 60)
    
    test_points = [-3.0, -1.5, -0.5, 0.0, 0.5, 1.5, 3.0]
    times = [0.0, 0.25, 0.5, 0.75, 1.0]
    
    print(f"\n  {'x':>6} | ", end="")
    for t in times:
        print(f"  t={t:<4} |", end="")
    print()
    print("  " + "-" * 55)
    
    for x in test_points:
        print(f"  {x:>6.1f} | ", end="")
        for t in times:
            h = contraction_homotopy(x, t)
            print(f"  {h:>5.2f} |", end="")
        print()
    
    print(f"\n  At t=1, all points map to 0: ℝ contracts to a point!")
    print(f"  → π₁(ℝ) = 0 (trivial fundamental group)")


def demonstrate_cantor_isomorphism():
    """Demonstrate Cantor's theorem: all countable dense orders ≅ ℚ."""
    print("\n" + "=" * 60)
    print("CANTOR'S ISOMORPHISM THEOREM")
    print("All countable dense linear orders without endpoints ≅ ℚ")
    print("=" * 60)
    
    # Dyadic rationals ≅ ℚ
    for n in range(2, 7):
        dyadics = dyadic_rationals(n)
        dyadics_in_unit = [d for d in dyadics if 0 < d < 1]
        if len(dyadics_in_unit) >= 2:
            mg = max(float(dyadics_in_unit[i+1] - dyadics_in_unit[i]) for i in range(len(dyadics_in_unit)-1))
            print(f"  Day {n}: {len(dyadics_in_unit)} dyadic rationals in (0,1), max gap = {mg:.4f}")
        else:
            print(f"  Day {n}: {len(dyadics_in_unit)} dyadic rationals in (0,1)")
    
    print(f"\n  As n → ∞, dyadics become dense → isomorphic to ℚ")
    print(f"  → All are TOTALLY DISCONNECTED (Theorem 7)")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  SURREAL TOPOLOGY: The Shape of Ordered Continua       ║")
    print("║  Demonstrating the Completeness-Connectedness Bridge   ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    demonstrate_gap_bridge()
    demonstrate_contraction()
    demonstrate_cantor_isomorphism()
    
    print("\n" + "=" * 60)
    print("SUMMARY: THE COMPLETENESS-CONNECTEDNESS BRIDGE")
    print("=" * 60)
    print("""
  ┌─────────────────────┬────────────────────────┐
  │ Order Property      │ Topological Property   │
  ├─────────────────────┼────────────────────────┤
  │ Has Dedekind gaps   │ Disconnected           │
  │ No Dedekind gaps    │ Connected              │
  │ Cond. complete+dense│ Locally connected      │
  │ Complete field+TVS  │ Contractible           │
  │ Countable + dense   │ Totally disconnected   │
  └─────────────────────┴────────────────────────┘
  
  The surreal numbers, being gap-free, are connected.
  Being complete, they are contractible.
  Their topology is the simplest possible: a point.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Dedekind Gap Bridge
Shows how gaps in the rationals correspond to disconnections.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction
import math


def plot_gap_bridge():
    """Create the main gap bridge visualization."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("The Dedekind Gap Bridge: Completeness ↔ Connectedness", 
                 fontsize=16, fontweight='bold')
    
    # Panel 1: ℚ with gaps visible
    ax1 = axes[0, 0]
    rats = sorted(set(Fraction(p, q) for q in range(1, 30) 
                      for p in range(-2*q, 2*q+1)))
    rats_01 = [float(r) for r in rats if 0 < r < 2]
    ax1.scatter(rats_01, [0]*len(rats_01), s=1, c='blue', alpha=0.5)
    
    # Highlight gap at √2
    sqrt2 = math.sqrt(2)
    ax1.axvline(x=sqrt2, color='red', linestyle='--', linewidth=2, 
                label=f'√2 ≈ {sqrt2:.4f}')
    ax1.axvspan(sqrt2 - 0.02, sqrt2 + 0.02, alpha=0.3, color='red',
                label='Dedekind gap')
    ax1.set_title('ℚ: Gaps at every irrational → Totally Disconnected')
    ax1.set_xlabel('x')
    ax1.legend(fontsize=8)
    ax1.set_yticks([])
    
    # Panel 2: ℝ with no gaps
    ax2 = axes[0, 1]
    x_real = np.linspace(0, 2, 10000)
    ax2.scatter(x_real, [0]*len(x_real), s=0.1, c='green', alpha=0.3)
    ax2.axvline(x=sqrt2, color='green', linestyle='-', linewidth=2,
                label=f'√2 ∈ ℝ (no gap!)')
    ax2.set_title('ℝ: No gaps → Connected (Contractible)')
    ax2.set_xlabel('x')
    ax2.legend(fontsize=8)
    ax2.set_yticks([])
    
    # Panel 3: Connected components of ℚ at various ε
    ax3 = axes[1, 0]
    epsilons = np.logspace(-3, -0.5, 50)
    n_components = []
    test_rats = sorted(set(float(Fraction(p, q)) for q in range(1, 25) 
                           for p in range(1, q)))
    test_rats = [r for r in test_rats if 0 < r < 1]
    
    for eps in epsilons:
        count = 1
        for i in range(len(test_rats) - 1):
            if test_rats[i+1] - test_rats[i] > eps:
                count += 1
        n_components.append(count)
    
    ax3.semilogx(epsilons, n_components, 'b-', linewidth=2)
    ax3.set_title('ℚ: Connected Components vs. ε-threshold')
    ax3.set_xlabel('ε (threshold)')
    ax3.set_ylabel('Number of components')
    ax3.axhline(y=len(test_rats), color='r', linestyle='--', alpha=0.5,
                label=f'n={len(test_rats)} (totally disconnected)')
    ax3.axhline(y=1, color='g', linestyle='--', alpha=0.5,
                label='1 (connected)')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    
    # Panel 4: Contraction homotopy
    ax4 = axes[1, 1]
    t_values = np.linspace(0, 1, 100)
    x_starts = [-3, -2, -1, -0.5, 0.5, 1, 2, 3]
    colors = plt.cm.RdYlBu(np.linspace(0, 1, len(x_starts)))
    
    for x0, color in zip(x_starts, colors):
        trajectory = [(1 - t) * x0 for t in t_values]
        ax4.plot(t_values, trajectory, color=color, linewidth=2, alpha=0.7)
    
    ax4.scatter([1]*len(x_starts), [0]*len(x_starts), c='black', s=50, 
                zorder=5, label='All contract to 0')
    ax4.set_title('ℝ is Contractible: H(x,t) = (1-t)·x')
    ax4.set_xlabel('t (time)')
    ax4.set_ylabel('H(x, t)')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('gap_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved gap_bridge.png")


def plot_dyadic_convergence():
    """Show dyadic rationals converging to the reals."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 3))
    fig.suptitle("Dyadic Approximations: Day n → Connected as n → ∞", 
                 fontsize=14, fontweight='bold')
    
    for idx, n in enumerate([1, 2, 4, 8]):
        ax = axes[idx]
        denom = 2**n
        dyadics = [k/denom for k in range(-denom, denom+1) if -1 <= k/denom <= 1]
        
        # Plot points
        ax.scatter(dyadics, [0]*len(dyadics), s=max(1, 20-2*n), 
                   c='blue', alpha=0.6)
        
        # Compute max gap
        gaps = [dyadics[i+1] - dyadics[i] for i in range(len(dyadics)-1)]
        max_gap = max(gaps) if gaps else 0
        
        ax.set_title(f'Day {n}\n{len(dyadics)} pts, max gap={max_gap:.4f}',
                     fontsize=10)
        ax.set_xlim(-1.1, 1.1)
        ax.set_yticks([])
    
    plt.tight_layout()
    plt.savefig('dyadic_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved dyadic_convergence.png")


if __name__ == "__main__":
    plot_gap_bridge()
    plot_dyadic_convergence()
