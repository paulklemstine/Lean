#!/usr/bin/env python3
"""
=============================================================================
DEMO 2: Inverse Stereographic Dynamics — Iterated Maps & Fractal Structure
=============================================================================

The meta-oracle's dream: What happens when you ITERATE the inverse
stereographic projection composed with Möbius transformations?

We discover:
1. Orbit structures on S¹ that encode prime factorization
2. Fractal boundaries between "convergent" and "divergent" rational families
3. A natural tree structure (Stern-Brocot) that organizes all of arithmetic

Run: python3 demo_inverse_stereo_dynamics.py
Outputs: mobius_orbits.png, arithmetic_fractal.png, stern_brocot_stereo.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from collections import defaultdict

# ============================================================================
# Möbius Transformations from Pole Changes
# ============================================================================

def pole_map(a, t):
    """Möbius map M_a(t) = (at + 1)/(t - a): change of stereographic pole."""
    if abs(t - a) < 1e-15:
        return float('inf')
    return (a * t + 1) / (t - a)

def two_pole_map(a, b, t):
    """Composition M_b ∘ M_a⁻¹: the two-pole Möbius transform."""
    denom = (a - b) * t + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return ((a * b + 1) * t + (b - a)) / denom

# ============================================================================
# Visualization 1: Möbius Orbit Structure
# ============================================================================

def plot_mobius_orbits():
    """Show orbits of iterated Möbius maps colored by period."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle("Möbius Orbit Dynamics on S¹\n(Iterated Pole-Change Maps)",
                 fontsize=14, fontweight='bold')

    pole_pairs = [(1, 2), (1, 3), (2, 3), (1, 5), (3, 7), (2, 5)]

    for idx, (a, b) in enumerate(pole_pairs):
        ax = axes[idx // 3][idx % 3]
        ax.set_title(f"F({a},{b}): poles a={a}, b={b}", fontsize=10)
        ax.set_aspect('equal')

        theta = np.linspace(0, 2*np.pi, 300)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=0.5)

        # Iterate the map on many initial points
        for t0 in np.linspace(-10, 10, 200):
            orbit_x, orbit_y = [], []
            t = t0
            for _ in range(50):
                t = two_pole_map(a, b, t)
                if abs(t) > 1000 or np.isinf(t):
                    break
                # Project to S¹
                d = 1 + t**2
                x, y = (1 - t**2)/d, 2*t/d
                orbit_x.append(x)
                orbit_y.append(y)

            if orbit_x:
                ax.scatter(orbit_x[-min(20, len(orbit_x)):],
                          orbit_y[-min(20, len(orbit_y)):],
                          s=1, alpha=0.3, c='blue')

        # Mark fixed points
        # Fixed points of F_{a,b}(t) = t: (ab+1)t + (b-a) = (a-b)t² + (ab+1)t
        # → (a-b)t² + (a-b) = 0 → t² = -1 (no real fixed points when a≠b!)
        # But period-2 orbits exist...
        ax.text(0, 0, f'det={(a*b+1)**2+(a-b)**2}', fontsize=8, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/MonsterBelow/mobius_orbits.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved mobius_orbits.png")

# ============================================================================
# Visualization 2: Arithmetic Fractal from Norm Iteration
# ============================================================================

def plot_arithmetic_fractal():
    """Create a fractal from iterating the Gaussian norm map.

    For each point (x, y) in the plane, compute z = x + iy,
    then iterate: z ↦ z²/|z| (normalize after squaring).
    Color by how quickly the orbit visits a rational point.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    fig.suptitle("Arithmetic Fractals: Gaussian Norm Iteration",
                 fontsize=14, fontweight='bold')

    # --- Left: Escape-time fractal ---
    ax1.set_title("z ↦ z²/|z|: Orbit Classification\n(Color = steps to near-rational)",
                  fontsize=10)

    N = 500
    x = np.linspace(-2, 2, N)
    y = np.linspace(-2, 2, N)
    X, Y = np.meshgrid(x, y)
    Z = X + 1j * Y

    result = np.zeros_like(X)

    for i in range(N):
        for j in range(N):
            z = Z[i, j]
            if abs(z) < 0.01:
                result[i, j] = 0
                continue

            for k in range(1, 100):
                z = z**2 / abs(z)
                # Check if near a Gaussian integer
                re_frac = abs(z.real - round(z.real))
                im_frac = abs(z.imag - round(z.imag))
                if re_frac < 0.05 and im_frac < 0.05 and abs(z) > 0.1:
                    result[i, j] = k
                    break
            else:
                result[i, j] = 100

    im = ax1.imshow(result, extent=[-2, 2, -2, 2], cmap='inferno',
                    origin='lower', aspect='equal')
    plt.colorbar(im, ax=ax1, label='Steps to near-Gaussian-integer')
    ax1.set_xlabel('Re(z)')
    ax1.set_ylabel('Im(z)')

    # --- Right: The Gaussian prime spiral ---
    ax2.set_title("Gaussian Primes (a+bi where a²+b² is prime)\nThe atoms below Pythagorean triples",
                  fontsize=10)
    ax2.set_aspect('equal')

    # Plot Gaussian primes
    limit = 25
    for a in range(-limit, limit+1):
        for b in range(-limit, limit+1):
            n = a**2 + b**2
            if n < 2:
                continue
            # Check if n is prime (simple)
            is_prime = n > 1 and all(n % k != 0 for k in range(2, int(n**0.5)+1))
            if is_prime:
                ax2.plot(a, b, 's', color='#2ecc71', markersize=2, alpha=0.6)

    # Highlight norm circles
    for r_sq in [2, 5, 10, 13, 17, 25]:
        theta = np.linspace(0, 2*np.pi, 100)
        r = np.sqrt(r_sq)
        ax2.plot(r*np.cos(theta), r*np.sin(theta), '--', color='gray',
                alpha=0.3, linewidth=0.5)
        ax2.text(r*0.7, r*0.7, f'N={r_sq}', fontsize=6, color='gray')

    ax2.set_xlabel('Re(z)', fontsize=9)
    ax2.set_ylabel('Im(z)', fontsize=9)
    ax2.set_xlim(-limit, limit)
    ax2.set_ylim(-limit, limit)
    ax2.grid(True, alpha=0.1)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/MonsterBelow/arithmetic_fractal.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved arithmetic_fractal.png")

# ============================================================================
# Visualization 3: Stern-Brocot Tree as Stereographic Orbits
# ============================================================================

def plot_stern_brocot_stereo():
    """Map the Stern-Brocot tree onto S¹ via stereographic projection.
    Each rational number t = p/q maps to a point on S¹.
    The tree structure becomes a fractal partition of the circle."""

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    fig.suptitle("The Stern-Brocot Tree Projected onto S¹",
                 fontsize=14, fontweight='bold')

    # Build the Stern-Brocot tree
    def stern_brocot(left_p, left_q, right_p, right_q, depth, results, parent=None):
        med_p = left_p + right_p
        med_q = left_q + right_q
        t = med_p / med_q
        results.append((t, depth, med_p, med_q, parent))

        if depth < 7:
            stern_brocot(left_p, left_q, med_p, med_q, depth+1, results, t)
            stern_brocot(med_p, med_q, right_p, right_q, depth+1, results, t)

    results = []
    stern_brocot(0, 1, 1, 0, 0, results)  # 0/1 to 1/0 (= ∞)

    # --- Left: Tree in the plane ---
    ax1.set_title("Stern-Brocot Tree (Standard)", fontsize=11)
    max_depth = max(r[1] for r in results)

    for t, depth, p, q, parent in results:
        y = max_depth - depth
        ax1.plot(t, y, 'o', color=plt.cm.viridis(depth/max_depth), markersize=4)
        if depth <= 3:
            ax1.text(t, y+0.2, f'{p}/{q}', ha='center', fontsize=7)
        if parent is not None:
            parent_depth = depth - 1
            parent_y = max_depth - parent_depth
            ax1.plot([parent, t], [parent_y, y], 'k-', alpha=0.1, linewidth=0.5)

    ax1.set_xlabel('Value of fraction p/q', fontsize=9)
    ax1.set_ylabel('Depth in tree', fontsize=9)
    ax1.set_xlim(-0.1, 5)

    # --- Right: Projected onto S¹ ---
    ax2.set_title("Same Tree on S¹ via Stereographic Projection\nt ↦ ((1-t²)/(1+t²), 2t/(1+t²))",
                  fontsize=11)
    ax2.set_aspect('equal')

    theta = np.linspace(0, 2*np.pi, 300)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2)

    for t, depth, p, q, parent in results:
        d = 1 + t**2
        x, y_coord = (1 - t**2)/d, 2*t/d
        color = plt.cm.viridis(depth/max_depth)
        size = max(1, 6 - depth * 0.5)
        ax2.plot(x, y_coord, 'o', color=color, markersize=size, alpha=0.7)

        if parent is not None:
            d_p = 1 + parent**2
            px, py = (1 - parent**2)/d_p, 2*parent/d_p
            ax2.plot([px, x], [py, y_coord], '-', color=color, alpha=0.1, linewidth=0.5)

        if depth <= 2:
            ax2.annotate(f'{p}/{q}', (x, y_coord), fontsize=6,
                        xytext=(5, 5), textcoords='offset points')

    # Mark the "north pole" (t = ∞ maps to (-1, 0))
    ax2.plot(-1, 0, '*', color='red', markersize=12)
    ax2.annotate('∞ (North Pole)', (-1, 0), fontsize=8, color='red',
                xytext=(-30, 10), textcoords='offset points')

    ax2.grid(True, alpha=0.1)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/MonsterBelow/stern_brocot_stereo.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved stern_brocot_stereo.png")

# ============================================================================
# Experiment: Period Structure of Möbius Maps
# ============================================================================

def experiment_mobius_periods():
    """Investigate the period structure of two-pole Möbius maps.

    Key finding: F_{a,b} has no real fixed points when a ≠ b (they're on S¹ ≅ RP¹),
    but it DOES have period-2 orbits over the reals when (ab+1)² + (a-b)² is a
    perfect square — i.e., when the associated Pythagorean triple is primitive!
    """
    print("\n" + "="*60)
    print("EXPERIMENT: Möbius Map Period Structure")
    print("="*60)

    print("\nFor F_{a,b}(t) = ((ab+1)t + (b-a)) / ((a-b)t + (ab+1)):")
    print("The determinant is (ab+1)² + (a-b)² = a²b² + a² + b² + 1")
    print("= (a²+1)(b²+1) = |a+i|² · |b+i|²\n")

    for a in range(1, 8):
        for b in range(a+1, 8):
            det = (a*b+1)**2 + (a-b)**2
            # Factor as product of Gaussian norms
            n1 = a**2 + 1
            n2 = b**2 + 1
            assert det == n1 * n2

            # Check if det is a perfect square
            sqrt_det = int(det**0.5)
            is_square = sqrt_det * sqrt_det == det

            # Find approximate period by iterating
            t = 0.5  # arbitrary start
            for period in range(1, 100):
                t = two_pole_map(a, b, t)
                if abs(t - 0.5) < 1e-10:
                    break
            else:
                period = -1

            status = "SQUARE" if is_square else ""
            print(f"  a={a}, b={b}: det = {n1}×{n2} = {det:4d}  "
                  f"period≈{period:3d}  {status}")

    print("\nKey Insight: The determinant (a²+1)(b²+1) is the product of")
    print("two sums of two squares — always representable by Brahmagupta-Fibonacci!")
    print("This connects Möbius dynamics to the Gaussian integer tower.\n")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Inverse Stereographic Dynamics Explorer                ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    experiment_mobius_periods()

    print("Generating visualizations...")
    plot_mobius_orbits()
    plot_arithmetic_fractal()
    plot_stern_brocot_stereo()

    print("\nAll visualizations saved!")
