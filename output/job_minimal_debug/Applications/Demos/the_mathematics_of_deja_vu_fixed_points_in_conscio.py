#!/usr/bin/env python3
"""
Déjà Vu Dynamics: Numerical Demonstrations

Demonstrates the mathematical inevitability of periodic recurrence (déjà vu)
in continuous dynamical systems, using the logistic map as the canonical model.

Key demonstrations:
1. Fixed points and periodic orbits of the logistic map
2. Period-3 orbit detection and Sharkovsky forcing
3. Covering relation visualization
4. Periodic point density vs. parameter r
"""

import numpy as np
from typing import List, Tuple, Optional


def logistic_map(r: float, x: float) -> float:
    """The logistic map f(x) = r * x * (1 - x)."""
    return r * x * (1.0 - x)


def iterate_logistic(r: float, x0: float, n: int) -> List[float]:
    """Compute the orbit x0, f(x0), f²(x0), ..., fⁿ(x0)."""
    orbit = [x0]
    x = x0
    for _ in range(n):
        x = logistic_map(r, x)
        orbit.append(x)
    return orbit


def find_fixed_points(r: float, tol: float = 1e-10) -> List[float]:
    """Find fixed points of the logistic map: solutions to rx(1-x) = x."""
    # x = 0 is always a fixed point
    # x = (r-1)/r is the nontrivial fixed point when r > 1
    fps = [0.0]
    if r > 1.0:
        fps.append((r - 1.0) / r)
    return fps


def find_period_n_points(r: float, n: int, num_samples: int = 10000,
                         tol: float = 1e-8) -> List[float]:
    """Find period-n points of the logistic map by numerical search."""
    points = []
    for x0 in np.linspace(0.001, 0.999, num_samples):
        x = x0
        for _ in range(n):
            x = logistic_map(r, x)
        if abs(x - x0) < tol:
            # Check it's not a fixed point of a shorter period
            is_shorter = False
            for d in range(1, n):
                if n % d == 0:
                    y = x0
                    for _ in range(d):
                        y = logistic_map(r, y)
                    if abs(y - x0) < tol:
                        is_shorter = True
                        break
            if not is_shorter:
                # Avoid duplicates
                if not any(abs(x0 - p) < 1e-6 for p in points):
                    points.append(x0)
    return sorted(points)


def compute_deja_vu_density(r: float, n_iter: int = 10000,
                            epsilon: float = 0.01) -> float:
    """
    Compute the 'déjà vu density': fraction of iterates that are
    ε-close to a previous iterate (recurrence rate).
    """
    x = 0.5  # Initial condition
    orbit = [x]
    recurrence_count = 0

    for i in range(1, n_iter):
        x = logistic_map(r, x)
        # Check if current state is ε-close to any previous state
        for prev in orbit:
            if abs(x - prev) < epsilon:
                recurrence_count += 1
                break
        orbit.append(x)

    return recurrence_count / n_iter


def verify_period3_orbit(r: float) -> Optional[Tuple[float, float, float]]:
    """
    Find a period-3 orbit of the logistic map at parameter r.
    Returns (a, b, c) with a < b < c if found, None otherwise.
    """
    for x0 in np.linspace(0.01, 0.99, 5000):
        x1 = logistic_map(r, x0)
        x2 = logistic_map(r, x1)
        x3 = logistic_map(r, x2)

        if abs(x3 - x0) < 1e-8 and abs(x1 - x0) > 1e-4 and abs(x2 - x0) > 1e-4:
            triple = sorted([x0, x1, x2])
            return tuple(triple)
    return None


def covering_relation_demo(r: float = 3.83):
    """
    Demonstrate the covering relations for a period-3 orbit.
    Shows that f([b,c]) ⊇ [a,c] and f([a,b]) ⊇ [b,c].
    """
    orbit = verify_period3_orbit(r)
    if orbit is None:
        print(f"No period-3 orbit found at r = {r}")
        return

    a, b, c = orbit
    print(f"\nCovering Relation Demo (r = {r})")
    print(f"Period-3 orbit: a={a:.6f}, b={b:.6f}, c={c:.6f}")

    # Check f([b,c]) ⊇ [a,c]
    xs_bc = np.linspace(b, c, 1000)
    ys_bc = [logistic_map(r, x) for x in xs_bc]
    print(f"\nf([b,c]) range: [{min(ys_bc):.6f}, {max(ys_bc):.6f}]")
    print(f"[a,c] = [{a:.6f}, {c:.6f}]")
    print(f"f([b,c]) ⊇ [a,c]: {min(ys_bc) <= a + 1e-6 and max(ys_bc) >= c - 1e-6}")

    # Check f([a,b]) ⊇ [b,c]
    xs_ab = np.linspace(a, b, 1000)
    ys_ab = [logistic_map(r, x) for x in xs_ab]
    print(f"\nf([a,b]) range: [{min(ys_ab):.6f}, {max(ys_ab):.6f}]")
    print(f"[b,c] = [{b:.6f}, {c:.6f}]")
    print(f"f([a,b]) ⊇ [b,c]: {min(ys_ab) <= b + 1e-6 and max(ys_ab) >= c - 1e-6}")


def bifurcation_analysis():
    """Analyze periodic point density across the bifurcation diagram."""
    print("\n=== Bifurcation Analysis: Periodic Point Density ===")
    print(f"{'r':>6s}  {'Period-1':>10s}  {'Period-2':>10s}  {'Period-3':>10s}  {'Density':>10s}")
    print("-" * 55)

    for r in [2.5, 3.0, 3.2, 3.5, 3.83, 3.9, 4.0]:
        fps = find_fixed_points(r)
        p2 = find_period_n_points(r, 2, num_samples=5000)
        p3 = find_period_n_points(r, 3, num_samples=5000)
        density = compute_deja_vu_density(r, n_iter=5000, epsilon=0.01)

        print(f"{r:6.2f}  {len(fps):10d}  {len(p2):10d}  {len(p3):10d}  {density:10.4f}")


def stability_analysis():
    """Analyze fixed point stability via derivative."""
    print("\n=== Fixed Point Stability Analysis ===")
    print("Derivative at nontrivial fixed point x* = (r-1)/r is (2-r)")
    print(f"{'r':>6s}  {'x*':>10s}  {'f\\'(x*)':>10s}  {'|f\\'(x*)|':>10s}  {'Stable?':>10s}")
    print("-" * 55)

    for r in [1.5, 2.0, 2.5, 3.0, 3.2, 3.5, 3.83, 4.0]:
        if r > 1:
            xstar = (r - 1) / r
            deriv = 2 - r
            stable = "Yes" if abs(deriv) < 1 else "No"
            print(f"{r:6.2f}  {xstar:10.6f}  {deriv:10.4f}  {abs(deriv):10.4f}  {stable:>10s}")


def main():
    print("=" * 60)
    print("  DÉJÀ VU DYNAMICS: Mathematical Inevitability of Recurrence")
    print("=" * 60)

    # Demo 1: Fixed points
    print("\n--- Demo 1: Fixed Points ---")
    for r in [2.0, 3.0, 4.0]:
        fps = find_fixed_points(r)
        print(f"r = {r}: fixed points = {fps}")

    # Demo 2: Period-3 orbit
    print("\n--- Demo 2: Period-3 Orbit at r = 3.83 ---")
    orbit = verify_period3_orbit(3.83)
    if orbit:
        a, b, c = orbit
        print(f"Period-3 orbit found: ({a:.6f}, {b:.6f}, {c:.6f})")
        print(f"f(a) = {logistic_map(3.83, a):.6f} ≈ b = {b:.6f}")
        print(f"f(b) = {logistic_map(3.83, b):.6f} ≈ c = {c:.6f}")
        print(f"f(c) = {logistic_map(3.83, c):.6f} ≈ a = {a:.6f}")

    # Demo 3: Covering relations
    covering_relation_demo(3.83)

    # Demo 4: Stability
    stability_analysis()

    # Demo 5: Bifurcation
    bifurcation_analysis()

    # Demo 6: Déjà vu density comparison
    print("\n--- Demo 6: Déjà Vu Density vs Empirical Rate ---")
    print("Empirical déjà vu lifetime incidence: ~70%")
    for r in [3.5, 3.83, 3.9, 4.0]:
        density = compute_deja_vu_density(r, n_iter=10000, epsilon=0.02)
        print(f"r = {r:.2f}: recurrence density = {density:.4f} ({density*100:.1f}%)")

    print("\n--- Demo 7: Sharkovsky Forcing ---")
    print("Period-3 at r=3.83 forces ALL periods:")
    for n in [1, 2, 3, 4, 5, 6, 7, 8]:
        pts = find_period_n_points(3.83, n, num_samples=10000)
        print(f"  Period {n}: {len(pts)} point(s) found")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Bifurcation Diagram and Periodic Point Density Visualization

Creates a publication-quality bifurcation diagram of the logistic map
with periodic point density overlay showing the déjà vu frequency.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def logistic_map(r, x):
    return r * x * (1.0 - x)


def compute_bifurcation_data(r_min=2.5, r_max=4.0, r_steps=2000,
                              warmup=500, n_plot=200):
    rs = np.linspace(r_min, r_max, r_steps)
    r_vals = []
    x_vals = []
    for r in rs:
        x = 0.5
        for _ in range(warmup):
            x = logistic_map(r, x)
        for _ in range(n_plot):
            x = logistic_map(r, x)
            r_vals.append(r)
            x_vals.append(x)
    return np.array(r_vals), np.array(x_vals)


def compute_recurrence_density(r_values, n_iter=5000, epsilon=0.02):
    densities = []
    for r in r_values:
        x = 0.5
        orbit = []
        recurrence_count = 0
        for _ in range(200):
            x = logistic_map(r, x)
        for i in range(n_iter):
            x = logistic_map(r, x)
            for prev in orbit[-50:]:
                if abs(x - prev) < epsilon:
                    recurrence_count += 1
                    break
            orbit.append(x)
        densities.append(recurrence_count / n_iter)
    return np.array(densities)


def main():
    fig = plt.figure(figsize=(14, 10))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

    # Panel 1: Bifurcation diagram
    ax1 = fig.add_subplot(gs[0, :])
    r_vals, x_vals = compute_bifurcation_data()
    ax1.scatter(r_vals, x_vals, s=0.01, c='#2c3e50', alpha=0.3, rasterized=True)
    ax1.axvline(x=3.83, color='red', linestyle='--', alpha=0.7, label='r=3.83 (Period-3)')
    ax1.set_xlabel('Parameter r', fontsize=12)
    ax1.set_ylabel('Attractor x', fontsize=12)
    ax1.set_title('Bifurcation Diagram of the Logistic Map', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)

    # Panel 2: Recurrence density
    ax2 = fig.add_subplot(gs[1, 0])
    r_range = np.linspace(2.5, 4.0, 150)
    densities = compute_recurrence_density(r_range)
    ax2.plot(r_range, densities, color='#e74c3c', linewidth=1.5)
    ax2.axhline(y=0.7, color='green', linestyle='--', alpha=0.7, label='70% empirical rate')
    ax2.axvline(x=3.83, color='red', linestyle=':', alpha=0.5)
    ax2.set_xlabel('Parameter r', fontsize=12)
    ax2.set_ylabel('Recurrence Density', fontsize=12)
    ax2.set_title('Déjà Vu Density vs. Parameter', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 1)

    # Panel 3: Lyapunov exponent
    ax3 = fig.add_subplot(gs[1, 1])
    lyap = []
    for r in r_range:
        x = 0.5
        for _ in range(500):
            x = logistic_map(r, x)
        s = 0.0
        for _ in range(5000):
            deriv = abs(r * (1.0 - 2.0 * x))
            if deriv > 0:
                s += np.log(deriv)
            x = logistic_map(r, x)
        lyap.append(s / 5000)

    ax3.plot(r_range, lyap, color='#3498db', linewidth=1.5)
    ax3.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax3.axvline(x=3.83, color='red', linestyle=':', alpha=0.5)
    ax3.fill_between(r_range, lyap, 0, where=[l > 0 for l in lyap],
                     color='#e74c3c', alpha=0.1, label='Chaotic (λ > 0)')
    ax3.fill_between(r_range, lyap, 0, where=[l <= 0 for l in lyap],
                     color='#2ecc71', alpha=0.1, label='Regular (λ ≤ 0)')
    ax3.set_xlabel('Parameter r', fontsize=12)
    ax3.set_ylabel('Lyapunov Exponent λ', fontsize=12)
    ax3.set_title('Chaos Indicator: Lyapunov Exponent', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=10)

    plt.suptitle('The Mathematics of Déjà Vu: Periodic Recurrence in Cognitive Dynamics',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.savefig('bifurcation_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved bifurcation_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Orbit and Covering Relation Visualization

Visualizes:
1. Cobweb diagrams showing periodic orbits
2. Covering relations between intervals
3. The forcing cascade from period-3
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def logistic_map(r, x):
    return r * x * (1.0 - x)


def cobweb_plot(ax, r, x0, n_iter, color='#e74c3c', title=''):
    """Draw a cobweb diagram for the logistic map."""
    x = np.linspace(0, 1, 500)
    y = r * x * (1 - x)

    ax.plot(x, y, 'b-', linewidth=2, label=f'f(x) = {r}x(1-x)')
    ax.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')

    # Cobweb
    xi = x0
    for _ in range(n_iter):
        yi = logistic_map(r, xi)
        ax.plot([xi, xi], [xi, yi], color=color, linewidth=0.8, alpha=0.7)
        ax.plot([xi, yi], [yi, yi], color=color, linewidth=0.8, alpha=0.7)
        xi = yi

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)


def covering_diagram(ax, r=3.83):
    """Visualize the interval covering relations for period-3."""
    # Find period-3 orbit
    x0 = 0.5
    for _ in range(1000):
        x0 = logistic_map(r, x0)

    x1 = logistic_map(r, x0)
    x2 = logistic_map(r, x1)
    pts = sorted([x0, x1, x2])
    a, b, c = pts

    x = np.linspace(0, 1, 1000)
    y = r * x * (1 - x)

    ax.plot(x, y, 'b-', linewidth=2)
    ax.plot(x, x, 'k--', linewidth=1, alpha=0.3)

    # Highlight intervals
    ax.axvspan(a, b, alpha=0.15, color='green', label=f'I₁=[{a:.2f},{b:.2f}]')
    ax.axvspan(b, c, alpha=0.15, color='orange', label=f'I₂=[{b:.2f},{c:.2f}]')

    # Show f(I₂) covers [a,c]
    xs_bc = np.linspace(b, c, 200)
    ys_bc = r * xs_bc * (1 - xs_bc)
    ax.fill_between(xs_bc, 0, ys_bc, alpha=0.1, color='red')

    # Mark period-3 orbit
    for p in pts:
        fp = logistic_map(r, p)
        ax.plot(p, fp, 'ro', markersize=8, zorder=5)
        ax.annotate(f'({p:.2f}, {fp:.2f})', (p, fp), fontsize=8,
                    xytext=(5, 5), textcoords='offset points')

    # Covering arrows
    mid_ab = (a + b) / 2
    mid_bc = (b + c) / 2
    ax.annotate('', xy=(mid_bc, 0.05), xytext=(mid_ab, 0.05),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.annotate('', xy=(mid_ab, 0.02), xytext=(mid_bc, 0.02),
                arrowprops=dict(arrowstyle='->', color='orange', lw=2))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('f(x)', fontsize=11)
    ax.set_title(f'Covering Relations at r={r}', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Panel 1: Stable fixed point (r = 2.5)
    cobweb_plot(axes[0, 0], 2.5, 0.2, 30, color='#27ae60',
                title='r=2.5: Stable Fixed Point (No Chaos)')

    # Panel 2: Period-2 orbit (r = 3.2)
    cobweb_plot(axes[0, 1], 3.2, 0.2, 50, color='#f39c12',
                title='r=3.2: Period-2 Orbit')

    # Panel 3: Period-3 orbit (r = 3.83)
    cobweb_plot(axes[1, 0], 3.83, 0.5, 100, color='#e74c3c',
                title='r=3.83: Period-3 → Chaos (Sharkovsky)')

    # Panel 4: Covering relations
    covering_diagram(axes[1, 1])

    plt.suptitle('Cognitive Dynamics: From Stability to Chaos',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('orbit_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved orbit_analysis.png")


if __name__ == "__main__":
    main()
