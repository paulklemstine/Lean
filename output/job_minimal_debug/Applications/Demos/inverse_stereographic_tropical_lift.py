#!/usr/bin/env python3
"""
Tropical Stereographic Projection — Interactive Demo

Demonstrates the key concepts:
1. Tropical Möbius transformation evaluation
2. Piecewise-linear structure with breakpoints
3. Stereographic projection properties
4. Tropical matrix multiplication and composition
"""

import numpy as np


def tropical_mobius_eval(a, b, c, d, t):
    """Evaluate the tropical Möbius transformation φ(t) = max(a+t, b) - max(c+t, d)."""
    return np.maximum(a + t, b) - np.maximum(c + t, d)


def tropical_mat_mul(M1, M2):
    """Tropical (max-plus) 2x2 matrix multiplication."""
    a1, b1, c1, d1 = M1
    a2, b2, c2, d2 = M2
    return (
        max(a1 + a2, b1 + c2),
        max(a1 + b2, b1 + d2),
        max(c1 + a2, d1 + c2),
        max(c1 + b2, d1 + d2),
    )


def trop_det(a, b, c, d):
    """Tropical determinant: max(a+d, b+c)."""
    return max(a + d, b + c)


def demo_piecewise_linear():
    """Demonstrate the piecewise-linear structure of tropical Möbius transformations."""
    print("=" * 60)
    print("DEMO 1: Piecewise-Linear Structure")
    print("=" * 60)

    # Example: M = [[2, 1], [0, 3]] → φ(t) = max(2+t, 1) - max(t, 3)
    a, b, c, d = 2.0, 1.0, 0.0, 3.0
    left_break = min(b - a, d - c)  # min(-1, 3) = -1
    right_break = max(b - a, d - c)  # max(-1, 3) = 3

    print(f"Matrix: [[{a}, {b}], [{c}, {d}]]")
    print(f"Left breakpoint:  {left_break}")
    print(f"Right breakpoint: {right_break}")
    print(f"Tropical width:   {right_break - left_break}")
    print(f"Asymptotic left (b-d):  {b - d}")
    print(f"Asymptotic right (a-c): {a - c}")
    print()

    ts = np.linspace(-5, 7, 25)
    print(f"{'t':>6} | {'φ(t)':>8} | Region")
    print("-" * 40)
    for t in ts:
        val = tropical_mobius_eval(a, b, c, d, t)
        if t <= left_break:
            region = "constant (b-d)"
        elif t >= right_break:
            region = "constant (a-c)"
        else:
            region = "active (slope ±1)"
        print(f"{t:6.2f} | {val:8.4f} | {region}")
    print()


def demo_stereographic():
    """Demonstrate tropical stereographic projection."""
    print("=" * 60)
    print("DEMO 2: Tropical Stereographic Projection")
    print("=" * 60)

    for p in [3.0, -2.0, 5.0]:
        print(f"\nPole p = {p}")
        print(f"  Matrix: [[0, 0], [0, {p}]]")
        print(f"  Tropical determinant: max({p}, 0) = {max(p, 0)}")
        print(f"  Tropical width: |{p}| = {abs(p)}")
        print(f"  Non-degenerate: {p != 0}")

        ts = np.linspace(-abs(p) - 2, abs(p) + 2, 15)
        print(f"  {'t':>6} | {'φ_p(t)':>8}")
        print(f"  {'-' * 20}")
        for t in ts:
            val = tropical_mobius_eval(0, 0, 0, p, t)
            print(f"  {t:6.2f} | {val:8.4f}")
    print()


def demo_composition():
    """Demonstrate tropical matrix multiplication and composition."""
    print("=" * 60)
    print("DEMO 3: Tropical Matrix Composition")
    print("=" * 60)

    M = (1.0, 2.0, 0.0, 3.0)
    N = (2.0, 0.0, 1.0, 1.0)
    MN = tropical_mat_mul(M, N)

    print(f"M  = {M}")
    print(f"N  = {N}")
    print(f"MN = {MN}")
    print()
    print(f"det(M)  = {trop_det(*M)}")
    print(f"det(N)  = {trop_det(*N)}")
    print(f"det(MN) = {trop_det(*MN)}")
    print(f"det(M) + det(N) = {trop_det(*M) + trop_det(*N)}")
    print(f"Super-multiplicativity: {trop_det(*MN)} >= {trop_det(*M) + trop_det(*N)}: "
          f"{trop_det(*MN) >= trop_det(*M) + trop_det(*N)}")
    print()

    # Verify representation theorem: actHom(MN, p) = actHom(M, actHom(N, p))
    print("Representation theorem verification:")
    for x, y in [(1.0, 0.0), (0.0, 1.0), (2.0, -1.0), (-3.0, 4.0)]:
        # actHom N (x, y)
        nx = max(N[0] + x, N[1] + y)
        ny = max(N[2] + x, N[3] + y)
        # actHom M (nx, ny)
        mx = max(M[0] + nx, M[1] + ny)
        my = max(M[2] + nx, M[3] + ny)
        # actHom MN (x, y)
        mnx = max(MN[0] + x, MN[1] + y)
        mny = max(MN[2] + x, MN[3] + y)
        match = abs(mx - mnx) < 1e-10 and abs(my - mny) < 1e-10
        print(f"  p=({x},{y}): M(N(p))=({mx:.2f},{my:.2f}), "
              f"MN(p)=({mnx:.2f},{mny:.2f}), match={match}")
    print()


def demo_active_interval():
    """Demonstrate injectivity on the active interval."""
    print("=" * 60)
    print("DEMO 4: Active Interval Injectivity")
    print("=" * 60)

    a, b, c, d = 1.0, 0.0, 0.0, 2.0
    print(f"Matrix: [[{a}, {b}], [{c}, {d}]]")
    print(f"a + d = {a + d}, b + c = {b + c}")
    print(f"Non-degenerate (a+d > b+c): {a + d > b + c}")
    print(f"Active interval: [{b - a}, {d - c}] = [{b-a}, {d-c}]")
    print(f"On active interval, φ(t) = a + t - d = {a} + t - {d} = t - {d - a}")
    print()

    ts = np.linspace(b - a, d - c, 10)
    vals = [tropical_mobius_eval(a, b, c, d, t) for t in ts]
    print("Injectivity check (all values distinct):")
    for t, v in zip(ts, vals):
        print(f"  φ({t:.3f}) = {v:.6f}")
    print(f"  All distinct: {len(set(round(v, 10) for v in vals)) == len(vals)}")
    print()


if __name__ == "__main__":
    demo_piecewise_linear()
    demo_stereographic()
    demo_composition()
    demo_active_interval()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Tropical Möbius Transformation Landscape

Generates a plot showing the piecewise-linear structure of tropical
Möbius transformations with breakpoints, active intervals, and bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_mobius_eval(a, b, c, d, t):
    return np.maximum(a + t, b) - np.maximum(c + t, d)


def plot_tropical_mobius_landscape():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Basic structure with breakpoints
    ax = axes[0, 0]
    a, b, c, d = 2.0, 1.0, 0.0, 3.0
    ts = np.linspace(-5, 7, 500)
    vals = tropical_mobius_eval(a, b, c, d, ts)

    left_break = min(b - a, d - c)
    right_break = max(b - a, d - c)

    ax.plot(ts, vals, 'b-', linewidth=2, label=r'$\varphi(t) = \max(2+t,1) - \max(t,3)$')
    ax.axhline(y=a - c, color='r', linestyle='--', alpha=0.5, label=f'a−c = {a-c}')
    ax.axhline(y=b - d, color='g', linestyle='--', alpha=0.5, label=f'b−d = {b-d}')
    ax.axvline(x=left_break, color='orange', linestyle=':', alpha=0.7, label=f'left break = {left_break}')
    ax.axvline(x=right_break, color='purple', linestyle=':', alpha=0.7, label=f'right break = {right_break}')
    ax.axvspan(left_break, right_break, alpha=0.1, color='yellow', label='Active interval')
    ax.set_xlabel('t')
    ax.set_ylabel('φ(t)')
    ax.set_title('Tropical Möbius: Piecewise-Linear Structure')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Stereographic projections for different poles
    ax = axes[0, 1]
    for p in [1.0, 2.0, 3.0, 5.0]:
        vals = tropical_mobius_eval(0, 0, 0, p, ts)
        ax.plot(ts, vals, linewidth=2, label=f'p = {p}')
    ax.set_xlabel('t')
    ax.set_ylabel('φ_p(t)')
    ax.set_title('Tropical Stereographic Projection (varying pole)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Boundedness theorem visualization
    ax = axes[1, 0]
    params = [
        (1, 3, 0, 1, 'red'),
        (2, 0, 1, 2, 'blue'),
        (0, 4, 2, 0, 'green'),
    ]
    for a, b, c, d, color in params:
        vals = tropical_mobius_eval(a, b, c, d, ts)
        lo = min(a - c, b - d)
        hi = max(a - c, b - d)
        ax.plot(ts, vals, color=color, linewidth=2,
                label=f'({a},{b},{c},{d}): [{lo:.0f},{hi:.0f}]')
        ax.axhspan(lo, hi, alpha=0.05, color=color)
    ax.set_xlabel('t')
    ax.set_ylabel('φ(t)')
    ax.set_title('Boundedness Theorem: eval ∈ [min, max]')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 4: Tropical width vs pole parameter
    ax = axes[1, 1]
    ps = np.linspace(-5, 5, 100)
    widths = np.abs(ps)
    dets = np.maximum(ps, 0)
    ax.plot(ps, widths, 'b-', linewidth=2, label='Tropical width |p|')
    ax.plot(ps, dets, 'r--', linewidth=2, label='Tropical det max(p,0)')
    ax.set_xlabel('Pole parameter p')
    ax.set_ylabel('Value')
    ax.set_title('Stereographic Invariants vs. Pole')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_mobius_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_mobius_landscape.png")


if __name__ == "__main__":
    plot_tropical_mobius_landscape()
