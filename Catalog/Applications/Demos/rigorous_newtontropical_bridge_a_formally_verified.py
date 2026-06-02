"""
Newton–Tropical Bridge: Demonstration

Numerical examples demonstrating the Root–Valuation Bridge Theorem
and related results.
"""

from algorithms import (
    tropical_eval, find_dominant_index, verify_slope_certificate,
    generate_divisibility_certificate, newton_polygon_breakpoints,
    tropical_concavity_check, p_adic_valuation, bridge_theorem_numerical_test
)


def demo_bridge_theorem():
    """Demonstrate the Root–Valuation Bridge Theorem with concrete examples."""
    print("=" * 70)
    print("DEMO 1: Root–Valuation Bridge Theorem")
    print("=" * 70)
    print()
    print("The bridge theorem states: v(f(a)) >= T_f(v(a))")
    print("where T_f(t) = min_i(v(a_i) + i*t) is the tropical evaluation.")
    print()

    test_cases = [
        # (coefficients, evaluation point, prime)
        ([1, 7, 49, 343], 7, 7),      # f(x) = 1 + 7x + 49x² + 343x³
        ([6, 15, 10], 3, 3),           # f(x) = 6 + 15x + 10x²
        ([2, 4, 8, 16], 2, 2),         # f(x) = 2 + 4x + 8x² + 16x³
        ([5, 25, 125], 5, 5),          # f(x) = 5 + 25x + 125x²
        ([3, 9, 27, 81, 243], 3, 3),   # f(x) = 3 + 9x + 27x² + 81x³ + 243x⁴
    ]

    for coeffs, a, p in test_cases:
        v_fa, trop, holds = bridge_theorem_numerical_test(coeffs, a, p)
        fa = sum(c * a**i for i, c in enumerate(coeffs))
        profile = [float(p_adic_valuation(c, p)) for c in coeffs]

        print(f"  f(x) = {' + '.join(f'{c}x^{i}' if i > 0 else str(c) for i, c in enumerate(coeffs))}")
        print(f"  a = {a}, p = {p}")
        print(f"  f({a}) = {fa}")
        print(f"  Newton profile: {profile}")
        print(f"  v_p(f(a)) = {v_fa}")
        print(f"  T_f(v_p(a)) = {trop}")
        print(f"  Bridge holds: {holds} (gap = {v_fa - trop})")
        print()


def demo_slope_certificates():
    """Demonstrate slope certificates and dominant term identification."""
    print("=" * 70)
    print("DEMO 2: Slope Certificates")
    print("=" * 70)
    print()
    print("A slope certificate identifies when one tropical term dominates all others.")
    print()

    profile = [3.0, 1.0, 4.0, 2.0]
    test_points = [0.0, 0.5, 1.0, 2.0, 3.0, 5.0]

    print(f"  Newton profile: {profile}")
    print(f"  Degree: {len(profile) - 1}")
    print()

    for t in test_points:
        trop = tropical_eval(profile, t)
        dom_idx, gap = find_dominant_index(profile, t)
        valid, cert_gap = verify_slope_certificate(profile, t, dom_idx)

        terms = [profile[i] + i * t for i in range(len(profile))]
        print(f"  t = {t:4.1f}: T_f(t) = {trop:5.1f}, dominant = index {dom_idx}, "
              f"gap = {gap:5.2f}, certificate {'VALID' if valid else 'INVALID'}")
        print(f"          terms = {[f'{v:.1f}' for v in terms]}")


def demo_newton_polygon():
    """Demonstrate Newton polygon breakpoint computation."""
    print()
    print("=" * 70)
    print("DEMO 3: Newton Polygon Breakpoints")
    print("=" * 70)
    print()
    print("Breakpoints of T_f(t) correspond to slopes of the Newton polygon.")
    print()

    profile = [6.0, 2.0, 5.0, 1.0, 3.0]
    breakpoints = newton_polygon_breakpoints(profile)

    print(f"  Newton profile: {profile}")
    print(f"  Number of breakpoints: {len(breakpoints)}")
    print()

    for t_break, left, right in breakpoints:
        print(f"  Breakpoint at t = {t_break:.4f}: "
              f"transition from index {left} -> {right}")
        print(f"    Left term:  profile[{left}] + {left}*t = {profile[left] + left * t_break:.4f}")
        print(f"    Right term: profile[{right}] + {right}*t = {profile[right] + right * t_break:.4f}")


def demo_concavity():
    """Demonstrate the concavity of tropical evaluation."""
    print()
    print("=" * 70)
    print("DEMO 4: Concavity of Tropical Evaluation")
    print("=" * 70)
    print()
    print("T_f(w₁t₁ + w₂t₂) ≥ w₁·T_f(t₁) + w₂·T_f(t₂)")
    print()

    profile = [3.0, 1.0, 4.0, 1.0, 5.0]
    pairs = [(0.0, 5.0), (1.0, 3.0), (-2.0, 4.0), (0.5, 2.5)]

    for t1, t2 in pairs:
        for w1 in [0.0, 0.25, 0.5, 0.75, 1.0]:
            w2 = 1.0 - w1
            holds, margin = tropical_concavity_check(profile, t1, t2, w1, w2)
            if w1 in [0.25, 0.5, 0.75]:
                status = "✓" if holds else "✗"
                print(f"  t₁={t1:5.1f}, t₂={t2:5.1f}, w₁={w1:.2f}: "
                      f"margin = {margin:8.4f}  {status}")


def demo_divisibility_certificate():
    """Demonstrate divisibility depth certificates."""
    print()
    print("=" * 70)
    print("DEMO 5: Divisibility Depth Certificates")
    print("=" * 70)
    print()

    # f(x) = 49 + 343x + 2401x² (all coefficients divisible by 7^2)
    coeffs = [49, 343, 2401]
    a = 7
    p = 7
    v_coeffs = [float(p_adic_valuation(c, p)) for c in coeffs]
    v_a = float(p_adic_valuation(a, p))

    print(f"  f(x) = {coeffs[0]} + {coeffs[1]}x + {coeffs[2]}x²")
    print(f"  Evaluating at a = {a}, p = {p}")
    print(f"  Coefficient valuations: {v_coeffs}")
    print(f"  Point valuation: v_{p}({a}) = {v_a}")
    print()

    for k in range(1, 6):
        cert = generate_divisibility_certificate(v_coeffs, v_a, float(k))
        if cert is not None:
            print(f"  Can certify {p}^{k} | f({a})? YES  "
                  f"(tropical eval = {cert['tropical_eval']})")
        else:
            print(f"  Can certify {p}^{k} | f({a})? NO")

    # Verify directly
    fa = sum(c * a**i for i, c in enumerate(coeffs))
    print(f"\n  Actual f({a}) = {fa}")
    print(f"  Actual v_{p}(f({a})) = {p_adic_valuation(fa, p)}")


if __name__ == "__main__":
    demo_bridge_theorem()
    demo_slope_certificates()
    demo_newton_polygon()
    demo_concavity()
    demo_divisibility_certificate()


"""
Visualization: Newton Polygon and Tropical Evaluation

Generates a plot showing:
1. The Newton polygon (coefficient valuation points + lower convex hull)
2. The tropical evaluation function T_f(t) as a piecewise-linear curve
3. Breakpoints where the dominant term changes
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_eval(profile, t):
    """Compute tropical evaluation T_f(t) = min_i(profile[i] + i*t)."""
    return min(profile[i] + i * t for i in range(len(profile)))


def newton_polygon_hull(profile):
    """Compute the lower convex hull of (i, profile[i])."""
    n = len(profile)
    hull = []
    for i in range(n):
        while len(hull) >= 2:
            i1, i2 = hull[-2], hull[-1]
            cross = (profile[i2] - profile[i1]) * (i - i1) - \
                    (profile[i] - profile[i1]) * (i2 - i1)
            if cross >= 0:
                hull.pop()
            else:
                break
        hull.append(i)
    return hull


def main():
    # Example Newton profile: v(a_i) for polynomial of degree 5
    profile = [5.0, 2.0, 6.0, 1.0, 4.0, 3.0]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Newton polygon ---
    ax1 = axes[0]
    n = len(profile)
    xs = list(range(n))

    # Plot all points
    ax1.scatter(xs, profile, color='steelblue', s=80, zorder=5, label='(i, v(aᵢ))')

    # Compute and plot lower convex hull
    hull = newton_polygon_hull(profile)
    hull_x = [i for i in hull]
    hull_y = [profile[i] for i in hull]
    ax1.plot(hull_x, hull_y, 'r-o', linewidth=2, markersize=6,
             label='Lower convex hull', zorder=4)

    # Annotate slopes
    for k in range(len(hull) - 1):
        i, j = hull[k], hull[k + 1]
        slope = (profile[j] - profile[i]) / (j - i)
        mid_x = (i + j) / 2
        mid_y = (profile[i] + profile[j]) / 2
        ax1.annotate(f'slope={slope:.1f}', (mid_x, mid_y - 0.3),
                     fontsize=9, ha='center', color='darkred')

    ax1.set_xlabel('Index i', fontsize=12)
    ax1.set_ylabel('v(aᵢ)', fontsize=12)
    ax1.set_title('Newton Polygon', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(xs)

    # --- Right panel: Tropical evaluation ---
    ax2 = axes[1]
    t_range = np.linspace(-3, 5, 500)
    trop_vals = [tropical_eval(profile, t) for t in t_range]

    ax2.plot(t_range, trop_vals, 'b-', linewidth=2.5, label='T_f(t)')

    # Plot individual tropical terms (dashed)
    colors = plt.cm.Set2(np.linspace(0, 1, n))
    for i in range(n):
        term_vals = [profile[i] + i * t for t in t_range]
        ax2.plot(t_range, term_vals, '--', color=colors[i], alpha=0.5,
                 linewidth=1, label=f'v(a_{i}) + {i}t')

    # Mark breakpoints
    for k in range(len(hull) - 1):
        i, j = hull[k], hull[k + 1]
        t_break = (profile[i] - profile[j]) / (j - i)
        y_break = tropical_eval(profile, t_break)
        ax2.plot(t_break, y_break, 'ro', markersize=8, zorder=5)
        ax2.annotate(f't={t_break:.2f}', (t_break, y_break - 0.5),
                     fontsize=8, ha='center', color='red')

    ax2.set_xlabel('t = v(a)', fontsize=12)
    ax2.set_ylabel('T_f(t)', fontsize=12)
    ax2.set_title('Tropical Evaluation (Lower Envelope)', fontsize=14)
    ax2.legend(fontsize=8, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-5, 15)

    plt.tight_layout()
    plt.savefig('newton_tropical_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved: newton_tropical_bridge.png")


if __name__ == "__main__":
    main()
