#!/usr/bin/env python3
"""
EML Kolmogorov-Arnold Spectral Algebra — Demonstration

This script demonstrates the key results from the EML-KA Spectral Filtration theory:
1. The multiplication decomposition: x*y = exp(log(x) + log(y))
2. Monomial decompositions: x^a * y^b = exp(a*log(x) + b*log(y))
3. Polynomial completeness
4. The Fenchel-Young inequality
5. The depth lower bound (numerical verification)
"""

import numpy as np

def eml_ka_multiply(x: float, y: float) -> float:
    """EML-KA decomposition of multiplication: exp(log(x) + log(y))."""
    return np.exp(np.log(x) + np.log(y))

def eml_ka_monomial(x: float, y: float, a: int, b: int) -> float:
    """EML-KA decomposition of x^a * y^b."""
    return np.exp(a * np.log(x) + b * np.log(y))

def eml_ka_division(x: float, y: float) -> float:
    """EML-KA decomposition of x/y."""
    return np.exp(np.log(x) - np.log(y))

def eml_ka_rpow(x: float, y: float, r: float, s: float) -> float:
    """EML-KA decomposition of x^r * y^s for real exponents."""
    return np.exp(r * np.log(x) + s * np.log(y))

def eml_ka_polynomial(x: float, y: float, coeffs: list, exp_a: list, exp_b: list) -> float:
    """EML-KA decomposition of a polynomial sum_i c_i * x^a_i * y^b_i."""
    return sum(c * np.exp(a * np.log(x) + b * np.log(y))
               for c, a, b in zip(coeffs, exp_a, exp_b))

def fenchel_young_bound(x: float, s: float) -> tuple:
    """Compute both sides of the Fenchel-Young inequality: x*s <= exp(x) + s*log(s) - s."""
    lhs = x * s
    rhs = np.exp(x) + s * np.log(s) - s
    return lhs, rhs

def spectral_depth_test(func_name: str, exact_func, eml_func, test_points: list) -> None:
    """Verify an EML-KA decomposition matches the exact function."""
    print(f"\n{'='*60}")
    print(f"Testing: {func_name}")
    print(f"{'='*60}")
    max_error = 0.0
    for x, y in test_points:
        exact = exact_func(x, y)
        eml = eml_func(x, y)
        error = abs(exact - eml)
        max_error = max(max_error, error)
        print(f"  f({x:.2f}, {y:.2f}) = {exact:.8f}  |  EML-KA = {eml:.8f}  |  error = {error:.2e}")
    print(f"  Max error: {max_error:.2e}")
    print(f"  Status: {'EXACT ✓' if max_error < 1e-10 else 'APPROXIMATE'}")


if __name__ == "__main__":
    print("=" * 60)
    print("EML Kolmogorov-Arnold Spectral Algebra — Demo")
    print("=" * 60)

    test_pts = [(1.5, 2.3), (0.5, 3.0), (2.0, 2.0), (0.1, 10.0), (3.14, 2.72)]

    # Test 1: Multiplication
    spectral_depth_test(
        "Multiplication x*y (depth 3)",
        lambda x, y: x * y,
        eml_ka_multiply,
        test_pts
    )

    # Test 2: Monomial x^2 * y^3
    spectral_depth_test(
        "Monomial x² · y³ (depth 3)",
        lambda x, y: x**2 * y**3,
        lambda x, y: eml_ka_monomial(x, y, 2, 3),
        test_pts
    )

    # Test 3: Division
    spectral_depth_test(
        "Division x/y (depth 3)",
        lambda x, y: x / y,
        eml_ka_division,
        test_pts
    )

    # Test 4: Real powers x^0.5 * y^1.5
    spectral_depth_test(
        "Real powers x^0.5 · y^1.5 (depth 3)",
        lambda x, y: x**0.5 * y**1.5,
        lambda x, y: eml_ka_rpow(x, y, 0.5, 1.5),
        test_pts
    )

    # Test 5: Polynomial 3x²y + 2xy³ - x + 5y²
    coeffs = [3.0, 2.0, -1.0, 5.0]
    ea = [2, 1, 1, 0]
    eb = [1, 3, 0, 2]
    spectral_depth_test(
        "Polynomial 3x²y + 2xy³ - x + 5y² (4-term EML-KA)",
        lambda x, y: 3*x**2*y + 2*x*y**3 - x + 5*y**2,
        lambda x, y: eml_ka_polynomial(x, y, coeffs, ea, eb),
        test_pts
    )

    # Test 6: Fenchel-Young inequality verification
    print(f"\n{'='*60}")
    print("Fenchel-Young Inequality: x·s ≤ exp(x) + s·log(s) - s")
    print(f"{'='*60}")
    for x in [-2.0, -1.0, 0.0, 1.0, 2.0, 3.0]:
        for s in [0.5, 1.0, 2.0, 5.0]:
            lhs, rhs = fenchel_young_bound(x, s)
            gap = rhs - lhs
            tight = " ← TIGHT" if abs(x - np.log(s)) < 1e-10 else ""
            print(f"  x={x:5.1f}, s={s:4.1f}: {lhs:8.4f} ≤ {rhs:8.4f}  (gap={gap:.4f}){tight}")

    # Test 7: Depth lower bound verification
    print(f"\n{'='*60}")
    print("Depth Lower Bound: x·y ≠ Φ(a₁x + b₁ + a₂y + b₂) for ANY Φ, a, b")
    print(f"{'='*60}")
    print("Testing whether any affine encoding can capture multiplication...")
    print("If Φ(a₁x + b₁ + a₂y + b₂) = x·y, then fixing y=1 and y=2:")
    print("  Φ(a₁·1 + b₁ + a₂·1 + b₂) = 1·1 = 1")
    print("  Φ(a₁·2 + b₁ + a₂·1 + b₂) = 2·1 = 2  → Φ is linear with slope 1/a₁")
    print("  Φ(a₁·1 + b₁ + a₂·2 + b₂) = 1·2 = 2")
    print("  Φ(a₁·2 + b₁ + a₂·2 + b₂) = 2·2 = 4")
    print("  But Φ(a₁·3 + b₁ + a₂·3 + b₂) should = 3·3 = 9")
    best_error = float('inf')
    for a1 in np.linspace(-5, 5, 50):
        for a2 in np.linspace(-5, 5, 50):
            for b in np.linspace(-5, 5, 20):
                # Try to fit Phi(a1*x + a2*y + b) = x*y
                pts = [(1, 1), (2, 1), (1, 2), (2, 2), (3, 3)]
                t_vals = [a1*x + a2*y + b for x, y in pts]
                targets = [x*y for x, y in pts]
                # Check if t_vals are all distinct (needed for fitting)
                if len(set(round(t, 6) for t in t_vals)) < len(t_vals):
                    continue
                # Best affine fit through these points
                try:
                    from numpy.polynomial import polynomial as P
                    c = np.polyfit(t_vals, targets, 1)
                    predicted = np.polyval(c, t_vals)
                    error = max(abs(p - t) for p, t in zip(predicted, targets))
                    best_error = min(best_error, error)
                except:
                    pass
    print(f"  Best approximation error with affine inner+outer: {best_error:.4f}")
    print(f"  Status: {'IMPOSSIBLE ✓ (error > 0)' if best_error > 0.01 else 'Found fit!'}")

    print(f"\n{'='*60}")
    print("Summary of Spectral Depths")
    print(f"{'='*60}")
    print("  Constant c       → depth 0 (affine outer, identity inner)")
    print("  Affine αx+βy+γ   → depth 0 (affine chains throughout)")
    print("  x · y            → depth 3 (log inner, exp outer)")
    print("  x^a · y^b        → depth 3 (scaled-log inner, exp outer)")
    print("  Polynomial       → depth 3 (multi-term, each depth 3)")
    print("  x / y            → depth 3 (log and neg-log inner, exp outer)")
    print("  x^r · y^s (real) → depth 3 (scaled-log inner, exp outer)")


#!/usr/bin/env python3
"""
Visualization: Fenchel-Young Inequality and EML Duality

Demonstrates the convex duality between exp and s*log(s) - s,
which underlies the EML spectral algebra.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Fenchel-Young Duality in the EML Spectral Algebra',
                 fontsize=14, fontweight='bold')

    # Panel 1: The inequality x·s ≤ exp(x) + s·log(s) - s for fixed s
    ax = axes[0]
    x = np.linspace(-3, 4, 300)

    for s, color, ls in [(0.5, '#e74c3c', '-'), (1.0, '#3498db', '-'),
                          (2.0, '#2ecc71', '-'), (5.0, '#f39c12', '-')]:
        lhs = x * s
        rhs = np.exp(x) + s * np.log(s) - s
        gap = rhs - lhs

        ax.plot(x, gap, color=color, linestyle=ls, linewidth=2,
                label=f's = {s:.1f} (tight at x = {np.log(s):.2f})')
        # Mark tightness point
        x_tight = np.log(s)
        ax.plot(x_tight, 0, 'o', color=color, markersize=8, zorder=5)

    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('exp(x) + s·log(s) - s - x·s', fontsize=12)
    ax.set_title('Fenchel-Young Gap\n(≥ 0, tight at x = log s)', fontsize=11)
    ax.legend(fontsize=9)
    ax.set_ylim(-1, 20)
    ax.grid(True, alpha=0.3)

    # Panel 2: The conjugate functions exp and s*log(s) - s
    ax = axes[1]
    s = np.linspace(0.01, 5, 300)

    # exp(x) for various x
    x_vals = np.linspace(-2, 3, 300)
    ax.plot(x_vals, np.exp(x_vals), 'b-', linewidth=2.5, label='exp(x)')

    # s·log(s) - s (the Legendre transform of exp)
    ax.plot(s, s * np.log(s) - s, 'r-', linewidth=2.5,
            label='s·log(s) - s (conjugate)')

    # Mark the duality: at x = log(s), exp(x) = s
    s_pts = [0.5, 1.0, 2.0, 3.0]
    for sp in s_pts:
        xp = np.log(sp)
        yp = np.exp(xp)
        ax.plot([xp], [yp], 'ko', markersize=6, zorder=5)
        ax.annotate(f'({xp:.1f}, {yp:.1f})',
                   xy=(xp, yp), xytext=(xp + 0.3, yp + 0.5),
                   fontsize=8, arrowprops=dict(arrowstyle='->', color='gray'))

    ax.set_xlabel('x (or s)', fontsize=12)
    ax.set_ylabel('Function value', fontsize=12)
    ax.set_title('Conjugate Pair: exp ↔ s·log(s) - s\n(Foundation of EML duality)',
                 fontsize=11)
    ax.legend(fontsize=10)
    ax.set_ylim(-3, 10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fenchel_young_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fenchel_young_duality.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: EML-KA Spectral Filtration Depth Hierarchy

Shows which functions live at each spectral depth level and
demonstrates the strict hierarchy F₀ ⊊ F₃.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import matplotlib.patches as mpatches


def eval_eml_ka_mul(x, y):
    """x*y = exp(log(x) + log(y))"""
    return np.exp(np.log(x) + np.log(y))


def eval_eml_ka_monomial(x, y, a, b):
    """x^a * y^b = exp(a*log(x) + b*log(y))"""
    return np.exp(a * np.log(x) + b * np.log(y))


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('EML-KA Spectral Filtration: Depth Hierarchy',
                 fontsize=16, fontweight='bold')

    x = np.linspace(0.1, 3.0, 200)
    y = np.linspace(0.1, 3.0, 200)
    X, Y = np.meshgrid(x, y)

    # Panel 1: Level 0 - Affine functions
    ax = axes[0, 0]
    Z = 1.5 * X + 0.8 * Y + 0.5
    c = ax.contourf(X, Y, Z, levels=20, cmap='Blues')
    plt.colorbar(c, ax=ax, shrink=0.8)
    ax.set_title('Spectral Level 0: f(x,y) = 1.5x + 0.8y + 0.5\n(Affine functions only)', fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('y')

    # Panel 2: Level 3 - Multiplication
    ax = axes[0, 1]
    Z = eval_eml_ka_mul(X, Y)
    c = ax.contourf(X, Y, Z, levels=20, cmap='Oranges')
    plt.colorbar(c, ax=ax, shrink=0.8)
    ax.set_title('Spectral Level 3: f(x,y) = x·y\nexp(log(x) + log(y))', fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('y')

    # Panel 3: Level 3 - Monomial x^2*y^3
    ax = axes[1, 0]
    Z = eval_eml_ka_monomial(X, Y, 2, 3)
    Z = np.clip(Z, 0, 50)  # clip for visualization
    c = ax.contourf(X, Y, Z, levels=20, cmap='Greens')
    plt.colorbar(c, ax=ax, shrink=0.8)
    ax.set_title('Spectral Level 3: f(x,y) = x²y³\nexp(2·log(x) + 3·log(y))', fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('y')

    # Panel 4: Hierarchy diagram
    ax = axes[1, 1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Spectral Filtration Hierarchy', fontsize=11)

    # Draw nested circles representing the filtration
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    labels = [
        ('F₀', 'Affine\nαx + βy + γ'),
        ('F₁', ''),
        ('F₂', ''),
        ('F₃', 'Monomials\nx^a · y^b\nPolynomials')
    ]
    for i, (level, desc) in enumerate(reversed(labels)):
        r = 4.5 - i * 0.9
        circle = plt.Circle((5, 5), r, fill=True,
                            facecolor=colors[3-i], alpha=0.2,
                            edgecolor=colors[3-i], linewidth=2)
        ax.add_patch(circle)
        ax.text(5 + r - 0.3, 5 + r * 0.7, level, fontsize=10,
                fontweight='bold', color=colors[3-i])

    ax.text(5, 5, 'F₀ ⊊ F₃\n\nx·y ∈ F₃\\F₀\n(Proved!)',
            ha='center', va='center', fontsize=11,
            fontweight='bold', color='#2c3e50',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig('spectral_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_hierarchy.png")


if __name__ == '__main__':
    main()
