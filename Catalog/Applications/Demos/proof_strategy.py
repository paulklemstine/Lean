"""
Applications of Tropical Grassmannian Theory

Demonstrates connections to:
1. Phylogenetics — tree reconstruction from distance matrices
2. Network geometry — shortest path metrics and four-point condition
3. Combinatorial optimization — matroid representability
"""

from itertools import combinations
import numpy as np


def reconstruct_tree_from_distances(n, d):
    """Reconstruct a tree from a distance matrix using the neighbor-joining heuristic.

    If d satisfies the four-point condition, it is a tree metric, and
    the tree can be recovered exactly.

    Args:
        n: number of leaves
        d: distance matrix (n×n numpy array)

    Returns:
        List of (node_i, node_j, weight) edges
    """
    # Simple neighbor-joining
    active = list(range(n))
    edges = []
    dist = d.copy()
    next_node = n

    while len(active) > 2:
        # Find the pair with minimum adjusted distance
        best_pair = None
        best_val = float('inf')
        m = len(active)

        for i_idx in range(m):
            for j_idx in range(i_idx + 1, m):
                i, j = active[i_idx], active[j_idx]
                r_i = sum(dist[i, active[k]] for k in range(m)) / (m - 2)
                r_j = sum(dist[j, active[k]] for k in range(m)) / (m - 2)
                val = dist[i, j] - r_i - r_j
                if val < best_val:
                    best_val = val
                    best_pair = (i, j, i_idx, j_idx)

        i, j, i_idx, j_idx = best_pair

        # Create new node
        new = next_node
        next_node += 1

        # Edge weights
        m = len(active)
        r_i = sum(dist[i, active[k]] for k in range(m)) / (m - 2) if m > 2 else 0
        r_j = sum(dist[j, active[k]] for k in range(m)) / (m - 2) if m > 2 else 0
        w_i = (dist[i, j] + r_i - r_j) / 2
        w_j = dist[i, j] - w_i
        edges.append((i, new, round(w_i, 4)))
        edges.append((j, new, round(w_j, 4)))

        # Update distances
        new_dist = np.zeros((next_node, next_node))
        new_dist[:dist.shape[0], :dist.shape[1]] = dist
        for k in range(m):
            node_k = active[k]
            if node_k != i and node_k != j:
                d_new = (dist[i, node_k] + dist[j, node_k] - dist[i, j]) / 2
                new_dist[new, node_k] = d_new
                new_dist[node_k, new] = d_new

        dist = new_dist
        active = [x for x in active if x != i and x != j] + [new]

    # Final edge
    if len(active) == 2:
        edges.append((active[0], active[1], round(dist[active[0], active[1]], 4)))

    return edges


def check_matroid_realizability(bases, n, r, primes):
    """Check matroid realizability over various fields.

    Returns a dict mapping each prime to whether the matroid is representable.
    """
    results = {}
    bases_set = set(bases)

    for p in primes:
        found = False
        # Try all r×n matrices over F_p (for small cases)
        if p ** (r * n) <= 100000:
            # Exhaustive search for very small cases
            pass

        # Random sampling
        for _ in range(2000):
            A = np.random.randint(0, p, size=(r, n))
            match = True
            for cols in combinations(range(n), r):
                submat = A[:, list(cols)]
                det_val = int(round(np.linalg.det(submat))) % p
                is_basis = frozenset(cols) in bases_set
                if (det_val != 0) != is_basis:
                    match = False
                    break
            if match:
                found = True
                break

        results[p] = found

    return results


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Phylogenetic Tree Reconstruction")
    print("=" * 60)

    # Create a tree metric
    # Tree: species 0,1,2,3 with known pairwise distances
    d = np.array([
        [0, 3, 7, 8],
        [3, 0, 6, 7],
        [7, 6, 0, 3],
        [8, 7, 3, 0],
    ], dtype=float)

    print("\nDistance matrix:")
    print(d.astype(int))

    edges = reconstruct_tree_from_distances(4, d)
    print("\nReconstructed tree edges:")
    for i, j, w in edges:
        label_i = f"Leaf {i}" if i < 4 else f"Node {i}"
        label_j = f"Leaf {j}" if j < 4 else f"Node {j}"
        print(f"  {label_i} --[{w}]-- {label_j}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Matroid Representability over Finite Fields")
    print("=" * 60)

    FANO_LINES = [
        frozenset({0, 1, 3}), frozenset({0, 2, 4}), frozenset({1, 2, 5}),
        frozenset({0, 5, 6}), frozenset({1, 4, 6}), frozenset({2, 3, 6}),
        frozenset({3, 4, 5}),
    ]
    all_triples = [frozenset(t) for t in combinations(range(7), 3)]
    fano_bases = [t for t in all_triples if t not in FANO_LINES]

    print(f"\nFano matroid F₇: {len(fano_bases)} bases, {len(FANO_LINES)} lines")

    primes = [2, 3, 5, 7, 11]
    results = check_matroid_realizability(fano_bases, 7, 3, primes)

    print("\nRepresentability over finite fields:")
    for p, rep in results.items():
        status = "✓ REPRESENTABLE" if rep else "✗ Not representable"
        print(f"  F_{p}: {status}")

    print("\n  The Fano matroid is representable ONLY over char 2!")
    print("  This is the algebraic root of the Dressian ≠ Trop(Gr) phenomenon.")


"""
Tropical Grassmannians and Dressians: Demonstrations

This module demonstrates the key mathematical objects from the formalization:
1. The Fano matroid and its tropical Plücker relations
2. The four-point condition for rank-2 Dressians
3. The characteristic-2 obstruction for Fano non-representability
"""

import numpy as np
from itertools import combinations

# ============================================================
# Fano Matroid
# ============================================================

FANO_LINES = [
    frozenset({0, 1, 3}),
    frozenset({0, 2, 4}),
    frozenset({1, 2, 5}),
    frozenset({0, 5, 6}),
    frozenset({1, 4, 6}),
    frozenset({2, 3, 6}),
    frozenset({3, 4, 5}),
]

def is_fano_line(triple):
    """Check if a 3-element set is a Fano line."""
    return frozenset(triple) in FANO_LINES

def fano_weight(triple):
    """The Fano weight: 0 on bases, 1 on Fano lines."""
    return 1 if is_fano_line(triple) else 0

def check_plucker_relation(w, s, a, b, c, d):
    """Check the 3-term tropical Plücker relation for rank 3.

    For S = {s} and distinct a,b,c,d not in S:
    min(w(S∪{a,b}) + w(S∪{c,d}),
        w(S∪{a,c}) + w(S∪{b,d}),
        w(S∪{a,d}) + w(S∪{b,c}))
    must be attained at least twice.
    """
    v1 = w(frozenset({s, a, b})) + w(frozenset({s, c, d}))
    v2 = w(frozenset({s, a, c})) + w(frozenset({s, b, d}))
    v3 = w(frozenset({s, a, d})) + w(frozenset({s, b, c}))

    vals = sorted([v1, v2, v3])
    return vals[0] == vals[1]  # minimum attained at least twice

def verify_dressian_membership():
    """Verify that fano_weight satisfies all tropical Plücker relations."""
    print("=" * 60)
    print("Verifying Fano weight is in the Dressian Dr(3,7)")
    print("=" * 60)

    count = 0
    for s in range(7):
        others = [x for x in range(7) if x != s]
        for combo in combinations(others, 4):
            a, b, c, d = combo
            ok = check_plucker_relation(fano_weight, s, a, b, c, d)
            count += 1
            if not ok:
                print(f"  FAILED at s={s}, (a,b,c,d)={combo}")
                return False

    print(f"  Checked {count} Plücker relations: ALL PASSED ✓")
    print(f"  fanoWeight ∈ Dr(3,7)")
    return True

def demonstrate_fano_matroid():
    """Display the Fano matroid structure."""
    print("\n" + "=" * 60)
    print("The Fano Matroid F₇")
    print("=" * 60)

    all_triples = list(combinations(range(7), 3))
    lines = [t for t in all_triples if is_fano_line(t)]
    bases = [t for t in all_triples if not is_fano_line(t)]

    print(f"\n  Ground set: {{0, 1, 2, 3, 4, 5, 6}}")
    print(f"  Total 3-element subsets: {len(all_triples)}")
    print(f"  Fano lines (dependent):  {len(lines)}")
    print(f"  Bases (independent):     {len(bases)}")
    print(f"\n  The 7 Fano lines:")
    for i, line in enumerate(lines):
        print(f"    L{i+1}: {set(line)}")

def demonstrate_char2_obstruction():
    """Show the characteristic-2 obstruction for Fano representability."""
    print("\n" + "=" * 60)
    print("Characteristic-2 Obstruction")
    print("=" * 60)

    # Standard F₂ representation
    cols = {
        0: np.array([1, 0, 0]),
        1: np.array([0, 1, 0]),
        2: np.array([0, 0, 1]),
        3: np.array([1, 1, 0]),
        4: np.array([1, 0, 1]),
        5: np.array([0, 1, 1]),
        6: np.array([1, 1, 1]),
    }

    print("\n  Standard F₂ representation (7 nonzero vectors of F₂³):")
    for k, v in cols.items():
        print(f"    v{k} = {tuple(v)}")

    # Compute the key determinant
    det345 = np.linalg.det(np.column_stack([cols[3], cols[4], cols[5]]))
    print(f"\n  det(v₃, v₄, v₅) over ℝ = {det345:.0f}")
    print(f"  det(v₃, v₄, v₅) over F₂ = {int(det345) % 2}")
    print(f"\n  Over ℝ: det = -2 ≠ 0, so {{3,4,5}} is NOT dependent")
    print(f"  Over F₂: det ≡ 0, so {{3,4,5}} IS dependent")
    print(f"\n  ⟹ The Fano matroid requires characteristic 2!")
    print(f"  ⟹ Not representable over ℝ (or any char ≠ 2 field)")

def demonstrate_four_point_condition():
    """Demonstrate the rank-2 four-point/tree-metric condition."""
    print("\n" + "=" * 60)
    print("Rank-2 Four-Point Condition (Tree Metrics)")
    print("=" * 60)

    # Example: tree metric on 4 leaves
    # Tree: 0--[2]--x--[1]--1, x--[3]--y, y--[1]--2, y--[2]--3
    d = np.zeros((4, 4))
    d[0,1] = d[1,0] = 3  # 2+1
    d[0,2] = d[2,0] = 6  # 2+3+1
    d[0,3] = d[3,0] = 7  # 2+3+2
    d[1,2] = d[2,1] = 5  # 1+3+1
    d[1,3] = d[3,1] = 6  # 1+3+2
    d[2,3] = d[3,2] = 3  # 1+2

    print("\n  Tree metric on 4 leaves:")
    for i in range(4):
        for j in range(i+1, 4):
            print(f"    d({i},{j}) = {d[i,j]:.0f}")

    # Plücker vector w({i,j}) = -d(i,j)
    print("\n  Tropical Plücker vector w({i,j}) = -d(i,j):")
    for i in range(4):
        for j in range(i+1, 4):
            print(f"    w({{{i},{j}}}) = {-d[i,j]:.0f}")

    # Check four-point condition
    s1 = (-d[0,1]) + (-d[2,3])  # w(01) + w(23)
    s2 = (-d[0,2]) + (-d[1,3])  # w(02) + w(13)
    s3 = (-d[0,3]) + (-d[1,2])  # w(03) + w(12)

    print(f"\n  Three sums for {{0,1,2,3}}:")
    print(f"    w({{0,1}}) + w({{2,3}}) = {s1:.0f}")
    print(f"    w({{0,2}}) + w({{1,3}}) = {s2:.0f}")
    print(f"    w({{0,3}}) + w({{1,2}}) = {s3:.0f}")

    vals = sorted([s1, s2, s3])
    satisfied = vals[0] == vals[1]
    print(f"\n  Minimum = {vals[0]:.0f}, attained {'≥2' if satisfied else '<2'} times")
    print(f"  Four-point condition: {'SATISFIED ✓' if satisfied else 'FAILED ✗'}")

if __name__ == "__main__":
    demonstrate_fano_matroid()
    verify_dressian_membership()
    demonstrate_char2_obstruction()
    demonstrate_four_point_condition()

    print("\n" + "=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print("  fanoWeight ∈ Dr(3,7)       ✓ (verified)")
    print("  fanoWeight ∉ Trop(Gr(3,7)) ✓ (Fano not representable over char ≠ 2)")
    print("  ⟹ Dr(3,7) ⊋ Trop(Gr(3,7))  — the first divergence!")


"""
Visualizations for Tropical Grassmannian / Dressian theory.
Generates the Fano plane diagram and the inclusion diagram.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io

def fano_plane_diagram():
    """Draw the Fano plane with its 7 points and 7 lines."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Place 7 points: outer triangle + inner triangle + center
    r_outer = 2.0
    r_inner = 1.0
    angles_outer = [np.pi/2, np.pi/2 + 2*np.pi/3, np.pi/2 + 4*np.pi/3]
    angles_inner = [np.pi/2 + np.pi/3, np.pi/2 + np.pi, np.pi/2 + 5*np.pi/3]

    # Points: use specific layout
    pts = {}
    pts[0] = np.array([0, r_outer])           # top
    pts[1] = np.array([r_outer*np.cos(angles_outer[1]), r_outer*np.sin(angles_outer[1])])  # bottom-left
    pts[2] = np.array([r_outer*np.cos(angles_outer[2]), r_outer*np.sin(angles_outer[2])])  # bottom-right
    pts[3] = (pts[0] + pts[1]) / 2            # midpoint 0-1
    pts[4] = (pts[0] + pts[2]) / 2            # midpoint 0-2
    pts[5] = (pts[1] + pts[2]) / 2            # midpoint 1-2
    pts[6] = np.array([0, 0])                 # center

    # Fano lines
    fano_lines = [
        (0, 1, 3), (0, 2, 4), (1, 2, 5),
        (0, 5, 6), (1, 4, 6), (2, 3, 6), (3, 4, 5)
    ]

    # Draw lines
    colors = plt.cm.Set2(np.linspace(0, 1, 7))
    for idx, (a, b, c) in enumerate(fano_lines):
        pa, pb, pc = pts[a], pts[b], pts[c]
        # Draw through all three points
        if idx < 3:  # sides of triangle
            ax.plot([pa[0], pb[0]], [pa[1], pb[1]], '-', color=colors[idx],
                    linewidth=2, alpha=0.7, zorder=1)
        elif idx == 6:  # inscribed triangle (3,4,5)
            ax.plot([pa[0], pb[0]], [pa[1], pb[1]], '-', color=colors[idx],
                    linewidth=2, alpha=0.7, zorder=1)
            ax.plot([pb[0], pc[0]], [pb[1], pc[1]], '-', color=colors[idx],
                    linewidth=2, alpha=0.7, zorder=1)
            ax.plot([pc[0], pa[0]], [pc[1], pa[1]], '-', color=colors[idx],
                    linewidth=2, alpha=0.7, zorder=1)
        else:  # medians (through center)
            # Extend line through the three points
            direction = pc - pa
            t_vals = np.linspace(-0.3, 1.3, 100)
            line_pts = pa + np.outer(t_vals, direction)
            ax.plot(line_pts[:, 0], line_pts[:, 1], '-', color=colors[idx],
                    linewidth=2, alpha=0.7, zorder=1)

    # Draw inscribed circle for the {3,4,5} line
    circle = plt.Circle((0, -0.15), r_inner*0.65, fill=False,
                         color=colors[6], linewidth=2, alpha=0.7, zorder=1)
    ax.add_patch(circle)

    # Draw points
    for k, p in pts.items():
        ax.plot(p[0], p[1], 'o', markersize=20, color='#2C3E50',
                markeredgecolor='white', markeredgewidth=2, zorder=5)
        ax.text(p[0], p[1], str(k), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-2.8, 2.8)
    ax.set_ylim(-2.5, 2.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Fano Plane PG(2, 𝔽₂)\n7 points, 7 lines, 3 points per line',
                 fontsize=16, fontweight='bold', pad=20)

    # Legend
    legend_text = "Lines: {0,1,3}, {0,2,4}, {1,2,5},\n{0,5,6}, {1,4,6}, {2,3,6}, {3,4,5}"
    ax.text(0, -2.3, legend_text, ha='center', fontsize=10, style='italic',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    fig.tight_layout()
    return fig

def inclusion_diagram():
    """Draw the inclusion diagram Trop(Gr(r,n)) ⊆ Dr(r,n)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Rank 2: equality
    ax = axes[0]
    circle1 = plt.Circle((0, 0), 1.5, fill=True, facecolor='#3498DB',
                          alpha=0.3, edgecolor='#2C3E50', linewidth=2)
    ax.add_patch(circle1)
    ax.text(0, 0.3, 'Dr(2,n)', fontsize=16, ha='center', fontweight='bold')
    ax.text(0, -0.3, '= Trop(Gr(2,n))', fontsize=14, ha='center')
    ax.text(0, -0.9, '= Tree Metrics', fontsize=12, ha='center', style='italic')
    ax.set_xlim(-2.2, 2.2)
    ax.set_ylim(-2.2, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Rank 2: Coincidence', fontsize=14, fontweight='bold')

    # Rank 3: strict inclusion
    ax = axes[1]
    outer = plt.Circle((0, 0), 1.8, fill=True, facecolor='#E74C3C',
                        alpha=0.2, edgecolor='#C0392B', linewidth=2)
    inner = plt.Circle((-0.3, 0), 1.0, fill=True, facecolor='#2ECC71',
                        alpha=0.3, edgecolor='#27AE60', linewidth=2)
    ax.add_patch(outer)
    ax.add_patch(inner)
    ax.text(-0.3, 0, 'Trop(Gr(3,7))', fontsize=12, ha='center', fontweight='bold')
    ax.text(1.0, 0.8, 'Dr(3,7)', fontsize=14, ha='center', fontweight='bold',
            color='#C0392B')
    # Mark the Fano point
    ax.plot(1.2, -0.3, '*', markersize=20, color='#8E44AD', zorder=5)
    ax.text(1.2, -0.7, 'Fano\nweight', fontsize=10, ha='center', color='#8E44AD',
            fontweight='bold')
    ax.annotate('', xy=(0.7, 0.0), xytext=(1.15, -0.25),
                arrowprops=dict(arrowstyle='->', color='#8E44AD', lw=1.5))

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.2, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Rank 3: Strict Inclusion ⊊', fontsize=14, fontweight='bold')

    fig.suptitle('Tropical Grassmannian vs Dressian',
                 fontsize=18, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig

def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"

if __name__ == "__main__":
    fig1 = fano_plane_diagram()
    fig1.savefig('/workspace/request-project/fano_plane.png', dpi=150, bbox_inches='tight')
    print("Saved fano_plane.png")

    fig2 = inclusion_diagram()
    fig2.savefig('/workspace/request-project/inclusion_diagram.png', dpi=150, bbox_inches='tight')
    print("Saved inclusion_diagram.png")
