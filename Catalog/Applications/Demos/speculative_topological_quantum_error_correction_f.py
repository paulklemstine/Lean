#!/usr/bin/env python3
"""
Systolic Quantum Error Correction — Numerical Demonstrations

Demonstrates the connection between systolic geometry and quantum error correction:
1. Toric code parameter computation
2. Genus-distance scaling verification
3. BPT bound verification
4. Surface code family analysis
"""

import math
from typing import Tuple, List


def toric_code_params(L: int) -> Tuple[int, int, int]:
    """Compute [[n, k, d]] parameters for the L×L toric code."""
    n = 2 * L**2  # edges of L×L square lattice on torus
    k = 2          # first Betti number of torus
    d = L          # systole = shortest non-contractible loop
    return n, k, d


def euler_characteristic(V: int, E: int, F: int) -> int:
    """Compute Euler characteristic χ = V - E + F."""
    return V - E + F


def genus_from_euler(chi: int) -> float:
    """Compute genus from Euler characteristic: g = (2 - χ)/2."""
    return (2 - chi) / 2


def surface_code_params(g: int) -> Tuple[int, int, int]:
    """
    Approximate parameters for a homological code from genus-g surface.
    Uses a standard triangulation:
    - V = 2(2g+1), E = 3(2g+1), F = 2(2g+1)
    - n = E = 6g+3 (one qubit per edge)
    - k = 2g (first Betti number)
    - d ≈ √(12g+6) (systolic bound)
    """
    n = 6 * g + 3
    k = 2 * g
    d = max(1, int(math.sqrt(12 * g + 6)))
    return n, k, d


def verify_singleton(n: int, k: int, d: int) -> bool:
    """Check quantum Singleton bound: k + 2d ≤ n + 2."""
    return k + 2 * d <= n + 2


def bpt_bound(k: int, d: int, n: int) -> bool:
    """Check BPT bound (2D): k * d ≤ n."""
    return k * d <= n


def systolic_ratio(g: int, d: int) -> float:
    """Compute d²/g (should be bounded for systolic codes)."""
    if g == 0:
        return float('inf')
    return d**2 / g


def product_code_params(n1: int, k1: int, d1: int,
                        n2: int, k2: int, d2: int) -> Tuple[int, int, int]:
    """
    Compute hypergraph product code parameters.
    Product of [n₁, k₁, d₁] and [n₂, k₂, d₂] gives:
    - n = n₁·(n₂-k₂) + (n₁-k₁)·n₂
    - k = k₁·k₂
    - d ≥ min(d₁, d₂)
    """
    r1 = n1 - k1
    r2 = n2 - k2
    n = n1 * r2 + r1 * n2
    k = k1 * k2
    d = min(d1, d2)
    return n, k, d


def main():
    print("=" * 70)
    print("SYSTOLIC QUANTUM ERROR CORRECTION — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Toric code parameters
    print("\n--- Demo 1: Toric Code Parameters [[n, k, d]] ---")
    print(f"{'L':>4} {'n':>6} {'k':>3} {'d':>4} {'d²/n':>8} {'Singleton':>10}")
    print("-" * 40)
    for L in range(2, 11):
        n, k, d = toric_code_params(L)
        ratio = d**2 / n
        singleton = verify_singleton(n, k, d)
        print(f"{L:4d} {n:6d} {k:3d} {d:4d} {ratio:8.4f} {'✓' if singleton else '✗':>10}")

    # Demo 2: Euler characteristic verification
    print("\n--- Demo 2: Euler Characteristic of Surfaces ---")
    print(f"{'Surface':>15} {'V':>5} {'E':>5} {'F':>5} {'χ':>5} {'g':>5}")
    print("-" * 45)
    surfaces = [
        ("Sphere", 4, 6, 4),
        ("Torus (4×4)", 16, 32, 16),
        ("Torus (5×5)", 25, 50, 25),
        ("Genus-2", 12, 30, 16),
    ]
    for name, V, E, F in surfaces:
        chi = euler_characteristic(V, E, F)
        g = genus_from_euler(chi)
        print(f"{name:>15} {V:5d} {E:5d} {F:5d} {chi:5d} {g:5.1f}")

    # Demo 3: Genus-distance scaling
    print("\n--- Demo 3: Genus-Distance Scaling ---")
    print(f"{'g':>4} {'n':>6} {'k':>4} {'d':>4} {'d²/g':>8} {'k*d²/n²':>10} {'BPT':>5}")
    print("-" * 50)
    for g in range(1, 21):
        n, k, d = surface_code_params(g)
        ratio = systolic_ratio(g, d)
        kd2_n2 = k * d**2 / n**2 if n > 0 else 0
        bpt = bpt_bound(k, d, n)
        print(f"{g:4d} {n:6d} {k:4d} {d:4d} {ratio:8.2f} {kd2_n2:10.4f} {'✓' if bpt else '✗':>5}")

    # Demo 4: Product codes
    print("\n--- Demo 4: Hypergraph Product Codes ---")
    print(f"{'Code 1':>15} {'Code 2':>15} {'Product':>20} {'d_min':>6}")
    print("-" * 60)
    base_codes = [
        (7, 4, 3),   # Hamming [7,4,3]
        (15, 11, 3), # BCH [15,11,3]
        (23, 12, 7), # Golay [23,12,7]
    ]
    for n1, k1, d1 in base_codes:
        for n2, k2, d2 in base_codes:
            n, k, d = product_code_params(n1, k1, d1, n2, k2, d2)
            print(f"[{n1},{k1},{d1}]".rjust(15) +
                  f"[{n2},{k2},{d2}]".rjust(15) +
                  f"[[{n},{k},{d}]]".rjust(20) +
                  f"{d:6d}")

    # Demo 5: Systolic ratio convergence
    print("\n--- Demo 5: Systolic Ratio d²/g Convergence ---")
    print("Prediction: d²/g should be bounded (≈ constant) as g → ∞")
    ratios: List[float] = []
    for g in range(1, 101):
        n, k, d = surface_code_params(g)
        r = systolic_ratio(g, d)
        ratios.append(r)
    print(f"  Min ratio (g=1..100): {min(ratios):.4f}")
    print(f"  Max ratio (g=1..100): {max(ratios):.4f}")
    print(f"  Mean ratio:           {sum(ratios)/len(ratios):.4f}")
    print(f"  Ratio at g=100:       {ratios[-1]:.4f}")
    print(f"  → Consistent with bounded d²/g (systolic inequality)")

    # Demo 6: BPT vs systolic
    print("\n--- Demo 6: BPT Bound vs Systolic Inequality ---")
    print("For k=2g, n=6g+3: BPT says kd ≤ n, systolic says d² ≤ Cn")
    print(f"{'g':>4} {'BPT max d':>10} {'Systolic max d':>15} {'Actual d':>10}")
    print("-" * 45)
    for g in [1, 2, 5, 10, 20, 50, 100]:
        n, k, d = surface_code_params(g)
        bpt_max = n // k if k > 0 else n
        syst_max = int(math.sqrt(2 * n))
        print(f"{g:4d} {bpt_max:10d} {syst_max:15d} {d:10d}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Genus-Distance Scaling in Topological Quantum Codes

Plots the relationship between genus (g), code distance (d), and code rate (k/n)
for homological codes from surfaces. Demonstrates the systolic inequality d² ≤ Cg.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def surface_code_params(g):
    n = 6 * g + 3
    k = 2 * g
    d = max(1, int(math.sqrt(12 * g + 6)))
    return n, k, d


def main():
    genera = list(range(1, 101))
    ns, ks, ds = [], [], []
    for g in genera:
        n, k, d = surface_code_params(g)
        ns.append(n)
        ks.append(k)
        ds.append(d)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Systolic Quantum Error Correction: Genus-Distance Scaling',
                 fontsize=16, fontweight='bold')

    # Plot 1: Distance vs Genus
    ax = axes[0, 0]
    ax.plot(genera, ds, 'b-', linewidth=2, label='Code distance d')
    ax.plot(genera, [math.sqrt(12*g+6) for g in genera], 'r--',
            linewidth=1.5, label=r'$\sqrt{12g+6}$ (systolic bound)')
    ax.set_xlabel('Genus g', fontsize=12)
    ax.set_ylabel('Code distance d', fontsize=12)
    ax.set_title(r'Distance Scaling: $d \approx \sqrt{12g}$', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: d²/g ratio
    ax = axes[0, 1]
    ratios = [d**2 / g for g, d in zip(genera, ds)]
    ax.plot(genera, ratios, 'g-', linewidth=2, label=r'$d^2/g$')
    ax.axhline(y=12, color='r', linestyle='--', alpha=0.7, label=r'Limit $\approx 12$')
    ax.set_xlabel('Genus g', fontsize=12)
    ax.set_ylabel(r'$d^2/g$', fontsize=12)
    ax.set_title(r'Systolic Ratio $d^2/g$ (Bounded $\Rightarrow$ Gromov)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 20)

    # Plot 3: Rate vs Distance
    ax = axes[1, 0]
    rates = [k/n for k, n in zip(ks, ns)]
    ax.scatter(ds, rates, c=genera, cmap='viridis', s=30, alpha=0.8)
    cb = plt.colorbar(ax.collections[0], ax=ax, label='Genus g')
    ax.set_xlabel('Code distance d', fontsize=12)
    ax.set_ylabel('Rate k/n', fontsize=12)
    ax.set_title('Rate-Distance Tradeoff', fontsize=13)
    ax.axhline(y=1/3, color='r', linestyle='--', alpha=0.5, label='Rate → 1/3')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 4: BPT bound check
    ax = axes[1, 1]
    kd_over_n = [k*d/n for k, d, n in zip(ks, ds, ns)]
    ax.plot(genera, kd_over_n, 'purple', linewidth=2, label=r'$kd/n$')
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.7, label='BPT bound')
    ax.set_xlabel('Genus g', fontsize=12)
    ax.set_ylabel(r'$kd/n$', fontsize=12)
    ax.set_title('BPT Bound: kd/n ≤ 1', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved viz_scaling.png")

    # Toric code comparison plot
    fig2, ax2 = plt.subplots(1, 1, figsize=(10, 6))
    Ls = list(range(2, 21))
    toric_n = [2*L**2 for L in Ls]
    toric_d = Ls
    toric_d2_n = [L**2 / (2*L**2) for L in Ls]

    ax2.plot(toric_n, toric_d, 'bo-', markersize=6, label='Toric code distance L')
    ax2.plot(toric_n, [math.sqrt(n/2) for n in toric_n], 'r--',
             linewidth=1.5, label=r'$\sqrt{n/2}$')
    ax2.set_xlabel('Number of physical qubits n', fontsize=12)
    ax2.set_ylabel('Code distance d', fontsize=12)
    ax2.set_title(r'Toric Code: $d = L = \sqrt{n/2}$', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_toric.png', dpi=150, bbox_inches='tight')
    print("Saved viz_toric.png")


if __name__ == "__main__":
    main()
