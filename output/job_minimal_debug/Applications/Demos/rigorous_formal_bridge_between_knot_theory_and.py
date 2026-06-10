#!/usr/bin/env python3
"""
Demo: Cyclotomic Structure of Torus Knot Alexander Polynomials

Demonstrates the key results from the formal Lean proofs:
1. Alternating sum identity (X+1)·A_n(X) = X^n + 1 for odd n
2. Cyclotomic identification: A_3 = Φ_6, A_5 = Φ_{10}, A_7 = Φ_{14}
3. Spectral dichotomy: crystalline vs metallic OAM spectra
4. Composite factorization: A_{15} = Φ_6 · Φ_{10} · Φ_{30}
"""

import numpy as np
from numpy.polynomial import polynomial as P


def alternating_poly(n: int) -> np.ndarray:
    """Compute A_n(X) = sum_{k=0}^{n-1} (-1)^k X^k as coefficient array."""
    return np.array([(-1)**k for k in range(n)], dtype=float)


def cyclotomic_poly(n: int) -> np.ndarray:
    """Compute the n-th cyclotomic polynomial Φ_n(X) via Möbius inversion."""
    from math import gcd
    # Start with X^n - 1
    poly = np.zeros(n + 1)
    poly[0] = -1.0
    poly[n] = 1.0
    # Divide by Φ_d for each proper divisor d of n
    for d in range(1, n):
        if n % d == 0:
            div = cyclotomic_poly(d)
            poly, rem = P.polydiv(poly, div)
            assert np.allclose(rem, 0, atol=1e-10), f"Division not exact for d={d}"
    # Clean up near-zero coefficients
    return np.round(poly).astype(int).astype(float)


def demo_alternating_identity():
    """Verify (X+1)·A_n(X) = X^n + 1 for odd n."""
    print("=" * 60)
    print("DEMO 1: Alternating Sum Identity")
    print("(X+1) · A_n(X) = X^n + 1  for odd n")
    print("=" * 60)
    
    xp1 = np.array([1.0, 1.0])  # X + 1
    
    for n in [3, 5, 7, 9, 11, 15]:
        an = alternating_poly(n)
        product = P.polymul(xp1, an)
        expected = np.zeros(n + 1)
        expected[0] = 1.0
        expected[n] = 1.0
        
        match = np.allclose(product, expected, atol=1e-10)
        print(f"  n={n:2d}: (X+1)·A_{n}(X) = X^{n}+1?  {match}  "
              f"[deg(A_{n}) = {len(an)-1}]")
    print()


def demo_cyclotomic_identification():
    """Verify A_p = Φ_{2p} for prime p."""
    print("=" * 60)
    print("DEMO 2: Cyclotomic Identification")
    print("A_p(X) = Φ_{2p}(X)  for prime p")
    print("=" * 60)
    
    primes = [3, 5, 7, 11, 13]
    for p in primes:
        ap = alternating_poly(p)
        phi_2p = cyclotomic_poly(2 * p)
        match = np.allclose(ap, phi_2p, atol=1e-10)
        print(f"  p={p:2d}: A_{p} = Φ_{2*p}?  {match}")
        print(f"         A_{p}  = {ap.astype(int).tolist()}")
        print(f"         Φ_{2*p:2d} = {phi_2p.astype(int).tolist()}")
    print()


def demo_spectral_dichotomy():
    """Demonstrate the palindromic discriminant classification."""
    print("=" * 60)
    print("DEMO 3: Spectral Dichotomy")
    print("t² + bt + 1: disc = b² - 4")
    print("=" * 60)
    
    for b in range(-5, 6):
        disc = b**2 - 4
        if disc < 0:
            category = "CRYSTALLINE (unit circle roots)"
            roots = np.roots([1, b, 1])
            root_info = f"|r| = {abs(roots[0]):.6f}"
        elif disc > 0:
            category = "METALLIC    (real roots)"
            r1 = (-b + np.sqrt(disc)) / 2
            r2 = (-b - np.sqrt(disc)) / 2
            root_info = f"r = {r1:.6f}, {r2:.6f}"
        else:
            category = "DEGENERATE  (double root)"
            root_info = f"r = {-b/2:.1f}"
        
        knot = ""
        if b == -1:
            knot = "  [TREFOIL]"
        elif b == -3:
            knot = "  [FIGURE-EIGHT]"
        elif b == 0:
            knot = "  [HOPF LINK]"
        
        print(f"  b={b:+2d}: disc={disc:+3d}  {category}  {root_info}{knot}")
    print()


def demo_composite_factorization():
    """Verify A_15 = Φ_6 · Φ_10 · Φ_30."""
    print("=" * 60)
    print("DEMO 4: Composite Factorization")
    print("A_15 = Φ_6 · Φ_10 · Φ_30")
    print("=" * 60)
    
    a15 = alternating_poly(15)
    phi6 = cyclotomic_poly(6)
    phi10 = cyclotomic_poly(10)
    phi30 = cyclotomic_poly(30)
    
    product = P.polymul(P.polymul(phi6, phi10), phi30)
    match = np.allclose(a15, product, atol=1e-10)
    
    print(f"  A_15 coefficients:    {a15.astype(int).tolist()}")
    print(f"  Φ_6 · Φ_10 · Φ_30:   {product.astype(int).tolist()}")
    print(f"  Match: {match}")
    print(f"\n  Mode count breakdown:")
    from sympy import totient
    for d, name in [(6, "Φ_6 "), (10, "Φ_10"), (30, "Φ_30")]:
        phi_d = cyclotomic_poly(d)
        tot = int(totient(d))
        print(f"    {name}: degree = {len(phi_d)-1}, φ({d}) = {tot} modes")
    print(f"    Total: {len(a15)-1} = deg(A_15)")
    print()


def demo_oam_roots():
    """Visualize OAM root positions on the unit circle."""
    print("=" * 60)
    print("DEMO 5: OAM Mode Positions (roots of unity)")
    print("=" * 60)
    
    for n, name in [(3, "Trefoil T(2,3)"), (5, "Cinquefoil T(2,5)"),
                     (7, "T(2,7)")]:
        an = alternating_poly(n)
        # Compute roots
        # Reverse coefficients for np.roots (highest degree first)
        roots = np.roots(an[::-1])
        
        print(f"\n  {name}: A_{n} roots:")
        for i, r in enumerate(sorted(roots, key=lambda z: np.angle(z))):
            angle_deg = np.degrees(np.angle(r))
            print(f"    root {i+1}: |z| = {abs(r):.6f}, "
                  f"arg = {angle_deg:+8.3f}° = {angle_deg/180:.4f}π")
        print(f"    All on unit circle: {all(abs(abs(r) - 1) < 1e-10 for r in roots)}")
        print(f"    Angular gap: π/{n} = {180/n:.1f}°")
    print()


if __name__ == "__main__":
    demo_alternating_identity()
    demo_cyclotomic_identification()
    demo_spectral_dichotomy()
    try:
        demo_composite_factorization()
    except ImportError:
        print("  (Skipping composite demo - sympy not available)")
    demo_oam_roots()
    
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Cyclotomic Factorization of Composite Torus Knot Polynomials

Shows how A_15 = Φ_6 · Φ_10 · Φ_30, with each cyclotomic factor contributing
its own set of OAM modes on the unit circle.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd, pi


def primitive_roots_of_unity(n):
    """Return primitive n-th roots of unity."""
    return [np.exp(2j * pi * k / n) for k in range(n) if gcd(k, n) == 1]


def euler_totient(n):
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def plot_composite_factorization():
    fig, axes = plt.subplots(1, 4, figsize=(20, 5))
    
    cyclotomic_factors = [
        (6, "Φ₆", "#e74c3c"),
        (10, "Φ₁₀", "#3498db"),
        (30, "Φ₃₀", "#2ecc71"),
    ]
    
    theta = np.linspace(0, 2*np.pi, 200)
    
    # Individual factors
    all_roots = []
    all_colors = []
    
    for ax, (d, name, color) in zip(axes[:3], cyclotomic_factors):
        ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
        ax.axhline(0, color='gray', linewidth=0.3)
        ax.axvline(0, color='gray', linewidth=0.3)
        
        roots = primitive_roots_of_unity(d)
        for r in roots:
            ax.plot(r.real, r.imag, 'o', color=color, markersize=10,
                   markeredgecolor='black', markeredgewidth=1)
            all_roots.append(r)
            all_colors.append(color)
        
        phi_d = euler_totient(d)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(f'{name}\nφ({d}) = {phi_d} modes', fontsize=12,
                    fontweight='bold', color=color)
    
    # Combined
    ax = axes[3]
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
    ax.axhline(0, color='gray', linewidth=0.3)
    ax.axvline(0, color='gray', linewidth=0.3)
    
    for r, c in zip(all_roots, all_colors):
        ax.plot(r.real, r.imag, 'o', color=c, markersize=8,
               markeredgecolor='black', markeredgewidth=0.8)
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(f'A₁₅ = Φ₆·Φ₁₀·Φ₃₀\n{len(all_roots)} total modes',
                fontsize=12, fontweight='bold')
    
    fig.suptitle('Cyclotomic Factorization: T(2,15) Torus Knot OAM Spectrum',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('composite_factorization.png', dpi=150, bbox_inches='tight')
    print("Saved: composite_factorization.png")


if __name__ == "__main__":
    plot_composite_factorization()


#!/usr/bin/env python3
"""
Visualization: OAM Mode Positions on the Unit Circle

Shows how roots of the Alexander polynomial (= cyclotomic polynomial)
create discrete OAM mode positions on the unit circle for torus knots.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def alternating_poly_roots(n):
    """Compute roots of A_n(X) = sum_{k=0}^{n-1} (-1)^k X^k."""
    coeffs = [(-1)**k for k in range(n)]
    return np.roots(coeffs[::-1])


def plot_oam_spectrum():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    knots = [
        (3, "Trefoil T(2,3)\nΔ = Φ₆", "#e74c3c"),
        (5, "Cinquefoil T(2,5)\nΔ = Φ₁₀", "#3498db"),
        (7, "T(2,7)\nΔ = Φ₁₄", "#2ecc71"),
    ]
    
    for ax, (n, title, color) in zip(axes, knots):
        # Draw unit circle
        theta = np.linspace(0, 2*np.pi, 200)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
        ax.axhline(0, color='gray', linewidth=0.3)
        ax.axvline(0, color='gray', linewidth=0.3)
        
        # Plot roots
        roots = alternating_poly_roots(n)
        for r in roots:
            ax.plot(r.real, r.imag, 'o', color=color, markersize=10,
                   markeredgecolor='black', markeredgewidth=1)
            # Draw line from origin
            ax.plot([0, r.real], [0, r.imag], '-', color=color, alpha=0.3)
        
        # Annotate angular gap
        angles = sorted(np.angle(roots))
        if len(angles) >= 2:
            gap = angles[1] - angles[0]
            ax.annotate(f'gap = π/{n}\n= {np.degrees(gap):.1f}°',
                       xy=(0.5, -0.3), fontsize=9,
                       ha='center', color=color, fontweight='bold')
        
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.text(0.02, 0.98, f'{n-1} modes', transform=ax.transAxes,
               fontsize=10, va='top', color=color, fontweight='bold')
    
    fig.suptitle('OAM Mode Positions: Roots of Torus Knot Alexander Polynomials',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('oam_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: oam_spectrum.png")


def plot_spectral_dichotomy():
    """Plot the crystalline vs metallic dichotomy."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Crystalline: trefoil (b=-1)
    b = -1
    roots = np.roots([1, b, 1])
    theta = np.linspace(0, 2*np.pi, 200)
    
    ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
    ax1.axhline(0, color='gray', linewidth=0.3)
    ax1.axvline(0, color='gray', linewidth=0.3)
    for r in roots:
        ax1.plot(r.real, r.imag, 'o', color='#e74c3c', markersize=12,
                markeredgecolor='black', markeredgewidth=1.5)
        ax1.plot([0, r.real], [0, r.imag], '-', color='#e74c3c', alpha=0.4)
    ax1.set_xlim(-1.8, 1.8)
    ax1.set_ylim(-1.8, 1.8)
    ax1.set_aspect('equal')
    ax1.set_title('CRYSTALLINE (|b| < 2)\nTrefoil: t² - t + 1\ndisc = -3 < 0',
                  fontsize=11, fontweight='bold', color='#e74c3c')
    ax1.text(0.05, 0.05, 'Roots on unit circle\n→ Discrete OAM modes',
            transform=ax1.transAxes, fontsize=9, color='#e74c3c')
    
    # Metallic: figure-eight (b=-3)
    b = -3
    r1 = (3 + np.sqrt(5)) / 2  # golden ratio
    r2 = (3 - np.sqrt(5)) / 2
    
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)
    ax2.axhline(0, color='gray', linewidth=0.3)
    ax2.axvline(0, color='gray', linewidth=0.3)
    ax2.plot(r1, 0, 's', color='#f39c12', markersize=12,
            markeredgecolor='black', markeredgewidth=1.5)
    ax2.plot(r2, 0, 's', color='#f39c12', markersize=12,
            markeredgecolor='black', markeredgewidth=1.5)
    ax2.annotate(f'φ = {r1:.4f}', xy=(r1, 0), xytext=(r1+0.2, 0.4),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='#f39c12'),
                color='#f39c12', fontweight='bold')
    ax2.annotate(f'1/φ = {r2:.4f}', xy=(r2, 0), xytext=(r2-0.5, -0.5),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='#f39c12'),
                color='#f39c12', fontweight='bold')
    ax2.set_xlim(-1.8, 2.2)
    ax2.set_ylim(-1.8, 1.8)
    ax2.set_aspect('equal')
    ax2.set_title('METALLIC (|b| > 2)\nFigure-eight: t² - 3t + 1\ndisc = +5 > 0',
                  fontsize=11, fontweight='bold', color='#f39c12')
    ax2.text(0.05, 0.05, 'Real roots (golden ratio)\n→ Continuous OAM band',
            transform=ax2.transAxes, fontsize=9, color='#f39c12')
    
    fig.suptitle('Spectral Dichotomy: Palindromic Alexander Polynomials',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('spectral_dichotomy.png', dpi=150, bbox_inches='tight')
    print("Saved: spectral_dichotomy.png")


if __name__ == "__main__":
    plot_oam_spectrum()
    plot_spectral_dichotomy()
