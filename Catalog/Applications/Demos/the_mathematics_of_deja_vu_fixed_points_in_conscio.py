#!/usr/bin/env python3
"""
Cognitive Dynamics Demo: Fixed Points and Periodic Orbits in the Logistic Map

Demonstrates the mathematical framework for modeling déjà vu as periodic
recurrence in a discrete dynamical system. Computes fixed points, periodic
orbits, bifurcation diagrams, and Lyapunov exponents for the logistic map
f(x) = r*x*(1-x).
"""

import numpy as np
from typing import List, Tuple, Optional


def logistic_map(x: float, r: float) -> float:
    """Logistic map f(x) = r*x*(1-x)."""
    return r * x * (1.0 - x)


def iterate_map(f, x0: float, n: int, r: float) -> List[float]:
    """Compute the orbit x0, f(x0), f^2(x0), ..., f^n(x0)."""
    orbit = [x0]
    x = x0
    for _ in range(n):
        x = f(x, r)
        orbit.append(x)
    return orbit


def find_fixed_points(r: float, tol: float = 1e-12) -> List[float]:
    """Find fixed points of the logistic map f(x) = r*x*(1-x).

    Fixed points satisfy r*x*(1-x) = x, i.e., x*(r - r*x - 1) = 0.
    Solutions: x = 0 and x = (r-1)/r (if r > 1).
    """
    fps = [0.0]
    if r > 1.0:
        fps.append((r - 1.0) / r)
    return fps


def find_periodic_points(r: float, period: int, n_seeds: int = 1000,
                          tol: float = 1e-10, max_iter: int = 100) -> List[float]:
    """Find period-n points of the logistic map using Newton's method.

    A period-n point satisfies f^n(x) = x. We search for roots of
    g(x) = f^n(x) - x using Newton-Raphson with multiple initial seeds.
    """
    def f_iterate(x: float, n: int) -> float:
        """Compute f^n(x)."""
        val = x
        for _ in range(n):
            val = logistic_map(val, r)
        return val

    def df_iterate(x: float, n: int) -> float:
        """Compute (f^n)'(x) via chain rule: product of f'(f^k(x))."""
        val = x
        deriv = 1.0
        for _ in range(n):
            deriv *= r * (1.0 - 2.0 * val)
            val = logistic_map(val, r)
        return deriv

    points = set()
    seeds = np.linspace(0.01, 0.99, n_seeds)

    for x0 in seeds:
        x = x0
        for _ in range(max_iter):
            g = f_iterate(x, period) - x
            dg = df_iterate(x, period) - 1.0
            if abs(dg) < 1e-15:
                break
            x_new = x - g / dg
            if abs(x_new - x) < tol:
                x = x_new
                break
            x = x_new

        # Verify it's actually a period-n point
        if 0.0 < x < 1.0 and abs(f_iterate(x, period) - x) < 1e-8:
            # Round to avoid duplicates
            x_rounded = round(x, 10)
            points.add(x_rounded)

    return sorted(points)


def compute_lyapunov_exponent(r: float, x0: float = 0.4,
                                n_transient: int = 1000,
                                n_compute: int = 10000) -> float:
    """Compute the Lyapunov exponent of the logistic map at parameter r.

    λ = lim (1/n) Σ log|f'(f^k(x))| = lim (1/n) Σ log|r(1-2*f^k(x))|
    """
    x = x0
    for _ in range(n_transient):
        x = logistic_map(x, r)

    lyap_sum = 0.0
    for _ in range(n_compute):
        deriv = abs(r * (1.0 - 2.0 * x))
        if deriv > 0:
            lyap_sum += np.log(deriv)
        x = logistic_map(x, r)

    return lyap_sum / n_compute


def recurrence_spectrum(r: float, max_period: int = 20) -> List[int]:
    """Compute the recurrence spectrum: set of periods with periodic points.

    Returns list of periods n for which the logistic map at parameter r
    has at least one period-n point (with minimal period exactly n).
    """
    spectrum = []
    all_periodic = {}

    for n in range(1, max_period + 1):
        pts = find_periodic_points(r, n)
        # Filter to those with minimal period exactly n
        genuine = []
        for p in pts:
            # Check if this point has a smaller period
            is_lower = False
            for d in range(1, n):
                if n % d == 0 and d in all_periodic:
                    for q in all_periodic[d]:
                        if abs(p - q) < 1e-8:
                            is_lower = True
                            break
                if is_lower:
                    break
            if not is_lower:
                genuine.append(p)

        if genuine:
            spectrum.append(n)
            all_periodic[n] = genuine

    return spectrum


def demo_fixed_points():
    """Demonstrate fixed point computation."""
    print("=" * 60)
    print("DEMO 1: Fixed Points of the Logistic Map")
    print("=" * 60)

    for r in [0.5, 1.0, 2.0, 3.0, 3.5, 3.83, 4.0]:
        fps = find_fixed_points(r)
        print(f"\nr = {r:.2f}: Fixed points = {[f'{x:.6f}' for x in fps]}")

        # Verify by iteration
        for fp in fps:
            val = logistic_map(fp, r)
            print(f"  f({fp:.6f}) = {val:.6f} (error: {abs(val - fp):.2e})")


def demo_periodic_orbits():
    """Demonstrate periodic orbit detection."""
    print("\n" + "=" * 60)
    print("DEMO 2: Periodic Orbits at r = 3.83 (Period-3 Window)")
    print("=" * 60)

    r = 3.83
    for period in [1, 2, 3]:
        pts = find_periodic_points(r, period, n_seeds=2000)
        print(f"\nPeriod-{period} points ({len(pts)} found):")
        for p in pts[:6]:
            orbit = iterate_map(logistic_map, p, period, r)
            print(f"  x = {p:.10f}, orbit: {[f'{v:.6f}' for v in orbit]}")


def demo_recurrence_spectrum():
    """Demonstrate recurrence spectrum computation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Recurrence Spectra at Various Parameters")
    print("=" * 60)

    params = [
        (2.5, "Stable fixed point"),
        (3.2, "Period-2 regime"),
        (3.5, "Period-4 regime"),
        (3.83, "Period-3 window (chaos)"),
        (4.0, "Full chaos"),
    ]

    for r, desc in params:
        spec = recurrence_spectrum(r, max_period=12)
        print(f"\nr = {r:.2f} ({desc})")
        print(f"  Spectrum (up to period 12): {spec}")


def demo_lyapunov():
    """Demonstrate Lyapunov exponent computation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Lyapunov Exponents")
    print("=" * 60)

    params = np.linspace(2.5, 4.0, 20)
    print(f"\n{'r':>6s} | {'λ':>10s} | {'Behavior':>20s}")
    print("-" * 42)
    for r in params:
        lyap = compute_lyapunov_exponent(r)
        if lyap < -0.01:
            behavior = "Stable periodic"
        elif lyap < 0.01:
            behavior = "Edge of chaos"
        else:
            behavior = "Chaotic"
        print(f"{r:6.3f} | {lyap:10.4f} | {behavior:>20s}")


def demo_ivt_fixed_point():
    """Demonstrate the IVT-based fixed point existence proof numerically."""
    print("\n" + "=" * 60)
    print("DEMO 5: IVT Fixed Point Existence (Numerical Verification)")
    print("=" * 60)

    r = 3.83
    print(f"\nLogistic map f(x) = {r}*x*(1-x) on [0, 1]")
    print("g(x) = f(x) - x")

    # Check boundary conditions
    g0 = logistic_map(0, r) - 0  # = 0
    g1 = logistic_map(1, r) - 1  # = -1
    print(f"\ng(0) = f(0) - 0 = {g0:.4f} ≥ 0 ✓")
    print(f"g(1) = f(1) - 1 = {g1:.4f} ≤ 0 ✓")
    print("By IVT, ∃ c ∈ [0,1] with g(c) = 0, i.e., f(c) = c")

    # Find the fixed point
    fp = (r - 1) / r
    print(f"\nFixed point: c = (r-1)/r = {fp:.10f}")
    print(f"Verification: f(c) = {logistic_map(fp, r):.10f}")
    print(f"Error: |f(c) - c| = {abs(logistic_map(fp, r) - fp):.2e}")


def demo_period3_cascade():
    """Demonstrate period-3 forcing cascading recurrence."""
    print("\n" + "=" * 60)
    print("DEMO 6: Period-3 Forces Cascading Recurrence")
    print("=" * 60)

    r = 3.83
    # Find period-3 orbit
    p3_pts = find_periodic_points(r, 3, n_seeds=5000)

    # Filter to genuine period-3 (not fixed points)
    fps = find_fixed_points(r)
    genuine_p3 = [p for p in p3_pts if all(abs(p - fp) > 1e-6 for fp in fps)]

    if len(genuine_p3) >= 3:
        # Take a period-3 orbit
        a = genuine_p3[0]
        b = logistic_map(a, r)
        c = logistic_map(b, r)
        vals = sorted([a, b, c])
        print(f"\nPeriod-3 orbit found at r = {r}:")
        print(f"  a = {vals[0]:.10f}")
        print(f"  b = {vals[1]:.10f}")
        print(f"  c = {vals[2]:.10f}")
        print(f"  f(a) = {logistic_map(vals[0], r):.10f}")
        print(f"  f(b) = {logistic_map(vals[1], r):.10f}")
        print(f"  f(c) = {logistic_map(vals[2], r):.10f}")

        # Verify IVT conditions for fixed point
        fa = logistic_map(vals[0], r)
        fc = logistic_map(vals[2], r)
        print(f"\nIVT conditions:")
        print(f"  f(a) = {fa:.6f} > a = {vals[0]:.6f}: {fa > vals[0]}")
        print(f"  f(c) = {fc:.6f} < c = {vals[2]:.6f}: {fc < vals[2]}")
        print(f"  ∴ Fixed point exists in [{vals[0]:.4f}, {vals[2]:.4f}]")

        # Verify f²-recurrence in subinterval
        f2a = logistic_map(logistic_map(vals[0], r), r)
        f2b = logistic_map(logistic_map(vals[1], r), r)
        print(f"\nf²-recurrence (Theorem 4):")
        print(f"  f²(a) = {f2a:.6f} > a = {vals[0]:.6f}: {f2a > vals[0]}")
        print(f"  f²(b) = {f2b:.6f} < b = {vals[1]:.6f}: {f2b < vals[1]}")
        print(f"  ∴ f² has fixed point in [{vals[0]:.4f}, {vals[1]:.4f}]")


if __name__ == "__main__":
    demo_fixed_points()
    demo_periodic_orbits()
    demo_recurrence_spectrum()
    demo_lyapunov()
    demo_ivt_fixed_point()
    demo_period3_cascade()

    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Bifurcation diagram of the logistic map, highlighting the period-3 window."""

import numpy as np
import matplotlib.pyplot as plt


def logistic_map(x, r):
    return r * x * (1.0 - x)


def bifurcation_diagram():
    fig, ax = plt.subplots(figsize=(14, 8))

    r_values = np.linspace(2.5, 4.0, 3000)
    n_transient = 500
    n_plot = 200

    all_r = []
    all_x = []

    for r in r_values:
        x = 0.4
        for _ in range(n_transient):
            x = logistic_map(x, r)
        for _ in range(n_plot):
            x = logistic_map(x, r)
            all_r.append(r)
            all_x.append(x)

    ax.scatter(all_r, all_x, s=0.01, c='black', alpha=0.3)

    # Highlight period-3 window
    ax.axvspan(3.828, 3.857, alpha=0.15, color='red', label='Period-3 window')
    ax.axvline(x=3.83, color='red', linestyle='--', alpha=0.5, linewidth=1)

    ax.set_xlabel('r (Cognitive Processing Intensity)', fontsize=14)
    ax.set_ylabel('x (Cognitive State)', fontsize=14)
    ax.set_title('Bifurcation Diagram: The Road to Cognitive Chaos', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xlim(2.5, 4.0)
    ax.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150)
    plt.close()
    print("Saved bifurcation_diagram.png")


if __name__ == "__main__":
    bifurcation_diagram()


#!/usr/bin/env python3
"""Cobweb diagram showing fixed point convergence and periodic orbits."""

import numpy as np
import matplotlib.pyplot as plt


def logistic_map(x, r):
    return r * x * (1.0 - x)


def cobweb_plot(r, x0, n_iter, ax, title):
    x = np.linspace(0, 1, 500)
    y = r * x * (1.0 - x)

    ax.plot(x, y, 'b-', linewidth=2, label=f'f(x) = {r}x(1-x)')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x')

    # Cobweb
    xn = x0
    xs = [xn]
    ys = [0]
    for _ in range(n_iter):
        yn = logistic_map(xn, r)
        xs.extend([xn, yn])
        ys.extend([yn, yn])
        xn = yn

    ax.plot(xs, ys, 'r-', linewidth=0.8, alpha=0.7)
    ax.plot(x0, 0, 'go', markersize=8, label=f'x₀ = {x0}')

    # Mark fixed point(s)
    if r > 1:
        fp = (r - 1) / r
        ax.plot(fp, fp, 'ko', markersize=8, zorder=5)
        ax.annotate(f'Fixed point\n({fp:.3f}, {fp:.3f})',
                     xy=(fp, fp), xytext=(fp + 0.1, fp - 0.15),
                     fontsize=10, arrowprops=dict(arrowstyle='->', color='black'))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title(title, fontsize=13)
    ax.legend(fontsize=9, loc='upper left')


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))

    configs = [
        (2.8, 0.1, 30, 'r = 2.8: Stable Fixed Point\n(Calm cognition)'),
        (3.3, 0.1, 50, 'r = 3.3: Period-2 Orbit\n(Oscillating cognition)'),
        (3.5, 0.1, 80, 'r = 3.5: Period-4 Orbit\n(Complex cycling)'),
        (3.83, 0.1, 100, 'r = 3.83: Period-3 / Chaos\n(Déjà vu regime)'),
    ]

    for ax, (r, x0, n, title) in zip(axes.flat, configs):
        cobweb_plot(r, x0, n, ax, title)

    plt.suptitle('Cobweb Diagrams: Cognitive State Trajectories',
                  fontsize=16, y=1.01)
    plt.tight_layout()
    plt.savefig('cobweb_diagrams.png', dpi=150)
    plt.close()
    print("Saved cobweb_diagrams.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Lyapunov exponent as a function of the logistic map parameter r."""

import numpy as np
import matplotlib.pyplot as plt


def logistic_map(x, r):
    return r * x * (1.0 - x)


def lyapunov_exponent(r, x0=0.4, n_transient=1000, n_compute=20000):
    x = x0
    for _ in range(n_transient):
        x = logistic_map(x, r)
    lyap_sum = 0.0
    count = 0
    for _ in range(n_compute):
        d = abs(r * (1.0 - 2.0 * x))
        if d > 0:
            lyap_sum += np.log(d)
            count += 1
        x = logistic_map(x, r)
    return lyap_sum / count if count > 0 else 0.0


def plot_lyapunov():
    fig, ax = plt.subplots(figsize=(14, 6))

    r_values = np.linspace(2.5, 4.0, 1500)
    lyap_values = [lyapunov_exponent(r) for r in r_values]

    ax.plot(r_values, lyap_values, 'b-', linewidth=0.5, alpha=0.7)
    ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax.axvspan(3.828, 3.857, alpha=0.15, color='red', label='Period-3 window')

    ax.fill_between(r_values, lyap_values, 0,
                     where=[l > 0 for l in lyap_values],
                     alpha=0.2, color='red', label='Chaotic (λ > 0)')
    ax.fill_between(r_values, lyap_values, 0,
                     where=[l <= 0 for l in lyap_values],
                     alpha=0.2, color='blue', label='Ordered (λ ≤ 0)')

    ax.set_xlabel('r (Cognitive Processing Intensity)', fontsize=14)
    ax.set_ylabel('Lyapunov Exponent λ', fontsize=14)
    ax.set_title('Lyapunov Exponent: Order vs. Chaos in Cognitive Dynamics',
                  fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xlim(2.5, 4.0)

    plt.tight_layout()
    plt.savefig('lyapunov_exponent.png', dpi=150)
    plt.close()
    print("Saved lyapunov_exponent.png")


if __name__ == "__main__":
    plot_lyapunov()
