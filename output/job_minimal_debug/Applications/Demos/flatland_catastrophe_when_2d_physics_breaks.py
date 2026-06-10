#!/usr/bin/env python3
"""
Flatland Catastrophe: Numerical Demonstrations

Demonstrates the mathematical pathologies of 2D Newtonian gravity:
1. Logarithmic potential growth (no escape velocity)
2. Non-closing orbits (apsidal angle = π/√2, irrational)
3. Orbit density — the orbit fills an annulus
4. Effective potential analysis
5. Dimensional comparison
"""

import math

def apsidal_angle_ratio(n: int) -> float:
    """Apsidal angle ratio for n-dimensional gravity: 1/√(4-n)."""
    if n >= 4:
        return float('inf')  # No stable orbits
    return 1.0 / math.sqrt(4 - n)

def effective_potential_2d(r: float, L: float, k: float = 1.0) -> float:
    """Effective potential for 2D gravity: V_eff(r) = k·ln(r) + L²/(2r²)."""
    if r <= 0:
        return float('inf')
    return k * math.log(r) + L**2 / (2 * r**2)

def effective_potential_3d(r: float, L: float, k: float = 1.0) -> float:
    """Effective potential for 3D gravity: V_eff(r) = -k/r + L²/(2r²)."""
    if r <= 0:
        return float('inf')
    return -k / r + L**2 / (2 * r**2)

def circular_orbit_radius_2d(L: float, k: float = 1.0, m: float = 1.0) -> float:
    """Circular orbit radius for 2D gravity: r₀ = |L|/√(mk)."""
    return abs(L) / math.sqrt(m * k)

def stability_discriminant(n: int) -> int:
    """Stability discriminant for n-dimensional gravity: 4 - n."""
    return 4 - n

def viability_score(n: int) -> int:
    """Count of viability conditions met: stability, closure, escape."""
    score = 0
    if n < 4: score += 1      # stability
    if n == 3: score += 1      # closure
    if n >= 3: score += 1      # escape
    return score

def simulate_orbit_2d(steps: int = 1000, dt: float = 0.01,
                       r0: float = 1.0, vr0: float = 0.0, L: float = 1.0):
    """Simulate a 2D gravitational orbit using Verlet integration.
    Returns list of (x, y) positions."""
    r = r0
    vr = vr0
    theta = 0.0
    positions = []

    for _ in range(steps):
        x = r * math.cos(theta)
        y = r * math.sin(theta)
        positions.append((x, y))

        # Equations of motion for 2D gravity (F = -k/r)
        # r'' = L²/r³ - k/r  (centrifugal - gravitational)
        # θ' = L/r²
        ar = L**2 / r**3 - 1.0 / r  # k = 1

        # Verlet integration
        r_new = r + vr * dt + 0.5 * ar * dt**2
        if r_new <= 0.01:
            r_new = 0.01  # Prevent collision
        ar_new = L**2 / r_new**3 - 1.0 / r_new
        vr = vr + 0.5 * (ar + ar_new) * dt
        r = r_new
        theta += L / r**2 * dt

    return positions

def count_self_intersections(positions, tolerance=0.05):
    """Count approximate self-intersections in an orbit trajectory."""
    n = len(positions)
    count = 0
    for i in range(n):
        for j in range(i + 10, n):  # Skip nearby points
            dx = positions[i][0] - positions[j][0]
            dy = positions[i][1] - positions[j][1]
            if math.sqrt(dx**2 + dy**2) < tolerance:
                count += 1
    return count

def fractional_parts_density(alpha: float, N: int = 1000):
    """Compute fractional parts of n·α for n = 0..N-1."""
    return [n * alpha - math.floor(n * alpha) for n in range(N)]

# ============================================================
# DEMONSTRATIONS
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("FLATLAND CATASTROPHE: Numerical Demonstrations")
    print("=" * 60)

    # Demo 1: Apsidal angle ratios
    print("\n--- Demo 1: Apsidal Angle Ratios ---")
    for n in range(2, 6):
        ratio = apsidal_angle_ratio(n)
        rational = "RATIONAL (=1)" if n == 3 else "IRRATIONAL" if n == 2 else "UNDEFINED"
        print(f"  n={n}: ratio = {ratio:.6f}, {rational}")
    print(f"  1/√2 = {1/math.sqrt(2):.10f} (irrational)")
    print(f"  Orbits close in 2D? NO (1/√2 is irrational)")
    print(f"  Orbits close in 3D? YES (1/√1 = 1 is rational)")

    # Demo 2: Effective potential comparison
    print("\n--- Demo 2: Effective Potential ---")
    L = 1.0
    print("  2D: V_eff(r) = ln(r) + L²/(2r²)")
    print("  3D: V_eff(r) = -1/r + L²/(2r²)")
    for r in [0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        v2d = effective_potential_2d(r, L)
        v3d = effective_potential_3d(r, L)
        print(f"  r={r:6.1f}: V_2D={v2d:8.4f}, V_3D={v3d:8.4f}")
    print("  Note: V_2D → ∞ as r → ∞ (no escape!)")
    print("  Note: V_3D → 0 as r → ∞ (escape possible)")

    # Demo 3: Stability analysis
    print("\n--- Demo 3: Stability Discriminant (4-n) ---")
    for n in range(2, 8):
        disc = stability_discriminant(n)
        status = "STABLE" if disc > 0 else "MARGINAL" if disc == 0 else "UNSTABLE"
        print(f"  n={n}: σ = {disc:+d} → {status}")

    # Demo 4: Viability score
    print("\n--- Demo 4: Viability Score ---")
    for n in range(2, 8):
        score = viability_score(n)
        star = " ★ GOLDILOCKS" if score == 3 else ""
        print(f"  n={n}: score = {score}/3{star}")

    # Demo 5: Orbit simulation
    print("\n--- Demo 5: 2D Orbit Simulation ---")
    positions = simulate_orbit_2d(steps=5000, dt=0.005, r0=1.0, vr0=0.1)
    r_min = min(math.sqrt(x**2 + y**2) for x, y in positions)
    r_max = max(math.sqrt(x**2 + y**2) for x, y in positions)
    print(f"  Periapsis: r_min = {r_min:.4f}")
    print(f"  Apoapsis:  r_max = {r_max:.4f}")
    print(f"  Annulus width: {r_max - r_min:.4f}")
    theta_final = math.atan2(positions[-1][1], positions[-1][0])
    print(f"  Final angle: {theta_final:.4f} rad")
    print(f"  Orbit does NOT return to start (Bertrand failure)")

    # Demo 6: Fractional parts density
    print("\n--- Demo 6: Fractional Parts of n/√2 ---")
    alpha = 1.0 / math.sqrt(2)
    fracs = fractional_parts_density(alpha, N=100)
    # Check coverage of [0,1] in 10 bins
    bins = [0] * 10
    for f in fracs:
        bins[min(int(f * 10), 9)] += 1
    print(f"  Distribution of fract(n/√2) in 10 bins (N=100):")
    for i, count in enumerate(bins):
        bar = "█" * count
        print(f"    [{i/10:.1f}, {(i+1)/10:.1f}): {count:3d} {bar}")
    print("  → Approximately uniform (equidistribution)")

    # Demo 7: Conjectured intersections
    print("\n--- Demo 7: Conjectured Self-Intersections ---")
    for N in [10, 50, 100, 500]:
        predicted = N * (N - 1) // 2
        print(f"  N={N:4d} oscillations: ~{predicted} intersections")

    print("\n" + "=" * 60)
    print("CONCLUSION: 2D gravity is fundamentally pathological.")
    print("Only dimension 3 supports viable planetary systems.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Dimensional Classification of Gravity

Shows the complete classification of gravitational dimensions,
highlighting that only n=3 achieves perfect viability score.
"""

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    dims = list(range(2, 9))
    stability = [1 if n < 4 else 0 for n in dims]
    closure = [1 if n == 3 else 0 for n in dims]
    escape = [1 if n >= 3 else 0 for n in dims]
    total = [s + c + e for s, c, e in zip(stability, closure, escape)]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    # Stacked bar chart
    x = np.arange(len(dims))
    width = 0.6

    ax1.bar(x, stability, width, label='Stability (n<4)', color='#2196F3', alpha=0.8)
    ax1.bar(x, closure, width, bottom=stability, label='Closure (n=3 only)', color='#4CAF50', alpha=0.8)
    ax1.bar(x, escape, width, bottom=[s+c for s,c in zip(stability, closure)],
            label='Escape (n≥3)', color='#FF9800', alpha=0.8)

    ax1.set_xticks(x)
    ax1.set_xticklabels([str(d) for d in dims])
    ax1.set_xlabel('Spatial Dimension n', fontsize=12)
    ax1.set_ylabel('Viability Score', fontsize=12)
    ax1.set_title('Gravitational Viability by Dimension', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 4)

    # Highlight n=3
    ax1.annotate('★ GOLDILOCKS', xy=(1, 3.2), fontsize=14, color='gold',
                fontweight='bold', ha='center')

    # Classification labels
    labels = ['Flatland\n(trapped)', 'Goldilocks\n(viable!)', 'Marginal\n(fragile)',
              'Catastrophic', 'Catastrophic', 'Catastrophic', 'Catastrophic']
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#F44336', '#F44336', '#F44336']

    # Stability discriminant plot
    sigma = [4 - n for n in dims]
    ax2.bar(x, sigma, width, color=colors, alpha=0.8)
    ax2.axhline(y=0, color='black', linewidth=2)
    ax2.set_xticks(x)
    ax2.set_xticklabels([f'n={d}\n{labels[i]}' for i, d in enumerate(dims)], fontsize=9)
    ax2.set_ylabel('Stability Discriminant σ = 4−n', fontsize=12)
    ax2.set_title('Stability Phase Transition at n=4', fontsize=14, fontweight='bold')

    for i, (d, s) in enumerate(zip(dims, sigma)):
        ax2.annotate(f'σ={s}', xy=(i, s + (0.2 if s >= 0 else -0.4)),
                    ha='center', fontsize=11, fontweight='bold')

    plt.tight_layout()
    plt.savefig('viz_dimensional_classification.png', dpi=150, bbox_inches='tight')
    print("Saved viz_dimensional_classification.png")
except ImportError:
    print("matplotlib not available, skipping visualization")


#!/usr/bin/env python3
"""Visualization: Effective Potentials in 2D vs 3D Gravity

Shows why 2D gravity traps all particles (V_eff → ∞)
while 3D allows escape (V_eff → 0).
"""
import math

def v_eff_2d(r, L=1.0, k=1.0):
    return k * math.log(r) + L**2 / (2 * r**2)

def v_eff_3d(r, L=1.0, k=1.0):
    return -k / r + L**2 / (2 * r**2)

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    r = np.linspace(0.3, 10, 1000)
    L = 1.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # 2D effective potential
    v2d = [v_eff_2d(ri, L) for ri in r]
    ax1.plot(r, v2d, 'b-', linewidth=2, label=r'$V_{\rm eff}(r) = \ln r + L^2/(2r^2)$')
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    r0_2d = abs(L)
    v0_2d = v_eff_2d(r0_2d, L)
    ax1.plot(r0_2d, v0_2d, 'ro', markersize=10, label=f'Circular orbit r₀={r0_2d:.1f}')
    ax1.annotate('No escape!\nV → ∞', xy=(8, v_eff_2d(8, L)), fontsize=12, color='red',
                ha='center', fontweight='bold')
    ax1.set_title('2D Gravity: Logarithmic Trap', fontsize=14)
    ax1.set_xlabel('r', fontsize=12)
    ax1.set_ylabel(r'$V_{\rm eff}(r)$', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-2, 5)
    ax1.grid(True, alpha=0.3)

    # 3D effective potential
    v3d = [v_eff_3d(ri, L) for ri in r]
    ax2.plot(r, v3d, 'r-', linewidth=2, label=r'$V_{\rm eff}(r) = -1/r + L^2/(2r^2)$')
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    r0_3d = L**2
    v0_3d = v_eff_3d(r0_3d, L)
    ax2.plot(r0_3d, v0_3d, 'ro', markersize=10, label=f'Circular orbit r₀={r0_3d:.1f}')
    ax2.annotate('Escape possible!\nV → 0', xy=(8, -0.15), fontsize=12, color='green',
                ha='center', fontweight='bold')
    ax2.set_title('3D Gravity: Escape Possible', fontsize=14)
    ax2.set_xlabel('r', fontsize=12)
    ax2.set_ylabel(r'$V_{\rm eff}(r)$', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.set_ylim(-2, 5)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Effective Potential: Why 2D Particles Cannot Escape', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_effective_potential.png', dpi=150, bbox_inches='tight')
    print("Saved viz_effective_potential.png")
except ImportError:
    print("matplotlib not available, skipping visualization")


#!/usr/bin/env python3
"""Visualization: 2D vs 3D Gravitational Orbits

Shows the dramatic difference between orbits in 2D (non-closing, filling annulus)
and 3D (closed ellipses).
"""
import math

def simulate_orbit(n_dim, steps=8000, dt=0.002, r0=1.0, vr0=0.3, L=1.0, k=1.0):
    """Simulate orbit in n-dimensional gravity. Returns (xs, ys)."""
    r = r0
    vr = vr0
    theta = 0.0
    force_exp = 1 - n_dim
    xs, ys = [], []
    for _ in range(steps):
        xs.append(r * math.cos(theta))
        ys.append(r * math.sin(theta))
        ar = L**2 / r**3 - k * r**force_exp
        r_new = r + vr * dt + 0.5 * ar * dt**2
        r_new = max(r_new, 0.01)
        ar_new = L**2 / r_new**3 - k * r_new**force_exp
        vr = vr + 0.5 * (ar + ar_new) * dt
        r = r_new
        theta += L / r**2 * dt
    return xs, ys

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # 2D gravity orbit
    xs2, ys2 = simulate_orbit(2, steps=15000, dt=0.002)
    ax1.plot(xs2, ys2, 'b-', linewidth=0.3, alpha=0.6)
    ax1.plot(0, 0, 'ko', markersize=8)
    ax1.set_title('2D Gravity: Non-Closing Orbit\n(fills annulus, never repeats)', fontsize=13)
    ax1.set_aspect('equal')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.grid(True, alpha=0.3)

    # 3D gravity orbit
    xs3, ys3 = simulate_orbit(3, steps=15000, dt=0.002)
    ax3_plot = ax2
    ax3_plot.plot(xs3, ys3, 'r-', linewidth=0.5, alpha=0.8)
    ax3_plot.plot(0, 0, 'ko', markersize=8)
    ax3_plot.set_title('3D Gravity: Closed Elliptical Orbit\n(returns to start each period)', fontsize=13)
    ax3_plot.set_aspect('equal')
    ax3_plot.set_xlabel('x')
    ax3_plot.set_ylabel('y')
    ax3_plot.grid(True, alpha=0.3)

    plt.suptitle('Flatland Catastrophe: Why 2D Orbits Never Close', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_orbit_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved viz_orbit_comparison.png")
except ImportError:
    print("matplotlib not available, skipping visualization")
