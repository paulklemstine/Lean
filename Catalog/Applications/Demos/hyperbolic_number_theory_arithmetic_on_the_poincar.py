#!/usr/bin/env python3
"""
Hyperbolic Number Theory — Numerical Demonstrations
=====================================================

Demonstrates key results:
1. Conformal factor divergence near the boundary
2. Möbius addition vs Euclidean addition
3. Thomas gyration (non-associativity measure)
4. Lattice point counting for PSL(2,Z) and growth ratio
5. Hyperbolic zeta partial sums
"""

import math
import cmath
from algorithms import (
    poincare_conformal_factor, mobius_add, hyp_dist,
    hyp_area, gyration, gyration_factor,
    sl2z_hyp_dist_from_origin, sl2z_matrices_up_to_trace,
    lattice_growth_ratio
)


def demo_conformal_divergence():
    """Show the conformal factor diverging as |z| → 1."""
    print("\n" + "="*60)
    print("DEMO 1: Conformal Factor Divergence")
    print("="*60)
    print(f"{'|z|':>10}  {'λ(z)':>12}  {'2/(1-|z|²)':>12}")
    print("-" * 40)
    for r in [0.0, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99, 0.999, 0.9999]:
        z = complex(r, 0)
        lam = poincare_conformal_factor(z)
        print(f"{r:>10.4f}  {lam:>12.4f}  {2/(1-r**2):>12.4f}")
    print("\nKey insight: λ(z) → ∞ as |z| → 1.")
    print("This means hyperbolic space has infinite extent")
    print("packed into the unit disk — a finite model of infinity.")


def demo_mobius_addition():
    """Compare Möbius and Euclidean addition."""
    print("\n" + "="*60)
    print("DEMO 2: Möbius Addition vs Euclidean Addition")
    print("="*60)
    pairs = [
        (0.3+0j, 0.2+0j),
        (0.5+0j, 0.3+0j),
        (0.1+0.2j, 0.2+0.1j),
        (0.4+0.3j, 0.2-0.1j),
    ]
    print(f"{'z':>15}  {'w':>15}  {'z+w (Euclid)':>15}  {'z⊕w (Möbius)':>15}")
    print("-" * 65)
    for z, w in pairs:
        euc = z + w
        mob = mobius_add(z, w)
        print(f"{z!s:>15}  {w!s:>15}  {euc!s:>15}  {mob:.6f}")
    print("\nMöbius addition 'compresses' results to stay inside the disk.")
    print("This is exactly Einstein velocity addition in special relativity!")


def demo_gyration():
    """Show the Thomas gyration — non-associativity of Möbius addition."""
    print("\n" + "="*60)
    print("DEMO 3: Thomas Gyration (Non-Associativity)")
    print("="*60)
    a, b, c = 0.3+0.1j, 0.1+0.2j, 0.2-0.1j
    
    # Check |gyr[a,b](c)| = |c|
    gc = gyration(a, b, c)
    print(f"a = {a}, b = {b}, c = {c}")
    print(f"gyr[a,b](c) = {gc:.6f}")
    print(f"|c|       = {abs(c):.10f}")
    print(f"|gyr(c)|  = {abs(gc):.10f}")
    print(f"Preserved: {abs(abs(gc) - abs(c)) < 1e-12}")
    
    # Check gyr[0,b] = id
    gc0 = gyration(0, b, c)
    print(f"\ngyr[0,b](c) = {gc0:.6f} (should equal c = {c})")
    print(f"Is identity: {abs(gc0 - c) < 1e-12}")
    
    # Show non-associativity
    lhs = mobius_add(a, mobius_add(b, c))
    rhs = mobius_add(mobius_add(a, b), c)
    print(f"\na ⊕ (b ⊕ c) = {lhs:.6f}")
    print(f"(a ⊕ b) ⊕ c = {rhs:.6f}")
    print(f"Difference:    {abs(lhs - rhs):.2e}")
    print("Möbius addition is NOT associative — this is the gyration effect.")
    
    # But with gyration correction:
    rhs_corrected = mobius_add(mobius_add(a, b), gyration(a, b, c))
    print(f"\n(a ⊕ b) ⊕ gyr[a,b](c) = {rhs_corrected:.6f}")
    print(f"a ⊕ (b ⊕ c)           = {lhs:.6f}")
    print(f"Match: {abs(lhs - rhs_corrected) < 1e-10}")


def demo_lattice_counting():
    """Count PSL(2,Z) lattice points and check growth ratio."""
    print("\n" + "="*60)
    print("DEMO 4: Lattice Point Counting for PSL(2,Z)")
    print("="*60)
    
    covolume = math.pi / 3.0
    print(f"Covolume V = π/3 ≈ {covolume:.6f}")
    print(f"\n{'R':>6}  {'N(R)':>8}  {'e^R':>12}  {'A(R)':>12}  {'N·V/e^R':>10}")
    print("-" * 55)
    
    for R in [1.0, 2.0, 3.0, 4.0, 5.0]:
        cosh_R = math.cosh(R)
        bound = int(math.ceil(math.sqrt(2 * cosh_R))) + 2
        
        count = 0
        for a in range(-bound, bound+1):
            for d in range(-bound, bound+1):
                bc = a * d - 1
                for b in range(-bound, bound+1):
                    if b == 0:
                        if bc == 0:
                            c = 0
                            if a * d - b * c == 1:
                                dist = sl2z_hyp_dist_from_origin(a, b, c, d)
                                if dist <= R:
                                    count += 1
                        continue
                    if bc % b != 0:
                        continue
                    c = bc // b
                    if abs(c) > bound:
                        continue
                    dist = sl2z_hyp_dist_from_origin(a, b, c, d)
                    if dist <= R:
                        count += 1
        
        eR = math.exp(R)
        area = hyp_area(R)
        ratio = lattice_growth_ratio(R, count, covolume)
        print(f"{R:>6.1f}  {count:>8d}  {eR:>12.2f}  {area:>12.2f}  {ratio:>10.4f}")
    
    print("\nSelberg-Huber conjecture: N·V/e^R → 1 as R → ∞")


def demo_hyperbolic_zeta():
    """Compute partial sums of the hyperbolic zeta function."""
    print("\n" + "="*60)
    print("DEMO 5: Hyperbolic Zeta Function Partial Sums")
    print("="*60)
    
    # Generate some lattice distances
    distances = []
    bound = 5
    for a in range(-bound, bound+1):
        for d in range(-bound, bound+1):
            bc = a * d - 1
            for b in range(-bound, bound+1):
                if b == 0:
                    continue
                if bc % b != 0:
                    continue
                c = bc // b
                if abs(c) > bound:
                    continue
                dist = sl2z_hyp_dist_from_origin(a, b, c, d)
                if dist > 0.01:
                    distances.append(dist)
    
    distances = sorted(set([round(d, 8) for d in distances]))
    print(f"Found {len(distances)} distinct non-zero distances")
    
    print(f"\n{'s':>6}  {'ζ_H(s, partial)':>18}")
    print("-" * 30)
    for s in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        zeta_val = sum(d ** (-2 * s) for d in distances if d > 0.01)
        print(f"{s:>6.1f}  {zeta_val:>18.6f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Hyperbolic Number Theory: Arithmetic on the          ║")
    print("║   Poincaré Disk — Numerical Demonstrations             ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_conformal_divergence()
    demo_mobius_addition()
    demo_gyration()
    demo_lattice_counting()
    demo_hyperbolic_zeta()
    
    print("\n" + "="*60)
    print("All demonstrations complete.")
    print("="*60)


#!/usr/bin/env python3
"""
Visualization: Conformal Factor Growth and Hyperbolic Area
==========================================================

Plots showing:
1. Conformal factor as a function of |z|
2. Hyperbolic area A(R) vs Euclidean area and exponential bound
3. Lattice counting growth (if computable)
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def conformal_factor_vs_r():
    """Plot λ(r) = 2/(1-r²) for r ∈ [0, 1)."""
    r = np.linspace(0, 0.995, 500)
    lam = 2.0 / (1.0 - r**2)
    return r, lam


def hyperbolic_area(R: np.ndarray) -> np.ndarray:
    """A(R) = 2π(cosh R - 1)."""
    return 2.0 * np.pi * (np.cosh(R) - 1.0)


def euclidean_area(R: np.ndarray) -> np.ndarray:
    """πR² for comparison."""
    return np.pi * R**2


def exp_bound(R: np.ndarray) -> np.ndarray:
    """π·e^R upper bound."""
    return np.pi * np.exp(R)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
    
    # ─── Panel 1: Conformal Factor ───
    ax1 = axes[0]
    r, lam = conformal_factor_vs_r()
    ax1.semilogy(r, lam, 'b-', linewidth=2, label='λ(z) = 2/(1-|z|²)')
    ax1.axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='λ = 2 (minimum)')
    ax1.set_xlabel('|z| (Euclidean distance from origin)', fontsize=12)
    ax1.set_ylabel('Conformal factor λ(z)', fontsize=12)
    ax1.set_title('Poincaré Disk:\nConformal Factor Divergence', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_xlim(0, 1)
    ax1.set_ylim(1, 2000)
    ax1.grid(True, alpha=0.3)
    
    # Annotate
    ax1.annotate('λ ≥ 2 everywhere\n(Theorem: poincareCF_ge_two)',
                 xy=(0.3, 2), xytext=(0.15, 10),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=9, color='red')
    ax1.annotate('λ → ∞ at boundary\n(Theorem: poincareCF_diverges)',
                 xy=(0.98, 500), xytext=(0.5, 800),
                 arrowprops=dict(arrowstyle='->', color='darkred'),
                 fontsize=9, color='darkred')
    
    # ─── Panel 2: Hyperbolic vs Euclidean Area ───
    ax2 = axes[1]
    R = np.linspace(0, 5, 300)
    A_hyp = hyperbolic_area(R)
    A_euc = euclidean_area(R)
    A_exp = exp_bound(R)
    
    ax2.semilogy(R, A_hyp, 'b-', linewidth=2.5, label='A_H(R) = 2π(cosh R - 1)')
    ax2.semilogy(R, A_euc, 'g--', linewidth=1.5, label='A_E(R) = πR² (Euclidean)')
    ax2.semilogy(R, A_exp, 'r:', linewidth=1.5, label='π·e^R (upper bound)')
    
    ax2.set_xlabel('Radius R (hyperbolic)', fontsize=12)
    ax2.set_ylabel('Area', fontsize=12)
    ax2.set_title('Hyperbolic Area Growth\nvs Euclidean and Exponential', fontsize=13)
    ax2.legend(fontsize=9, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 5)
    
    ax2.annotate('Hyperbolic area grows\nexponentially, not quadratically!',
                 xy=(3.5, hyperbolic_area(np.array([3.5]))[0]),
                 xytext=(1.5, 100),
                 arrowprops=dict(arrowstyle='->', color='blue'),
                 fontsize=9, color='blue')
    
    # ─── Panel 3: Möbius Addition Comparison ───
    ax3 = axes[2]
    
    # Show how Möbius addition compresses
    r_vals = np.linspace(0, 0.9, 50)
    euc_sum = []
    mob_sum = []
    for r in r_vals:
        z = complex(r, 0)
        w = complex(0.3, 0)
        euc = abs(z + w)
        mob = abs((z + w) / (1.0 + z.conjugate() * w))
        euc_sum.append(euc)
        mob_sum.append(mob)
    
    ax3.plot(r_vals, euc_sum, 'g-', linewidth=2, label='|z + 0.3| (Euclidean)')
    ax3.plot(r_vals, mob_sum, 'b-', linewidth=2, label='|z ⊕ 0.3| (Möbius)')
    ax3.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='|w| = 1 boundary')
    
    ax3.set_xlabel('|z| (along real axis)', fontsize=12)
    ax3.set_ylabel('|z + w| or |z ⊕ w|', fontsize=12)
    ax3.set_title('Möbius vs Euclidean Addition\n(w = 0.3, z real)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    ax3.set_xlim(0, 0.9)
    ax3.set_ylim(0, 1.3)
    
    ax3.annotate('Möbius stays\ninside the disk!',
                 xy=(0.7, mob_sum[35]), xytext=(0.4, 0.3),
                 arrowprops=dict(arrowstyle='->', color='blue'),
                 fontsize=10, color='blue')
    
    plt.tight_layout()
    plt.savefig('conformal_growth_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conformal_growth_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk with Lattice Points and Conformal Factor
=====================================================================

Self-contained matplotlib visualization showing:
1. Conformal factor heatmap on the Poincaré disk
2. Lattice points of PSL(2,Z) (via Cayley transform from upper half-plane)
3. Geodesics between lattice points
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def cayley_transform(z: complex) -> complex:
    """Map from upper half-plane to unit disk: w = (z - i)/(z + i)."""
    return (z - 1j) / (z + 1j)


def conformal_factor(z: complex) -> float:
    """λ(z) = 2/(1 - |z|²)."""
    nsq = abs(z) ** 2
    if nsq >= 1.0:
        return float('nan')
    return 2.0 / (1.0 - nsq)


def sl2z_orbit_points(max_entry: int = 6) -> list:
    """Generate PSL(2,Z) orbit of i in the upper half-plane, mapped to disk."""
    points = set()
    for a in range(-max_entry, max_entry + 1):
        for b in range(-max_entry, max_entry + 1):
            for c in range(-max_entry, max_entry + 1):
                d_vals = []
                if c != 0:
                    # ad - bc = 1 => d = (1 + bc) / a if a != 0
                    if a != 0 and (1 + b * c) % a == 0:
                        d_vals.append((1 + b * c) // a)
                else:
                    # c = 0, ad = 1
                    if a == 1:
                        d_vals.append(1)
                    elif a == -1:
                        d_vals.append(-1)
                for d in d_vals:
                    if a * d - b * c != 1:
                        continue
                    # γ·i = (ai + b)/(ci + d)
                    num = complex(b, a)
                    den = complex(d, c)
                    if abs(den) < 1e-12:
                        continue
                    z = num / den
                    if z.imag > 0.001:
                        w = cayley_transform(z)
                        if abs(w) < 0.999:
                            points.add((round(w.real, 8), round(w.imag, 8)))
    return [complex(x, y) for x, y in points]


def poincare_geodesic(z1: complex, z2: complex, n_pts: int = 100) -> list:
    """Compute the geodesic between two points on the Poincaré disk."""
    # Parametrize via Möbius: send z1 to origin, geodesic is a line
    if abs(z1 - z2) < 1e-10:
        return [z1]
    
    # φ_{z1}(z) sends z1 to 0
    def mobius(z, a):
        return (z - a) / (1.0 - a.conjugate() * z)
    
    def inv_mobius(w, a):
        return (w + a) / (1.0 + a.conjugate() * w)
    
    w2 = mobius(z2, z1)
    # Geodesic from 0 to w2 is a diameter
    pts = []
    for t in np.linspace(0, 1, n_pts):
        w = t * w2
        z = inv_mobius(w, z1)
        pts.append(z)
    return pts


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))
    
    # ─── Panel 1: Conformal factor heatmap ───
    ax1 = axes[0]
    N = 400
    x = np.linspace(-1, 1, N)
    y = np.linspace(-1, 1, N)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    CF = np.full_like(R, np.nan)
    mask = R < 0.999
    CF[mask] = 2.0 / (1.0 - R[mask]**2)
    
    im = ax1.pcolormesh(X, Y, CF, cmap='inferno',
                         norm=mcolors.LogNorm(vmin=2, vmax=500),
                         shading='auto')
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
    
    # Add lattice points
    pts = sl2z_orbit_points(5)
    if pts:
        px = [p.real for p in pts]
        py = [p.imag for p in pts]
        ax1.scatter(px, py, c='cyan', s=8, zorder=5, alpha=0.7)
    
    ax1.set_xlim(-1.1, 1.1)
    ax1.set_ylim(-1.1, 1.1)
    ax1.set_aspect('equal')
    ax1.set_title('Poincaré Disk: Conformal Factor λ(z)\nwith PSL(2,ℤ) Lattice Points',
                   fontsize=13)
    ax1.set_xlabel('Re(z)')
    ax1.set_ylabel('Im(z)')
    plt.colorbar(im, ax=ax1, label='λ(z) = 2/(1-|z|²)', shrink=0.8)
    
    # ─── Panel 2: Lattice points with geodesics ───
    ax2 = axes[1]
    
    # Draw disk boundary
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5)
    ax2.fill(np.cos(theta), np.sin(theta), color='#f0f0f0')
    
    # Draw lattice points
    pts_sorted = sorted(pts, key=lambda p: abs(p))
    if len(pts_sorted) > 100:
        pts_sorted = pts_sorted[:100]
    
    # Draw some geodesics from origin
    origin = complex(0, 0)
    for i, p in enumerate(pts_sorted[:20]):
        geo = poincare_geodesic(origin, p, 50)
        gx = [g.real for g in geo]
        gy = [g.imag for g in geo]
        ax2.plot(gx, gy, '-', color='steelblue', alpha=0.3, linewidth=0.8)
    
    # Draw lattice points colored by distance from origin
    dists = [abs(p) for p in pts_sorted]
    sc = ax2.scatter([p.real for p in pts_sorted],
                      [p.imag for p in pts_sorted],
                      c=dists, cmap='viridis', s=15, zorder=5,
                      edgecolors='k', linewidth=0.3)
    ax2.scatter([0], [0], c='red', s=50, zorder=6, marker='*',
                edgecolors='k', linewidth=0.5, label='Origin')
    
    ax2.set_xlim(-1.1, 1.1)
    ax2.set_ylim(-1.1, 1.1)
    ax2.set_aspect('equal')
    ax2.set_title('Hyperbolic Integers ℤ_H\n(PSL(2,ℤ) orbit with geodesics)',
                   fontsize=13)
    ax2.set_xlabel('Re(z)')
    ax2.set_ylabel('Im(z)')
    ax2.legend(loc='lower right')
    plt.colorbar(sc, ax=ax2, label='|z| (Euclidean)', shrink=0.8)
    
    plt.tight_layout()
    plt.savefig('poincare_disk_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: poincare_disk_visualization.png")


if __name__ == "__main__":
    main()
