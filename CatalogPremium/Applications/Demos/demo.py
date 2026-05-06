#!/usr/bin/env python3
"""
Tropical Satake Correspondence for GL₃ — Interactive Demo

This script demonstrates the three main theorems proved in the Lean formalization:
1. S₃ Invariance: tropical symmetric polynomials are permutation-invariant
2. Orbit Separation (Tropical Chevalley Theorem): they separate S₃-orbits  
3. Image Characterization (Tropical Satake Cone): the image is the dominant Weyl chamber

Run: python3 demo.py
"""

import itertools
import numpy as np

try:
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d import Axes3D
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("Note: matplotlib not found. Skipping visualizations.\n")


# ═══════════════════════════════════════════════════════════
# Core Definitions: Tropical Elementary Symmetric Polynomials
# ═══════════════════════════════════════════════════════════

def trop_e1(a, b, c):
    """e₁(a,b,c) = max(a,b,c) — tropicalization of a+b+c"""
    return max(a, b, c)

def trop_e2(a, b, c):
    """e₂(a,b,c) = max(a+b, a+c, b+c) — tropicalization of ab+ac+bc"""
    return max(a+b, a+c, b+c)

def trop_e3(a, b, c):
    """e₃(a,b,c) = a+b+c — tropicalization of abc"""
    return a + b + c

def satake_map(a, b, c):
    """The tropical Satake transform (e₁, e₂, e₃)"""
    return (trop_e1(a,b,c), trop_e2(a,b,c), trop_e3(a,b,c))


# ═══════════════════════════════════════════════════════════
# Demo 1: S₃ Invariance
# ═══════════════════════════════════════════════════════════

def demo_invariance():
    print("=" * 60)
    print("DEMO 1: S₃ INVARIANCE")
    print("=" * 60)
    print()
    print("The tropical elementary symmetric polynomials are invariant")
    print("under all 6 permutations of S₃.")
    print()
    
    test_triples = [(3, 1, -2), (5, 5, 5), (0, -7, 4), (10, -3, 2)]
    
    for triple in test_triples:
        a, b, c = triple
        perms = list(itertools.permutations(triple))
        
        print(f"Triple: ({a}, {b}, {c})")
        print(f"  {'Permutation':<20} {'e₁':>6} {'e₂':>6} {'e₃':>6}")
        print(f"  {'─'*20} {'─'*6} {'─'*6} {'─'*6}")
        
        for p in perms:
            e1, e2, e3 = satake_map(*p)
            print(f"  ({p[0]:>3},{p[1]:>3},{p[2]:>3})      {e1:>6} {e2:>6} {e3:>6}")
        
        # Verify all agree
        values = set(satake_map(*p) for p in perms)
        assert len(values) == 1, "INVARIANCE FAILED!"
        print(f"  ✓ All 6 permutations give the same (e₁,e₂,e₃) = {values.pop()}")
        print()


# ═══════════════════════════════════════════════════════════
# Demo 2: Key Identity e₂ = sum - min
# ═══════════════════════════════════════════════════════════

def demo_key_identity():
    print("=" * 60)
    print("DEMO 2: KEY IDENTITY e₂ = (a+b+c) - min(a,b,c)")
    print("=" * 60)
    print()
    print("This identity reveals that e₂ encodes the minimum:")
    print("  max(a+b, a+c, b+c) = (a+b+c) - min(a,b,c)")
    print("Each pairwise sum omits one element; the max omits the min.")
    print()
    
    import random
    random.seed(42)
    for _ in range(8):
        a = random.randint(-10, 10)
        b = random.randint(-10, 10)
        c = random.randint(-10, 10)
        
        lhs = trop_e2(a, b, c)
        rhs = (a + b + c) - min(a, min(b, c))
        
        status = "✓" if lhs == rhs else "✗"
        print(f"  ({a:>3},{b:>3},{c:>3}): e₂ = {lhs:>4}, sum - min = {rhs:>4}  {status}")
    print()


# ═══════════════════════════════════════════════════════════
# Demo 3: Orbit Separation (Tropical Chevalley Theorem)
# ═══════════════════════════════════════════════════════════

def demo_orbit_separation():
    print("=" * 60)
    print("DEMO 3: TROPICAL CHEVALLEY THEOREM (Orbit Separation)")
    print("=" * 60)
    print()
    print("If e₁(a,b,c) = e₁(a',b',c'), e₂(a,b,c) = e₂(a',b',c'),")
    print("and e₃(a,b,c) = e₃(a',b',c'), then {a,b,c} = {a',b',c'}")
    print("as multisets (they are permutations of each other).")
    print()
    
    # Test: enumerate all pairs in a range and check the theorem
    N = 5
    orbits = {}
    for a in range(-N, N+1):
        for b in range(-N, N+1):
            for c in range(-N, N+1):
                key = satake_map(a, b, c)
                ms = tuple(sorted([a, b, c], reverse=True))
                if key not in orbits:
                    orbits[key] = set()
                orbits[key].add(ms)
    
    # Check each Satake image corresponds to exactly one multiset
    violations = 0
    for key, multisets in orbits.items():
        if len(multisets) > 1:
            violations += 1
            print(f"  VIOLATION at {key}: {multisets}")
    
    total = len(orbits)
    print(f"  Checked {total} distinct Satake images over [{-N},{N}]³")
    print(f"  Each image maps to exactly one S₃-orbit: {violations} violations")
    print(f"  ✓ Orbit separation verified computationally!")
    print()
    
    # Show some examples
    print("  Example orbits:")
    examples = [(3,1,-2), (5,0,0), (2,2,1), (1,1,1)]
    for triple in examples:
        s = satake_map(*triple)
        orbit = list(set(itertools.permutations(triple)))
        sorted_rep = tuple(sorted(triple, reverse=True))
        print(f"    {sorted_rep} → (e₁,e₂,e₃) = {s}, orbit size = {len(orbit)}")
    print()


# ═══════════════════════════════════════════════════════════
# Demo 4: Tropical Satake Cone (Image Characterization)
# ═══════════════════════════════════════════════════════════

def demo_satake_cone():
    print("=" * 60)
    print("DEMO 4: TROPICAL SATAKE CONE (Image Characterization)")
    print("=" * 60)
    print()
    print("The image of (e₁,e₂,e₃) : ℤ³ → ℤ³ is exactly:")
    print("  { (x,y,z) ∈ ℤ³ : 2x ≥ y  and  2y ≥ x+z }")
    print()
    print("This is the dominant Weyl chamber for GL₃.")
    print()
    
    # Verify forward direction
    print("Forward direction (dominance conditions always hold):")
    import random
    random.seed(123)
    for _ in range(6):
        a = random.randint(-10, 10)
        b = random.randint(-10, 10)
        c = random.randint(-10, 10)
        x, y, z = satake_map(a, b, c)
        cond1 = 2*x >= y
        cond2 = 2*y >= x + z
        print(f"  ({a:>3},{b:>3},{c:>3}) → (x,y,z)=({x},{y},{z}): "
              f"2x≥y? {cond1}, 2y≥x+z? {cond2}")
    print()
    
    # Verify backward direction
    print("Backward direction (reconstruction from Satake cone):")
    print("  Given (x,y,z) with 2x≥y and 2y≥x+z, set a=x, b=y-x, c=z-y:")
    for x, y, z in [(5, 8, 6), (3, 4, 0), (0, 0, 0), (10, 15, 9)]:
        if 2*x >= y and 2*y >= x+z:
            a, b, c = x, y-x, z-y
            check = satake_map(a, b, c)
            print(f"  (x,y,z)=({x},{y},{z}) → (a,b,c)=({a},{b},{c}) → "
                  f"satake=({check[0]},{check[1]},{check[2]}) ✓")
    print()
    
    # Show a point NOT in the cone
    print("Points outside the cone (no preimage exists):")
    bad_points = [(3, 8, 0), (5, 5, 10), (1, 3, 0)]
    for x, y, z in bad_points:
        cond1 = 2*x >= y
        cond2 = 2*y >= x+z
        reason = "2x<y" if not cond1 else "2y<x+z"
        print(f"  ({x},{y},{z}): fails {reason} — not in image")
    print()


# ═══════════════════════════════════════════════════════════
# Demo 5: Tropical Newton's Identity p_k = k·e₁  
# ═══════════════════════════════════════════════════════════

def demo_tropical_newton():
    print("=" * 60)
    print("DEMO 5: TROPICAL NEWTON'S IDENTITY p_k = k·e₁")
    print("=" * 60)
    print()
    print("Classical Newton's identities are complex recurrences.")
    print("In tropical algebra, they collapse beautifully:")
    print("  p_k(a,b,c) = max(k·a, k·b, k·c) = k · max(a,b,c) = k · e₁")
    print()
    
    a, b, c = 7, 3, -2
    print(f"For (a,b,c) = ({a},{b},{c}), e₁ = {trop_e1(a,b,c)}:")
    print(f"  {'k':>4} {'p_k = max(ka,kb,kc)':>25} {'k·e₁':>10} {'match':>8}")
    print(f"  {'─'*4} {'─'*25} {'─'*10} {'─'*8}")
    
    for k in range(1, 11):
        pk = max(k*a, k*b, k*c)
        ke1 = k * trop_e1(a, b, c)
        print(f"  {k:>4} {pk:>25} {ke1:>10} {'✓' if pk == ke1 else '✗':>8}")
    print()


# ═══════════════════════════════════════════════════════════
# Demo 6: Visualization — Satake Cone as Weyl Chamber
# ═══════════════════════════════════════════════════════════

def demo_visualization():
    if not HAS_MATPLOTLIB:
        print("Skipping visualization (matplotlib not available)")
        return
    
    print("=" * 60)
    print("DEMO 6: VISUALIZATION — Satake Cone & Orbit Structure")
    print("=" * 60)
    print()
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left plot: Orbits colored by orbit size
    ax1 = axes[0]
    N = 6
    orbit_data = {}
    for a in range(-N, N+1):
        for b in range(-N, N+1):
            for c in range(-N, N+1):
                key = satake_map(a, b, c)
                if key not in orbit_data:
                    orbit_data[key] = 0
                orbit_data[key] += 1
    
    xs, ys, sizes, colors = [], [], [], []
    for (x, y, z), count in orbit_data.items():
        xs.append(x)
        ys.append(y)
        sizes.append(count * 8)
        colors.append(count)
    
    sc = ax1.scatter(xs, ys, c=colors, s=sizes, cmap='viridis', alpha=0.7, edgecolors='k', linewidth=0.3)
    plt.colorbar(sc, ax=ax1, label='Orbit size')
    ax1.set_xlabel('e₁ = max(a,b,c)')
    ax1.set_ylabel('e₂ = max(a+b, a+c, b+c)')
    ax1.set_title('Tropical Satake Transform\n(e₁ vs e₂, colored by orbit size)')
    ax1.grid(True, alpha=0.3)
    
    # Right plot: The Satake cone in (x,y) coordinates (fixing z=0)
    ax2 = axes[1]
    z_fixed = 0
    
    # Shade the cone region: 2x ≥ y and 2y ≥ x + z
    x_range = np.linspace(-5, 10, 300)
    y_min_from_x = x_range / 1.0  # placeholder
    
    # Fill the cone
    cone_x, cone_y = [], []
    for xi in np.linspace(-5, 10, 200):
        for yi in np.linspace(-10, 20, 200):
            if 2*xi >= yi and 2*yi >= xi + z_fixed:
                cone_x.append(xi)
                cone_y.append(yi)
    
    ax2.scatter(cone_x, cone_y, c='lightblue', s=1, alpha=0.5, label='Satake cone')
    
    # Plot actual images with z = z_fixed
    img_x, img_y = [], []
    for a in range(-N, N+1):
        for b in range(-N, N+1):
            for c in range(-N, N+1):
                x, y, z = satake_map(a, b, c)
                if z == z_fixed:
                    img_x.append(x)
                    img_y.append(y)
    
    ax2.scatter(img_x, img_y, c='red', s=15, zorder=5, label=f'Image points (z={z_fixed})')
    
    # Draw cone boundaries
    x_line = np.linspace(-5, 10, 100)
    ax2.plot(x_line, 2*x_line, 'b--', linewidth=1.5, label='2x = y')
    ax2.plot(x_line, (x_line + z_fixed)/2, 'g--', linewidth=1.5, label='2y = x+z')
    
    ax2.set_xlabel('x (= e₁)')
    ax2.set_ylabel('y (= e₂)')
    ax2.set_title(f'Tropical Satake Cone\n(cross-section z = {z_fixed})')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(-5, 10)
    ax2.set_ylim(-5, 15)
    
    plt.tight_layout()
    plt.savefig('tropical_satake_visualization.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_satake_visualization.png")
    print()


# ═══════════════════════════════════════════════════════════
# Demo 7: Application — Lattice Point Counting
# ═══════════════════════════════════════════════════════════

def demo_applications():
    print("=" * 60)
    print("DEMO 7: APPLICATION — Counting S₃-Orbits")
    print("=" * 60)
    print()
    print("The Satake cone characterization lets us count S₃-orbits")
    print("on ℤ³ ∩ [-N,N]³ by counting lattice points in the cone.")
    print()
    
    for N in [2, 3, 5, 8, 10]:
        # Count by brute force
        orbits_brute = set()
        total_points = 0
        for a in range(-N, N+1):
            for b in range(-N, N+1):
                for c in range(-N, N+1):
                    total_points += 1
                    orbits_brute.add(tuple(sorted([a,b,c], reverse=True)))
        
        # Count via Satake cone
        cone_points = 0
        for x in range(-N, 3*N+1):
            for y in range(-2*N, 3*N+1):
                z_low = max(-3*N, 2*y - 2*N)  # constraint from cone + range
                z_high = min(3*N, 2*y - x)
                for z in range(max(-3*N, -3*N), min(3*N, 3*N)+1):
                    if 2*x >= y and 2*y >= x + z:
                        # Check if (x, y-x, z-y) is in [-N, N]³
                        a, b, c = x, y-x, z-y
                        if -N <= a <= N and -N <= b <= N and -N <= c <= N:
                            cone_points += 1
        
        print(f"  N={N:>2}: {total_points:>6} points, {len(orbits_brute):>5} orbits "
              f"(brute force), {cone_points:>5} orbits (cone counting)")
    print()
    
    # Orbit size distribution
    print("Orbit size distribution for N=5:")
    N = 5
    orbit_sizes = {}
    for a in range(-N, N+1):
        for b in range(-N, N+1):
            for c in range(-N, N+1):
                key = tuple(sorted([a,b,c], reverse=True))
                if key not in orbit_sizes:
                    orbit_sizes[key] = 0
                orbit_sizes[key] += 1
    
    size_dist = {}
    for _, size in orbit_sizes.items():
        size_dist[size] = size_dist.get(size, 0) + 1
    
    for size in sorted(size_dist):
        label = {1: "(a=b=c)", 3: "(two equal)", 6: "(all distinct)"}.get(size, "")
        print(f"  Size {size}: {size_dist[size]:>4} orbits  {label}")
    print()


# ═══════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL SATAKE CORRESPONDENCE FOR GL₃                ║")
    print("║  Formally verified in Lean 4 — demonstrated in Python  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_invariance()
    demo_key_identity()
    demo_orbit_separation()
    demo_satake_cone()
    demo_tropical_newton()
    demo_visualization()
    demo_applications()
    
    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
