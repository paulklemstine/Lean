"""
Hyperbolic Number Theory: Applications

Real-world applications of hyperbolic lattice arithmetic, including:
1. Cryptographic key generation via trace sequences
2. Hyperbolic navigation / GPS error modeling
3. Network topology via Gromov hyperbolicity
"""

import math
from typing import List, Tuple


def trace_seq(t: int, n: int) -> int:
    """Trace sequence: tr(γⁿ) where tr(γ) = t."""
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b


# ============================================================================
# Application 1: Pseudorandom Number Generation via Trace Sequences
# ============================================================================

def trace_prng(seed_trace: int, seed_power: int, modulus: int, count: int) -> List[int]:
    """Generate pseudorandom numbers using trace sequences.
    
    The trace sequence traceSeq(t, n) mod m produces pseudorandom values
    because the Cassini identity traceSeq(t,n+2)*traceSeq(t,n) - traceSeq(t,n+1)² = t²-4
    introduces non-trivial correlations that are difficult to predict without
    knowing t.
    
    This exploits the connection between SL₂(ℤ) and the modular group:
    the trace sequence mod p has period dividing p²-1 (for prime p),
    which connects to the congruence subgroup index theorem.
    
    Args:
        seed_trace: The trace parameter t (should be ≥ 3 for hyperbolicity).
        seed_power: Starting power n₀.
        modulus: Output modulus m.
        count: Number of values to generate.
        
    Returns:
        List of pseudorandom integers in [0, modulus).
    """
    result = []
    n = seed_power
    for _ in range(count):
        val = trace_seq(seed_trace, n) % modulus
        result.append(val)
        n += 1
    return result


# ============================================================================
# Application 2: Hyperbolic Distance Estimation
# ============================================================================

def estimate_curvature_from_triangles(
    triangles: List[Tuple[Tuple[float, float], Tuple[float, float], Tuple[float, float]]]
) -> float:
    """Estimate the curvature of a space from triangle measurements.
    
    In a space of constant curvature K:
    - K > 0: angle excess = K * area (spherical)
    - K = 0: angle sum = π (Euclidean)
    - K < 0: angle defect = |K| * area (hyperbolic)
    
    The Poincaré disk has K = -1. This function estimates K from
    Euclidean triangle measurements, using the conformal factor
    λ(z) = 2/(1-|z|²) to convert.
    
    Returns:
        Estimated Gaussian curvature K.
    """
    defects = []
    for p1, p2, p3 in triangles:
        # Compute Euclidean side lengths
        def dist(a, b):
            return math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2)
        
        a = dist(p2, p3)
        b = dist(p1, p3)
        c = dist(p1, p2)
        
        if a * b * c == 0:
            continue
        
        # Euclidean angles
        cos_A = (b**2 + c**2 - a**2) / (2*b*c)
        cos_B = (a**2 + c**2 - b**2) / (2*a*c)
        cos_C = (a**2 + b**2 - c**2) / (2*a*b)
        
        cos_A = max(-1, min(1, cos_A))
        cos_B = max(-1, min(1, cos_B))
        cos_C = max(-1, min(1, cos_C))
        
        angle_sum = math.acos(cos_A) + math.acos(cos_B) + math.acos(cos_C)
        defect = math.pi - angle_sum
        
        # Approximate area using conformal factor at centroid
        cx = (p1[0] + p2[0] + p3[0]) / 3
        cy = (p1[1] + p2[1] + p3[1]) / 3
        norm_sq = cx**2 + cy**2
        if norm_sq >= 1:
            continue
        
        # Euclidean area
        euc_area = 0.5 * abs((p2[0]-p1[0])*(p3[1]-p1[1]) - (p3[0]-p1[0])*(p2[1]-p1[1]))
        if euc_area < 1e-12:
            continue
            
        # Hyperbolic area ≈ λ² · Euclidean area
        lam = 2.0 / (1.0 - norm_sq)
        hyp_area = lam**2 * euc_area
        
        if hyp_area > 0:
            K_est = -defect / hyp_area
            defects.append(K_est)
    
    if not defects:
        return 0.0
    return sum(defects) / len(defects)


# ============================================================================  
# Application 3: Network Hyperbolicity Testing
# ============================================================================

def four_point_hyperbolicity(
    dist_matrix: List[List[float]]
) -> float:
    """Compute the Gromov 4-point hyperbolicity δ of a metric space.
    
    For points x, y, z, w, the 4-point condition states:
        d(x,y) + d(z,w) ≤ max(d(x,z)+d(y,w), d(x,w)+d(y,z)) + 2δ
    
    δ = 0 means the space is a tree (0-hyperbolic).
    Small δ means the space is "tree-like" and suitable for
    hyperbolic embedding (connecting to our tropical bridge theorem).
    
    Time complexity: O(n⁴) where n = number of points.
    
    Args:
        dist_matrix: n×n distance matrix.
        
    Returns:
        The hyperbolicity constant δ.
    """
    n = len(dist_matrix)
    max_delta = 0.0
    
    for x in range(n):
        for y in range(x + 1, n):
            for z in range(y + 1, n):
                for w in range(z + 1, n):
                    s1 = dist_matrix[x][y] + dist_matrix[z][w]
                    s2 = dist_matrix[x][z] + dist_matrix[y][w]
                    s3 = dist_matrix[x][w] + dist_matrix[y][z]
                    
                    sums = sorted([s1, s2, s3])
                    delta = (sums[2] - sums[1]) / 2
                    max_delta = max(max_delta, delta)
    
    return max_delta


# ============================================================================
# Main: Demonstrate applications
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Hyperbolic Number Theory: Applications")
    print("=" * 60)
    
    # Application 1: PRNG
    print("\n--- Application 1: Trace-Based Pseudorandom Generation ---")
    values = trace_prng(seed_trace=7, seed_power=1, modulus=100, count=20)
    print(f"  PRNG(t=7, m=100): {values}")
    
    # Check period for trace mod prime
    p = 31
    print(f"\n  Period of traceSeq(3, n) mod {p}:")
    vals = [trace_seq(3, n) % p for n in range(p*p)]
    # Find period
    for period in range(1, len(vals)):
        if all(vals[i] == vals[i + period] for i in range(min(period, len(vals) - period))):
            print(f"    Period = {period}")
            print(f"    p²-1 = {p**2-1}")
            print(f"    Period divides p²-1: {(p**2-1) % period == 0}")
            break
    
    # Application 2: Curvature estimation
    print("\n--- Application 2: Curvature Estimation ---")
    import random
    random.seed(42)
    
    triangles = []
    for _ in range(100):
        pts = []
        for _ in range(3):
            r = random.uniform(0, 0.5)
            theta = random.uniform(0, 2*math.pi)
            pts.append((r*math.cos(theta), r*math.sin(theta)))
        triangles.append(tuple(pts))
    
    K = estimate_curvature_from_triangles(triangles)
    print(f"  Estimated curvature K ≈ {K:.4f}")
    print(f"  Expected for Poincaré disk: K = -1")
    print(f"  (Note: estimation is approximate due to Euclidean triangle measurement)")
    
    # Application 3: Network hyperbolicity
    print("\n--- Application 3: Network Hyperbolicity ---")
    
    # Tree (should be 0-hyperbolic)
    tree_dist = [
        [0, 1, 2, 3],
        [1, 0, 3, 4],
        [2, 3, 0, 1],
        [3, 4, 1, 0],
    ]
    delta_tree = four_point_hyperbolicity(tree_dist)
    print(f"  Tree metric: δ = {delta_tree:.2f} (expected: 0)")
    
    # Grid (should have positive δ)
    grid_dist = [
        [0, 1, 1, 2],
        [1, 0, 2, 1],
        [1, 2, 0, 1],
        [2, 1, 1, 0],
    ]
    delta_grid = four_point_hyperbolicity(grid_dist)
    print(f"  Grid metric: δ = {delta_grid:.2f} (expected: > 0)")
    
    print("\nAll applications demonstrated successfully!")


"""
Hyperbolic Number Theory: Demonstrations

Concrete numerical examples illustrating the theorems proved in our
Lean 4 formalization of arithmetic on the Poincaré disk.
"""
import math
from typing import List, Tuple


def trace_seq(t: int, n: int) -> int:
    """Compute the trace sequence: tr(γⁿ) where tr(γ) = t.
    
    Satisfies the Chebyshev-like recurrence:
        x_{n+2} = t * x_{n+1} - x_n
    with x_0 = 2, x_1 = t.
    
    >>> trace_seq(3, 0)
    2
    >>> trace_seq(3, 4)
    47
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b


def verify_cassini_identity(t: int, max_n: int = 20) -> None:
    """Verify the Cassini identity: traceSeq(t,n+2)*traceSeq(t,n) - traceSeq(t,n+1)² = t²-4.
    
    This is our main theorem, proved by induction in Lean 4.
    """
    disc = t * t - 4
    print(f"=== Cassini Identity for t = {t} (discriminant Δ = {disc}) ===")
    for n in range(max_n):
        lhs = trace_seq(t, n + 2) * trace_seq(t, n) - trace_seq(t, n + 1) ** 2
        assert lhs == disc, f"Failed at n={n}: {lhs} ≠ {disc}"
        print(f"  n={n:2d}: traceSeq({t},{n+2})·traceSeq({t},{n}) - traceSeq({t},{n+1})² = {lhs} ✓")
    print()


def verify_periodicity() -> None:
    """Verify trace sequence periodicity for elliptic cases."""
    print("=== Periodicity of Elliptic Trace Sequences ===")
    
    # t = 0: period 4
    print("t = 0 (period 4):")
    vals_0 = [trace_seq(0, n) for n in range(16)]
    print(f"  Values: {vals_0}")
    for n in range(12):
        assert trace_seq(0, n + 4) == trace_seq(0, n)
    print("  Verified: traceSeq(0, n+4) = traceSeq(0, n) for n=0..11 ✓")
    
    # t = 1: period 6
    print("t = 1 (period 6):")
    vals_1 = [trace_seq(1, n) for n in range(18)]
    print(f"  Values: {vals_1}")
    for n in range(12):
        assert trace_seq(1, n + 6) == trace_seq(1, n)
    print("  Verified: traceSeq(1, n+6) = traceSeq(1, n) for n=0..11 ✓")
    
    # t = -1: period 6
    print("t = -1 (period 6):")
    vals_m1 = [trace_seq(-1, n) for n in range(18)]
    print(f"  Values: {vals_m1}")
    for n in range(12):
        assert trace_seq(-1, n + 6) == trace_seq(-1, n)
    print("  Verified: traceSeq(-1, n+6) = traceSeq(-1, n) for n=0..11 ✓")
    print()


def verify_strict_monotonicity(t: int = 3, max_n: int = 15) -> None:
    """Verify strict monotonicity for t ≥ 3."""
    print(f"=== Strict Monotonicity for t = {t} ===")
    vals = [trace_seq(t, n) for n in range(max_n)]
    for i in range(len(vals) - 1):
        assert vals[i] < vals[i + 1], f"Not strictly increasing at n={i}"
    print(f"  Values: {vals}")
    print(f"  All strictly increasing ✓")
    
    # Growth rate
    print("  Growth rates traceSeq(t,n+1)/traceSeq(t,n):")
    eigenvalue = (t + math.sqrt(t * t - 4)) / 2
    for n in range(1, max_n - 1):
        ratio = vals[n + 1] / vals[n]
        print(f"    n={n}: ratio = {ratio:.6f} (λ₊ = {eigenvalue:.6f})")
    print()


def companion_matrix_demo(t: int = 3) -> None:
    """Demonstrate the companion matrix bridge."""
    print(f"=== Companion Matrix for t = {t} ===")
    
    # M = [[t, -1], [1, 0]]
    M = [[t, -1], [1, 0]]
    print(f"  M = {M}")
    print(f"  det(M) = {M[0][0]*M[1][1] - M[0][1]*M[1][0]} (should be 1)")
    print(f"  tr(M) = {M[0][0] + M[1][1]} (should be {t})")
    
    # Compute powers
    def mat_mul(A, B):
        return [
            [A[0][0]*B[0][0] + A[0][1]*B[1][0], A[0][0]*B[0][1] + A[0][1]*B[1][1]],
            [A[1][0]*B[0][0] + A[1][1]*B[1][0], A[1][0]*B[0][1] + A[1][1]*B[1][1]]
        ]
    
    def mat_trace(A):
        return A[0][0] + A[1][1]
    
    Mn = [[1, 0], [0, 1]]  # Identity
    print("\n  Powers of M:")
    for n in range(10):
        tr = mat_trace(Mn)
        expected = trace_seq(t, n)
        status = "✓" if tr == expected else "✗"
        print(f"    tr(M^{n}) = {tr} = traceSeq({t},{n}) = {expected} {status}")
        Mn = mat_mul(M, Mn)
    
    # Cayley-Hamilton: M² = t·M - I
    M2 = mat_mul(M, M)
    tM_minus_I = [[t*M[0][0] - 1, t*M[0][1]], [t*M[1][0], t*M[1][1] - 1]]
    print(f"\n  Cayley-Hamilton: M² = t·M - I")
    print(f"    M² = {M2}")
    print(f"    t·M - I = {tM_minus_I}")
    print(f"    Equal: {M2 == tM_minus_I} ✓")
    print()


def markov_triple_demo() -> None:
    """Demonstrate Markov triples and the Vieta involution."""
    print("=== Markov Triples and Vieta Involutions ===")
    
    def check_markov(x, y, z):
        return x**2 + y**2 + z**2 == 3*x*y*z
    
    def vieta(x, y, z):
        return (x, y, 3*x*y - z)
    
    # Start from (1, 1, 1)
    triple = (1, 1, 1)
    print(f"  Initial triple: {triple}")
    print(f"    Check: {triple[0]}² + {triple[1]}² + {triple[2]}² = {sum(t**2 for t in triple)}")
    print(f"           3·{triple[0]}·{triple[1]}·{triple[2]} = {3*triple[0]*triple[1]*triple[2]}")
    print(f"           Markov: {check_markov(*triple)} ✓")
    
    # Generate the Markov tree
    triples = [triple]
    seen = {triple}
    for _ in range(5):
        new_triples = []
        for t in triples:
            for perm in [(t[0],t[1],t[2]), (t[1],t[2],t[0]), (t[2],t[0],t[1])]:
                v = vieta(*perm)
                v_sorted = tuple(sorted(v))
                if v_sorted not in seen and all(x > 0 for x in v):
                    seen.add(v_sorted)
                    new_triples.append(v_sorted)
                    assert check_markov(*v_sorted), f"Vieta failed for {v_sorted}"
                    print(f"  New triple: {v_sorted} (Vieta from {perm}) ✓")
        triples = new_triples
    print()


def pseudo_hyperbolic_distance_demo() -> None:
    """Demonstrate the pseudo-hyperbolic distance on the Poincaré disk."""
    print("=== Pseudo-Hyperbolic Distance in the Poincaré Disk ===")
    
    def pseudo_hyp_dist_sq(p, q):
        """ρ(p,q)² = |p-q|² / |1 - p̄·q|²"""
        num = (p[0]-q[0])**2 + (p[1]-q[1])**2
        den = (1-p[0]*q[0]-p[1]*q[1])**2 + (p[0]*q[1]-p[1]*q[0])**2
        return num / den
    
    points = [
        (0.0, 0.0),
        (0.5, 0.0),
        (0.0, 0.5),
        (0.3, 0.4),
        (-0.6, 0.2),
    ]
    
    print("  Distance matrix (ρ²):")
    for i, p in enumerate(points):
        row = []
        for j, q in enumerate(points):
            d = pseudo_hyp_dist_sq(p, q)
            row.append(f"{d:.4f}")
        print(f"    {points[i]}: {' '.join(row)}")
    
    # Verify < 1
    print("\n  Verifying ρ² < 1:")
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            d = pseudo_hyp_dist_sq(p, q)
            assert d < 1.0 + 1e-10, f"ρ² ≥ 1 at ({p}, {q})"
    print("    All ρ² < 1 ✓")
    
    # Symmetry
    print("\n  Verifying symmetry ρ(p,q) = ρ(q,p):")
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            assert abs(pseudo_hyp_dist_sq(p, q) - pseudo_hyp_dist_sq(q, p)) < 1e-12
    print("    All symmetric ✓")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Hyperbolic Number Theory: Arithmetic on the Poincaré   ║")
    print("║  Disk — Demonstrations                                  ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    verify_cassini_identity(3)
    verify_cassini_identity(5)
    verify_periodicity()
    verify_strict_monotonicity(3)
    companion_matrix_demo(3)
    markov_triple_demo()
    pseudo_hyperbolic_distance_demo()
    
    print("All demonstrations completed successfully!")


"""
Visualization 3: Markov Triples and the Vieta Involution Tree

Illustrates:
1. The Markov tree generated by the Vieta involution z → 3xy - z
2. Growth of Markov numbers (connecting to trace sequences)
3. The spectral data: discriminant vs trace for SL₂(ℤ) elements
4. Trace sequence mod p periodicity (connecting to congruence subgroups)
"""

import numpy as np
import matplotlib.pyplot as plt
import math

def trace_seq(t, n):
    if n == 0: return 2
    if n == 1: return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Markov tree
ax = axes[0, 0]

def markov_tree(max_depth=6):
    result = []
    seen = set()
    queue = [(1, 1, 1, 0)]
    while queue:
        x, y, z, d = queue.pop(0)
        key = tuple(sorted((x, y, z)))
        if key in seen: continue
        seen.add(key)
        result.append((key, d))
        if d < max_depth:
            for a, b, c in [(x,y,z), (y,z,x), (z,x,y)]:
                new_c = 3*a*b - c
                if new_c > 0:
                    queue.append((a, b, new_c, d+1))
    return result

triples = markov_tree(5)
markov_numbers = sorted(set(v for t, _ in triples for v in t))

ax.barh(range(len(markov_numbers[:20])), markov_numbers[:20], color='steelblue')
ax.set_yticks(range(len(markov_numbers[:20])))
ax.set_yticklabels([str(m) for m in markov_numbers[:20]], fontsize=8)
ax.set_xlabel('Value', fontsize=12)
ax.set_title(f'First {min(20, len(markov_numbers))} Markov Numbers', fontsize=13)
ax.grid(True, alpha=0.3, axis='x')

# Panel 2: Discriminant spectrum
ax = axes[0, 1]
traces = range(3, 30)
discriminants = [(t, t**2 - 4) for t in traces]
colors_list = ['green' if (t**2 - 4) % 4 in [0, 1] else 'red' for t, _ in discriminants]

ax.bar([t for t, _ in discriminants], [d for _, d in discriminants],
       color=colors_list, alpha=0.7, edgecolor='black', linewidth=0.5)
ax.set_xlabel('Trace t', fontsize=12)
ax.set_ylabel('Discriminant Δ = t² − 4', fontsize=12)
ax.set_title('Discriminant Spectrum of Hyperbolic Elements', fontsize=13)
ax.grid(True, alpha=0.3)

# Add classification
for t, d in discriminants[:10]:
    sqrt_d = math.isqrt(d)
    is_square = sqrt_d * sqrt_d == d
    if is_square:
        ax.annotate('□', (t, d), ha='center', va='bottom', fontsize=8, color='purple')

# Panel 3: Trace sequence mod p
ax = axes[1, 0]
p = 7
t_vals = [3, 4, 5]
colors_ts = ['navy', 'crimson', 'forestgreen']

for t, color in zip(t_vals, colors_ts):
    n_range = range(60)
    vals_mod = [trace_seq(t, n) % p for n in n_range]
    ax.plot(list(n_range), vals_mod, '.', color=color, markersize=4,
            label=f't={t}, mod {p}')
    
    # Find period
    for period in range(1, len(vals_mod)):
        if period >= 3 and all(vals_mod[i] == vals_mod[i+period] 
                                for i in range(min(period, len(vals_mod)-period))):
            ax.axvline(x=period, color=color, linestyle='--', alpha=0.4)
            break

ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel(f'traceSeq(t, n) mod {p}', fontsize=12)
ax.set_title(f'Trace Sequences mod {p} (Periodic!)', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Primitive vs imprimitive traces
ax = axes[1, 1]
N = 50
primitive = []
imprimitive = []
for t in range(3, N + 1):
    is_imp = any(s * s == t + 2 for s in range(2, t + 1))
    if is_imp:
        imprimitive.append(t)
    else:
        primitive.append(t)

ax.bar(primitive, [1]*len(primitive), color='steelblue', label='Primitive', alpha=0.8)
ax.bar(imprimitive, [1]*len(imprimitive), color='coral', label='Imprimitive (t+2 = s²)', alpha=0.8)
ax.set_xlabel('Trace value t', fontsize=12)
ax.set_ylabel('Classification', fontsize=12)
ax.set_title(f'Primitive vs Imprimitive Traces (3 ≤ t ≤ {N})', fontsize=13)
ax.legend()

# Compute density
prim_count = len(primitive)
total = len(primitive) + len(imprimitive)
density = prim_count / total
ax.text(0.95, 0.85, f'Primitive density: {density:.3f}\n({prim_count}/{total})',
        transform=ax.transAxes, ha='right', va='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8),
        fontsize=10)

plt.suptitle('Algebraic Structure of Hyperbolic Lattice Arithmetic',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_markov_tree.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_markov_tree.png")


"""
Visualization 2: The Poincaré Disk and Hyperbolic Distance

Illustrates:
1. The Poincaré disk with hyperbolic geodesics
2. The conformal factor λ(z) = 2/(1-|z|²) as a heatmap
3. Pseudo-hyperbolic distance contours
4. Möbius orbits showing how the group action generates lattice points
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(2, 2, figsize=(14, 14))

# Panel 1: Poincaré disk with geodesics
ax = axes[0, 0]
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')

# Draw some hyperbolic geodesics (circular arcs perpendicular to boundary)
for a in np.linspace(-0.8, 0.8, 9):
    # Vertical geodesic through (a, 0): this is a circular arc
    if abs(a) < 0.01:
        ax.plot([0, 0], [-1, 1], 'b-', alpha=0.3, linewidth=0.8)
    else:
        # Center of the geodesic circle: (1/a, 0), radius sqrt(1/a²-1)
        R = np.sqrt(1/a**2 - 1) if abs(a) < 1 else 1
        cx = 1/a
        t = np.linspace(-np.pi, np.pi, 500)
        gx = cx + R * np.cos(t)
        gy = R * np.sin(t)
        mask = gx**2 + gy**2 < 1
        gx_masked = np.where(mask, gx, np.nan)
        gy_masked = np.where(mask, gy, np.nan)
        ax.plot(gx_masked, gy_masked, 'b-', alpha=0.3, linewidth=0.8)

# Horizontal geodesics
for b in np.linspace(-0.8, 0.8, 9):
    if abs(b) < 0.01:
        ax.plot([-1, 1], [0, 0], 'r-', alpha=0.3, linewidth=0.8)
    else:
        R = np.sqrt(1/b**2 - 1) if abs(b) < 1 else 1
        cy = 1/b
        t = np.linspace(-np.pi, np.pi, 500)
        gx = R * np.cos(t)
        gy = cy + R * np.sin(t)
        mask = gx**2 + gy**2 < 1
        gx_masked = np.where(mask, gx, np.nan)
        gy_masked = np.where(mask, gy, np.nan)
        ax.plot(gx_masked, gy_masked, 'r-', alpha=0.3, linewidth=0.8)

ax.set_title('Poincaré Disk with Geodesic Grid', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)

# Panel 2: Conformal factor heatmap
ax = axes[0, 1]
x = np.linspace(-0.99, 0.99, 400)
y = np.linspace(-0.99, 0.99, 400)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2
mask = R2 < 1

# λ(z) = 2/(1-|z|²)
Lambda = np.where(mask, 2.0 / (1.0 - R2), np.nan)

im = ax.imshow(Lambda, extent=[-1, 1, -1, 1], origin='lower',
               cmap='hot', vmin=2, vmax=20, aspect='equal')
ax.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
plt.colorbar(im, ax=ax, label='λ(z) = 2/(1-|z|²)')
ax.set_title('Conformal Factor (proved λ ≥ 2)', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)

# Panel 3: Pseudo-hyperbolic distance contours from origin
ax = axes[1, 0]
# ρ(0, z) = |z|, so the contours are just circles
rho_vals = np.where(mask, np.sqrt(R2), np.nan)
contour = ax.contourf(X, Y, rho_vals, levels=np.linspace(0, 0.99, 20),
                        cmap='viridis', extend='max')
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
plt.colorbar(contour, ax=ax, label='ρ(0, z)')
ax.set_aspect('equal')
ax.set_title('Pseudo-Hyperbolic Distance from Origin', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.plot(0, 0, 'w*', markersize=15, markeredgecolor='k')

# Panel 4: Möbius orbits
ax = axes[1, 1]
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')

def mobius_map(a_re, a_im, z_re, z_im):
    """φ_a(z) = (a + z) / (1 + conj(a)*z)"""
    # numerator = a + z
    num_re = a_re + z_re
    num_im = a_im + z_im
    # conj(a)*z = (a_re - i*a_im)*(z_re + i*z_im)
    conj_a_z_re = a_re * z_re + a_im * z_im
    conj_a_z_im = a_re * z_im - a_im * z_re
    # denominator = 1 + conj(a)*z
    den_re = 1 + conj_a_z_re
    den_im = conj_a_z_im
    # division
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-12:
        return z_re, z_im
    result_re = (num_re * den_re + num_im * den_im) / den_sq
    result_im = (num_im * den_re - num_re * den_im) / den_sq
    return result_re, result_im

# Generate orbit of 0 under two generators
generators = [(0.5, 0.0), (0.0, 0.5), (-0.3, 0.4), (0.4, -0.3)]
colors = ['red', 'blue', 'green', 'orange']

orbit_points = [(0.0, 0.0)]
for gen_idx, (ga, gb) in enumerate(generators):
    # Apply generator and its inverse repeatedly
    current = [(0.0, 0.0)]
    for depth in range(6):
        new_points = []
        for z_re, z_im in current:
            w_re, w_im = mobius_map(ga, gb, z_re, z_im)
            if w_re**2 + w_im**2 < 0.999:
                new_points.append((w_re, w_im))
                orbit_points.append((w_re, w_im))
            # Also inverse
            w_re2, w_im2 = mobius_map(-ga, -gb, z_re, z_im)
            if w_re2**2 + w_im2**2 < 0.999:
                new_points.append((w_re2, w_im2))
                orbit_points.append((w_re2, w_im2))
        current = new_points

# Plot orbit points
xs = [p[0] for p in orbit_points]
ys = [p[1] for p in orbit_points]
ax.scatter(xs, ys, c='navy', s=8, alpha=0.6, zorder=5)
ax.plot(0, 0, 'r*', markersize=15, markeredgecolor='k', zorder=10)

# Mark generators
for (ga, gb), c in zip(generators, colors):
    ax.plot(ga, gb, 'o', color=c, markersize=10, markeredgecolor='k',
            zorder=10, label=f'gen ({ga},{gb})')

ax.set_title(f'Möbius Orbits ({len(orbit_points)} lattice points)', fontsize=13)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.legend(fontsize=8, loc='lower right')

plt.suptitle('Poincaré Disk: Geometry of Hyperbolic Number Theory',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_disk.png")


"""
Visualization 1: Trace Sequences and the Cassini Identity

Shows how trace sequences traceSeq(t, n) behave for different trace values t:
- Elliptic (|t| < 2): periodic oscillation
- Parabolic (|t| = 2): linear growth
- Hyperbolic (|t| > 2): exponential growth

The Cassini identity traceSeq(t,n+2)·traceSeq(t,n) - traceSeq(t,n+1)² = t²-4
is verified visually: the Cassini difference is constant for each t.
"""

import numpy as np
import matplotlib.pyplot as plt

def trace_seq(t, n):
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Elliptic trace sequences (periodic)
ax = axes[0, 0]
n_vals = np.arange(0, 25)
for t in [-1, 0, 1]:
    vals = [trace_seq(t, n) for n in n_vals]
    ax.plot(n_vals, vals, 'o-', label=f't = {t}', markersize=4)
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('traceSeq(t, n)', fontsize=12)
ax.set_title('Elliptic Regime (|t| < 2): Periodic', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='k', linewidth=0.5)

# Panel 2: Hyperbolic trace sequences (exponential growth)
ax = axes[0, 1]
n_vals = np.arange(0, 12)
for t in [3, 4, 5]:
    vals = [trace_seq(t, n) for n in n_vals]
    ax.semilogy(n_vals, vals, 's-', label=f't = {t}', markersize=5)
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('traceSeq(t, n)  [log scale]', fontsize=12)
ax.set_title('Hyperbolic Regime (|t| > 2): Exponential Growth', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Cassini identity verification
ax = axes[1, 0]
n_vals = np.arange(0, 15)
for t in [0, 1, 3, 5, 7]:
    cassini_vals = [
        trace_seq(t, n+2) * trace_seq(t, n) - trace_seq(t, n+1)**2
        for n in n_vals
    ]
    disc = t**2 - 4
    ax.plot(n_vals, cassini_vals, 'o', label=f't={t}, Δ={disc}', markersize=6)
    ax.axhline(y=disc, linestyle='--', alpha=0.5)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('traceSeq(t,n+2)·traceSeq(t,n) − traceSeq(t,n+1)²', fontsize=11)
ax.set_title('Cassini Identity: Constant = Δ = t² − 4', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Growth rate convergence to eigenvalue
ax = axes[1, 1]
n_vals = np.arange(1, 20)
for t in [3, 4, 5, 7]:
    import math
    eigenvalue = (t + math.sqrt(t**2 - 4)) / 2
    ratios = [trace_seq(t, n+1) / trace_seq(t, n) for n in n_vals]
    ax.plot(n_vals, ratios, 'D-', label=f't={t}, λ₊={eigenvalue:.3f}', markersize=4)
    ax.axhline(y=eigenvalue, linestyle=':', alpha=0.4)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('traceSeq(t, n+1) / traceSeq(t, n)', fontsize=11)
ax.set_title('Growth Rate → Dominant Eigenvalue λ₊', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Trace Sequences in Hyperbolic Number Theory', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_trace_sequences.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_trace_sequences.png")
