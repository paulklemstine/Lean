"""
Mathematical Uncanny Valley Theory — Demonstration Script

This script demonstrates the key results of the uncanny valley theory for
mathematical proofs, computing suspicion kernels, trust functions, and
verifying the valley monotonicity conjecture computationally.
"""

from typing import List, Tuple


def sym_suspicion(k: int, n: int) -> int:
    """Symmetric suspicion kernel: k * (n - k)"""
    if k > n:
        return 0
    return k * (n - k)


def asym_suspicion(k: int, n: int) -> int:
    """Asymmetric suspicion kernel: k^2 * (n - k)"""
    if k > n:
        return 0
    return k ** 2 * (n - k)


def proof_trust(k: int, n: int) -> int:
    """Trust level: n^3 - asymSuspicion(k, n)"""
    return n ** 3 - asym_suspicion(k, n)


def find_valley(n: int) -> Tuple[int, int]:
    """Find the position and value of maximum suspicion."""
    best_k, best_v = 0, 0
    for k in range(n + 1):
        v = asym_suspicion(k, n)
        if v > best_v:
            best_k, best_v = k, v
    return best_k, best_v


def verify_monotonicity_conjecture(max_n: int = 100) -> bool:
    """Verify the valley monotonicity conjecture up to proof length max_n."""
    for n in range(3, max_n + 1):
        for k in range(1, 2 * n // 3 + 1):
            if 3 * k > 2 * n:
                break
            if asym_suspicion(k - 1, n) >= asym_suspicion(k, n):
                print(f"COUNTEREXAMPLE at n={n}, k1={k-1}, k2={k}")
                return False
    return True


def demo_uncanny_valley_ordering():
    """Demonstrate Theorem 3.1: Almost-complete proofs are more suspicious."""
    print("=" * 60)
    print("UNCANNY VALLEY ORDERING THEOREM")
    print("For n >= 3: suspicion(1, n) < suspicion(n-1, n)")
    print("=" * 60)
    for n in [3, 5, 10, 20, 50, 100]:
        s1 = asym_suspicion(1, n)
        sn1 = asym_suspicion(n - 1, n)
        ratio = sn1 / s1 if s1 > 0 else float('inf')
        print(f"  n={n:3d}: S(1,n)={s1:8d}, S(n-1,n)={sn1:8d}, ratio={ratio:.1f}x")
    print()


def demo_valley_depth_growth():
    """Demonstrate Theorem 3.4: Valley depth grows with proof length."""
    print("=" * 60)
    print("VALLEY DEPTH GROWTH")
    print("S(n-1, n) grows quadratically as (n-1)^2")
    print("=" * 60)
    for n in [2, 5, 10, 20, 50, 100]:
        depth = asym_suspicion(n - 1, n)
        expected = (n - 1) ** 2
        print(f"  n={n:3d}: valley depth = {depth:8d}, (n-1)^2 = {expected:8d}, match={depth==expected}")
    print()


def demo_trust_recovery():
    """Demonstrate Theorems 3.5-3.6: Trust recovery and last sorry penalty."""
    print("=" * 60)
    print("TRUST RECOVERY AND LAST SORRY PENALTY")
    print("=" * 60)
    for n in [5, 10, 20, 50, 100]:
        t_full = proof_trust(n, n)
        t_penult = proof_trust(n - 1, n)
        penalty = t_full - t_penult
        pct = 100 * penalty / t_full if t_full > 0 else 0
        print(f"  n={n:3d}: T(n,n)={t_full:12d}, T(n-1,n)={t_penult:12d}, "
              f"penalty={penalty:8d} ({pct:.2f}%)")
    print()


def demo_valley_position():
    """Demonstrate the valley position and its asymmetry."""
    print("=" * 60)
    print("VALLEY POSITION ANALYSIS")
    print("Valley peak occurs near k = 2n/3")
    print("=" * 60)
    for n in [6, 9, 12, 15, 30, 60, 100]:
        v_pos, v_val = find_valley(n)
        theoretical = 2 * n / 3
        print(f"  n={n:3d}: valley at k={v_pos:3d} (theoretical 2n/3={theoretical:.1f}), "
              f"value={v_val:10d}")
    print()


def demo_symmetric_vs_asymmetric():
    """Demonstrate that symmetric kernel lacks the uncanny valley."""
    print("=" * 60)
    print("SYMMETRIC vs. ASYMMETRIC KERNELS")
    print("Symmetric: S_sym(1,n) = S_sym(n-1,n) (no valley)")
    print("Asymmetric: S_asym(1,n) << S_asym(n-1,n) (valley!)")
    print("=" * 60)
    for n in [5, 10, 20, 50]:
        print(f"  n={n}:")
        print(f"    Symmetric:  S(1,{n})={sym_suspicion(1,n):6d}, "
              f"S({n-1},{n})={sym_suspicion(n-1,n):6d}, equal={sym_suspicion(1,n)==sym_suspicion(n-1,n)}")
        print(f"    Asymmetric: S(1,{n})={asym_suspicion(1,n):6d}, "
              f"S({n-1},{n})={asym_suspicion(n-1,n):6d}, ratio={asym_suspicion(n-1,n)/asym_suspicion(1,n):.1f}x")
    print()


def demo_monotonicity_conjecture():
    """Verify the valley monotonicity conjecture."""
    print("=" * 60)
    print("VALLEY MONOTONICITY CONJECTURE VERIFICATION")
    print("=" * 60)
    max_n = 1000
    result = verify_monotonicity_conjecture(max_n)
    print(f"  Verified for n = 3 to {max_n}: {'PASSED' if result else 'FAILED'}")
    print()


def demo_full_suspicion_curve(n: int = 20):
    """Print the full suspicion curve for a specific n."""
    print("=" * 60)
    print(f"FULL SUSPICION CURVE (n={n})")
    print("=" * 60)
    max_s = max(asym_suspicion(k, n) for k in range(n + 1))
    for k in range(n + 1):
        s = asym_suspicion(k, n)
        bar_len = int(50 * s / max_s) if max_s > 0 else 0
        bar = "█" * bar_len
        marker = " ← VALLEY PEAK" if s == max_s else ""
        marker = " ← COMPLETE (trust=max)" if k == n else marker
        marker = " ← SKETCH" if k == 0 else marker
        print(f"  k={k:2d}: {s:6d} |{bar}{marker}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICAL UNCANNY VALLEY THEORY — DEMONSTRATION")
    print("=" * 60 + "\n")

    demo_uncanny_valley_ordering()
    demo_valley_depth_growth()
    demo_trust_recovery()
    demo_valley_position()
    demo_symmetric_vs_asymmetric()
    demo_monotonicity_conjecture()
    demo_full_suspicion_curve(20)
    demo_full_suspicion_curve(10)


"""
Visualization: Suspicion Curves — Symmetric vs. Asymmetric Kernels

Generates a side-by-side comparison of the symmetric and asymmetric
suspicion kernels, showing how the asymmetric kernel shifts the valley
toward the "almost complete" end of the rigor spectrum.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sym_suspicion(k: int, n: int) -> int:
    if k > n:
        return 0
    return k * (n - k)


def asym_suspicion(k: int, n: int) -> int:
    if k > n:
        return 0
    return k * k * (n - k)


def main():
    n = 30
    ks = list(range(n + 1))
    sym_vals = [sym_suspicion(k, n) for k in ks]
    asym_vals = [asym_suspicion(k, n) for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Symmetric kernel
    ax1.fill_between(ks, sym_vals, alpha=0.3, color='steelblue')
    ax1.plot(ks, sym_vals, 'o-', color='steelblue', markersize=3, linewidth=1.5)
    sym_max_k = max(range(n + 1), key=lambda k: sym_suspicion(k, n))
    ax1.axvline(x=sym_max_k, color='red', linestyle='--', alpha=0.7, label=f'Peak at k={sym_max_k}')
    ax1.axvline(x=n/2, color='gray', linestyle=':', alpha=0.5, label=f'n/2={n/2:.0f}')
    ax1.set_title('Symmetric Suspicion: k(n−k)', fontsize=14, fontweight='bold')
    ax1.set_xlabel('Verified steps (k)', fontsize=12)
    ax1.set_ylabel('Suspicion', fontsize=12)
    ax1.legend()
    ax1.annotate('Sketch\n(accepted)', xy=(0, 0), fontsize=9, ha='center',
                 xytext=(2, max(sym_vals)*0.3), arrowprops=dict(arrowstyle='->', color='green'))
    ax1.annotate('Complete\n(trusted)', xy=(n, 0), fontsize=9, ha='center',
                 xytext=(n-2, max(sym_vals)*0.3), arrowprops=dict(arrowstyle='->', color='green'))

    # Asymmetric kernel
    ax2.fill_between(ks, asym_vals, alpha=0.3, color='crimson')
    ax2.plot(ks, asym_vals, 'o-', color='crimson', markersize=3, linewidth=1.5)
    asym_max_k = max(range(n + 1), key=lambda k: asym_suspicion(k, n))
    ax2.axvline(x=asym_max_k, color='red', linestyle='--', alpha=0.7, label=f'Peak at k={asym_max_k}')
    ax2.axvline(x=n/2, color='gray', linestyle=':', alpha=0.5, label=f'n/2={n/2:.0f}')
    ax2.axvline(x=2*n/3, color='orange', linestyle='-.', alpha=0.7, label=f'2n/3={2*n/3:.1f}')
    ax2.set_title('Asymmetric Suspicion: k²(n−k)', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Verified steps (k)', fontsize=12)
    ax2.set_ylabel('Suspicion', fontsize=12)
    ax2.legend()

    # Annotate the uncanny valley
    ax2.annotate('UNCANNY\nVALLEY', xy=(asym_max_k, max(asym_vals)),
                 fontsize=11, ha='center', fontweight='bold', color='darkred',
                 xytext=(asym_max_k, max(asym_vals)*1.1))

    fig.suptitle('The Mathematical Uncanny Valley', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_suspicion_curves.png', dpi=150, bbox_inches='tight')
    print("Saved viz_suspicion_curves.png")


if __name__ == "__main__":
    main()


"""
Visualization: Trust Landscape — How trust varies with proof length and completion

Generates a heatmap showing the trust level T(k,n) = n³ - k²(n-k) for varying
proof lengths n and completion levels k, revealing the uncanny valley as a
diagonal band of low trust.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def asym_suspicion(k: int, n: int) -> int:
    if k > n or k < 0:
        return 0
    return k * k * (n - k)


def proof_trust_normalized(k: int, n: int) -> float:
    if n == 0:
        return 1.0
    return 1.0 - asym_suspicion(k, n) / (n ** 3) if n > 0 else 1.0


def main():
    max_n = 40
    grid = np.zeros((max_n + 1, max_n + 1))

    for n in range(1, max_n + 1):
        for k in range(n + 1):
            grid[n][k] = proof_trust_normalized(k, n)

    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(grid[1:, :], aspect='auto', origin='lower',
                   cmap='RdYlGn', vmin=0.8, vmax=1.0,
                   extent=[0, max_n, 1, max_n])

    # Draw the valley ridge line (k = 2n/3)
    ns = np.linspace(3, max_n, 100)
    ax.plot(2 * ns / 3, ns, 'k--', linewidth=2, label='Valley ridge (k=2n/3)')
    ax.plot(ns, ns, 'w-', linewidth=1.5, alpha=0.5, label='Full verification (k=n)')

    ax.set_xlabel('Verified steps (k)', fontsize=13)
    ax.set_ylabel('Proof length (n)', fontsize=13)
    ax.set_title('Trust Landscape: The Uncanny Valley of Mathematics',
                 fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)

    cbar = plt.colorbar(im, ax=ax, label='Normalized trust T(k,n)/n³')
    cbar.set_label('Normalized trust', fontsize=12)

    plt.tight_layout()
    plt.savefig('viz_trust_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_trust_landscape.png")


if __name__ == "__main__":
    main()


"""
Visualization: Valley Depth Growth — How the uncanny valley deepens with proof length

Shows the quadratic growth of the valley depth (suspicion at k=n-1) as proof
length increases, alongside the uncanny valley ratio.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def asym_suspicion(k: int, n: int) -> int:
    if k > n or k < 0:
        return 0
    return k * k * (n - k)


def main():
    ns = list(range(2, 101))
    depths = [(n - 1) ** 2 for n in ns]
    ratios = [asym_suspicion(n - 1, n) / max(asym_suspicion(1, n), 1) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Valley depth
    ax1.plot(ns, depths, 'b-', linewidth=2)
    ax1.fill_between(ns, depths, alpha=0.2, color='blue')
    ax1.set_xlabel('Proof length (n)', fontsize=12)
    ax1.set_ylabel('Valley depth: (n−1)²', fontsize=12)
    ax1.set_title('Valley Depth Grows Quadratically', fontsize=14, fontweight='bold')

    # Annotate key points
    for n_mark in [10, 50, 100]:
        d = (n_mark - 1) ** 2
        ax1.annotate(f'n={n_mark}\ndepth={d}', xy=(n_mark, d),
                     xytext=(n_mark + 5, d - 500),
                     arrowprops=dict(arrowstyle='->', color='black'),
                     fontsize=9)

    # Uncanny valley ratio
    ax2.plot(ns, ratios, 'r-', linewidth=2)
    ax2.fill_between(ns, ratios, alpha=0.2, color='red')
    ax2.set_xlabel('Proof length (n)', fontsize=12)
    ax2.set_ylabel('Ratio: S(n−1,n) / S(1,n)', fontsize=12)
    ax2.set_title('Uncanny Valley Ratio = n−1', fontsize=14, fontweight='bold')
    ax2.set_yscale('linear')

    # The ratio equals n-1 exactly
    theoretical = [n - 1 for n in ns]
    ax2.plot(ns, theoretical, 'k--', alpha=0.5, label='Theoretical: n−1')
    ax2.legend(fontsize=11)

    fig.suptitle('The Mathematical Uncanny Valley Deepens with Proof Length',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_valley_depth.png', dpi=150, bbox_inches='tight')
    print("Saved viz_valley_depth.png")


if __name__ == "__main__":
    main()
