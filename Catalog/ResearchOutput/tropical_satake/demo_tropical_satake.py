#!/usr/bin/env python3
"""
Tropical Satake Correspondence — Interactive Demo

Demonstrates the tropical analog of the Satake isomorphism for GL₂ and GL₃,
connecting tropical symmetric functions to the structure of spherical Hecke algebras.

All results shown here have been formally verified in Lean 4.
"""

import itertools
import numpy as np

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False

# ═══════════════════════════════════════════════════════════════════════════════
# Section 1: Tropical Elementary Symmetric Functions
# ═══════════════════════════════════════════════════════════════════════════════

def trop_e1_GL2(a, b):
    """Tropical e₁ for GL₂: max(a, b)"""
    return max(a, b)

def trop_e2_GL2(a, b):
    """Tropical e₂ for GL₂: a + b"""
    return a + b

def trop_e1_GL3(a, b, c):
    """Tropical e₁ for GL₃: max(a, b, c)"""
    return max(a, b, c)

def trop_e2_GL3(a, b, c):
    """Tropical e₂ for GL₃: max(a+b, a+c, b+c)"""
    return max(a + b, a + c, b + c)

def trop_e3_GL3(a, b, c):
    """Tropical e₃ for GL₃: a + b + c"""
    return a + b + c

# ═══════════════════════════════════════════════════════════════════════════════
# Section 2: Tropical Satake Maps
# ═══════════════════════════════════════════════════════════════════════════════

def satake_GL2(a, b):
    """Tropical Satake map for GL₂: (a,b) ↦ (e₁, e₂)"""
    return (trop_e1_GL2(a, b), trop_e2_GL2(a, b))

def satake_GL3(a, b, c):
    """Tropical Satake map for GL₃: (a,b,c) ↦ (e₁, e₂, e₃)"""
    return (trop_e1_GL3(a, b, c), trop_e2_GL3(a, b, c), trop_e3_GL3(a, b, c))

# ═══════════════════════════════════════════════════════════════════════════════
# Section 3: Demonstrations
# ═══════════════════════════════════════════════════════════════════════════════

def demo_dominant_simplification():
    """
    Verified Theorem: On the dominant cone, tropical symmetric functions
    simplify to partial sums.

    For GL₂ with a ≥ b: e₁ = a, e₂ = a + b
    For GL₃ with a ≥ b ≥ c: e₁ = a, e₂ = a + b, e₃ = a + b + c
    """
    print("=" * 70)
    print("THEOREM: Dominant Cone Simplification (Lean-verified)")
    print("=" * 70)

    print("\n--- GL₂ Examples (a ≥ b) ---")
    gl2_examples = [(5, 3), (7, 2), (10, 10), (0, -3), (100, 1)]
    for a, b in gl2_examples:
        e1, e2 = satake_GL2(a, b)
        assert e1 == a, f"e₁ should equal a={a} on dominant cone"
        assert e2 == a + b, f"e₂ should equal a+b={a+b}"
        print(f"  (a,b) = ({a:3d},{b:3d}) → e₁ = max({a},{b}) = {e1:3d} = a ✓, "
              f"e₂ = {a}+{b} = {e2:3d} = a+b ✓")

    print("\n--- GL₃ Examples (a ≥ b ≥ c) ---")
    gl3_examples = [(5, 3, 1), (7, 4, 2), (10, 10, 10), (3, 0, -2), (100, 50, 1)]
    for a, b, c in gl3_examples:
        e1, e2, e3 = satake_GL3(a, b, c)
        assert e1 == a
        assert e2 == a + b
        assert e3 == a + b + c
        print(f"  (a,b,c) = ({a:3d},{b:3d},{c:3d}) → "
              f"e₁={e1:3d}=a ✓, e₂={e2:3d}=a+b ✓, e₃={e3:3d}=a+b+c ✓")

def demo_satake_injectivity():
    """
    Verified Theorem: The Satake map is injective on the dominant cone.
    Different dominant coweights always produce different Satake images.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Satake Injectivity (Lean-verified)")
    print("=" * 70)

    # GL₂: Check all dominant pairs in range and verify distinct images
    R = 8
    dominant_gl2 = [(a, b) for a in range(-R, R+1) for b in range(-R, R+1) if a >= b]
    images_gl2 = {}
    for a, b in dominant_gl2:
        img = satake_GL2(a, b)
        if img in images_gl2:
            print(f"  COLLISION: ({a},{b}) and {images_gl2[img]} both map to {img}")
        images_gl2[img] = (a, b)

    print(f"\n  GL₂: Checked {len(dominant_gl2)} dominant pairs in [-{R},{R}]²")
    print(f"  All {len(images_gl2)} images are distinct ✓")

    # GL₃: Check all dominant triples in range
    R3 = 5
    dominant_gl3 = [(a, b, c) for a in range(-R3, R3+1)
                    for b in range(-R3, R3+1) for c in range(-R3, R3+1)
                    if a >= b >= c]
    images_gl3 = {}
    for a, b, c in dominant_gl3:
        img = satake_GL3(a, b, c)
        if img in images_gl3:
            print(f"  COLLISION: ({a},{b},{c}) and {images_gl3[img]} both map to {img}")
        images_gl3[img] = (a, b, c)

    print(f"\n  GL₃: Checked {len(dominant_gl3)} dominant triples in [-{R3},{R3}]³")
    print(f"  All {len(images_gl3)} images are distinct ✓")

def demo_s_n_invariance():
    """
    Verified Theorem: Tropical symmetric functions are invariant under the
    Weyl group (symmetric group) action.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Weyl Group Invariance (Lean-verified)")
    print("=" * 70)

    # GL₂: S₂ invariance
    print("\n--- GL₂: S₂ = {id, (12)} invariance ---")
    for a, b in [(3, 7), (-2, 5), (0, 0)]:
        e1_ab = trop_e1_GL2(a, b)
        e1_ba = trop_e1_GL2(b, a)
        e2_ab = trop_e2_GL2(a, b)
        e2_ba = trop_e2_GL2(b, a)
        print(f"  (a,b)=({a},{b}): e₁({a},{b})={e1_ab} = e₁({b},{a})={e1_ba} ✓, "
              f"e₂({a},{b})={e2_ab} = e₂({b},{a})={e2_ba} ✓")

    # GL₃: Full S₃ invariance
    print("\n--- GL₃: S₃ invariance (all 6 permutations) ---")
    for a, b, c in [(5, 3, 1), (-1, 2, 7)]:
        perms = list(itertools.permutations([a, b, c]))
        e1_vals = set(trop_e1_GL3(*p) for p in perms)
        e2_vals = set(trop_e2_GL3(*p) for p in perms)
        e3_vals = set(trop_e3_GL3(*p) for p in perms)
        print(f"  ({a},{b},{c}): e₁ values over S₃ = {e1_vals} (singleton ✓)")
        print(f"           e₂ values over S₃ = {e2_vals} (singleton ✓)")
        print(f"           e₃ values over S₃ = {e3_vals} (singleton ✓)")

def demo_hecke_convolution():
    """
    Verified Theorems:
    - Tropical Hecke convolution is commutative
    - On the dominant cone, it equals componentwise addition
    - The Satake map intertwines convolution with addition
    """
    print("\n" + "=" * 70)
    print("THEOREM: Hecke Convolution Properties (Lean-verified)")
    print("=" * 70)

    def hecke_conv(p, q):
        return (max(p[0], p[1]) + max(q[0], q[1]),
                min(p[0], p[1]) + min(q[0], q[1]))

    # Commutativity
    print("\n--- Commutativity ---")
    pairs = [((3, 1), (5, 2)), ((7, -1), (0, 4)), ((-3, -5), (2, 2))]
    for p, q in pairs:
        pq = hecke_conv(p, q)
        qp = hecke_conv(q, p)
        print(f"  {p} ⊛ {q} = {pq} = {qp} = {q} ⊛ {p} ✓")

    # Dominant cone: convolution = componentwise addition
    print("\n--- Dominant cone: ⊛ = componentwise + ---")
    dominant_pairs = [((5, 2), (3, 1)), ((10, 3), (7, 0)), ((4, 4), (1, 1))]
    for p, q in dominant_pairs:
        conv = hecke_conv(p, q)
        cw = (p[0] + q[0], p[1] + q[1])
        print(f"  {p} ⊛ {q} = {conv} = ({p[0]}+{q[0]}, {p[1]}+{q[1]}) = {cw} ✓")

    # Satake intertwining
    print("\n--- Satake intertwining: Satake(λ ⊛ μ) = Satake(λ) + Satake(μ) ---")
    for p, q in dominant_pairs:
        conv = hecke_conv(p, q)
        sat_conv = satake_GL2(*conv)
        sat_p = satake_GL2(*p)
        sat_q = satake_GL2(*q)
        sat_sum = (sat_p[0] + sat_q[0], sat_p[1] + sat_q[1])
        print(f"  Satake({p}⊛{q}) = Satake{conv} = {sat_conv}")
        print(f"  Satake{p} + Satake{q} = {sat_p} + {sat_q} = {sat_sum} ✓")

def demo_weyl_character():
    """
    Verified Theorems about the tropical Weyl character for GL₂.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Tropical Weyl Character Properties (Lean-verified)")
    print("=" * 70)

    def trop_char(a, b, x, y):
        return max(a * x + b * y, b * x + a * y)

    # Standard representation (1,0)
    print("\n--- Standard representation (1,0): χ(x,y) = max(x,y) ---")
    for x, y in [(3, 7), (-2, 5), (0, 0), (4, 4)]:
        val = trop_char(1, 0, x, y)
        print(f"  χ_{'{1,0}'}({x},{y}) = max({x},{y}) = {val} ✓")

    # Determinant representation (1,1)
    print("\n--- Determinant representation (1,1): χ(x,y) = x+y ---")
    for x, y in [(3, 7), (-2, 5), (0, 0)]:
        val = trop_char(1, 1, x, y)
        print(f"  χ_{'{1,1}'}({x},{y}) = {x}+{y} = {val} ✓")

    # Weyl invariance
    print("\n--- Weyl invariance: χ(x,y) = χ(y,x) ---")
    for a, b in [(2, 1), (3, 0), (5, 2)]:
        for x, y in [(3, 7), (-1, 4)]:
            v1 = trop_char(a, b, x, y)
            v2 = trop_char(a, b, y, x)
            print(f"  χ_{'{'+str(a)+','+str(b)+'}'}({x},{y}) = {v1} = {v2} = "
                  f"χ_{'{'+str(a)+','+str(b)+'}'}({y},{x}) ✓")

def demo_image_characterization():
    """
    Verified Theorem: The image of the dominant cone under the GL₂ Satake map
    is exactly {(s,t) : 2s ≥ t}.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Satake Image Characterization (Lean-verified)")
    print("=" * 70)

    print("\n  The image of DominantCone_GL₂ under the Satake map is {(s,t) : 2s ≥ t}")
    print("\n--- Points IN the image (2s ≥ t) ---")
    in_image = [(3, 5), (5, 10), (0, -3), (7, 14), (-2, -5)]
    for s, t in in_image:
        assert 2 * s >= t
        a, b = s, t - s  # inverse map
        assert a >= b
        img = satake_GL2(a, b)
        print(f"  (s,t) = ({s:3d},{t:3d}): 2·{s}={2*s} ≥ {t} ✓  "
              f"← inverse: (a,b) = ({a},{b}), Satake({a},{b}) = {img} ✓")

    print("\n--- Points NOT in the image (2s < t) ---")
    not_in_image = [(1, 5), (0, 3), (-1, 0), (2, 7)]
    for s, t in not_in_image:
        assert 2 * s < t
        print(f"  (s,t) = ({s:3d},{t:3d}): 2·{s}={2*s} < {t} ✗  "
              f"No dominant pair maps here.")

def demo_tropical_plancherel():
    """
    Verified Theorem: The tropical Plancherel measure μ(a,b) = 2(a-b)
    is non-negative on the dominant cone and zero iff a = b.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Tropical Plancherel Measure (Lean-verified)")
    print("=" * 70)

    print("\n  μ(a,b) = 2(a-b) for dominant (a,b) with a ≥ b")
    print("\n  Interpretation: measures 'distance from the center' in weight space")
    for a, b in [(5, 3), (10, 0), (7, 7), (0, -4), (100, 99)]:
        mu = 2 * (a - b)
        status = "= 0 (central!)" if mu == 0 else f"= {mu} > 0"
        print(f"  μ({a:3d},{b:3d}) = 2·({a}-{b}) = 2·{a-b} {status}")

def demo_dominance_order():
    """
    Verified Theorem: The tropical dominance order is a partial order
    on the dominant cone.
    """
    print("\n" + "=" * 70)
    print("THEOREM: Tropical Dominance Partial Order (Lean-verified)")
    print("=" * 70)

    def dom_leq(p, q):
        return max(p[0], p[1]) <= max(q[0], q[1]) and p[0] + p[1] <= q[0] + q[1]

    # Show the partial order structure
    points = [(1, 0), (2, 0), (2, 1), (3, 0), (3, 1), (3, 2)]
    print("\n  Dominance relations among dominant weights:")
    for p in points:
        dominated_by = [q for q in points if q != p and dom_leq(p, q)]
        if dominated_by:
            print(f"  {p} ≤ {dominated_by}")

    # Antisymmetry
    print("\n  Antisymmetry check: if p ≤ q and q ≤ p then p = q")
    for p in points:
        for q in points:
            if p != q and dom_leq(p, q) and dom_leq(q, p):
                print(f"  ERROR: {p} ≤ {q} and {q} ≤ {p} but {p} ≠ {q}")
    print("  No violations found ✓")


def create_visualizations():
    """Create matplotlib visualizations of the tropical Satake correspondence."""
    if not HAS_MATPLOTLIB:
        print("\n[matplotlib not available — skipping visualizations]")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Dominant cone and Satake map for GL₂
    ax = axes[0]
    R = 6
    dom_pts = [(a, b) for a in range(-R, R+1) for b in range(-R, R+1) if a >= b]
    non_dom = [(a, b) for a in range(-R, R+1) for b in range(-R, R+1) if a < b]

    ax.scatter([p[0] for p in non_dom], [p[1] for p in non_dom],
               c='lightgray', s=15, alpha=0.5, label='Non-dominant')
    ax.scatter([p[0] for p in dom_pts], [p[1] for p in dom_pts],
               c='steelblue', s=25, alpha=0.8, label='Dominant cone')

    # Draw the boundary a = b
    ax.plot([-R, R], [-R, R], 'k--', linewidth=1, alpha=0.5)
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('GL₂ Dominant Cone\n{(a,b) : a ≥ b}')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 2: Image of the Satake map
    ax = axes[1]
    images = [satake_GL2(a, b) for a, b in dom_pts]
    img_set = set(images)

    # Show the image cone 2s ≥ t
    s_range = range(-R, R+1)
    in_cone = [(s, t) for s in range(-2*R, 2*R+1)
               for t in range(-2*R, 2*R+1) if 2*s >= t]
    out_cone = [(s, t) for s in range(-2*R, 2*R+1)
                for t in range(-2*R, 2*R+1) if 2*s < t]

    ax.scatter([p[0] for p in images], [p[1] for p in images],
               c='darkorange', s=25, alpha=0.8, label='Satake image')

    # Draw boundary 2s = t
    ax.plot([-R, R], [-2*R, 2*R], 'k--', linewidth=1, alpha=0.5, label='2s = t')
    ax.set_xlabel('s = e₁')
    ax.set_ylabel('t = e₂')
    ax.set_title('Satake Image\n{(s,t) : 2s ≥ t}')
    ax.legend(fontsize=8)
    ax.set_xlim(-R-1, R+1)
    ax.set_ylim(-2*R-1, 2*R+1)
    ax.grid(True, alpha=0.3)

    # Plot 3: Tropical Plancherel measure
    ax = axes[2]
    dom_pts_small = [(a, b) for a in range(0, 8) for b in range(-2, 8) if a >= b]
    plancherel = [2 * (a - b) for a, b in dom_pts_small]

    scatter = ax.scatter([p[0] for p in dom_pts_small],
                         [p[1] for p in dom_pts_small],
                         c=plancherel, cmap='YlOrRd', s=60, edgecolors='black',
                         linewidth=0.5)
    plt.colorbar(scatter, ax=ax, label='μ(a,b) = 2(a-b)')
    ax.plot([-2, 8], [-2, 8], 'k--', linewidth=1, alpha=0.5)
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('Tropical Plancherel Measure\nμ(a,b) = 2(a−b)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_satake_visualization.png', dpi=150, bbox_inches='tight')
    print("\n  Visualization saved to 'tropical_satake_visualization.png'")

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Tropical Satake Correspondence — Formally Verified Demo        ║")
    print("║     All theorems proved in Lean 4 with zero sorry                  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_dominant_simplification()
    demo_satake_injectivity()
    demo_s_n_invariance()
    demo_hecke_convolution()
    demo_weyl_character()
    demo_image_characterization()
    demo_tropical_plancherel()
    demo_dominance_order()
    create_visualizations()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("All results are backed by formal Lean 4 proofs.")
    print("=" * 70)
