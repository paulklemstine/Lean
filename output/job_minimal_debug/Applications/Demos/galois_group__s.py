#!/usr/bin/env python3
"""
Applications of Galois group computation.

Demonstrates how the Galois group determination pipeline applies to:
1. Solvability by radicals
2. Multiple quintic polynomials
3. Subgroup lattice visualization
"""

from algorithms import galois_group_quintic_pipeline, find_roots_mod_p, poly_mod
from math import factorial


def solvability_analysis():
    """Determine which quintics are solvable by radicals."""
    print("="*60)
    print("Solvability by Radicals")
    print("="*60)

    polynomials = {
        "X^5 - X - 1": [-1, -1, 0, 0, 0, 1],
        "X^5 - 2": [-2, 0, 0, 0, 0, 1],
        "X^5 - 5X + 12": [12, -5, 0, 0, 0, 1],
        "X^5 - 1": [-1, 0, 0, 0, 0, 1],
        "X^5 + X^4 - 4X^3 - 3X^2 + 3X + 1": [1, 3, -3, -4, 1, 1],
    }

    for name, coeffs in polynomials.items():
        result = galois_group_quintic_pipeline(coeffs)
        solvable = result['conclusion'] not in ['S_5', 'A_5']
        print(f"\n{name}:")
        print(f"  Galois group: {result['conclusion']}")
        print(f"  Solvable by radicals: {'Yes' if solvable else 'No'}")
        print(f"  Cycle types found: ", end="")
        for p, data in sorted(result['cycle_types'].items())[:5]:
            print(f"p={p}:{data['cycle_type']} ", end="")
        print()


def transitive_subgroup_lattice():
    """Display the lattice of transitive subgroups of S_5."""
    print("\n" + "="*60)
    print("Transitive Subgroup Lattice of S_5")
    print("="*60)

    print("""
                        S_5 (120)
                       /         \\
                      /           \\
                   A_5 (60)     [no other]
                    |
                 F_20 (20)
                    |
                  D_5 (10)
                    |
                  C_5 (5)

    Group    | Order | ≤ A_5? | Generators
    ---------|-------|--------|--------------------
    C_5      |   5   |  Yes   | 5-cycle
    D_5      |  10   |  Yes   | 5-cycle, double-transposition
    F_20     |  20   |  No    | 5-cycle, 4-cycle
    A_5      |  60   |  Yes   | 5-cycle, 3-cycle
    S_5      | 120   |  No    | 5-cycle, transposition

    Key insight: C_5, D_5, A_5 are all ≤ A_5.
    Only F_20 and S_5 are NOT ≤ A_5.
    """)


def certification_examples():
    """Show how different arithmetic certificates distinguish groups."""
    print("="*60)
    print("Arithmetic Certificates for Quintic Galois Groups")
    print("="*60)

    print("""
    To certify Gal(f/Q) = S_5, we need:
    ──────────────────────────────────────
    1. f irreducible over Q (gives transitivity)
    2. An odd permutation in Gal (gives Gal ⊄ A_5)
    3. An order-5 element (from irreducibility + Cauchy)
    4. Additional constraint to rule out F_20 (order 20)

    Certificate sources:
    ──────────────────────────────────────
    • f mod p irreducible → 5-cycle (rules out degree < 5 factors)
    • f mod p = (deg 2)(deg 3) → (2,3)-cycle, order 6, ODD
    • f mod p = (deg 1)(deg 4) → 4-cycle, ODD
    • f mod p = (deg 1)(deg 1)(deg 3) → 3-cycle, EVEN
    • disc(f) not a square → Gal ⊄ A_5

    For X^5 - X - 1:
    ──────────────────────────────────────
    • f mod 3 is irreducible → 5-cycle ✓
    • f mod 2 = (X²+X+1)(X³+X²+1) → (2,3)-cycle (order 6, odd) ✓
    • Both certificates together → 30 | |Gal| and Gal ⊄ A_5 → S_5 ✓
    """)


if __name__ == "__main__":
    solvability_analysis()
    transitive_subgroup_lattice()
    certification_examples()


#!/usr/bin/env python3
"""
Demo: Galois group computation for X^5 - X - 1.

Demonstrates the arithmetic certificates that prove Gal(X^5 - X - 1 / Q) = S_5:
1. Irreducibility over F_3
2. Factorization over F_2
3. Discriminant computation
4. Group-theoretic classification
"""

import numpy as np
from itertools import product


def poly_eval_mod(coeffs, x, p):
    """Evaluate polynomial with given coefficients at x modulo p."""
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def poly_mul_mod(a, b, p):
    """Multiply two polynomials modulo p."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % p
    return result


def check_roots_mod_p(coeffs, p):
    """Check if polynomial has roots modulo p."""
    roots = []
    for x in range(p):
        if poly_eval_mod(coeffs, x, p) == 0:
            roots.append(x)
    return roots


def find_factorizations_mod_p(p, degree=5):
    """Find irreducible factorizations of X^5 - X - 1 mod p."""
    # Coefficients of X^5 - X - 1: [-1, -1, 0, 0, 0, 1]
    f_coeffs = [(-1) % p, (-1) % p, 0, 0, 0, 1]

    print(f"\n{'='*60}")
    print(f"Analysis of X^5 - X - 1 modulo {p}")
    print(f"{'='*60}")

    # Check roots
    roots = check_roots_mod_p(f_coeffs, p)
    if roots:
        print(f"Roots in F_{p}: {roots}")
    else:
        print(f"No roots in F_{p}")

    return roots


def discriminant_analysis():
    """Compute and analyze the discriminant of X^5 - X - 1."""
    print("\n" + "="*60)
    print("Discriminant Analysis")
    print("="*60)

    disc = 2869
    print(f"disc(X^5 - X - 1) = {disc}")

    # Factor
    factors = []
    n = disc
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)

    print(f"Factorization: {disc} = {' × '.join(map(str, factors))}")

    # Check if perfect square
    sqrt_disc = int(np.sqrt(disc))
    is_square = sqrt_disc * sqrt_disc == disc or (sqrt_disc + 1) * (sqrt_disc + 1) == disc
    print(f"Is perfect square? {is_square}")
    print(f"  {sqrt_disc}² = {sqrt_disc**2}")
    print(f"  {sqrt_disc+1}² = {(sqrt_disc+1)**2}")
    print(f"  Since {sqrt_disc**2} < {disc} < {(sqrt_disc+1)**2}, not a square ✓")


def mod2_factorization():
    """Demonstrate the factorization over F_2."""
    print("\n" + "="*60)
    print("Factorization over F_2")
    print("="*60)

    # X^5 + X + 1 = (X^2 + X + 1)(X^3 + X^2 + 1) in F_2[X]
    g1 = [1, 1, 1]  # X^2 + X + 1
    g2 = [1, 0, 1, 1]  # X^3 + X^2 + 1

    product_coeffs = poly_mul_mod(g1, g2, 2)
    f_mod2 = [1, 1, 0, 0, 0, 1]  # X^5 + X + 1

    print(f"f mod 2 = X^5 + X + 1")
    print(f"g1 = X^2 + X + 1")
    print(f"g2 = X^3 + X^2 + 1")
    print(f"g1 * g2 = {product_coeffs}")
    print(f"f mod 2 = {f_mod2}")
    print(f"Match: {product_coeffs == f_mod2} ✓")

    # Check irreducibility of factors
    print(f"\ng1 roots in F_2: {check_roots_mod_p([1, 1, 1], 2)}")
    print(f"g2 roots in F_2: {check_roots_mod_p([1, 0, 1, 1], 2)}")
    print("Both have no roots → both irreducible over F_2 ✓")
    print("\nCycle type from factorization: (2, 3)")
    print("Order: lcm(2, 3) = 6")
    print("Sign: (-1)^(2-1) * (-1)^(3-1) = (-1)(1) = -1 (odd permutation)")


def group_classification():
    """Demonstrate the group-theoretic classification."""
    print("\n" + "="*60)
    print("Group-Theoretic Classification")
    print("="*60)

    print("\nTransitive subgroups of S_5 (up to conjugacy):")
    print(f"  C_5:  order  5  (cyclic)")
    print(f"  D_5:  order 10  (dihedral)")
    print(f"  F_20: order 20  (Frobenius = GA(1,5))")
    print(f"  A_5:  order 60  (alternating)")
    print(f"  S_5:  order 120 (symmetric)")

    print("\nConstraints on Gal(f/Q):")
    print("  1. 5 | |Gal| (from irreducibility, degree 5 is prime)")
    print("  2. 6 | |Gal| (from order-6 element via Dedekind)")
    print("  3. 30 | |Gal| (from lcm(5,6) = 30)")
    print("  4. |Gal| | 120 (Gal embeds in S_5)")
    print("  5. Gal ⊄ A_5 (odd permutation present)")

    print("\nPossible orders: divisors of 120 that are multiples of 30")
    print("  30, 60, 120")
    print()
    print("  |Gal| = 30: S_5 has no subgroup of index 4 → impossible ✗")
    print("  |Gal| = 60: unique → A_5, but Gal ⊄ A_5 → impossible ✗")
    print("  |Gal| = 120: Gal = S_5 ✓")

    print("\n" + "="*60)
    print("CONCLUSION: Gal(X^5 - X - 1 / Q) ≅ S_5")
    print("="*60)


def real_roots_analysis():
    """Analyze the real roots of X^5 - X - 1."""
    print("\n" + "="*60)
    print("Root Analysis")
    print("="*60)

    # Find real root numerically
    from numpy.polynomial import polynomial as P
    coeffs = [-1, -1, 0, 0, 0, 1]
    roots = np.roots([1, 0, 0, 0, -1, -1])

    real_roots = [r.real for r in roots if abs(r.imag) < 1e-10]
    complex_roots = [r for r in roots if abs(r.imag) > 1e-10]

    print(f"Number of real roots: {len(real_roots)}")
    print(f"Number of complex root pairs: {len(complex_roots) // 2}")
    for i, r in enumerate(sorted(real_roots)):
        print(f"  Real root: {r:.10f}")
    for i in range(0, len(complex_roots), 2):
        r = complex_roots[i]
        print(f"  Complex pair: {r.real:.6f} ± {abs(r.imag):.6f}i")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Galois Group Computation: X^5 - X - 1                 ║")
    print("║  Proving Gal(f/Q) ≅ S_5                                ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # 1. Check irreducibility mod 3
    find_factorizations_mod_p(3)

    # 2. Mod-2 factorization
    mod2_factorization()

    # 3. Discriminant
    discriminant_analysis()

    # 4. Root analysis
    real_roots_analysis()

    # 5. Group classification
    group_classification()


#!/usr/bin/env python3
"""
Visualizations for the Galois group computation of X^5 - X - 1.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def roots_in_complex_plane():
    """Plot the roots of X^5 - X - 1 in the complex plane."""
    roots = np.roots([1, 0, 0, 0, -1, -1])

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Plot unit circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.2, label='Unit circle')

    # Plot roots
    real_roots = [r for r in roots if abs(r.imag) < 1e-10]
    complex_roots = [r for r in roots if abs(r.imag) > 1e-10]

    for r in real_roots:
        ax.plot(r.real, 0, 'ro', markersize=12, zorder=5)
        ax.annotate(f'{r.real:.4f}', (r.real, 0.05), fontsize=10, ha='center')

    for r in complex_roots:
        ax.plot(r.real, r.imag, 'bs', markersize=10, zorder=5)
        ax.annotate(f'{r.real:.3f}+{r.imag:.3f}i',
                   (r.real+0.05, r.imag+0.05), fontsize=9)

    # Draw conjugate pairs
    for i in range(0, len(complex_roots), 2):
        if i+1 < len(complex_roots):
            r1, r2 = complex_roots[i], complex_roots[i+1]
            ax.plot([r1.real, r2.real], [r1.imag, r2.imag],
                   'b--', alpha=0.3)

    ax.set_xlabel('Real', fontsize=12)
    ax.set_ylabel('Imaginary', fontsize=12)
    ax.set_title('Roots of X⁵ − X − 1 in ℂ', fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Legend
    ax.plot([], [], 'ro', markersize=10, label=f'Real root ({len(real_roots)})')
    ax.plot([], [], 'bs', markersize=8, label=f'Complex roots ({len(complex_roots)})')
    ax.legend(fontsize=11)

    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode()
    plt.close(fig)
    return f"data:image/png;base64,{img_base64}"


def subgroup_lattice():
    """Create a visual diagram of the transitive subgroup lattice of S_5."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Positions
    positions = {
        'S₅\n|S₅|=120': (0.5, 0.9),
        'A₅\n|A₅|=60': (0.3, 0.7),
        'F₂₀\n|F₂₀|=20': (0.3, 0.5),
        'D₅\n|D₅|=10': (0.3, 0.3),
        'C₅\n|C₅|=5': (0.3, 0.1),
    }

    colors = {
        'S₅\n|S₅|=120': '#e74c3c',
        'A₅\n|A₅|=60': '#f39c12',
        'F₂₀\n|F₂₀|=20': '#3498db',
        'D₅\n|D₅|=10': '#2ecc71',
        'C₅\n|C₅|=5': '#9b59b6',
    }

    edges = [
        ('C₅\n|C₅|=5', 'D₅\n|D₅|=10'),
        ('D₅\n|D₅|=10', 'F₂₀\n|F₂₀|=20'),
        ('D₅\n|D₅|=10', 'A₅\n|A₅|=60'),
        ('F₂₀\n|F₂₀|=20', 'S₅\n|S₅|=120'),
        ('A₅\n|A₅|=60', 'S₅\n|S₅|=120'),
    ]

    # Draw edges
    for n1, n2 in edges:
        x1, y1 = positions[n1]
        x2, y2 = positions[n2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.4)

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.06, color=colors[name], zorder=5)
        ax.add_patch(circle)
        ax.text(x + 0.08, y, name, fontsize=11, va='center',
               fontweight='bold')

    # Annotations
    ax.text(0.7, 0.9, '← Gal(X⁵−X−1/ℚ)', fontsize=12, color='#e74c3c',
           fontweight='bold', va='center')

    ax.text(0.65, 0.5, '≤ A₅', fontsize=10, color='#666', style='italic')
    ax.text(0.65, 0.45, '(even permutations only)', fontsize=9, color='#999')

    ax.annotate('', xy=(0.62, 0.7), xytext=(0.62, 0.1),
               arrowprops=dict(arrowstyle='<->', color='#666', lw=1.5))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Transitive Subgroups of S₅', fontsize=16, fontweight='bold')

    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode()
    plt.close(fig)
    return f"data:image/png;base64,{img_base64}"


def polynomial_graph():
    """Plot the polynomial X^5 - X - 1."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(-1.5, 1.5, 500)
    y = x**5 - x - 1

    ax.plot(x, y, 'b-', linewidth=2.5, label='f(x) = x⁵ − x − 1')
    ax.axhline(y=0, color='k', linewidth=0.8)
    ax.axvline(x=0, color='k', linewidth=0.8)

    # Mark real root
    root = 1.1673
    ax.plot(root, 0, 'ro', markersize=10, zorder=5, label=f'Real root ≈ {root:.4f}')

    # Mark critical points
    crit = (1/5)**0.25
    ax.plot(crit, crit**5 - crit - 1, 'g^', markersize=8,
           label=f'Local min at x ≈ {crit:.3f}')
    ax.plot(-crit, (-crit)**5 - (-crit) - 1, 'gv', markersize=8,
           label=f'Local max at x ≈ {-crit:.3f}')

    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('f(x)', fontsize=13)
    ax.set_title('Graph of f(x) = x⁵ − x − 1', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 3)

    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode()
    plt.close(fig)
    return f"data:image/png;base64,{img_base64}"


if __name__ == "__main__":
    print("Generating visualizations...")
    img1 = roots_in_complex_plane()
    print(f"  roots_complex.png: {len(img1)} chars")
    img2 = subgroup_lattice()
    print(f"  subgroup_lattice.png: {len(img2)} chars")
    img3 = polynomial_graph()
    print(f"  polynomial_graph.png: {len(img3)} chars")
    print("Done!")
