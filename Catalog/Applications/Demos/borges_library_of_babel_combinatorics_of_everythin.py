#!/usr/bin/env python3
"""
Demo: The Library of Babel — Combinatorics of Everything

Numerical examples illustrating key theorems about the Babel space.
"""

import math
from typing import List, Tuple

# Constants from Borges
BABEL_ALPHA = 25  # 22 letters + period + comma + space
BABEL_LENGTH = 1312000  # 410 pages × 40 lines × 80 chars

def babel_cardinality(alpha: int, n: int) -> int:
    """Total number of books: α^N"""
    return alpha ** n

def compressible_fraction(alpha: int, n: int, m: int) -> float:
    """Fraction of books compressible from length N to M: α^M / α^N = α^{-(N-M)}"""
    return alpha ** (m - n)

def singleton_bound(alpha: int, n: int, d: int) -> int:
    """Maximum code size with minimum distance d: α^(N-d+1)"""
    return alpha ** (n - d + 1)

def hamming_ball_volume(alpha: int, n: int, t: int) -> int:
    """Volume of Hamming ball of radius t: Σ_{k=0}^{t} C(n,k) * (α-1)^k"""
    return sum(math.comb(n, k) * (alpha - 1) ** k for k in range(t + 1))

def sphere_packing_bound(alpha: int, n: int, d: int) -> float:
    """Maximum code size from sphere-packing bound: α^N / V(N, ⌊(d-1)/2⌋)"""
    t = (d - 1) // 2
    vol = hamming_ball_volume(alpha, n, t)
    return alpha ** n / vol


def main():
    print("=" * 70)
    print("THE LIBRARY OF BABEL: COMBINATORICS OF EVERYTHING")
    print("=" * 70)

    # 1. Cardinality
    print("\n1. CARDINALITY OF THE LIBRARY")
    print(f"   Alphabet size: {BABEL_ALPHA}")
    print(f"   Book length:   {BABEL_LENGTH:,} characters")
    log_card = BABEL_LENGTH * math.log10(BABEL_ALPHA)
    print(f"   Total books:   25^1312000 ≈ 10^{log_card:,.0f}")
    print(f"   (Compare: observable universe has ~10^80 atoms)")
    print(f"   The library has ~10^{log_card - 80:,.0f} times more books than atoms!")

    # 2. Incompressibility
    print("\n2. INCOMPRESSIBILITY (Exponential Decay)")
    print("   Fraction of books compressible to ratio r of original length:")
    for r in [0.99, 0.9, 0.5, 0.1]:
        m = int(r * BABEL_LENGTH)
        frac = compressible_fraction(BABEL_ALPHA, BABEL_LENGTH, m)
        log_frac = (m - BABEL_LENGTH) * math.log10(BABEL_ALPHA)
        print(f"   r = {r:.2f}: ≤ 10^{log_frac:,.0f}")

    # 3. Small examples
    print("\n3. SMALL EXAMPLES")
    for alpha, n in [(2, 8), (3, 5), (25, 3)]:
        total = babel_cardinality(alpha, n)
        print(f"\n   α={alpha}, N={n}: {total} total books")
        for m in range(1, n):
            comp = babel_cardinality(alpha, m)
            frac = comp / total
            print(f"     Compressible to M={m}: ≤ {comp}/{total} = {frac:.4f}")

    # 4. Singleton bound examples
    print("\n4. SINGLETON BOUND (Coding Theory Bridge)")
    for alpha, n, d in [(2, 7, 3), (2, 15, 7), (3, 11, 5), (25, 10, 4)]:
        sb = singleton_bound(alpha, n, d)
        spb = sphere_packing_bound(alpha, n, d)
        print(f"   α={alpha}, N={n}, d={d}: Singleton ≤ {sb}, "
              f"Sphere-packing ≤ {spb:.1f}")

    # 5. Hamming ball volumes
    print("\n5. HAMMING BALL VOLUMES")
    for alpha, n in [(2, 15), (25, 10)]:
        print(f"\n   α={alpha}, N={n}:")
        for t in range(min(5, n + 1)):
            vol = hamming_ball_volume(alpha, n, t)
            total = alpha ** n
            frac = vol / total
            print(f"     V(N,{t}) = {vol:>15,}  "
                  f"({frac:.6f} of total space)")

    # 6. Automorphism group
    print("\n6. AUTOMORPHISM GROUP (Wreath Product)")
    for alpha, n in [(2, 3), (3, 2), (25, 2)]:
        coord_perms = math.factorial(n)
        symbol_perms = math.factorial(alpha) ** n
        total = coord_perms * symbol_perms
        print(f"   α={alpha}, N={n}: |Aut| = {n}! × ({alpha}!)^{n} = {total:,}")

    # 7. Infinite Babel space topology
    print("\n7. INFINITE BABEL SPACE (Cantor Topology)")
    print("   ℕ → Fin α with α ≥ 2:")
    print("   • Compact (Tychonoff)")
    print("   • Totally disconnected")
    print("   • Metrizable")
    print("   • No isolated points (perfect)")
    print("   → Homeomorphic to the Cantor set!")

    # 8. Module structure
    print("\n8. VECTOR SPACE BRIDGE (α = p prime)")
    for p, n in [(2, 8), (3, 5), (5, 4)]:
        dim = n
        total = p ** n
        print(f"   F_{p} (p={p}), N={n}: "
              f"dim = {dim}, |space| = {total}")

    print("\n" + "=" * 70)
    print("All results formally verified in Lean 4.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Exponential Decay of Compressible Books

Shows how the fraction of compressible books decays exponentially
as the compression ratio decreases, for various alphabet sizes.
"""

import math

def compressible_log_fraction(alpha: int, n: int, ratio: float) -> float:
    """Log10 of the fraction of books compressible to ratio*N symbols."""
    m = int(ratio * n)
    return (m - n) * math.log10(alpha)

def hamming_ball_volume(alpha: int, n: int, t: int) -> int:
    """Volume of Hamming ball of radius t in F_alpha^n."""
    return sum(math.comb(n, k) * (alpha - 1) ** k for k in range(min(t + 1, n + 1)))

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available. Printing text output instead.")
        print("\nCompressible fraction (log10) for alpha=2, N=100:")
        for r in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]:
            lf = compressible_log_fraction(2, 100, r)
            print(f"  ratio={r:.1f}: 10^{lf:.1f}")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Exponential decay of compressible fraction
    ax1 = axes[0]
    ratios = np.linspace(0.01, 0.99, 200)
    for alpha in [2, 3, 5, 25]:
        n = 100
        log_fracs = [(int(r * n) - n) * math.log10(alpha) for r in ratios]
        ax1.plot(ratios, log_fracs, label=f'α={alpha}', linewidth=2)
    ax1.set_xlabel('Compression ratio r = M/N', fontsize=12)
    ax1.set_ylabel('log₁₀(compressible fraction)', fontsize=12)
    ax1.set_title('Exponential Incompressibility Decay\n(N=100)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-150, 5)

    # Plot 2: Singleton bound vs sphere-packing bound
    ax2 = axes[1]
    n = 31
    alpha = 2
    ds = range(1, n + 1)
    singleton = [alpha ** (n - d + 1) for d in ds]
    sp_bounds = []
    for d in ds:
        t = (d - 1) // 2
        vol = hamming_ball_volume(alpha, n, t)
        sp_bounds.append(alpha ** n / vol)
    ax2.semilogy(list(ds), singleton, 'b-o', label='Singleton bound', markersize=3, linewidth=2)
    ax2.semilogy(list(ds), sp_bounds, 'r-s', label='Sphere-packing bound', markersize=3, linewidth=2)
    ax2.set_xlabel('Minimum distance d', fontsize=12)
    ax2.set_ylabel('Maximum code size |C|', fontsize=12)
    ax2.set_title(f'Code Size Bounds\n(α={alpha}, N={n})', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Hamming ball volume growth
    ax3 = axes[2]
    for alpha in [2, 3, 5]:
        n = 50
        ts = range(0, n + 1)
        vols = [hamming_ball_volume(alpha, n, t) for t in ts]
        total = alpha ** n
        fracs = [v / total for v in vols]
        ax3.plot(list(ts), fracs, label=f'α={alpha}, N={n}', linewidth=2)
    ax3.set_xlabel('Ball radius t', fontsize=12)
    ax3.set_ylabel('V(N,t) / α^N', fontsize=12)
    ax3.set_title('Hamming Ball Volume Fraction', fontsize=14)
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('babel_visualizations.png', dpi=150, bbox_inches='tight')
    print("Saved babel_visualizations.png")

if __name__ == "__main__":
    main()
