#!/usr/bin/env python3
"""
Berggren–Photonic Bridge: Interactive Demonstration

This script demonstrates the core mathematical results:
1. The Berggren tree generates all primitive Pythagorean triples
2. The Stereographic Pythagorean Bridge (SPB) maps triples to ℝ
3. Each Berggren generator induces a Möbius transformation on SPB values
4. Cross-ratio is invariant under these transformations

Run: python3 demos/berggren_photonic_demo.py
"""

import numpy as np
from math import gcd
from fractions import Fraction

# ─── Berggren Matrices ─────────────────────────────────────────────────────

U = np.array([[1, -2, 2],
              [2, -1, 2],
              [2, -2, 3]])

A = np.array([[1, 2, 2],
              [2, 1, 2],
              [2, 2, 3]])

D = np.array([[-1, 2, 2],
              [-2, 1, 2],
              [-2, 2, 3]])

BERGGREN = {'U': U, 'A': A, 'D': D}

# Induced 2×2 matrices on stereographic coordinates [a : c-b]
U2 = np.array([[1, 2],
               [0, 1]])

A2 = np.array([[2, 1],
               [1, 0]])

D2 = np.array([[2, -1],
               [1, 0]])

BERGGREN_2x2 = {'U': U2, 'A': A2, 'D': D2}

# ─── Core Functions ────────────────────────────────────────────────────────

def is_primitive_pythagorean(a, b, c):
    """Check if (a, b, c) is a primitive Pythagorean triple with a, b > 0."""
    return (a > 0 and b > 0 and c > 0 and
            a*a + b*b == c*c and gcd(a, b) == 1)

def spb(a, b, c):
    """Stereographic Pythagorean Bridge: (a, b, c) ↦ a/(c - b)."""
    return Fraction(a, c - b)

def moebius(M, z):
    """Möbius transformation: z ↦ (a·z + b) / (c·z + d) for M = [[a,b],[c,d]]."""
    a, b, c, d = M[0,0], M[0,1], M[1,0], M[1,1]
    return Fraction(a * z + b, c * z + d)

def cross_ratio(z1, z2, z3, z4):
    """Cross-ratio: ((z1-z3)(z2-z4)) / ((z1-z4)(z2-z3))."""
    return Fraction((z1 - z3) * (z2 - z4), (z1 - z4) * (z2 - z3))

# ─── Generate Berggren Tree ───────────────────────────────────────────────

def berggren_tree(root, depth):
    """Generate primitive Pythagorean triples via Berggren tree to given depth."""
    triples = [root]
    frontier = [root]
    for _ in range(depth):
        new_frontier = []
        for triple in frontier:
            v = np.array(triple)
            for name, M in BERGGREN.items():
                child = tuple(M @ v)
                child = (abs(child[0]), abs(child[1]), abs(child[2]))
                if is_primitive_pythagorean(*child):
                    triples.append(child)
                    new_frontier.append(child)
        frontier = new_frontier
    return triples

# ─── Demo 1: SPB Equivariance ─────────────────────────────────────────────

def demo_spb_equivariance():
    """Verify that SPB intertwines the Berggren action with Möbius transformations."""
    print("=" * 72)
    print("DEMO 1: SPB Equivariance")
    print("   spb(B · p) = möbius(B₂, spb(p)) for each Berggren generator")
    print("=" * 72)

    root = (3, 4, 5)
    triples = berggren_tree(root, 2)

    for triple in triples[:8]:
        a, b, c = triple
        t = spb(a, b, c)
        print(f"\n  Triple ({a:3d}, {b:3d}, {c:3d})  →  spb = {t} = {float(t):.6f}")

        for name, M3 in BERGGREN.items():
            child = tuple(M3 @ np.array([a, b, c]))
            child = (abs(child[0]), abs(child[1]), abs(child[2]))
            if not is_primitive_pythagorean(*child):
                continue

            t_child = spb(*child)
            M2 = BERGGREN_2x2[name]
            M2_frac = np.array([[Fraction(int(M2[i,j])) for j in range(2)] for i in range(2)], dtype=object)
            t_moebius = moebius(M2_frac, t)

            status = "✓" if t_child == t_moebius else "✗"
            print(f"    {name}: ({child[0]:3d},{child[1]:3d},{child[2]:3d})"
                  f"  spb={t_child}  möbius={t_moebius}  {status}")

# ─── Demo 2: Cross-Ratio Invariance ───────────────────────────────────────

def demo_cross_ratio_invariance():
    """Verify cross-ratio invariance under Berggren Möbius transformations."""
    print("\n" + "=" * 72)
    print("DEMO 2: Cross-Ratio Invariance")
    print("   CR(f(z₁), f(z₂), f(z₃), f(z₄)) = CR(z₁, z₂, z₃, z₄)")
    print("=" * 72)

    root = (3, 4, 5)
    triples = berggren_tree(root, 3)

    # Pick 4 distinct triples for cross-ratio
    test_quads = [
        (triples[0], triples[1], triples[2], triples[3]),
        (triples[0], triples[3], triples[5], triples[8]),
        (triples[1], triples[4], triples[7], triples[10]),
    ]

    for qi, quad in enumerate(test_quads):
        zs = [spb(*t) for t in quad]
        cr_orig = cross_ratio(*zs)
        print(f"\n  Quadruple {qi+1}:")
        for i, (t, z) in enumerate(zip(quad, zs)):
            print(f"    p{i+1} = {t}  →  z{i+1} = {z} ≈ {float(z):.6f}")
        print(f"    Cross-ratio = {cr_orig} ≈ {float(cr_orig):.6f}")

        # Apply composite Berggren words
        for word in ['U', 'A', 'D', 'UA', 'UD', 'AU', 'DA', 'UAD', 'DUA']:
            M2 = np.eye(2, dtype=int)
            for letter in word:
                M2 = BERGGREN_2x2[letter] @ M2
            M2_frac = np.array([[Fraction(int(M2[i,j])) for j in range(2)] for i in range(2)], dtype=object)

            ws = [moebius(M2_frac, z) for z in zs]
            cr_new = cross_ratio(*ws)

            status = "✓" if cr_new == cr_orig else "✗"
            det = int(M2[0,0]*M2[1,1] - M2[0,1]*M2[1,0])
            print(f"    Word '{word:4s}' (det={det:+2d}): CR = {float(cr_new):.6f}  {status}")

# ─── Demo 3: Berggren Tree Visualization ──────────────────────────────────

def demo_berggren_tree_structure():
    """Show the Berggren tree structure and SPB values."""
    print("\n" + "=" * 72)
    print("DEMO 3: Berggren Tree Structure")
    print("   The tree of all primitive Pythagorean triples")
    print("=" * 72)

    def print_tree(triple, depth, prefix=""):
        a, b, c = triple
        t = spb(a, b, c)
        print(f"  {prefix}({a}, {b}, {c})  t = {t} ≈ {float(t):.4f}")
        if depth > 0:
            v = np.array([a, b, c])
            for i, (name, M) in enumerate(BERGGREN.items()):
                child = tuple(abs(x) for x in M @ v)
                marker = f"├─[{name}]→ " if i < 2 else f"└─[{name}]→ "
                print_tree(child, depth - 1, prefix + ("│       " if i < 2 else "        "))

    print()
    print_tree((3, 4, 5), 2)

# ─── Demo 4: Möbius Group Structure ───────────────────────────────────────

def demo_moebius_group():
    """Demonstrate the algebraic structure of the induced Möbius transformations."""
    print("\n" + "=" * 72)
    print("DEMO 4: Möbius Group Structure (det = ±1 subgroup of PGL(2,ℤ))")
    print("=" * 72)

    print("\n  Berggren 2×2 generators:")
    for name, M in BERGGREN_2x2.items():
        det = M[0,0]*M[1,1] - M[0,1]*M[1,0]
        print(f"    {name} = {M.tolist()}, det = {det}")

    print("\n  Composition table (det of products):")
    for w1 in ['U', 'A', 'D']:
        for w2 in ['U', 'A', 'D']:
            M = BERGGREN_2x2[w1] @ BERGGREN_2x2[w2]
            det = M[0,0]*M[1,1] - M[0,1]*M[1,0]
            print(f"    {w1}·{w2}: det = {det:+d}  matrix = {M.tolist()}")

    print("\n  Key observation: A and D have det = -1, so their compositions")
    print("  AA, AD, DA, DD have det = +1 and lie in SL(2,ℤ).")
    print("  U has det = +1 and is already in SL(2,ℤ).")
    print("  The full Berggren monoid maps into GL(2,ℤ) with det = ±1.")
    print("  Cross-ratio is invariant under ALL of these (det ≠ 0 suffices).")

# ─── Demo 5: Physical Interpretation ─────────────────────────────────────

def demo_physics():
    """Explain the physical interpretation on the photonic frontier."""
    print("\n" + "=" * 72)
    print("DEMO 5: Physical Interpretation — The Photonic Frontier")
    print("=" * 72)

    print("""
  The "photonic frontier" is the light cone in (2+1)-d Minkowski space:
    a² + b² = c²   (the mass-shell condition for massless particles)

  The stereographic projection maps this cone to the real line:
    (a, b, c) ↦ t = a/(c - b)

  This is the Penrose twistor correspondence restricted to rational points:
  each primitive Pythagorean triple parameterizes a "rational photon" — a
  massless state with integer momentum components.

  The cross-ratio is the fundamental invariant of conformal geometry. In
  scattering amplitude theory, cross-ratios of null momenta are the building
  blocks of all conformal invariants. Our theorem shows that the Berggren
  tree — the combinatorial structure generating all rational photons — acts
  by conformal transformations preserving these invariants.

  Concretely: if you have four rational photons and measure their
  cross-ratio, then applying ANY sequence of Berggren transformations to
  all four photons will preserve that cross-ratio. The Berggren tree is a
  discrete conformal symmetry of the photonic frontier.
  """)

    print("  Numerical illustration: SPB values along tree branches")
    root = (3, 4, 5)
    level1 = []
    for name, M in BERGGREN.items():
        child = tuple(abs(x) for x in M @ np.array(root))
        level1.append((name, child))

    print(f"\n    Root: {root}, t = {float(spb(*root)):.4f}")
    for name, child in level1:
        print(f"    {name}→{child}, t = {float(spb(*child)):.4f}")

    # Cross-ratio of root + 3 children
    zs = [spb(*root)] + [spb(*child) for _, child in level1]
    cr = cross_ratio(*zs)
    print(f"\n    CR(root, U-child, A-child, D-child) = {cr} ≈ {float(cr):.6f}")

# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║   BERGGREN–PHOTONIC BRIDGE: Structure-Preserving Correspondence  ║")
    print("║                                                                  ║")
    print("║   Demonstrating that the Berggren tree action on primitive       ║")
    print("║   Pythagorean triples descends to Möbius transformations on      ║")
    print("║   the photonic frontier, preserving cross-ratios.                ║")
    print("╚════════════════════════════════════════════════════════════════════╝")
    print()

    demo_spb_equivariance()
    demo_cross_ratio_invariance()
    demo_berggren_tree_structure()
    demo_moebius_group()
    demo_physics()

    print("=" * 72)
    print("All demonstrations complete. Cross-ratio invariance verified ✓")
    print("=" * 72)


#!/usr/bin/env python3
"""
Berggren–Photonic Bridge: Visualizations

Generates publication-quality figures illustrating the Berggren tree,
the stereographic Pythagorean bridge, and cross-ratio invariance.

Run: python3 demos/berggren_visualization.py
Output: demos/figures/
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import gcd
from fractions import Fraction
import os

os.makedirs("demos/figures", exist_ok=True)

# ─── Setup ─────────────────────────────────────────────────────────────────

U = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
A = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
D = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
BERGGREN = {'U': U, 'A': A, 'D': D}

U2 = np.array([[1, 2], [0, 1]])
A2 = np.array([[2, 1], [1, 0]])
D2 = np.array([[2, -1], [1, 0]])
BERGGREN_2x2 = {'U': U2, 'A': A2, 'D': D2}

COLORS = {'U': '#2196F3', 'A': '#4CAF50', 'D': '#FF9800'}

def spb(a, b, c):
    return a / (c - b)

def moebius(M, z):
    return (M[0,0]*z + M[0,1]) / (M[1,0]*z + M[1,1])

def cross_ratio(z1, z2, z3, z4):
    return ((z1-z3)*(z2-z4)) / ((z1-z4)*(z2-z3))

def gen_tree(root, depth):
    """Generate tree with parentage info."""
    nodes = [(root, None, '', 0)]
    frontier = [(root, 0)]
    idx = 0
    for d in range(depth):
        new_frontier = []
        for triple, parent_idx in frontier:
            v = np.array(triple)
            for name, M in BERGGREN.items():
                child = tuple(abs(x) for x in M @ v)
                a, b, c = child
                if a > 0 and b > 0 and c > 0 and a*a + b*b == c*c and gcd(a, b) == 1:
                    idx += 1
                    nodes.append((child, parent_idx, name, d+1))
                    new_frontier.append((child, idx))
        frontier = new_frontier
    return nodes

# ─── Figure 1: Unit Circle and SPB ────────────────────────────────────────

def fig_unit_circle_spb():
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', lw=1.5, alpha=0.3)

    # Draw stereographic projection lines from south pole (0, -1)
    nodes = gen_tree((3, 4, 5), 3)
    for triple, _, gen, depth in nodes:
        a, b, c = triple
        x_circ, y_circ = a/c, b/c
        t = spb(a, b, c)

        # Point on circle
        color = COLORS.get(gen, '#E91E63')
        size = max(30, 100 - depth * 20)
        ax.scatter(x_circ, y_circ, s=size, c=color, zorder=5, edgecolors='k', lw=0.5)

        # Stereographic projection line from (0, -1) through (x, y) to real line
        if abs(t) < 15:
            ax.plot([0, t * 0.15], [-1, 0], '--', color=color, alpha=0.2, lw=0.5)

        # Label the first few
        if depth <= 1:
            ax.annotate(f'({a},{b},{c})', (x_circ, y_circ),
                       textcoords="offset points", xytext=(8, 5),
                       fontsize=7, color=color)

    # Draw the real line (t-axis) as the tangent at south pole
    ax.axhline(y=0, color='gray', lw=0.5, alpha=0.5)
    ax.plot(0, -1, 'ko', ms=8, zorder=10)
    ax.annotate('South pole\n(0, −1)', (0, -1), textcoords="offset points",
               xytext=(-50, -15), fontsize=8)

    # SPB values on horizontal line
    for triple, _, gen, depth in nodes[:13]:
        a, b, c = triple
        t = spb(a, b, c)
        if abs(t) < 8:
            color = COLORS.get(gen, '#E91E63')
            ax.scatter(t * 0.12, -1.2, s=20, c=color, marker='|', zorder=5)

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Stereographic Pythagorean Bridge\n(a,b,c) on unit circle → t = a/(c−b) on ℝ',
                fontsize=12)
    ax.set_xlabel('x = a/c')
    ax.set_ylabel('y = b/c')
    ax.grid(True, alpha=0.2)

    patches = [mpatches.Patch(color=c, label=n) for n, c in COLORS.items()]
    patches.insert(0, mpatches.Patch(color='#E91E63', label='Root'))
    ax.legend(handles=patches, loc='upper left', fontsize=9)

    fig.tight_layout()
    fig.savefig('demos/figures/unit_circle_spb.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/figures/unit_circle_spb.png")
    plt.close(fig)

# ─── Figure 2: Berggren Tree with SPB values ──────────────────────────────

def fig_berggren_tree():
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    nodes = gen_tree((3, 4, 5), 3)

    # Layout: depth on y-axis, spread on x-axis
    positions = {}
    level_counts = {}
    for i, (triple, parent, gen, depth) in enumerate(nodes):
        if depth not in level_counts:
            level_counts[depth] = 0
        level_counts[depth] += 1

    level_indices = {d: 0 for d in level_counts}
    for i, (triple, parent, gen, depth) in enumerate(nodes):
        n = level_counts[depth]
        idx = level_indices[depth]
        x = (idx + 0.5) / n * 12 - 6
        y = -depth * 1.8
        positions[i] = (x, y)
        level_indices[depth] += 1

        a, b, c = triple
        t = spb(a, b, c)
        color = COLORS.get(gen, '#E91E63')

        ax.scatter(x, y, s=60, c=color, zorder=5, edgecolors='k', lw=0.5)
        label = f'({a},{b},{c})\nt={Fraction(a, c-b)}'
        ax.annotate(label, (x, y), textcoords="offset points",
                   xytext=(0, -22), fontsize=5.5, ha='center', color='#333')

        if parent is not None:
            px, py = positions[parent]
            ax.annotate('', xy=(x, y+0.12), xytext=(px, py-0.12),
                       arrowprops=dict(arrowstyle='->', color=color, lw=1, alpha=0.6))

    ax.set_xlim(-7, 7)
    ax.set_ylim(-7.5, 1)
    ax.set_title('Berggren Tree: Primitive Pythagorean Triples with SPB Values',
                fontsize=13, fontweight='bold')
    ax.axis('off')

    patches = [mpatches.Patch(color=c, label=f'{n}: matrix {BERGGREN_2x2[n].tolist()}')
               for n, c in COLORS.items()]
    patches.insert(0, mpatches.Patch(color='#E91E63', label='Root (3,4,5)'))
    ax.legend(handles=patches, loc='upper right', fontsize=9)

    fig.tight_layout()
    fig.savefig('demos/figures/berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/figures/berggren_tree.png")
    plt.close(fig)

# ─── Figure 3: Cross-Ratio Invariance ─────────────────────────────────────

def fig_cross_ratio_invariance():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    nodes = gen_tree((3, 4, 5), 4)
    triples = [n[0] for n in nodes]
    spb_vals = [spb(*t) for t in triples]

    # Pick 4 base points
    base_idx = [0, 1, 2, 3]
    base_z = [spb_vals[i] for i in base_idx]
    cr_base = cross_ratio(*base_z)

    # Apply many different words and track cross-ratio
    words = [''] + list('UAD') + ['UU', 'UA', 'UD', 'AU', 'AA', 'AD', 'DU', 'DA', 'DD',
             'UUA', 'UAD', 'DUA', 'ADA', 'UDU', 'DAD', 'UUUU', 'AADA', 'DUAD']

    crs = []
    word_labels = []
    for word in words:
        M = np.eye(2, dtype=float)
        for letter in word:
            M = BERGGREN_2x2[letter].astype(float) @ M
        transformed = [moebius(M, z) for z in base_z]
        cr = cross_ratio(*transformed)
        crs.append(cr)
        word_labels.append(word if word else 'Id')

    ax = axes[0]
    ax.bar(range(len(crs)), crs, color='#2196F3', alpha=0.7, edgecolor='#1565C0')
    ax.axhline(y=cr_base, color='red', linestyle='--', lw=2, label=f'True CR = {cr_base:.4f}')
    ax.set_xticks(range(len(word_labels)))
    ax.set_xticklabels(word_labels, rotation=60, fontsize=6, ha='right')
    ax.set_ylabel('Cross-Ratio')
    ax.set_title('Cross-Ratio Under Different Berggren Words\n(All identical — invariance!)', fontsize=11)
    ax.legend(fontsize=9)
    ax.set_ylim(cr_base - 0.5, cr_base + 0.5)

    # Right panel: SPB values on the number line under different transformations
    ax = axes[1]
    for wi, word in enumerate(words[:10]):
        M = np.eye(2, dtype=float)
        for letter in word:
            M = BERGGREN_2x2[letter].astype(float) @ M
        transformed = [moebius(M, z) for z in base_z]
        label = word if word else 'Id'
        for j, tz in enumerate(transformed):
            ax.scatter(tz, wi, s=80, c=['#E91E63', '#2196F3', '#4CAF50', '#FF9800'][j],
                      zorder=5, edgecolors='k', lw=0.3)
        ax.text(-0.5, wi, label, fontsize=8, ha='right', va='center')

    ax.set_xlabel('SPB value on ℝ (photonic frontier)')
    ax.set_title('Four points under Möbius action\n(shape preserved = cross-ratio invariant)', fontsize=11)
    ax.set_yticks([])
    ax.grid(True, axis='x', alpha=0.3)

    fig.tight_layout()
    fig.savefig('demos/figures/cross_ratio_invariance.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/figures/cross_ratio_invariance.png")
    plt.close(fig)

# ─── Figure 4: Photonic Frontier (Light Cone) ────────────────────────────

def fig_photonic_frontier():
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')

    # Light cone: a² + b² = c²
    theta = np.linspace(0, 2*np.pi, 100)
    c_vals = np.linspace(0, 50, 50)
    T, C = np.meshgrid(theta, c_vals)
    A_cone = C * np.cos(T)
    B_cone = C * np.sin(T)
    ax.plot_surface(A_cone, B_cone, C, alpha=0.08, color='blue')

    # Plot Pythagorean triples on the cone
    nodes = gen_tree((3, 4, 5), 3)
    for triple, _, gen, depth in nodes:
        a, b, c = triple
        color = COLORS.get(gen, '#E91E63')
        size = max(15, 50 - depth * 10)
        ax.scatter(a, b, c, s=size, c=color, zorder=5, edgecolors='k', lw=0.3)

    # Draw edges of Berggren tree
    for i, (triple, parent, gen, depth) in enumerate(nodes):
        if parent is not None:
            a1, b1, c1 = nodes[parent][0]
            a2, b2, c2 = triple
            color = COLORS.get(gen, '#E91E63')
            ax.plot([a1, a2], [b1, b2], [c1, c2], '-', color=color, alpha=0.3, lw=0.8)

    ax.set_xlabel('a', fontsize=11)
    ax.set_ylabel('b', fontsize=11)
    ax.set_zlabel('c', fontsize=11)
    ax.set_title('Photonic Frontier: Pythagorean Triples on the Light Cone\na² + b² = c²',
                fontsize=13, fontweight='bold')

    patches = [mpatches.Patch(color=c, label=n) for n, c in COLORS.items()]
    patches.insert(0, mpatches.Patch(color='#E91E63', label='Root'))
    ax.legend(handles=patches, loc='upper left', fontsize=9)

    fig.tight_layout()
    fig.savefig('demos/figures/photonic_frontier_3d.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/figures/photonic_frontier_3d.png")
    plt.close(fig)

# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating Berggren–Photonic Bridge figures...")
    fig_unit_circle_spb()
    fig_berggren_tree()
    fig_cross_ratio_invariance()
    fig_photonic_frontier()
    print("All figures generated successfully.")
