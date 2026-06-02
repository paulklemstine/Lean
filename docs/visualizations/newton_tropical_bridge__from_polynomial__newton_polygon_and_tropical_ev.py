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
