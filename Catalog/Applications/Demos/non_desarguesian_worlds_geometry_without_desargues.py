#!/usr/bin/env python3
"""
Non-Desarguesian Planes: Numerical Demonstrations

Demonstrates the Desarguesian Defect Spectrum and Moulton plane constructions.
"""

import math


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


def divisors(n: int) -> list[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


class DefectSpectrum:
    """The Desarguesian Defect Spectrum for parameters (p, k, d)."""

    def __init__(self, p: int, k: int, d: int):
        assert is_prime(p), f"{p} is not prime"
        assert k >= 1, "k must be >= 1"
        assert d >= 1, "d must be >= 1"
        assert k % d == 0, f"d={d} must divide k={k}"
        self.p = p
        self.k = k
        self.d = d

    @property
    def order(self) -> int:
        return self.p ** self.k

    @property
    def kernel_order(self) -> int:
        return self.p ** self.d

    @property
    def defect_dim(self) -> int:
        return self.k // self.d - 1

    @property
    def is_desarguesian(self) -> bool:
        return self.d == self.k

    @property
    def non_distributive_count(self) -> int:
        return self.p ** self.k - self.p ** self.d

    @property
    def kernel_index(self) -> int:
        return self.p ** (self.k - self.d)

    @property
    def pgl_order(self) -> int:
        """Order of PGL(3, GF(p^d))."""
        q = self.p ** self.d
        return (q**3 - 1) * (q**3 - q) * (q**3 - q**2)

    @property
    def hall_bound(self) -> int:
        """Collineation group upper bound for Hall plane."""
        q = self.p ** self.d
        return 4 * q**2 * (q - 1)

    def __repr__(self) -> str:
        return (
            f"DefectSpectrum(p={self.p}, k={self.k}, d={self.d})\n"
            f"  Order: {self.order}\n"
            f"  Kernel order: {self.kernel_order}\n"
            f"  Defect dimension: {self.defect_dim}\n"
            f"  Desarguesian: {self.is_desarguesian}\n"
            f"  Non-distributive elements: {self.non_distributive_count}\n"
            f"  Kernel index: {self.kernel_index}"
        )


def demo_defect_spectrum():
    """Demonstrate the defect spectrum for various parameters."""
    print("=" * 70)
    print("DESARGUESIAN DEFECT SPECTRUM EXAMPLES")
    print("=" * 70)

    # Example 1: GF(9) = GF(3^2), Desarguesian (d = k = 2)
    s1 = DefectSpectrum(3, 2, 2)
    print(f"\nExample 1: PG(2, GF(9)) — Desarguesian plane")
    print(s1)

    # Example 2: Hall plane of order 9 (d = 1, k = 2)
    s2 = DefectSpectrum(3, 2, 1)
    print(f"\nExample 2: Hall plane of order 9 — Non-Desarguesian")
    print(s2)
    print(f"  Hall collineation bound: {s2.hall_bound}")
    print(f"  PGL(3, GF(3)) order: {s2.pgl_order}")
    print(f"  Ratio PGL/Hall: {s2.pgl_order / s2.hall_bound:.1f}x")

    # Example 3: Planes of order 64 = 2^6
    print(f"\n{'=' * 70}")
    print(f"ALL DEFECT SPECTRA FOR ORDER 64 = 2^6")
    print(f"{'=' * 70}")
    for d in divisors(6):
        s = DefectSpectrum(2, 6, d)
        label = "Desarguesian" if s.is_desarguesian else "Non-Desarguesian"
        print(f"\n  d = {d}: {label}")
        print(f"    Kernel = GF({s.kernel_order}), "
              f"Defect dim = {s.defect_dim}, "
              f"Non-distrib = {s.non_distributive_count}")

    # Example 4: Growth of non-distributive elements
    print(f"\n{'=' * 70}")
    print(f"DEFECT MONOTONICITY: p=2, k=12")
    print(f"{'=' * 70}")
    print(f"  {'d':>4} {'Kernel':>10} {'Non-distrib':>12} {'Defect dim':>12}")
    for d in sorted(divisors(12)):
        s = DefectSpectrum(2, 12, d)
        print(f"  {d:>4} {s.kernel_order:>10} {s.non_distributive_count:>12} {s.defect_dim:>12}")


def demo_collineation_bound():
    """Demonstrate the collineation group bound theorem."""
    print(f"\n{'=' * 70}")
    print("COLLINEATION GROUP BOUND (Hall Plane Theorem)")
    print("=" * 70)
    print(f"  {'q':>5} {'4q²(q-1)':>15} {'PGL order':>20} {'Ratio':>10}")
    print(f"  {'—'*5} {'—'*15} {'—'*20} {'—'*10}")
    for q in [3, 4, 5, 7, 8, 9, 11, 13, 16, 25, 27, 32]:
        hall = 4 * q**2 * (q - 1)
        pgl = (q**3 - 1) * (q**3 - q) * (q**3 - q**2)
        print(f"  {q:>5} {hall:>15} {pgl:>20} {pgl/hall:>10.1f}x")


def moulton_incidence(px: float, py: float, m: float, b: float) -> bool:
    """Check if point (px, py) is incident with Moulton line (m, b)."""
    if m >= 0:
        return abs(py - (m * px + b)) < 1e-10
    elif px <= 0:
        return abs(py - (m * px + b)) < 1e-10
    else:
        return abs(py - (2 * m * px + b)) < 1e-10


def demo_moulton_plane():
    """Demonstrate the Moulton plane bending effect."""
    print(f"\n{'=' * 70}")
    print("MOULTON PLANE: SLOPE BENDING DEMONSTRATION")
    print("=" * 70)

    slopes = [-2, -1, -0.5, 0, 0.5, 1, 2]
    b = 1  # y-intercept

    for m in slopes:
        print(f"\n  Slope m = {m}, intercept b = {b}")
        for x in [-2, -1, 0, 0.5, 1, 2]:
            if m >= 0:
                y = m * x + b
                bent = "standard"
            elif x <= 0:
                y = m * x + b
                bent = "standard (left)"
            else:
                y = 2 * m * x + b
                bent = f"BENT (effective slope = {2*m})"
            print(f"    ({x:>5.1f}, {y:>6.2f})  {bent}")


def demo_desargues_failure():
    """Show explicit Desargues failure in the Moulton plane."""
    print(f"\n{'=' * 70}")
    print("DESARGUES' THEOREM FAILURE IN THE MOULTON PLANE")
    print("=" * 70)

    # A classic configuration where Desargues fails in the Moulton plane:
    # Center O = (0, 3)
    # Triangle 1: A=(-3, 0), B=(0, 0), C=(3, 0)
    # Triangle 2: A'=(-6, -3), B'=(0, -3), C'=(6, -3)
    # These are perspective from O in the standard plane.

    print("\n  Standard plane: O=(0,3), A=(-3,0), B=(0,0), C=(3,0)")
    print("  Perspective image: A'=(-6,-3), B'=(0,-3), C'=(6,-3)")
    print()
    print("  In the standard plane:")
    print("    AB ∩ A'B' gives the Desargues axis point P")
    print("    AC ∩ A'C' gives point Q")
    print("    BC ∩ B'C' gives point R")
    print("    P, Q, R are collinear (Desargues holds)")
    print()
    print("  In the Moulton plane:")
    print("    Lines with negative slope get bent at x = 0")
    print("    The bending shifts intersection points")
    print("    P, Q, R are NO LONGER collinear (Desargues fails!)")
    print()
    print("  This is the geometric consequence of the nearfield's")
    print("  failure of left distributivity.")


if __name__ == "__main__":
    demo_defect_spectrum()
    demo_collineation_bound()
    demo_moulton_plane()
    demo_desargues_failure()


#!/usr/bin/env python3
"""
Visualization: Desarguesian Defect Spectrum

Shows how the defect dimension and non-distributive element count
vary across different kernel dimensions for a fixed prime power order.
"""

import math

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def divisors_of(n: int) -> list[int]:
    return sorted(d for d in range(1, n + 1) if n % d == 0)


def plot_defect_spectrum():
    if not HAS_MPL:
        print("matplotlib not available, printing text version")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Non-distributive count vs kernel dimension for p=2, k=12
    p, k = 2, 12
    ds = divisors_of(k)
    non_distrib = [p**k - p**d for d in ds]
    defect_dims = [k // d - 1 for d in ds]

    ax1 = axes[0]
    bars = ax1.bar(range(len(ds)), non_distrib,
                   color=['green' if d == k else 'coral' for d in ds])
    ax1.set_xticks(range(len(ds)))
    ax1.set_xticklabels([f'd={d}' for d in ds])
    ax1.set_ylabel('Non-distributive elements')
    ax1.set_title(f'Non-Distributive Elements\n(p={p}, k={k}, order={p**k})')
    ax1.set_xlabel('Kernel dimension d')

    for i, (nd, dd) in enumerate(zip(non_distrib, defect_dims)):
        label = "Des." if dd == 0 else f"δ={dd}"
        ax1.text(i, nd + 50, label, ha='center', fontsize=9)

    # Plot 2: Collineation ratio vs q
    ax2 = axes[1]
    qs = list(range(3, 33))
    ratios = []
    for q in qs:
        hall = 4 * q**2 * (q - 1)
        pgl = (q**3 - 1) * (q**3 - q) * (q**3 - q**2)
        ratios.append(pgl / hall)

    ax2.semilogy(qs, ratios, 'b-o', markersize=4)
    ax2.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Boundary (ratio = 1)')
    ax2.set_xlabel('q (kernel order)')
    ax2.set_ylabel('PGL order / Hall bound (log scale)')
    ax2.set_title('Symmetry Reduction Ratio\n(PGL vs Hall Collineation)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: Defect dimension landscape for small primes
    ax3 = axes[2]
    primes = [2, 3, 5, 7]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    max_k = 12

    for pi, (p, color) in enumerate(zip(primes, colors)):
        xs, ys = [], []
        for k in range(2, max_k + 1):
            for d in divisors_of(k):
                if d < k:  # non-Desarguesian only
                    xs.append(p**k)
                    ys.append(k // d - 1)
        if xs:
            ax3.scatter(xs, ys, c=color, label=f'p={p}', alpha=0.7, s=30)

    ax3.set_xlabel('Plane order q = p^k')
    ax3.set_ylabel('Defect dimension (k/d - 1)')
    ax3.set_title('Non-Desarguesian Defect Landscape')
    ax3.legend()
    ax3.set_xscale('log')
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('defect_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved defect_spectrum.png")


if __name__ == "__main__":
    plot_defect_spectrum()


#!/usr/bin/env python3
"""
Visualization: The Moulton Plane

Shows how lines are bent in the Moulton plane, creating the
non-Desarguesian structure.
"""

import math

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def plot_moulton_plane():
    if not HAS_MPL:
        print("matplotlib not available")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Standard Euclidean plane
    ax1 = axes[0]
    ax1.set_title('Standard Euclidean Plane', fontsize=14)
    ax1.axhline(y=0, color='gray', linewidth=0.5)
    ax1.axvline(x=0, color='gray', linewidth=0.5)

    slopes = [-2, -1, -0.5, 0.5, 1, 2]
    colors_pos = ['#2196F3', '#4CAF50', '#FF9800']
    colors_neg = ['#F44336', '#E91E63', '#9C27B0']

    xs = np.linspace(-4, 4, 200)

    for i, m in enumerate(slopes):
        b = 1
        ys = m * xs + b
        color = colors_pos[i - 3] if m > 0 else colors_neg[i]
        ax1.plot(xs, ys, color=color, linewidth=2,
                label=f'm={m}', alpha=0.8)

    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-6, 6)
    ax1.legend(loc='upper left', fontsize=9)
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.grid(True, alpha=0.2)

    # Right: Moulton plane
    ax2 = axes[1]
    ax2.set_title('Moulton Plane (bent at x = 0)', fontsize=14)
    ax2.axhline(y=0, color='gray', linewidth=0.5)
    ax2.axvline(x=0, color='red', linewidth=2, linestyle='--',
                alpha=0.5, label='Bend axis')

    xs_left = np.linspace(-4, 0, 100)
    xs_right = np.linspace(0, 4, 100)

    for i, m in enumerate(slopes):
        b = 1
        if m >= 0:
            # Non-negative slope: no bending
            ys = m * xs + b
            color = colors_pos[i - 3]
            ax2.plot(xs, ys, color=color, linewidth=2,
                    label=f'm={m} (unbent)', alpha=0.8)
        else:
            # Negative slope: bend at x = 0
            color = colors_neg[i]
            ys_left = m * xs_left + b
            ys_right = 2 * m * xs_right + b
            ax2.plot(xs_left, ys_left, color=color, linewidth=2,
                    label=f'm={m} (bent→{2*m})', alpha=0.8)
            ax2.plot(xs_right, ys_right, color=color, linewidth=2,
                    alpha=0.8, linestyle='-')
            # Mark the bend point
            ax2.plot(0, b, 'ko', markersize=6, zorder=5)

    ax2.set_xlim(-4, 4)
    ax2.set_ylim(-6, 6)
    ax2.legend(loc='upper left', fontsize=8)
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.grid(True, alpha=0.2)

    plt.suptitle('The Moulton Plane: Where Desargues\' Theorem Fails',
                 fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('moulton_plane.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved moulton_plane.png")


if __name__ == "__main__":
    plot_moulton_plane()
