#!/usr/bin/env python3
"""
Resolution of Singularities in Positive Characteristic: Demonstrations

This script demonstrates the key algorithms and phenomena formalized in
the Lean proofs, with numerical examples over small finite fields.
"""

from algorithms import (
    Monomial, PolynomialFp, compute_inseparability_degree,
    blowup_at_origin_affine_chart, resolution_sequence,
    newton_polygon_2d, frobenius_image, random_polynomial_fp
)


def demo_derivative_vanishing():
    """Demonstrate that d/dx(x^p) = 0 in characteristic p.
    
    This is the fundamental phenomenon: in F_p[x], the formal derivative
    of x^p is p*x^(p-1) = 0.
    """
    print("=" * 60)
    print("DEMO 1: Derivative Vanishing in Characteristic p")
    print("=" * 60)
    
    for p in [2, 3, 5, 7]:
        # f = x^p (univariate, so dim=1)
        f = PolynomialFp(p, 1, [Monomial(1, (p,))])
        df = f.formal_derivative(0)
        
        print(f"\n  char = {p}:")
        print(f"    f = x^{p}")
        print(f"    f' = {df.terms if df.terms else '0'}")
        
        # Also check x^(p^2)
        f2 = PolynomialFp(p, 1, [Monomial(1, (p*p,))])
        df2 = f2.formal_derivative(0)
        print(f"    g = x^{p*p}")
        print(f"    g' = {df2.terms if df2.terms else '0'}")
    
    # Contrast: x^(p-1) does NOT have vanishing derivative
    print(f"\n  Contrast (non-vanishing derivatives):")
    for p in [3, 5, 7]:
        f = PolynomialFp(p, 1, [Monomial(1, (p-1,))])
        df = f.formal_derivative(0)
        print(f"    char={p}: d/dx(x^{p-1}) = {df.terms}")


def demo_inseparability_degree():
    """Demonstrate the inseparability degree computation.
    
    The inseparability degree measures how deeply a polynomial is in 
    the image of the Frobenius map.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Inseparability Degree")
    print("=" * 60)
    
    p = 3
    
    # k=0: x^2 + y^3 (ordinary double point, separable)
    f0 = PolynomialFp(p, 2, [
        Monomial(1, (2, 0)),
        Monomial(1, (0, 3))
    ])
    print(f"\n  f = x^2 + y^3 over F_{p}")
    print(f"  Inseparability degree: {compute_inseparability_degree(f0)}")
    
    # k=1: x^3 + y^3 (all exponents divisible by 3)
    f1 = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),
        Monomial(1, (0, 3))
    ])
    print(f"\n  f = x^3 + y^3 over F_{p}")
    print(f"  Inseparability degree: {compute_inseparability_degree(f1)}")
    print(f"  Note: This is Frobenius image of x + y, so derivative vanishes!")
    
    # k=2: x^9 + y^9 (all exponents divisible by 9 = 3^2)
    f2 = PolynomialFp(p, 2, [
        Monomial(1, (9, 0)),
        Monomial(1, (0, 9))
    ])
    print(f"\n  f = x^9 + y^9 over F_{p}")
    print(f"  Inseparability degree: {compute_inseparability_degree(f2)}")
    
    # Mixed: x^3 + y^2 (gcd of exponents is 1, but x exponent is div by 3)
    f_mix = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),
        Monomial(1, (0, 2))
    ])
    print(f"\n  f = x^3 + y^2 over F_{p} (cusp)")
    print(f"  Inseparability degree: {compute_inseparability_degree(f_mix)}")
    print(f"  Note: Not fully inseparable, but x-derivative vanishes!")


def demo_freshman_dream():
    """Demonstrate the freshman's dream: (a+b)^p = a^p + b^p in char p."""
    print("\n" + "=" * 60)
    print("DEMO 3: Freshman's Dream in F_p")
    print("=" * 60)
    
    for p in [2, 3, 5]:
        print(f"\n  F_{p}:")
        for a in range(p):
            for b in range(p):
                lhs = pow(a + b, p, p)
                rhs = (pow(a, p, p) + pow(b, p, p)) % p
                if lhs != rhs:
                    print(f"    COUNTEREXAMPLE: ({a}+{b})^{p} = {lhs} != {rhs} = {a}^{p}+{b}^{p}")
                    break
        else:
            print(f"    Verified: (a+b)^{p} = a^{p} + b^{p} for all a, b in F_{p}")


def demo_blowup_resolution():
    """Demonstrate resolution by iterated blowup."""
    print("\n" + "=" * 60)
    print("DEMO 4: Resolution by Iterated Blowup")
    print("=" * 60)
    
    # Example 1: y^2 = x^3 (cusp) over F_5
    p = 5
    f_cusp = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),   # x^3
        Monomial(p-1, (0, 2))  # -y^2
    ])
    print(f"\n  Cusp: x^3 - y^2 = 0 over F_{p}")
    print(f"  Multiplicity at origin: {f_cusp.multiplicity_at_origin()}")
    print(f"  Inseparability degree: {compute_inseparability_degree(f_cusp)}")
    
    steps = resolution_sequence(f_cusp)
    for i, step in enumerate(steps):
        print(f"  Step {i+1}: chart={step.chart}, "
              f"mult {step.multiplicity_before} -> {step.multiplicity_after}, "
              f"insep_deg={step.insep_degree}")
    
    if not steps or steps[-1].multiplicity_after <= 1:
        print(f"  RESOLVED in {len(steps)} steps!")
    
    # Example 2: y^2 = x^5 (higher cusp) over F_3
    p = 3
    f_cusp2 = PolynomialFp(p, 2, [
        Monomial(1, (5, 0)),
        Monomial(p-1, (0, 2))
    ])
    print(f"\n  Higher cusp: x^5 - y^2 = 0 over F_{p}")
    print(f"  Multiplicity at origin: {f_cusp2.multiplicity_at_origin()}")
    
    steps = resolution_sequence(f_cusp2)
    for i, step in enumerate(steps):
        print(f"  Step {i+1}: chart={step.chart}, "
              f"mult {step.multiplicity_before} -> {step.multiplicity_after}, "
              f"insep_deg={step.insep_degree}")
    
    if not steps or steps[-1].multiplicity_after <= 1:
        print(f"  RESOLVED in {len(steps)} steps!")
    
    # Example 3: Inseparable singularity y^3 = x^3 over F_3
    p = 3
    f_insep = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),
        Monomial(p-1, (0, 3))
    ])
    print(f"\n  Inseparable: x^3 - y^3 = 0 over F_{p}")
    print(f"  Multiplicity at origin: {f_insep.multiplicity_at_origin()}")
    print(f"  Inseparability degree: {compute_inseparability_degree(f_insep)}")
    print(f"  Note: This factors as (x-y)^3 in characteristic 3!")
    
    steps = resolution_sequence(f_insep)
    for i, step in enumerate(steps):
        print(f"  Step {i+1}: chart={step.chart}, "
              f"mult {step.multiplicity_before} -> {step.multiplicity_after}, "
              f"insep_deg={step.insep_degree}")


def demo_frobenius_image():
    """Demonstrate the Frobenius endomorphism on polynomials."""
    print("\n" + "=" * 60)
    print("DEMO 5: Frobenius Endomorphism")
    print("=" * 60)
    
    p = 3
    # f = x + y 
    f = PolynomialFp(p, 2, [
        Monomial(1, (1, 0)),
        Monomial(1, (0, 1))
    ])
    
    print(f"\n  f = x + y over F_{p}")
    print(f"  Insep. degree: {compute_inseparability_degree(f)}")
    
    # Apply Frobenius: f(x^p, y^p) = x^p + y^p = (x+y)^p
    f_frob = frobenius_image(f)
    print(f"\n  Frobenius(f) = f(x^3, y^3) = x^3 + y^3")
    print(f"  Terms: {f_frob.terms}")
    print(f"  Insep. degree: {compute_inseparability_degree(f_frob)}")
    
    # Apply Frobenius again
    f_frob2 = frobenius_image(f_frob)
    print(f"\n  Frobenius^2(f) = x^9 + y^9")
    print(f"  Terms: {f_frob2.terms}")
    print(f"  Insep. degree: {compute_inseparability_degree(f_frob2)}")
    
    # Show derivative vanishing
    print(f"\n  Derivatives of Frobenius(f) = x^3 + y^3:")
    for i in range(2):
        deriv = f_frob.formal_derivative(i)
        print(f"    d/dx_{i} = {deriv.terms if deriv.terms else '0'}")


def demo_newton_polygon():
    """Demonstrate Newton polygon computation."""
    print("\n" + "=" * 60)
    print("DEMO 6: Newton Polygons")
    print("=" * 60)
    
    p = 5
    
    # f = x^3 + x*y + y^4
    f = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),
        Monomial(1, (1, 1)),
        Monomial(1, (0, 4))
    ])
    
    print(f"\n  f = x^3 + xy + y^4 over F_{p}")
    print(f"  Support points: {[(m.exponents[0], m.exponents[1]) for m in f.terms]}")
    hull = newton_polygon_2d(f)
    print(f"  Newton polygon vertices: {hull}")
    print(f"  Multiplicity: {f.multiplicity_at_origin()}")
    
    # Cusp
    f_cusp = PolynomialFp(p, 2, [
        Monomial(1, (3, 0)),
        Monomial(p-1, (0, 2))
    ])
    print(f"\n  f = x^3 - y^2 over F_{p}")
    hull = newton_polygon_2d(f_cusp)
    print(f"  Newton polygon vertices: {hull}")


def demo_conjecture_test():
    """Test the resolution complexity conjecture.
    
    Conjecture: For degree d polynomials in dim variables over F_p,
    resolution takes at most d^dim steps.
    """
    print("\n" + "=" * 60)
    print("DEMO 7: Testing Resolution Complexity Conjecture")
    print("=" * 60)
    
    results = []
    
    for p in [2, 3, 5]:
        for dim in [2]:
            for max_deg in [3, 4, 5, 6]:
                for seed in range(5):
                    f = random_polynomial_fp(p, dim, max_deg, seed=seed*100+p*10+max_deg)
                    mult = f.multiplicity_at_origin()
                    if mult <= 1:
                        continue
                    
                    steps = resolution_sequence(f, max_steps=max_deg**dim + 10)
                    n_steps = len(steps)
                    bound = max_deg ** dim
                    
                    resolved = (not steps) or steps[-1].multiplicity_after <= 1
                    within_bound = n_steps <= bound
                    
                    results.append({
                        'p': p, 'dim': dim, 'deg': max_deg,
                        'mult': mult, 'steps': n_steps,
                        'bound': bound, 'resolved': resolved,
                        'within_bound': within_bound
                    })
    
    print(f"\n  {'p':>3} {'dim':>4} {'deg':>4} {'mult':>5} {'steps':>6} {'bound':>6} {'resolved':>9} {'in_bound':>9}")
    print(f"  {'-'*3} {'-'*4} {'-'*4} {'-'*5} {'-'*6} {'-'*6} {'-'*9} {'-'*9}")
    
    for r in results:
        print(f"  {r['p']:>3} {r['dim']:>4} {r['deg']:>4} {r['mult']:>5} "
              f"{r['steps']:>6} {r['bound']:>6} {str(r['resolved']):>9} {str(r['within_bound']):>9}")
    
    # Summary
    total = len(results)
    resolved_count = sum(1 for r in results if r['resolved'])
    bound_count = sum(1 for r in results if r['within_bound'])
    
    print(f"\n  Summary: {resolved_count}/{total} resolved, "
          f"{bound_count}/{total} within d^dim bound")
    
    counterexamples = [r for r in results if not r['within_bound'] and r['resolved']]
    if counterexamples:
        print(f"  CONJECTURE VIOLATED: {len(counterexamples)} counterexamples found!")
    else:
        print(f"  Conjecture holds for all tested cases.")


if __name__ == "__main__":
    demo_derivative_vanishing()
    demo_inseparability_degree()
    demo_freshman_dream()
    demo_blowup_resolution()
    demo_frobenius_image()
    demo_newton_polygon()
    demo_conjecture_test()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization of Newton polygons and resolution sequences."""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def plot_newton_polygon():
    """Plot Newton polygons for key singularity types."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("Newton Polygons of Singularities in Characteristic p", fontsize=16)
    
    singularities = [
        ("Ordinary double point\ny² = x²", [(2, 0), (0, 2)], "char 0,p"),
        ("Cusp\ny² = x³", [(3, 0), (0, 2)], "char 0,p"),
        ("Inseparable (p=3)\ny³ = x³", [(3, 0), (0, 3)], "char 3"),
        ("Higher cusp\ny² = x⁵", [(5, 0), (0, 2)], "char 0,p"),
        ("Frobenius cusp (p=2)\ny² = x⁴", [(4, 0), (0, 2)], "char 2"),
        ("Deep inseparable (p=3)\ny⁹ = x⁹", [(9, 0), (0, 9)], "char 3"),
    ]
    
    for idx, (title, points, char_info) in enumerate(singularities):
        ax = axes[idx // 3][idx % 3]
        
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        
        max_coord = max(max(xs), max(ys)) + 1
        
        # Draw grid
        for i in range(max_coord + 1):
            ax.axhline(y=i, color='lightgray', linewidth=0.5)
            ax.axvline(x=i, color='lightgray', linewidth=0.5)
        
        # Draw Newton polygon (convex hull + axes)
        sorted_pts = sorted(points, key=lambda p: p[0])
        
        # Fill the region above/right of the Newton polygon
        polygon_pts = [(0, max_coord)]
        polygon_pts.append((0, sorted_pts[0][1]))
        polygon_pts.extend(sorted_pts)
        polygon_pts.append((sorted_pts[-1][0], 0))
        polygon_pts.append((max_coord, 0))
        polygon_pts.append((max_coord, max_coord))
        
        polygon = plt.Polygon(polygon_pts, alpha=0.15, color='blue')
        ax.add_patch(polygon)
        
        # Draw Newton polygon boundary
        boundary_x = [0, sorted_pts[0][0]] + xs + [sorted_pts[-1][0], max_coord]
        boundary_y = [sorted_pts[0][1], sorted_pts[0][1]] + ys + [0, 0]
        
        # Just the sloped part
        ax.plot([p[0] for p in sorted_pts], [p[1] for p in sorted_pts],
                'b-', linewidth=2)
        # Horizontal and vertical extensions
        ax.plot([0, sorted_pts[0][0]], [sorted_pts[0][1], sorted_pts[0][1]],
                'b--', linewidth=1)
        ax.plot([sorted_pts[-1][0], sorted_pts[-1][0]], [sorted_pts[-1][1], 0],
                'b--', linewidth=1)
        
        # Plot support points
        ax.scatter(xs, ys, color='red', s=100, zorder=5)
        
        # Labels
        for x, y in points:
            ax.annotate(f"({x},{y})", (x, y), textcoords="offset points",
                       xytext=(5, 5), fontsize=8)
        
        ax.set_xlim(-0.5, max_coord + 0.5)
        ax.set_ylim(-0.5, max_coord + 0.5)
        ax.set_xlabel("x-exponent")
        ax.set_ylabel("y-exponent")
        ax.set_title(f"{title}\n({char_info})", fontsize=10)
        ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig("newton_polygons.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved newton_polygons.png")


def plot_multiplicity_descent():
    """Plot multiplicity descent during blowup resolution."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Multiplicity Descent Under Blowup", fontsize=14)
    
    # Characteristic 0 behavior
    ax = axes[0]
    steps_char0 = [5, 4, 3, 2, 1]
    ax.plot(range(len(steps_char0)), steps_char0, 'go-', linewidth=2, markersize=8)
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='Resolution threshold')
    ax.set_xlabel("Blowup step")
    ax.set_ylabel("Multiplicity")
    ax.set_title("Characteristic 0\n(monotone descent)")
    ax.set_ylim(0, 6)
    ax.legend()
    
    # Characteristic p, dimension 2 (resolved)
    ax = axes[1]
    steps_dim2 = [4, 3, 3, 2, 1]
    ax.plot(range(len(steps_dim2)), steps_dim2, 'bo-', linewidth=2, markersize=8)
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.5)
    ax.fill_between([1, 2], [0, 0], [6, 6], alpha=0.1, color='red',
                    label='Frobenius stall')
    ax.set_xlabel("Blowup step")
    ax.set_ylabel("Multiplicity")
    ax.set_title("Char p, dim 2\n(stall then descent)")
    ax.set_ylim(0, 6)
    ax.legend()
    
    # Characteristic p, open case
    ax = axes[2]
    steps_open = [5, 4, 4, 4, 3, 3, 3, 2, 2]
    ax.plot(range(len(steps_open)), steps_open, 'ro-', linewidth=2, markersize=8)
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.5)
    ax.fill_between([1, 3], [0, 0], [6, 6], alpha=0.1, color='red')
    ax.fill_between([4, 6], [0, 0], [6, 6], alpha=0.1, color='red',
                    label='Frobenius stalls')
    ax.set_xlabel("Blowup step")
    ax.set_ylabel("Multiplicity")
    ax.set_title("Char p, dim ≥ 4\n(repeated stalls, open!)")
    ax.set_ylim(0, 6)
    ax.legend()
    
    plt.tight_layout()
    plt.savefig("multiplicity_descent.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved multiplicity_descent.png")


def plot_inseparability_landscape():
    """Heatmap of inseparability degree for polynomials x^a + y^b over F_p."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Inseparability Degree of x^a + y^b over F_p", fontsize=14)
    
    for idx, p in enumerate([2, 3, 5]):
        ax = axes[idx]
        max_exp = 16
        
        data = np.zeros((max_exp, max_exp))
        for a in range(1, max_exp + 1):
            for b in range(1, max_exp + 1):
                # Inseparability degree = min of p-adic valuations of a and b
                k = 0
                while a % (p ** (k+1)) == 0 and b % (p ** (k+1)) == 0:
                    k += 1
                data[b-1, a-1] = k
        
        im = ax.imshow(data, origin='lower', cmap='YlOrRd', aspect='equal',
                       extent=[0.5, max_exp+0.5, 0.5, max_exp+0.5])
        ax.set_xlabel("a (x-exponent)")
        ax.set_ylabel("b (y-exponent)")
        ax.set_title(f"F_{p}")
        plt.colorbar(im, ax=ax, label="Insep. degree k")
    
    plt.tight_layout()
    plt.savefig("inseparability_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved inseparability_landscape.png")


if __name__ == "__main__":
    plot_newton_polygon()
    plot_multiplicity_descent()
    plot_inseparability_landscape()
    print("\nAll visualizations complete.")
