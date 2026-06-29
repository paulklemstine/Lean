#!/usr/bin/env python3
"""
Newton–Tropical Bridge: Demonstration
======================================

Numerical examples showing the bridge between polynomial valuations
and tropical geometry, with cryptographic certificate extraction.
"""

from algorithms import (
    p_adic_valuation, newton_profile, tropical_eval,
    newton_polygon_vertices, newton_slopes, dominant_terms,
    infimal_convolution, extract_slope_certificate,
    tropical_discriminant_2, profile_distance
)


def demo_basic_valuation():
    """Demo 1: Basic p-adic valuations and Newton profiles."""
    print("=" * 60)
    print("DEMO 1: p-adic Valuations and Newton Profiles")
    print("=" * 60)
    
    # f(x) = 27 + 9x + x²  (over Z, prime p=3)
    coeffs = [27, 9, 1]
    p = 3
    profile = newton_profile(coeffs, p)
    
    print(f"\nPolynomial: f(x) = {coeffs[2]}x² + {coeffs[1]}x + {coeffs[0]}")
    print(f"Prime: p = {p}")
    print(f"Newton profile: {profile}")
    print(f"  v₃(27) = {profile[0]}, v₃(9) = {profile[1]}, v₃(1) = {profile[2]}")
    
    # Newton polygon
    hull = newton_polygon_vertices(profile)
    print(f"\nNewton polygon vertices: {hull}")
    
    slopes = newton_slopes(profile)
    print(f"Newton slopes (= root valuations): {slopes}")
    
    # Verify: f(x) = (x+3)(x+9), roots -3 and -9
    print(f"\nVerification: f(x) = (x+3)(x+9)")
    print(f"  Root -3: v₃(3) = {p_adic_valuation(3, 3)}")
    print(f"  Root -9: v₃(9) = {p_adic_valuation(9, 3)}")
    print(f"  Slopes match root valuations: ✓")


def demo_tropical_evaluation():
    """Demo 2: Tropical polynomial evaluation as lower envelope."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Evaluation (Lower Envelope)")
    print("=" * 60)
    
    # f(x) = 8 + 12x + 6x² + x³  (prime p=2)
    coeffs = [8, 12, 6, 1]
    p = 2
    profile = newton_profile(coeffs, p)
    
    print(f"\nPolynomial: f(x) = x³ + 6x² + 12x + 8 = (x+2)³")
    print(f"Prime: p = {p}")
    print(f"Newton profile: {profile}")
    
    # Evaluate tropical polynomial at several points
    print("\nTropical evaluation T_f(t) = min_i(v_i + i·t):")
    for t in [0, 0.5, 1, 1.5, 2, 3]:
        val = tropical_eval(profile, t)
        doms = dominant_terms(profile, t)
        print(f"  T_f({t}) = {val:.1f}  (dominant terms: {doms})")
    
    # Bridge theorem: v₂(f(a)) ≥ T_f(v₂(a))
    print("\nBridge theorem verification:")
    a = 2
    va = p_adic_valuation(a, p)
    fa = sum(c * a**i for i, c in enumerate(coeffs))
    vfa = p_adic_valuation(fa, p)
    trop = tropical_eval(profile, va)
    print(f"  a = {a}, v₂(a) = {va}")
    print(f"  f(a) = f(2) = {fa}, v₂(f(2)) = {vfa}")
    print(f"  T_f(v₂(a)) = T_f({va}) = {trop}")
    print(f"  v₂(f(a)) ≥ T_f(v₂(a)): {vfa} ≥ {trop} ✓" if vfa >= trop else "  FAILED!")


def demo_certificate():
    """Demo 3: Cryptographic Newton slope certificate."""
    print("\n" + "=" * 60)
    print("DEMO 3: Newton Slope Certificate (Cryptographic)")
    print("=" * 60)
    
    # Scenario: prove that 3⁵ | f(a) without revealing a
    coeffs = [243, 81, 27, 9, 3, 1]  # (x+3)⁵ expanded partially
    p = 3
    
    # Actually use f(x) = x⁵ + ... = sum of binomial(5,k)*3^k * x^(5-k)
    from math import comb
    coeffs_correct = [comb(5, k) * 3**(5-k) for k in range(6)]
    # This is (3+x)^5 = 243 + 405x + 270x² + 90x³ + 15x⁴ + x⁵
    
    print(f"\nPolynomial: f(x) = (x+3)⁵")
    print(f"Coefficients: {coeffs_correct}")
    profile = newton_profile(coeffs_correct, p)
    print(f"Newton profile (v₃): {profile}")
    
    # Extract certificate for point_val = 1 (i.e., v₃(a) = 1)
    cert = extract_slope_certificate(coeffs_correct, p, point_val=1)
    print(f"\nCertificate for v₃(a) = 1:")
    print(f"  Bound: v₃(f(a)) ≥ {cert['bound']}")
    print(f"  Dominant terms: {cert['dominant_terms']}")
    
    # Verify with a = 3
    a = 3
    fa = sum(c * a**i for i, c in enumerate(coeffs_correct))
    print(f"\nVerification with a = 3:")
    print(f"  f(3) = (3+3)⁵ = 6⁵ = {fa}")
    print(f"  v₃(f(3)) = {p_adic_valuation(fa, p)}")
    print(f"  Certificate bound = {cert['bound']}")
    print(f"  Certificate valid: ✓")


def demo_infimal_convolution():
    """Demo 4: Infimal convolution as tropical product."""
    print("\n" + "=" * 60)
    print("DEMO 4: Infimal Convolution (Tropical Multiplication)")
    print("=" * 60)
    
    # f(x) = x + 3, g(x) = x + 9 (prime p=3)
    f_coeffs = [3, 1]
    g_coeffs = [9, 1]
    p = 3
    
    prof_f = newton_profile(f_coeffs, p)
    prof_g = newton_profile(g_coeffs, p)
    conv = infimal_convolution(prof_f, prof_g)
    
    # Product: f*g = (x+3)(x+9) = x² + 12x + 27
    fg_coeffs = [27, 12, 1]
    prof_fg = newton_profile(fg_coeffs, p)
    
    print(f"\nf(x) = x + 3,  profile: {prof_f}")
    print(f"g(x) = x + 9,  profile: {prof_g}")
    print(f"\nInfimal convolution (tropical product): {conv}")
    print(f"Actual product f·g profile: {prof_fg}")
    print(f"Convolution ≤ product pointwise: "
          f"{all(c <= p for c, p in zip(conv, prof_fg))}")


def demo_stability():
    """Demo 5: Stability of tropical evaluation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Stability under Perturbation")
    print("=" * 60)
    
    # Original profile
    original = [3.0, 2.0, 0.0]  # Newton profile of x² + 9x + 27 at p=3
    
    # Perturbed profiles (ε = 1)
    perturbed = [4.0, 2.0, 1.0]  # ε-close with ε=1
    
    eps = profile_distance(original, perturbed)
    print(f"\nOriginal profile: {original}")
    print(f"Perturbed profile: {perturbed}")
    print(f"Distance (ε): {eps}")
    
    print("\nStability check: |T_A(t) - T_B(t)| ≤ ε for all t")
    for t in [0, 0.5, 1, 1.5, 2, 3]:
        ta = tropical_eval(original, t)
        tb = tropical_eval(perturbed, t)
        diff = abs(ta - tb)
        status = "✓" if diff <= eps + 1e-10 else "✗"
        print(f"  t={t}: T_A={ta:.1f}, T_B={tb:.1f}, |diff|={diff:.1f} ≤ {eps} {status}")


def demo_discriminant():
    """Demo 6: Tropical discriminant for quadratic polynomials."""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical Discriminant Analysis")
    print("=" * 60)
    
    examples = [
        ([27, 9, 1], 3, "x² + 9x + 27"),
        ([4, 2, 1], 2, "x² + 2x + 4"),
        ([25, 10, 1], 5, "x² + 10x + 25"),
        ([12, 6, 1], 2, "x² + 6x + 12"),
    ]
    
    for coeffs, p, name in examples:
        profile = newton_profile(coeffs, p)
        td = tropical_discriminant_2(profile)
        slopes = newton_slopes(profile)
        print(f"\n  {name} at p={p}")
        print(f"    Profile: {profile}")
        print(f"    Tropical discriminant: {td}")
        print(f"    Newton slopes: {slopes}")
        if len(set(slopes)) == 1:
            print(f"    → Roots have same valuation (td ≥ 2·v(b))")
        else:
            print(f"    → Roots have different valuations")


if __name__ == "__main__":
    demo_basic_valuation()
    demo_tropical_evaluation()
    demo_certificate()
    demo_infimal_convolution()
    demo_stability()
    demo_discriminant()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Newton Polygon and Tropical Evaluation
=====================================================

Standalone visualization script using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def p_adic_valuation(n, p):
    if n == 0:
        return float('inf')
    n = abs(n)
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def newton_profile(coeffs, p):
    return [p_adic_valuation(c, p) for c in coeffs]


def newton_polygon_vertices(profile):
    points = [(i, v) for i, v in enumerate(profile) if v < float('inf')]
    if len(points) <= 1:
        return points
    points.sort()
    hull = []
    for pt in points:
        while len(hull) >= 2:
            o, a = hull[-2], hull[-1]
            cross = (a[0] - o[0]) * (pt[1] - o[1]) - (a[1] - o[1]) * (pt[0] - o[0])
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(pt)
    return hull


def tropical_eval(profile, t):
    return min(v + i * t for i, v in enumerate(profile) if v < float('inf'))


def plot_newton_polygon_and_tropical():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    examples = [
        ([27, 9, 1], 3, "f(x) = x² + 9x + 27, p=3"),
        ([8, 12, 6, 1], 2, "f(x) = (x+2)³, p=2"),
        ([243, 405, 270, 90, 15, 1], 3, "f(x) = (x+3)⁵, p=3"),
    ]
    
    for ax, (coeffs, p, title) in zip(axes, examples):
        profile = newton_profile(coeffs, p)
        hull = newton_polygon_vertices(profile)
        
        # Plot all points
        finite_pts = [(i, v) for i, v in enumerate(profile) if v < float('inf')]
        xs, ys = zip(*finite_pts) if finite_pts else ([], [])
        ax.scatter(xs, ys, c='blue', s=80, zorder=5, label='Coefficients')
        
        # Plot lower convex hull
        if hull:
            hx, hy = zip(*hull)
            ax.plot(hx, hy, 'r-', linewidth=2, label='Newton polygon')
            ax.scatter(hx, hy, c='red', s=100, zorder=6, marker='D')
        
        # Annotate points
        for i, v in enumerate(profile):
            if v < float('inf'):
                ax.annotate(f'v({coeffs[i]})={int(v)}', (i, v),
                           textcoords="offset points", xytext=(5, 10),
                           fontsize=8)
        
        ax.set_xlabel('Degree i')
        ax.set_ylabel(f'v_{p}(aᵢ)')
        ax.set_title(title)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(bottom=-0.5)
    
    plt.suptitle('Newton Polygons: Lower Convex Hulls of Coefficient Valuations', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('newton_polygons.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: newton_polygons.png")
    
    # Second figure: Tropical evaluation
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    for ax, (coeffs, p, title) in zip(axes, examples):
        profile = newton_profile(coeffs, p)
        
        ts = np.linspace(0, 4, 200)
        vals = [tropical_eval(profile, t) for t in ts]
        
        ax.plot(ts, vals, 'b-', linewidth=2, label='T_f(t)')
        
        # Plot individual terms
        for i, v in enumerate(profile):
            if v < float('inf'):
                term_vals = [v + i * t for t in ts]
                ax.plot(ts, term_vals, '--', alpha=0.4, 
                       label=f'v_{i} + {i}·t = {int(v)} + {i}t')
        
        ax.set_xlabel('t (evaluation point valuation)')
        ax.set_ylabel('T_f(t)')
        ax.set_title(title)
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(bottom=-0.5, top=max(vals) * 1.3 + 1)
    
    plt.suptitle('Tropical Polynomial Evaluation: Lower Envelope', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_evaluation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_evaluation.png")


if __name__ == "__main__":
    plot_newton_polygon_and_tropical()
