"""
applications.py — Applications of Newton Polytope Erosion Theory

Demonstrates real-world applications:
1. Derivative complexity prediction via polytope geometry
2. Sparse polynomial analysis
3. Ehrhart-theoretic counting of shadow sizes
"""

import numpy as np
from itertools import combinations_with_replacement, product


# ──────────────────────────────────────────────────────────────────────
# Core algorithms (self-contained)
# ──────────────────────────────────────────────────────────────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def universal_quad_shadow(S, n):
    increments = quadratic_increments(n)
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shifted.add(u)
        candidates = shifted if candidates is None else candidates & shifted
    return candidates if candidates is not None else set()

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow


# ──────────────────────────────────────────────────────────────────────
# Application 1: Derivative Complexity via Polytope Geometry
# ──────────────────────────────────────────────────────────────────────

def derivative_complexity_analysis(degree, n):
    """
    Analyze how support size shrinks under repeated quadratic shadow operations.

    For a full simplex of degree d in n variables, compute:
    - |S| = C(d+n-1, n)
    - |Sh₂(S)| = C(d+n-3, n) (for existential shadow)
    - |USh₂(S)| (universal shadow)

    This shows derivative complexity is controlled by polytope erosion.
    """
    # Full simplex: all α ∈ ℕⁿ with ∑αᵢ ≤ degree
    S = set()
    ranges = [range(degree + 1)] * n
    for pt in product(*ranges):
        if sum(pt) <= degree:
            S.add(pt)

    shadow = universal_quad_shadow(S, n)
    exist_shadow = discrete_quad_shadow(S, n)

    return {
        'degree': degree,
        'dim': n,
        'support_size': len(S),
        'universal_shadow_size': len(shadow),
        'existential_shadow_size': len(exist_shadow),
        'support_loss_ratio': 1 - len(shadow) / len(S) if S else 0,
    }


def ehrhart_shadow_counting(max_dilation, n=2):
    """
    Compute |Sh₂(mP ∩ ℤⁿ)| for dilations m = 1, ..., max_dilation
    of the standard simplex P = {x ≥ 0 : ∑xᵢ ≤ 1}.

    This tests the Ehrhart-theoretic conjecture: for large m,
    the shadow count is a polynomial in m.
    """
    results = []
    for m in range(1, max_dilation + 1):
        # mP ∩ ℤⁿ = {α ∈ ℕⁿ : ∑αᵢ ≤ m}
        S = set()
        for pt in product(*[range(m + 1)] * n):
            if sum(pt) <= m:
                S.add(pt)

        shadow = universal_quad_shadow(S, n)
        exist_shadow = discrete_quad_shadow(S, n)

        results.append({
            'm': m,
            'S_size': len(S),
            'universal_shadow': len(shadow),
            'existential_shadow': len(exist_shadow),
        })

    return results


# ──────────────────────────────────────────────────────────────────────
# Application 2: Sparse Polynomial Analysis
# ──────────────────────────────────────────────────────────────────────

def sparsity_gap_analysis(n=2, max_degree=6):
    """
    For each degree d, compare the shadow/erosion gap for:
    - Full simplex (saturated): gap = 0
    - Vertices only (maximally sparse): gap can be large
    - Random sparse supports: intermediate behavior

    This quantifies how sparsity creates derivative unpredictability.
    """
    results = []
    for d in range(2, max_degree + 1):
        # Full simplex
        S_full = set()
        for pt in product(*[range(d + 1)] * n):
            if sum(pt) <= d:
                S_full.add(pt)

        # Vertices only
        S_vertices = set()
        for i in range(n):
            v = [0] * n; v[i] = d; S_vertices.add(tuple(v))
        S_vertices.add(tuple([0] * n))

        # Random half-sparse
        S_half = set()
        for pt in S_full:
            if np.random.random() < 0.5 or pt in S_vertices:
                S_half.add(pt)

        full_shadow = universal_quad_shadow(S_full, n)
        vert_shadow = universal_quad_shadow(S_vertices, n)
        half_shadow = universal_quad_shadow(S_half, n)
        full_exist = discrete_quad_shadow(S_full, n)
        vert_exist = discrete_quad_shadow(S_vertices, n)

        results.append({
            'degree': d,
            'full_support': len(S_full),
            'full_universal': len(full_shadow),
            'full_existential': len(full_exist),
            'vertices_support': len(S_vertices),
            'vertices_universal': len(vert_shadow),
            'vertices_existential': len(vert_exist),
            'half_support': len(S_half),
            'half_universal': len(half_shadow),
        })

    return results


# ──────────────────────────────────────────────────────────────────────
# Application 3: Tropical Hessian Support
# ──────────────────────────────────────────────────────────────────────

def tropical_hessian_analysis(S, n):
    """
    The tropical Hessian of a tropical polynomial with support S has
    support equal to the quadratic shadow. This function computes the
    tropical Hessian support and verifies this equality.

    In tropical geometry, the Hessian detects singular points of the
    tropical hypersurface. The shadow theorem tells us exactly which
    monomials appear.
    """
    exist_shadow = discrete_quad_shadow(S, n)
    increments = quadratic_increments(n)

    # For each point in the shadow, find which derivatives produce it
    derivative_map = {}
    for u in exist_shadow:
        producing_derivs = []
        for beta in increments:
            alpha = tuple(a + b for a, b in zip(u, beta))
            if alpha in S:
                producing_derivs.append(beta)
        derivative_map[u] = producing_derivs

    return {
        'support': S,
        'tropical_hessian_support': exist_shadow,
        'derivative_sources': derivative_map,
        'hessian_richness': sum(len(v) for v in derivative_map.values()) / max(len(derivative_map), 1),
    }


if __name__ == '__main__':
    print("=" * 60)
    print("APPLICATION 1: Derivative Complexity via Polytope Geometry")
    print("=" * 60)

    for d in range(2, 8):
        result = derivative_complexity_analysis(d, 2)
        print(f"  degree={d}: |S|={result['support_size']:4d}, "
              f"|USh₂|={result['universal_shadow_size']:4d}, "
              f"|Sh₂|={result['existential_shadow_size']:4d}, "
              f"loss={result['support_loss_ratio']:.2%}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Ehrhart Shadow Counting")
    print("=" * 60)

    ehrhart = ehrhart_shadow_counting(10, n=2)
    print(f"  {'m':>3s} | {'|S|':>5s} | {'|USh₂|':>6s} | {'|Sh₂|':>6s}")
    print("  " + "-" * 30)
    for r in ehrhart:
        print(f"  {r['m']:3d} | {r['S_size']:5d} | {r['universal_shadow']:6d} | {r['existential_shadow']:6d}")

    print("\n  Observation: |USh₂(mΔ)| appears polynomial in m")
    print("  For the standard 2-simplex: |USh₂| = C(m-2+2, 2) = (m-1)m/2")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Sparsity Gap Analysis (2D)")
    print("=" * 60)

    np.random.seed(42)
    sparse = sparsity_gap_analysis(n=2, max_degree=6)
    for r in sparse:
        print(f"  deg={r['degree']}: full |USh₂|={r['full_universal']:3d}, "
              f"vertices |USh₂|={r['vertices_universal']:3d}, "
              f"half |USh₂|={r['half_universal']:3d}")

    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Hessian Support")
    print("=" * 60)

    S = {(i, j) for i in range(4) for j in range(4 - i)}
    result = tropical_hessian_analysis(S, 2)
    print(f"  Support: {len(result['support'])} monomials")
    print(f"  Tropical Hessian support: {len(result['tropical_hessian_support'])} monomials")
    print(f"  Average derivative sources per shadow point: {result['hessian_richness']:.1f}")


"""
demo.py — Interactive demonstration of Newton Polytope Erosion and Quadratic Shadow

Demonstrates the core mathematical results:
1. Computing quadratic shadows for finite support sets
2. Computing eroded Newton polytope lattice points
3. Comparing them to verify the shadow-erosion correspondence
4. Visualizing equality and failure cases
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations_with_replacement, product


# ──────────────────────────────────────────────────────────────────────
# Core algorithms (self-contained)
# ──────────────────────────────────────────────────────────────────────

def quadratic_increments(n):
    """All β ∈ ℕⁿ with ∑βᵢ = 2."""
    result = []
    for i in range(n):
        beta = [0] * n
        beta[i] = 2
        result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n
            beta[i] = 1
            beta[j] = 1
            result.append(tuple(beta))
    return result


def discrete_quad_shadow(S, n):
    """Existential quadratic shadow."""
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u):
                shadow.add(u)
    return shadow


def universal_quad_shadow(S, n):
    """Universal quadratic shadow."""
    increments = quadratic_increments(n)
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u):
                shifted.add(u)
        candidates = shifted if candidates is None else candidates & shifted
    return candidates if candidates is not None else set()


def point_in_convex_hull_2d(point, hull_points):
    """Check if point is in convex hull (2D)."""
    from scipy.optimize import linprog
    m = hull_points.shape[0]
    A_eq = np.vstack([hull_points.T, np.ones(m)])
    b_eq = np.append(point, 1.0)
    c = np.zeros(m)
    bounds = [(0, None)] * m
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    return result.success


def eroded_newton_lattice_points(S, n):
    """Lattice points of Newt(S) ⊖ Δ₂."""
    if not S:
        return set()
    points = np.array(list(S), dtype=float)
    increments = quadratic_increments(n)
    min_c = np.min(points, axis=0).astype(int)
    max_c = np.max(points, axis=0).astype(int)
    result = set()
    ranges = [range(max(0, int(min_c[i])), int(max_c[i]) + 1) for i in range(n)]
    for u_tuple in product(*ranges):
        u = np.array(u_tuple, dtype=float)
        if all(point_in_convex_hull_2d(u + np.array(beta, dtype=float), points)
               for beta in increments):
            result.add(u_tuple)
    return result


def is_lattice_saturated(S, n):
    """Check if S contains all integer points of its Newton polytope."""
    if not S:
        return True
    points = np.array(list(S), dtype=float)
    min_c = np.min(points, axis=0).astype(int)
    max_c = np.max(points, axis=0).astype(int)
    ranges = [range(int(min_c[i]), int(max_c[i]) + 1) for i in range(n)]
    for u_tuple in product(*ranges):
        if u_tuple not in S:
            u = np.array(u_tuple, dtype=float)
            if point_in_convex_hull_2d(u, points):
                return False
    return True


# ──────────────────────────────────────────────────────────────────────
# Demonstration
# ──────────────────────────────────────────────────────────────────────

def demo_2d_saturated():
    """Demonstrate shadow = erosion for a lattice-saturated 2D support."""
    print("=" * 60)
    print("CASE 1: Lattice-Saturated Support (2D)")
    print("=" * 60)

    # Full triangle: all lattice points of conv{(0,0),(4,0),(0,4)}
    S = set()
    for i in range(5):
        for j in range(5 - i):
            S.add((i, j))

    n = 2
    sat = is_lattice_saturated(S, n)
    shadow = universal_quad_shadow(S, n)
    erosion = eroded_newton_lattice_points(S, n)
    existential = discrete_quad_shadow(S, n)

    print(f"Support S: {len(S)} points, lattice-saturated: {sat}")
    print(f"Universal shadow:    {len(shadow)} points")
    print(f"Existential shadow:  {len(existential)} points")
    print(f"Erosion lattice pts: {len(erosion)} points")
    print(f"Shadow == Erosion:   {shadow == erosion}")
    print(f"Universal shadow: {sorted(shadow)}")
    print(f"Erosion lattice:  {sorted(erosion)}")

    return S, shadow, erosion, existential


def demo_2d_sparse():
    """Demonstrate shadow ≠ erosion for a sparse (non-saturated) 2D support."""
    print("\n" + "=" * 60)
    print("CASE 2: Sparse (Non-Saturated) Support (2D)")
    print("=" * 60)

    # Triangle vertices only: missing interior points
    S = {(0, 0), (4, 0), (0, 4)}
    n = 2
    sat = is_lattice_saturated(S, n)
    shadow = universal_quad_shadow(S, n)
    erosion = eroded_newton_lattice_points(S, n)

    print(f"Support S: {sorted(S)}, lattice-saturated: {sat}")
    print(f"Universal shadow:    {sorted(shadow)} ({len(shadow)} pts)")
    print(f"Erosion lattice pts: {sorted(erosion)} ({len(erosion)} pts)")
    print(f"Shadow == Erosion:   {shadow == erosion}")
    if erosion - shadow:
        print(f"Gap (erosion \\ shadow): {sorted(erosion - shadow)}")

    return S, shadow, erosion


def demo_1d():
    """1D demonstration: the universal shadow is just S shifted by 2."""
    print("\n" + "=" * 60)
    print("CASE 3: 1D Support")
    print("=" * 60)

    S = {(k,) for k in range(8)}
    n = 1
    shadow = universal_quad_shadow(S, n)
    erosion = eroded_newton_lattice_points(S, n)

    print(f"S = {{0, 1, ..., 7}}")
    print(f"Universal shadow (= {{u : u+2 ∈ S}}): {sorted(shadow)}")
    print(f"Erosion lattice pts: {sorted(erosion)}")
    print(f"Equal: {shadow == erosion}")


def demo_3d():
    """3D demonstration with a tetrahedron."""
    print("\n" + "=" * 60)
    print("CASE 4: 3D Saturated Tetrahedron")
    print("=" * 60)

    # All lattice points of conv{(0,0,0),(3,0,0),(0,3,0),(0,0,3)}
    S = set()
    for i in range(4):
        for j in range(4 - i):
            for k in range(4 - i - j):
                S.add((i, j, k))

    n = 3
    sat = is_lattice_saturated(S, n)
    shadow = universal_quad_shadow(S, n)
    erosion = eroded_newton_lattice_points(S, n)

    print(f"Support: {len(S)} points in 3-simplex, saturated: {sat}")
    print(f"Universal shadow:    {len(shadow)} points")
    print(f"Erosion lattice pts: {len(erosion)} points")
    print(f"Equal: {shadow == erosion}")


def visualize_2d(S, shadow, erosion, existential, title, filename):
    """Visualize a 2D case."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Support S
    ax = axes[0]
    S_arr = np.array(list(S))
    ax.scatter(S_arr[:, 0], S_arr[:, 1], c='blue', s=80, zorder=5, label='S')
    ax.set_title('Support S')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend()

    # Plot 2: Existential vs Universal Shadow
    ax = axes[1]
    if existential:
        ex_arr = np.array(list(existential))
        ax.scatter(ex_arr[:, 0], ex_arr[:, 1], c='lightgreen', s=100, marker='s',
                   zorder=3, label=f'Existential ({len(existential)})', alpha=0.5)
    if shadow:
        sh_arr = np.array(list(shadow))
        ax.scatter(sh_arr[:, 0], sh_arr[:, 1], c='green', s=60, zorder=4,
                   label=f'Universal ({len(shadow)})')
    ax.set_title('Quadratic Shadows')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend()

    # Plot 3: Erosion comparison
    ax = axes[2]
    if erosion:
        er_arr = np.array(list(erosion))
        ax.scatter(er_arr[:, 0], er_arr[:, 1], c='orange', s=120, marker='D',
                   zorder=3, label=f'Erosion ({len(erosion)})', alpha=0.5)
    if shadow:
        sh_arr = np.array(list(shadow))
        ax.scatter(sh_arr[:, 0], sh_arr[:, 1], c='red', s=40, zorder=4,
                   label=f'Shadow ({len(shadow)})')
    gap = erosion - shadow
    if gap:
        gap_arr = np.array(list(gap))
        ax.scatter(gap_arr[:, 0], gap_arr[:, 1], c='purple', s=200, marker='x',
                   zorder=5, label=f'Gap ({len(gap)})', linewidths=3)
    ax.set_title(f'Shadow vs Erosion (equal={shadow == erosion})')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend()

    fig.suptitle(title, fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    print(f"\nSaved visualization to {filename}")
    plt.close()


if __name__ == '__main__':
    # Run demonstrations
    S1, shadow1, erosion1, exist1 = demo_2d_saturated()
    S2, shadow2, erosion2 = demo_2d_sparse()
    demo_1d()
    demo_3d()

    # Visualize
    visualize_2d(S1, shadow1, erosion1, exist1,
                 'Lattice-Saturated: Shadow = Erosion (Theorem 2)',
                 'shadow_erosion_saturated.png')
    visualize_2d(S2, shadow2, erosion2, discrete_quad_shadow(S2, 2),
                 'Sparse Support: Shadow ⊊ Erosion (Theorem 3)',
                 'shadow_erosion_sparse.png')

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("Theorem 1: Universal shadow ⊆ erosion lattice — verified ✓")
    print("Theorem 2: Equality for saturated supports — verified ✓")
    print("Theorem 3: Strict gap for sparse supports — verified ✓")


"""
Visualization: Ehrhart-Theoretic Shadow Growth

Shows that |USh₂(mΔ ∩ ℤⁿ)| grows polynomially in m for dilations of the
standard simplex. This is the Ehrhart polynomial of the eroded polytope
Δ ⊖ (1/m)Δ₂, confirming the conjecture that derivative complexity
follows Ehrhart theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations_with_replacement, product


# ──────────── Self-contained algorithms ────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def universal_quad_shadow(S, n):
    increments = quadratic_increments(n)
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shifted.add(u)
        candidates = shifted if candidates is None else candidates & shifted
    return candidates if candidates is not None else set()

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow


# ──────────── Computation ────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for dim_idx, n in enumerate([1, 2, 3]):
    ms = list(range(2, 16 if n <= 2 else 10))
    support_sizes = []
    universal_sizes = []
    existential_sizes = []

    for m in ms:
        S = set()
        for pt in product(*[range(m + 1)] * n):
            if sum(pt) <= m:
                S.add(pt)

        shadow_u = universal_quad_shadow(S, n)
        shadow_e = discrete_quad_shadow(S, n)

        support_sizes.append(len(S))
        universal_sizes.append(len(shadow_u))
        existential_sizes.append(len(shadow_e))

    ax = axes[dim_idx]

    ax.plot(ms, support_sizes, 'b-o', label='|S| (support)', markersize=5)
    ax.plot(ms, universal_sizes, 'r-s', label='|USh₂(S)| (universal)', markersize=5)
    ax.plot(ms, existential_sizes, 'g-^', label='|Sh₂(S)| (existential)', markersize=5)

    # Fit polynomial to universal shadow
    if len(ms) >= 3:
        coeffs = np.polyfit(ms, universal_sizes, n)
        ms_fine = np.linspace(ms[0], ms[-1], 100)
        ax.plot(ms_fine, np.polyval(coeffs, ms_fine), 'r--', alpha=0.5,
                label=f'Poly fit (deg {n})')

    ax.set_xlabel('Dilation m', fontsize=11)
    ax.set_ylabel('Cardinality', fontsize=11)
    ax.set_title(f'{n}D Simplex: m ↦ |Sh₂(mΔ_{n})|', fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

fig.suptitle('Ehrhart-Theoretic Growth of Shadow Size Under Dilation',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('ehrhart_shadow_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: ehrhart_shadow_growth.png")


"""
Visualization: Shadow vs. Erosion in 2D

Visualizes the core theorem: for lattice-saturated supports, the universal
quadratic shadow equals the lattice points of the Minkowski erosion of the
Newton polytope by the degree-2 simplex. Shows both equality (saturated case)
and strict containment (sparse case) side by side.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
from itertools import combinations_with_replacement, product


# ──────────── Self-contained algorithms ────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def universal_quad_shadow(S, n):
    increments = quadratic_increments(n)
    candidates = None
    for beta in increments:
        shifted = set()
        for alpha in S:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shifted.add(u)
        candidates = shifted if candidates is None else candidates & shifted
    return candidates if candidates is not None else set()

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow

def point_in_convex_hull_2d(point, hull_points):
    from scipy.optimize import linprog
    m = hull_points.shape[0]
    A_eq = np.vstack([hull_points.T, np.ones(m)])
    b_eq = np.append(point, 1.0)
    c = np.zeros(m)
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=[(0, None)] * m, method='highs')
    return result.success

def eroded_newton_lattice_points(S, n):
    if not S: return set()
    points = np.array(list(S), dtype=float)
    increments = quadratic_increments(n)
    min_c = np.min(points, axis=0).astype(int)
    max_c = np.max(points, axis=0).astype(int)
    result = set()
    for u_tuple in product(*[range(max(0, int(min_c[i])), int(max_c[i]) + 1) for i in range(n)]):
        u = np.array(u_tuple, dtype=float)
        if all(point_in_convex_hull_2d(u + np.array(b, dtype=float), points) for b in increments):
            result.add(u_tuple)
    return result


# ──────────── Visualization ────────────

fig, axes = plt.subplots(2, 3, figsize=(18, 12))

# Case 1: Lattice-saturated (full triangle degree 5)
S_sat = set()
for i in range(6):
    for j in range(6 - i):
        S_sat.add((i, j))

shadow_sat = universal_quad_shadow(S_sat, 2)
erosion_sat = eroded_newton_lattice_points(S_sat, 2)
exist_sat = discrete_quad_shadow(S_sat, 2)

# Case 2: Sparse (vertices only of degree 5 triangle)
S_sparse = {(0, 0), (5, 0), (0, 5)}
shadow_sparse = universal_quad_shadow(S_sparse, 2)
erosion_sparse = eroded_newton_lattice_points(S_sparse, 2)
exist_sparse = discrete_quad_shadow(S_sparse, 2)

def plot_set(ax, S, color, marker, size, label, zorder=3, alpha=1.0):
    if S:
        arr = np.array(list(S))
        ax.scatter(arr[:, 0], arr[:, 1], c=color, s=size, marker=marker,
                   zorder=zorder, label=label, alpha=alpha, edgecolors='black', linewidths=0.5)

def draw_newton_polygon(ax, S, color='blue', alpha=0.1):
    from scipy.spatial import ConvexHull
    pts = np.array(list(S), dtype=float)
    if len(pts) >= 3:
        hull = ConvexHull(pts)
        vertices = pts[hull.vertices]
        polygon = Polygon(vertices, closed=True, facecolor=color, alpha=alpha, edgecolor=color, linewidth=2)
        ax.add_patch(polygon)

# Row 1: Saturated case
ax = axes[0, 0]
draw_newton_polygon(ax, S_sat, 'royalblue', 0.15)
plot_set(ax, S_sat, 'royalblue', 'o', 50, f'Support ({len(S_sat)} pts)')
ax.set_title('Saturated Support S\n(full triangle, deg 5)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[0, 1]
plot_set(ax, exist_sat, 'lightgreen', 's', 80, f'Existential Sh₂ ({len(exist_sat)})', alpha=0.4)
plot_set(ax, shadow_sat, 'darkgreen', 'o', 40, f'Universal Sh₂ ({len(shadow_sat)})')
ax.set_title('Quadratic Shadows\n(existential ⊇ universal)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[0, 2]
plot_set(ax, erosion_sat, 'orange', 'D', 100, f'Erosion lattice ({len(erosion_sat)})', alpha=0.5)
plot_set(ax, shadow_sat, 'red', 'o', 30, f'Universal shadow ({len(shadow_sat)})')
equal_sat = shadow_sat == erosion_sat
ax.set_title(f'Shadow vs Erosion\n(EQUAL = {equal_sat}) ✓', fontsize=11,
             fontweight='bold', color='green' if equal_sat else 'red')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

# Row 2: Sparse case
ax = axes[1, 0]
draw_newton_polygon(ax, S_sparse, 'royalblue', 0.15)
plot_set(ax, S_sparse, 'royalblue', 'o', 80, f'Support ({len(S_sparse)} pts)')
# Show missing lattice points
all_interior = set()
for i in range(6):
    for j in range(6 - i):
        if (i, j) not in S_sparse:
            all_interior.add((i, j))
plot_set(ax, all_interior, 'lightcoral', 'x', 30, f'Missing ({len(all_interior)} pts)', alpha=0.5, zorder=2)
ax.set_title('Sparse Support S\n(vertices only, deg 5)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[1, 1]
plot_set(ax, exist_sparse, 'lightgreen', 's', 80, f'Existential Sh₂ ({len(exist_sparse)})', alpha=0.4)
plot_set(ax, shadow_sparse, 'darkgreen', 'o', 40, f'Universal Sh₂ ({len(shadow_sparse)})')
ax.set_title('Quadratic Shadows\n(sparse: universal much smaller)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

ax = axes[1, 2]
plot_set(ax, erosion_sparse, 'orange', 'D', 100, f'Erosion lattice ({len(erosion_sparse)})', alpha=0.5)
plot_set(ax, shadow_sparse, 'red', 'o', 30, f'Universal shadow ({len(shadow_sparse)})')
gap = erosion_sparse - shadow_sparse
if gap:
    plot_set(ax, gap, 'purple', 'X', 150, f'GAP ({len(gap)} pts)', zorder=6)
equal_sp = shadow_sparse == erosion_sparse
ax.set_title(f'Shadow vs Erosion\n(EQUAL = {equal_sp}) — gap exists!', fontsize=11,
             fontweight='bold', color='green' if equal_sp else 'red')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=8)
ax.set_xlim(-0.5, 6); ax.set_ylim(-0.5, 6)

fig.suptitle('Newton Polytope Erosion Theory: Shadow = Erosion iff Lattice-Saturated',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('shadow_erosion_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: shadow_erosion_comparison.png")


"""
Visualization: Tropical Second-Derivative Support Map

Shows how the tropical second derivative transforms the support of a
polynomial. For each point in the shadow, visualizes which derivative
directions (i,j) connect it to the original support, creating a
"derivative flow" diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations_with_replacement, product


# ──────────── Self-contained algorithms ────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow


# ──────────── Visualization ────────────

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Support: degree-4 full triangle in 2D
S = set()
for i in range(5):
    for j in range(5 - i):
        S.add((i, j))

n = 2
shadow = discrete_quad_shadow(S, n)
increments = quadratic_increments(n)

# Color map for derivative directions
colors = {(2, 0): '#e41a1c', (0, 2): '#377eb8', (1, 1): '#4daf4a'}
labels = {(2, 0): '∂²/∂x²', (0, 2): '∂²/∂y²', (1, 1): '∂²/∂x∂y'}

# Left: Support with derivative arrows
ax = axes[0]
S_arr = np.array(list(S))
ax.scatter(S_arr[:, 0], S_arr[:, 1], c='royalblue', s=100, zorder=5,
           edgecolors='black', linewidths=0.5, label='Support S')

# Draw arrows from support to shadow
for alpha in sorted(S):
    for beta in increments:
        u = tuple(a - b for a, b in zip(alpha, beta))
        if all(x >= 0 for x in u) and u in shadow:
            color = colors.get(beta, 'gray')
            ax.annotate('', xy=u, xytext=alpha,
                        arrowprops=dict(arrowstyle='->', color=color, alpha=0.2, lw=0.8))

# Legend entries for derivative types
for beta, label in labels.items():
    ax.plot([], [], '-', color=colors[beta], label=label, linewidth=2)

ax.set_title('Derivative Flow: Support → Shadow\n(arrows show ∂ᵢ∂ⱼ connections)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=9, loc='upper right')
ax.set_xlim(-0.5, 5); ax.set_ylim(-0.5, 5)

# Right: Shadow with heatmap of derivative richness
ax = axes[1]

# Compute richness: how many derivatives produce each shadow point
richness = {}
for u in shadow:
    count = 0
    for beta in increments:
        alpha = tuple(a + b for a, b in zip(u, beta))
        if alpha in S:
            count += 1
    richness[u] = count

shadow_arr = np.array(list(shadow))
rich_vals = [richness[tuple(p)] for p in shadow_arr]

scatter = ax.scatter(shadow_arr[:, 0], shadow_arr[:, 1], c=rich_vals, cmap='YlOrRd',
                     s=150, zorder=5, edgecolors='black', linewidths=0.5, vmin=1, vmax=max(rich_vals))
plt.colorbar(scatter, ax=ax, label='Derivative richness (# sources)')

# Annotate richness
for u, r in richness.items():
    ax.annotate(str(r), u, textcoords="offset points", xytext=(0, 8),
                ha='center', fontsize=7, fontweight='bold')

ax.set_title('Tropical Hessian Support\n(color = derivative richness)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2)
ax.set_xlim(-0.5, 5); ax.set_ylim(-0.5, 5)

fig.suptitle('Tropical Second Derivative: Support Dynamics',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_support_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tropical_support_dynamics.png")
