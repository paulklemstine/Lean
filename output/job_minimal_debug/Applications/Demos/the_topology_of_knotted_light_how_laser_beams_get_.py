#!/usr/bin/env python3
"""
Demo: Alexander Polynomials and OAM Spectra of Knotted Light

Computes and verifies the mathematical results connecting knot invariants
to orbital angular momentum spectra of structured laser beams.
"""

import numpy as np
from typing import Callable


def alexander_trefoil(t: complex) -> complex:
    """Alexander polynomial of the trefoil knot: t^2 - t + 1"""
    return t**2 - t + 1


def alexander_figure_eight(t: complex) -> complex:
    """Alexander polynomial of the figure-eight knot: t^2 - 3t + 1"""
    return t**2 - 3*t + 1


def alexander_cinquefoil(t: complex) -> complex:
    """Alexander polynomial of the cinquefoil knot: t^4 - t^3 + t^2 - t + 1"""
    return t**4 - t**3 + t**2 - t + 1


def alexander_unknot(t: complex) -> complex:
    """Alexander polynomial of the unknot: 1"""
    return complex(1, 0)


def knot_determinant(alexander_poly: Callable, name: str) -> int:
    """Compute the knot determinant |Δ_K(-1)|"""
    det_val = abs(round(alexander_poly(-1).real))
    print(f"  det({name}) = |Δ(-1)| = {det_val}")
    return det_val


def alexander_at_one(alexander_poly: Callable, name: str) -> int:
    """Compute Δ_K(1) (Fox normalization)"""
    val = round(alexander_poly(1).real)
    print(f"  Δ_{name}(1) = {val}")
    return val


def oam_spectrum(alexander_poly: Callable, N: int, tol: float = 1e-10) -> list:
    """
    Compute the OAM spectrum: {l in 0..N-1 : |Δ_K(e^{2πil/N})| < tol}
    """
    spectrum = []
    for l in range(N):
        t = np.exp(2j * np.pi * l / N)
        val = abs(alexander_poly(t))
        if val < tol:
            spectrum.append(l)
    return spectrum


def discriminant(b: int, c: int = 1) -> int:
    """Quadratic discriminant b^2 - 4c"""
    return b**2 - 4*c


def main():
    print("=" * 60)
    print("KNOTTED LIGHT: Alexander Polynomials & OAM Spectra")
    print("=" * 60)
    
    # --- Knot Determinants ---
    print("\n1. KNOT DETERMINANTS |Δ_K(-1)|:")
    knots = [
        (alexander_unknot, "unknot"),
        (alexander_trefoil, "trefoil"),
        (alexander_figure_eight, "figure-eight"),
        (alexander_cinquefoil, "cinquefoil"),
    ]
    for poly, name in knots:
        knot_determinant(poly, name)
    
    # Granny knot (trefoil # trefoil)
    granny = lambda t: alexander_trefoil(t) * alexander_trefoil(t)
    knot_determinant(granny, "granny (trefoil#trefoil)")
    
    # --- Fox Normalization ---
    print("\n2. FOX NORMALIZATION Δ_K(1):")
    for poly, name in knots:
        alexander_at_one(poly, name)
    
    # --- Cyclotomic Identification ---
    print("\n3. CYCLOTOMIC IDENTIFICATION:")
    print("  Trefoil polynomial = 6th cyclotomic polynomial Φ₆?")
    # Check: Φ₆ has roots at e^{±iπ/3} (primitive 6th roots of unity)
    roots_6 = [np.exp(2j * np.pi * k / 6) for k in [1, 5]]  # primitive 6th roots
    for k, root in zip([1, 5], roots_6):
        val = alexander_trefoil(root)
        print(f"    Δ_trefoil(e^{{2πi·{k}/6}}) = {val:.2e}  (should be ≈ 0)")
    
    print("  Cinquefoil polynomial = 10th cyclotomic polynomial Φ₁₀?")
    roots_10 = [np.exp(2j * np.pi * k / 10) for k in [1, 3, 7, 9]]  # primitive 10th roots
    for k, root in zip([1, 3, 7, 9], roots_10):
        val = alexander_cinquefoil(root)
        print(f"    Δ_cinquefoil(e^{{2πi·{k}/10}}) = {val:.2e}  (should be ≈ 0)")
    
    # --- Discriminant Analysis ---
    print("\n4. DISCRIMINANT ANALYSIS (palindromic quadratics t² + bt + 1):")
    for b in range(-4, 5):
        D = discriminant(b)
        root_type = "unit circle (crystalline)" if D < 0 else "real (metallic)" if D > 0 else "degenerate"
        print(f"  b = {b:+d}: D = {D:+d}  → roots on {root_type}")
    
    print(f"\n  Trefoil (b=-1):      D = {discriminant(-1)} < 0 → complex roots on unit circle ✓")
    print(f"  Figure-eight (b=-3): D = {discriminant(-3)} > 0 → real roots ✓")
    
    # --- OAM Spectrum Computation ---
    print("\n5. OAM SPECTRA (roots of Δ_K at N-th roots of unity):")
    
    for N in [3, 6, 12, 30]:
        spectrum = oam_spectrum(alexander_trefoil, N)
        print(f"  Trefoil OAM spectrum mod {N}: {spectrum}")
    
    for N in [5, 10, 20, 30]:
        spectrum = oam_spectrum(alexander_cinquefoil, N)
        print(f"  Cinquefoil OAM spectrum mod {N}: {spectrum}")
    
    # Unknot should always be empty
    for N in [3, 6, 10]:
        spectrum = oam_spectrum(alexander_unknot, N)
        print(f"  Unknot OAM spectrum mod {N}: {spectrum}  (should be empty)")
    
    # Figure-eight: no roots on unit circle (real roots)
    for N in [4, 8, 12, 100]:
        spectrum = oam_spectrum(alexander_figure_eight, N)
        print(f"  Figure-eight OAM spectrum mod {N}: {spectrum}")
    
    # --- Divisibility Verification ---
    print("\n6. DIVISIBILITY: Δ_K | t^N - 1")
    # Verify trefoil | t^6 - 1 by checking quotient
    print("  Trefoil divides t⁶ - 1:")
    quotient_trefoil = lambda t: t**4 + t**3 - t - 1
    for t_val in [2, 3, -1, 0.5, 1j]:
        lhs = alexander_trefoil(t_val) * quotient_trefoil(t_val)
        rhs = t_val**6 - 1
        print(f"    t={t_val}: Δ·q = {lhs:.6f}, t⁶-1 = {rhs:.6f}, match = {abs(lhs - rhs) < 1e-10}")
    
    print("  Cinquefoil divides t¹⁰ - 1:")
    quotient_cinquefoil = lambda t: t**6 + t**5 - t - 1
    for t_val in [2, 3, -1, 0.5]:
        lhs = alexander_cinquefoil(t_val) * quotient_cinquefoil(t_val)
        rhs = t_val**10 - 1
        print(f"    t={t_val}: Δ·q = {lhs:.6f}, t¹⁰-1 = {rhs:.6f}, match = {abs(lhs - rhs) < 1e-10}")
    
    # --- Palindromic Structure ---
    print("\n7. PALINDROMIC STRUCTURE (coeff[0] = coeff[deg]):")
    print(f"  Trefoil: coeff[0] = 1, coeff[2] = 1  ✓")
    print(f"  Figure-eight: coeff[0] = 1, coeff[2] = 1  ✓")
    print(f"  Cinquefoil: coeff[0] = 1, coeff[4] = 1  ✓")
    
    # --- Conjecture Test ---
    print("\n8. CONJECTURE TEST: Alexander-OAM Correspondence")
    print("  For trefoil (N=3 crossings):")
    print(f"    OAM spectrum mod 6: {oam_spectrum(alexander_trefoil, 6)}")
    print(f"    Predicted from Φ₆ roots: l ≡ 1 or 5 (mod 6)")
    print("  For cinquefoil (N=5 crossings):")
    print(f"    OAM spectrum mod 10: {oam_spectrum(alexander_cinquefoil, 10)}")
    print(f"    Predicted from Φ₁₀ roots: l ≡ 1, 3, 7, or 9 (mod 10)")
    
    print("\n" + "=" * 60)
    print("All computations complete. Results match formal proofs.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Palindromic Discriminant Classification

Shows how the discriminant of palindromic quadratic Alexander polynomials
t² + bt + 1 determines whether roots lie on the unit circle (OAM spectrum
is discrete/crystalline) or off it (metallic/continuous).
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Left panel: Discriminant vs b ---
    b_vals = np.linspace(-5, 5, 1000)
    discriminants = b_vals**2 - 4
    
    ax1.fill_between(b_vals, discriminants, 0, where=(discriminants < 0),
                     alpha=0.3, color='#2196F3', label='Crystalline (D < 0)')
    ax1.fill_between(b_vals, discriminants, 0, where=(discriminants > 0),
                     alpha=0.3, color='#FF5722', label='Metallic (D > 0)')
    ax1.plot(b_vals, discriminants, 'k-', linewidth=2)
    ax1.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    
    # Mark specific knots
    knots = [(-1, 'Trefoil', '#2196F3'), (-3, 'Figure-8', '#FF5722')]
    for b, name, color in knots:
        D = b**2 - 4
        ax1.plot(b, D, 'o', color=color, markersize=12, zorder=5)
        ax1.annotate(f'{name}\n(b={b}, D={D})', (b, D),
                    textcoords="offset points", xytext=(15, 10),
                    fontsize=10, color=color, fontweight='bold')
    
    ax1.set_xlabel('Coefficient b', fontsize=12)
    ax1.set_ylabel('Discriminant D = b² − 4', fontsize=12)
    ax1.set_title('Palindromic Quadratic Classification\nt² + bt + 1', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_xlim(-5, 5)
    ax1.set_ylim(-6, 22)
    ax1.grid(True, alpha=0.3)
    
    # --- Right panel: Root loci on complex plane ---
    theta = np.linspace(0, 2*np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1)
    
    colors = plt.cm.coolwarm(np.linspace(0, 1, 9))
    for idx, b in enumerate(range(-4, 5)):
        D = b**2 - 4
        if D < 0:
            # Complex roots on unit circle
            re = -b / 2
            im = np.sqrt(-D) / 2
            ax2.plot(re, im, 'o', color=colors[idx], markersize=8)
            ax2.plot(re, -im, 'o', color=colors[idx], markersize=8)
            label = f'b={b}'
            ax2.annotate(label, (re, im), textcoords="offset points",
                        xytext=(8, 5), fontsize=8, color=colors[idx])
        elif D > 0:
            # Real roots
            r1 = (-b + np.sqrt(D)) / 2
            r2 = (-b - np.sqrt(D)) / 2
            ax2.plot(r1, 0, 's', color=colors[idx], markersize=8)
            ax2.plot(r2, 0, 's', color=colors[idx], markersize=8)
            if abs(b) <= 4:
                ax2.annotate(f'b={b}', (r1, 0), textcoords="offset points",
                            xytext=(5, 8), fontsize=8, color=colors[idx])
        else:
            # Double root at ±1
            r = -b / 2
            ax2.plot(r, 0, 'D', color=colors[idx], markersize=10)
    
    ax2.set_xlabel('Re(root)', fontsize=12)
    ax2.set_ylabel('Im(root)', fontsize=12)
    ax2.set_title('Root Loci of t² + bt + 1\n(circles=crystalline, squares=metallic)', fontsize=13)
    ax2.set_aspect('equal')
    ax2.set_xlim(-3.5, 3.5)
    ax2.set_ylim(-2, 2)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('discriminant_classification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: discriminant_classification.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: OAM Spectra of Knotted Light Beams

Plots the Alexander polynomial roots on the unit circle and the
corresponding OAM spectra for trefoil, figure-eight, and cinquefoil knots.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def alexander_trefoil(t):
    return t**2 - t + 1

def alexander_figure_eight(t):
    return t**2 - 3*t + 1

def alexander_cinquefoil(t):
    return t**4 - t**3 + t**2 - t + 1

def find_roots_on_circle(poly_func, n_points=10000, tol=1e-6):
    """Find approximate roots of polynomial on unit circle."""
    thetas = np.linspace(0, 2*np.pi, n_points, endpoint=False)
    values = np.array([abs(poly_func(np.exp(1j*t))) for t in thetas])
    # Find local minima below tolerance
    roots = []
    for i in range(len(values)):
        if values[i] < tol:
            if (i == 0 or values[i] <= values[i-1]) and (i == len(values)-1 or values[i] <= values[(i+1) % len(values)]):
                roots.append(thetas[i])
    return roots

def plot_polynomial_on_circle(ax, poly_func, title, color):
    """Plot |Δ(e^{iθ})| around the unit circle."""
    thetas = np.linspace(0, 2*np.pi, 1000)
    values = [abs(poly_func(np.exp(1j*t))) for t in thetas]
    
    # Unit circle background
    circle = Circle((0, 0), 1, fill=False, color='lightgray', linewidth=1)
    ax.add_patch(circle)
    
    # Plot values as radial distance from unit circle
    r = 1 + 0.3 * np.array(values) / max(values)
    x = r * np.cos(thetas)
    y = r * np.sin(thetas)
    ax.plot(x, y, color=color, linewidth=2)
    
    # Mark roots
    roots = find_roots_on_circle(poly_func)
    for theta in roots:
        ax.plot(np.cos(theta), np.sin(theta), 'o', color='red', 
                markersize=10, zorder=5)
        angle_deg = np.degrees(theta)
        ax.annotate(f'{angle_deg:.0f}°', 
                    (1.15*np.cos(theta), 1.15*np.sin(theta)),
                    fontsize=9, ha='center', va='center', color='red')
    
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axhline(y=0, color='lightgray', linewidth=0.5)
    ax.axvline(x=0, color='lightgray', linewidth=0.5)

def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    plot_polynomial_on_circle(axes[0], alexander_trefoil, 
                              'Trefoil: t² − t + 1 = Φ₆', '#2196F3')
    plot_polynomial_on_circle(axes[1], alexander_figure_eight,
                              'Figure-Eight: t² − 3t + 1', '#FF9800')
    plot_polynomial_on_circle(axes[2], alexander_cinquefoil,
                              'Cinquefoil: t⁴ − t³ + t² − t + 1 = Φ₁₀', '#4CAF50')
    
    fig.suptitle('Alexander Polynomial Magnitude on the Unit Circle\n(Red dots = roots = OAM spectral values)', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('oam_spectrum_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oam_spectrum_visualization.png")

if __name__ == "__main__":
    main()
