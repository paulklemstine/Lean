#!/usr/bin/env python3
"""
Demo: F₁-Tropical Duality — The Field with One Element Meets Tropical Geometry

Demonstrates the key concepts from the formalization:
1. TropicalF1Algebra operations on WithTop ℕ
2. The F₁-order and its agreement with standard order
3. Tropical polynomial evaluation and corner loci
4. F₁-Betti numbers and Euler characteristics
5. Polytope-vertex correspondence
"""

import math
from typing import Optional

# Infinity sentinel
INF = float('inf')


def tropical_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == INF or b == INF:
        return INF
    return a + b


def f1_le(a: float, b: float) -> bool:
    """F₁-order: a ≤ b iff min(a, b) = a."""
    return tropical_add(a, b) == a


def tropical_poly_eval(coeffs: list[float], x: float) -> float:
    """Evaluate tropical polynomial: inf_i (c_i + i * x)."""
    result = INF
    for i, c in enumerate(coeffs):
        term = tropical_mul(c, i * x if x != INF else (INF if i > 0 else 0))
        if c == INF:
            term = INF
        else:
            term = c + i * x if x != INF else (c if i == 0 else INF)
        result = tropical_add(result, term)
    return result


def find_corner_locus(coeffs: list[float], x_range: tuple[float, float],
                      num_points: int = 10000) -> list[float]:
    """Find approximate corner points of a tropical polynomial."""
    corners = []
    x_min, x_max = x_range
    dx = (x_max - x_min) / num_points

    for k in range(num_points):
        x = x_min + k * dx
        terms = [c + i * x for i, c in enumerate(coeffs) if c != INF]
        if len(terms) < 2:
            continue
        terms.sort()
        if abs(terms[0] - terms[1]) < dx * 2:
            corners.append(x)

    # Cluster nearby corners
    if not corners:
        return []
    clustered = [corners[0]]
    for c in corners[1:]:
        if c - clustered[-1] > dx * 10:
            clustered.append(c)
    return clustered


def f1_betti_number(n: int, k: int) -> int:
    """F₁-Betti number β_k for complete simplicial complex on n+1 vertices.
    Equals C(n+1, k+1)."""
    return math.comb(n + 1, k + 1)


def tropical_euler_char(n: int, d: int) -> int:
    """Tropical Euler characteristic: Σ (-1)^k β_k."""
    return sum((-1)**k * f1_betti_number(n, k) for k in range(d + 1))


def main():
    print("=" * 60)
    print("F₁-Tropical Duality Demo")
    print("=" * 60)

    # 1. Basic tropical operations
    print("\n--- 1. Tropical Arithmetic ---")
    print(f"3 ⊕ 5 = min(3,5) = {tropical_add(3, 5)}")
    print(f"3 ⊗ 5 = 3+5 = {tropical_mul(3, 5)}")
    print(f"∞ ⊗ 3 = ∞ (absorption) = {tropical_mul(INF, 3)}")
    print(f"0 ⊗ 7 = 0+7 = {tropical_mul(0, 7)} (0 is multiplicative identity)")

    # 2. Idempotency
    print("\n--- 2. Idempotency (Characteristic 1) ---")
    for a in [0, 3, 7, 42]:
        print(f"  {a} ⊕ {a} = min({a},{a}) = {tropical_add(a, a)}  ✓ (= {a})")

    # 3. Distributivity
    print("\n--- 3. Distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c) ---")
    for a, b, c in [(2, 3, 5), (0, 1, 4), (10, 2, 7)]:
        lhs = tropical_mul(a, tropical_add(b, c))
        rhs = tropical_add(tropical_mul(a, b), tropical_mul(a, c))
        print(f"  {a} ⊗ ({b} ⊕ {c}) = {lhs}, ({a}⊗{b}) ⊕ ({a}⊗{c}) = {rhs}  {'✓' if lhs == rhs else '✗'}")

    # 4. F₁-order
    print("\n--- 4. F₁-Order: a ≤ b ⟺ min(a,b) = a ---")
    for a, b in [(2, 5), (5, 2), (3, 3), (0, INF)]:
        print(f"  {a} ≤ {b}: {f1_le(a, b)}  (min({a},{b}) = {tropical_add(a, b)})")

    # 5. Tropical polynomial
    print("\n--- 5. Tropical Polynomial: f(x) = min(6, 3+x, 2x) ---")
    coeffs = [6, 3, 0]
    for x in [0, 1, 2, 3, 4, 5]:
        val = tropical_poly_eval(coeffs, x)
        terms = [f"{c}+{i}·{x}={c+i*x}" for i, c in enumerate(coeffs)]
        print(f"  f({x}) = min({', '.join(terms)}) = {val}")

    corners = find_corner_locus(coeffs, (0, 10))
    print(f"  Corner points ≈ {[round(c, 2) for c in corners]}")
    print(f"  Expected: degree 2 polynomial has ≤ 2 corners")

    # 6. F₁-Betti numbers
    print("\n--- 6. F₁-Betti Numbers (Complete Simplicial Complex) ---")
    for n in range(1, 5):
        bettis = [f1_betti_number(n, k) for k in range(n + 1)]
        euler = tropical_euler_char(n, n)
        print(f"  n={n}: β = {bettis}, χ_{{F₁}} = {euler}")
        print(f"         β_k = C({n+1}, k+1): {[math.comb(n+1, k+1) for k in range(n+1)]}")

    # 7. Polytope correspondence
    print("\n--- 7. Polytope-Vertex Correspondence ---")
    polytopes = [
        ("Segment", 1, 2),
        ("Triangle", 2, 3),
        ("Square", 2, 4),
        ("Tetrahedron", 3, 4),
        ("Cube", 3, 8),
    ]
    for name, dim, verts in polytopes:
        print(f"  {name}: dim={dim}, #vertices={verts}, "
              f"#F₁-points={verts}, χ={verts}")

    # 8. Base change
    print("\n--- 8. Base Change F₁ → ℤ ---")
    for r in range(1, 5):
        print(f"  Free F₁-module of rank {r} → Free ℤ-module of rank {r}")
        print(f"    F₁^{r} ⊗_{{F₁}} ℤ = ℤ^{r} = ℤ[x₁,...,x_{r}] (polynomial ring)")

    # 9. Zeta function test (conjecture verification)
    print("\n--- 9. F₁-Zeta Function Test ---")
    print("  Unit square P: f₀=4, f₁=4, f₂=1")
    print("  Toric variety: ℙ¹ × ℙ¹")
    for q in [2, 3, 5, 7]:
        f_poly = 4 * 1 + 4 * (q - 1) + 1 * (q - 1)**2
        actual = (q + 1)**2
        print(f"  q={q}: Σ f_k(q-1)^k = {f_poly}, |X(F_q)| = {actual}  "
              f"{'✓' if f_poly == actual else '✗'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: F₁-Betti Numbers and Euler Characteristics"""

import matplotlib.pyplot as plt
import numpy as np
import math


def f1_betti(n, k):
    """F₁-Betti number β_k = C(n+1, k+1)."""
    return math.comb(n + 1, k + 1)


def tropical_euler(n, d):
    """Tropical Euler characteristic."""
    return sum((-1)**k * f1_betti(n, k) for k in range(d + 1))


def plot_betti_numbers():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: F₁-Betti numbers as Pascal's triangle
    max_n = 7
    for n in range(max_n):
        bettis = [f1_betti(n, k) for k in range(n + 1)]
        ax1.bar([k + n * 0.05 for k in range(n + 1)],
                bettis, width=0.8,
                alpha=0.7, label=f'n={n}' if n < 5 else None,
                color=plt.cm.viridis(n / max_n))
        for k, b in enumerate(bettis):
            ax1.text(k + n * 0.05, b + 0.3, str(b),
                     ha='center', fontsize=7)

    ax1.set_xlabel('Dimension k', fontsize=12)
    ax1.set_ylabel('β_k^{F₁}', fontsize=12)
    ax1.set_title('F₁-Betti Numbers = Binomial Coefficients',
                   fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3, axis='y')

    # Right: Tropical Euler characteristic
    ns = range(1, 10)
    eulers_full = [tropical_euler(n, n) for n in ns]

    # Also plot the alternating pattern
    ax2.bar(list(ns), eulers_full, color=['#e74c3c' if e < 0 else '#2ecc71'
                                           for e in eulers_full],
            alpha=0.8)
    ax2.axhline(y=0, color='k', linewidth=0.5)

    for n, e in zip(ns, eulers_full):
        ax2.text(n, e + (0.5 if e >= 0 else -1.5), str(e),
                 ha='center', fontsize=10, fontweight='bold')

    ax2.set_xlabel('n (simplicial complex on n+1 vertices)', fontsize=12)
    ax2.set_ylabel('χ_{F₁}', fontsize=12)
    ax2.set_title('Tropical Euler Characteristic\nχ_{F₁} = Σ(-1)^k β_k',
                   fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.suptitle('F₁-Topology: Betti Numbers and Euler Characteristics',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('f1_betti_numbers.png', dpi=150, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    plot_betti_numbers()


#!/usr/bin/env python3
"""Visualization: Tropical Polynomial and Corner Locus"""

import matplotlib.pyplot as plt
import numpy as np


def tropical_poly_eval(coeffs, x):
    """Evaluate tropical polynomial: min_i(c_i + i*x)."""
    terms = np.full_like(x, np.inf)
    result = np.full_like(x, np.inf)
    for i, c in enumerate(coeffs):
        if c < np.inf:
            term = c + i * x
            result = np.minimum(result, term)
    return result


def plot_tropical_polynomial():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    examples = [
        ([6, 3, 0], "min(6, 3+x, 2x)"),
        ([10, 5, 1, 0], "min(10, 5+x, 1+2x, 3x)"),
        ([4, 0, 3], "min(4, x, 3+2x)"),
    ]

    for ax, (coeffs, title) in zip(axes, examples):
        x = np.linspace(-2, 8, 1000)

        # Plot individual terms
        colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
        for i, c in enumerate(coeffs):
            term = c + i * x
            ax.plot(x, term, '--', color=colors[i % len(colors)],
                    alpha=0.4, label=f'c_{i}+{i}x = {c}+{i}x')

        # Plot the tropical polynomial (lower envelope)
        y = tropical_poly_eval(coeffs, x)
        ax.plot(x, y, 'k-', linewidth=2.5, label='f(x) = min(terms)')

        # Find and mark corners
        for i in range(len(coeffs)):
            for j in range(i + 1, len(coeffs)):
                if j - i != 0:
                    cx = (coeffs[i] - coeffs[j]) / (j - i)
                    cy = coeffs[i] + i * cx
                    # Verify it's on the lower envelope
                    actual = min(c + k * cx for k, c in enumerate(coeffs))
                    if abs(cy - actual) < 0.01 and -2 <= cx <= 8:
                        ax.plot(cx, cy, 'ro', markersize=10, zorder=5)
                        ax.annotate(f'({cx:.1f}, {cy:.1f})',
                                    (cx, cy), textcoords="offset points",
                                    xytext=(10, 10), fontsize=9)

        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_xlabel('x')
        ax.set_ylabel('f(x)')
        ax.legend(fontsize=8)
        ax.set_ylim(-2, 15)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical Polynomials and Corner Loci (F₁-Varieties)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_polynomials.png', dpi=150, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    plot_tropical_polynomial()
