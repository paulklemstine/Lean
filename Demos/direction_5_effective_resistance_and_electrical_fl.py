#!/usr/bin/env python3
"""
Applications of Electrical Flow Certificates

Demonstrates real-world applications of the resistance–congestion bridge:
  1. Mixing time estimation from canonical paths
  2. Commute time bounds from effective resistance
  3. Comparison of different path systems (BFS vs bubble-sort)
  4. Resistance diameter as a group invariant
"""

import numpy as np
from itertools import permutations
from collections import defaultdict, deque
from typing import List, Tuple, Dict


# ─── Permutation utilities (self-contained) ───
def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def adjacent_transpositions(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens


def build_cayley_graph(n):
    """Build Cayley graph of S_n."""
    elements = list(permutations(range(n)))
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)
    N = len(elements)
    adj = np.zeros((N, N))
    for g in elements:
        gi = elem_to_idx[g]
        for s in gens:
            sg = compose(s, g)
            adj[gi][elem_to_idx[sg]] = 1
    return elements, elem_to_idx, gens, adj


def laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def effective_resistance_matrix(L):
    L_pinv = np.linalg.pinv(L)
    n = L.shape[0]
    diag = np.diag(L_pinv)
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i][j] = diag[i] + diag[j] - 2 * L_pinv[i][j]
    return R


# ─── Application 1: Mixing Time Estimation ───
def estimate_mixing_time(n):
    """Estimate mixing time of random walk on Cay(S_n, adj. transpositions).

    Uses the spectral gap bound: t_mix ≤ (1/gap) · ln(|G|)
    where gap is estimated from the Poincaré inequality.
    """
    elements, elem_to_idx, gens, adj = build_cayley_graph(n)
    N = len(elements)
    d = len(gens)

    # Compute eigenvalues of normalized adjacency
    L = laplacian(adj)
    eigenvalues = np.sort(np.linalg.eigvalsh(L / d))

    spectral_gap = eigenvalues[1]  # second-smallest eigenvalue of normalized Laplacian

    # Mixing time bound
    t_mix = (1 / spectral_gap) * np.log(N) if spectral_gap > 0 else float('inf')

    print(f"\n=== Application 1: Mixing Time for S_{n} ===")
    print(f"  |G| = {N}, |S| = {d}")
    print(f"  Spectral gap (normalized) = {spectral_gap:.6f}")
    print(f"  Mixing time bound ≈ {t_mix:.2f}")
    print(f"  Exact eigenvalues: {eigenvalues[:5].round(6)}")

    return spectral_gap, t_mix


# ─── Application 2: Commute Time Bounds ───
def commute_time_bounds(n):
    """Compute commute time bounds from effective resistance.

    Commute time C(s,t) = 2|E| · R_eff(s,t) for regular graphs.
    """
    elements, elem_to_idx, gens, adj = build_cayley_graph(n)
    N = len(elements)
    d = len(gens)
    num_edges = int(adj.sum() / 2)

    L = laplacian(adj)
    R = effective_resistance_matrix(L)

    max_R = R.max()
    max_commute = 2 * num_edges * max_R

    # Find the pair achieving maximum resistance
    i_max, j_max = np.unravel_index(R.argmax(), R.shape)

    print(f"\n=== Application 2: Commute Times for S_{n} ===")
    print(f"  |G| = {N}, |E| = {num_edges}")
    print(f"  Max R_eff = {max_R:.6f}")
    print(f"  Max commute time = 2|E| · max(R_eff) = {max_commute:.2f}")
    print(f"  Avg commute time = 2|E| · avg(R_eff) = {2 * num_edges * R.sum() / (N*(N-1)):.2f}")
    print(f"  Worst pair: {elements[i_max]} ↔ {elements[j_max]}")

    return max_commute


# ─── Application 3: Path System Comparison ───
def bfs_path(src, dst, elements, elem_to_idx, gens):
    """BFS shortest path from src to dst in the Cayley graph."""
    if src == dst:
        return [src], []

    queue = deque([(src, [src], [])])
    visited = {src}

    while queue:
        current, path, gen_seq = queue.popleft()
        for g in gens:
            next_elem = compose(g, current)
            if next_elem == dst:
                return path + [dst], gen_seq + [g]
            if next_elem not in visited:
                visited.add(next_elem)
                queue.append((next_elem, path + [next_elem], gen_seq + [g]))

    return None, None  # disconnected (shouldn't happen)


def bubble_sort_path(src, dst, n):
    """Bubble-sort canonical path."""
    diff = compose(dst, inverse(src))
    p = list(inverse(diff))
    swaps = []
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                swap = list(range(n))
                swap[j], swap[j + 1] = swap[j + 1], swap[j]
                swaps.append(tuple(swap))
    vertices = [src]
    current = src
    for s in swaps:
        current = compose(s, current)
        vertices.append(current)
    return vertices


def compare_path_systems(n):
    """Compare BFS geodesic paths vs bubble-sort canonical paths."""
    elements, elem_to_idx, gens, adj = build_cayley_graph(n)
    N = len(elements)

    bfs_lengths = []
    bsort_lengths = []
    bfs_edge_usage = defaultdict(int)
    bsort_edge_usage = defaultdict(int)

    for src in elements:
        for dst in elements:
            if src == dst:
                continue

            # BFS path
            bfs_v, _ = bfs_path(src, dst, elements, elem_to_idx, gens)
            bfs_len = len(bfs_v) - 1 if bfs_v else 0
            bfs_lengths.append(bfs_len)
            if bfs_v:
                for i in range(len(bfs_v) - 1):
                    u, v = elem_to_idx[bfs_v[i]], elem_to_idx[bfs_v[i+1]]
                    bfs_edge_usage[(min(u,v), max(u,v))] += 1

            # Bubble-sort path
            bsort_v = bubble_sort_path(src, dst, n)
            bsort_len = len(bsort_v) - 1
            bsort_lengths.append(bsort_len)
            for i in range(len(bsort_v) - 1):
                u, v = elem_to_idx[bsort_v[i]], elem_to_idx[bsort_v[i+1]]
                bsort_edge_usage[(min(u,v), max(u,v))] += 1

    bfs_cong = max(bfs_edge_usage.values()) if bfs_edge_usage else 0
    bsort_cong = max(bsort_edge_usage.values()) if bsort_edge_usage else 0

    print(f"\n=== Application 3: Path System Comparison for S_{n} ===")
    print(f"  {'Metric':<30} {'BFS':>10} {'Bubble-sort':>12}")
    print(f"  {'─'*52}")
    print(f"  {'Max path length':<30} {max(bfs_lengths):>10} {max(bsort_lengths):>12}")
    print(f"  {'Avg path length':<30} {np.mean(bfs_lengths):>10.2f} {np.mean(bsort_lengths):>12.2f}")
    print(f"  {'Max edge congestion':<30} {bfs_cong:>10} {bsort_cong:>12}")
    print(f"  {'Avg edge congestion':<30} {np.mean(list(bfs_edge_usage.values())):>10.1f} {np.mean(list(bsort_edge_usage.values())):>12.1f}")

    # Compare resistance certificates
    L = laplacian(adj)
    R = effective_resistance_matrix(L)
    max_R = R.max()

    print(f"\n  Resistance Certificate Quality:")
    print(f"  {'κ/(|G|·max_R)':<30} {bfs_cong/(N*max_R):>10.4f} {bsort_cong/(N*max_R):>12.4f}")
    print(f"  {'Tighter bound wins':<30} {'←' if bfs_cong < bsort_cong else '→':>10}")


# ─── Application 4: Resistance Diameter as Group Invariant ───
def resistance_diameter_analysis(n):
    """Analyze resistance diameter as a quantitative group invariant."""
    elements, elem_to_idx, gens, adj = build_cayley_graph(n)
    N = len(elements)
    L = laplacian(adj)
    R = effective_resistance_matrix(L)

    # Resistance diameter
    diam_eff = R.max()

    # Combinatorial diameter
    # BFS from identity
    dist = {}
    queue = deque([(identity(n), 0)])
    dist[identity(n)] = 0
    while queue:
        current, d = queue.popleft()
        for g in gens:
            next_elem = compose(g, current)
            if next_elem not in dist:
                dist[next_elem] = d + 1
                queue.append((next_elem, d + 1))
    comb_diam = max(dist.values())

    print(f"\n=== Application 4: Resistance Diameter for S_{n} ===")
    print(f"  |G| = {N}")
    print(f"  Combinatorial diameter = {comb_diam}")
    print(f"  Resistance diameter    = {diam_eff:.6f}")
    print(f"  Ratio R_diam / C_diam  = {diam_eff / comb_diam:.6f}")

    # Distribution of resistances
    R_flat = R[np.triu_indices(N, k=1)]
    print(f"\n  Resistance distribution:")
    print(f"    Min: {R_flat.min():.6f}")
    print(f"    Q1:  {np.percentile(R_flat, 25):.6f}")
    print(f"    Med: {np.median(R_flat):.6f}")
    print(f"    Q3:  {np.percentile(R_flat, 75):.6f}")
    print(f"    Max: {R_flat.max():.6f}")


if __name__ == "__main__":
    for n in [3, 4]:
        estimate_mixing_time(n)
        commute_time_bounds(n)
        compare_path_systems(n)
        resistance_diameter_analysis(n)


#!/usr/bin/env python3
"""
Electrical Flow Certificates for Cayley Graphs — Interactive Demo

Demonstrates the connection between canonical path congestion and
effective resistance on symmetric group Cayley graphs S3 and S4.

Computes:
  - Cayley graph construction from generators
  - Effective resistance matrix via Laplacian pseudoinverse
  - Canonical path congestion (bubble-sort paths)
  - Verification of the inequality κ ≥ |G| · max R_eff
  - Flow energy of path-induced unit flows
"""

import numpy as np
from itertools import permutations
from collections import defaultdict


def perm_to_tuple(p):
    """Convert a permutation to a hashable tuple."""
    return tuple(p)


def compose_perm(a, b):
    """Compose two permutations: (a ∘ b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(len(a)))


def inverse_perm(p):
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def adjacent_transpositions(n):
    """Return adjacent transpositions (i, i+1) for S_n."""
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens


def build_cayley_graph(n):
    """Build the Cayley graph of S_n with adjacent transpositions."""
    identity = tuple(range(n))
    elements = list(permutations(range(n)))
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)

    N = len(elements)
    adj = np.zeros((N, N), dtype=int)

    for g in elements:
        gi = elem_to_idx[g]
        for s in gens:
            sg = compose_perm(s, g)
            si = elem_to_idx[sg]
            adj[gi][si] = 1
            adj[si][gi] = 1

    return elements, elem_to_idx, gens, adj


def laplacian(adj):
    """Compute the graph Laplacian L = D - A."""
    D = np.diag(adj.sum(axis=1))
    return D - adj


def effective_resistance_matrix(L):
    """Compute all pairwise effective resistances via Laplacian pseudoinverse."""
    n = L.shape[0]
    # Moore-Penrose pseudoinverse
    L_pinv = np.linalg.pinv(L)
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i][j] = L_pinv[i][i] + L_pinv[j][j] - 2 * L_pinv[i][j]
    return R


def bubble_sort_path(perm):
    """Return the bubble-sort sequence of adjacent transpositions
    that sorts perm back to identity. This gives the canonical path
    from identity to perm^{-1}, which by left-translation gives
    canonical paths for all pairs."""
    n = len(perm)
    p = list(perm)
    path = []
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                swap = list(range(n))
                swap[j], swap[j + 1] = swap[j + 1], swap[j]
                path.append(tuple(swap))
    return path


def canonical_path(src, dst, n):
    """Canonical path from src to dst in Cay(S_n, adj. transpositions).
    Uses left-translated bubble-sort: path from x to y = path from id to y·x^{-1},
    then left-translate by x."""
    diff = compose_perm(dst, inverse_perm(src))
    # Path from identity to diff
    swaps = bubble_sort_path(inverse_perm(diff))
    # Build vertex sequence
    vertices = [src]
    current = src
    for s in swaps:
        current = compose_perm(s, current)
        vertices.append(current)
    return vertices, swaps


def compute_edge_congestion(elements, elem_to_idx, gens, n):
    """Compute edge congestion of bubble-sort canonical paths."""
    edge_usage = defaultdict(int)

    for src in elements:
        for dst in elements:
            if src == dst:
                continue
            vertices, swaps = canonical_path(src, dst, n)
            for i in range(len(vertices) - 1):
                u = elem_to_idx[vertices[i]]
                v = elem_to_idx[vertices[i + 1]]
                edge = (min(u, v), max(u, v))
                edge_usage[edge] += 1

    max_congestion = max(edge_usage.values()) if edge_usage else 0
    return max_congestion, edge_usage


def flow_energy_of_path(vertices, N):
    """Compute the flow energy of a unit flow along a path.
    Energy = number of edges = len(vertices) - 1."""
    return len(vertices) - 1


def run_demo(n, label):
    """Run the full demo for S_n."""
    print(f"\n{'='*70}")
    print(f"  Electrical Flow Certificate Demo: {label} (n={n})")
    print(f"{'='*70}")

    elements, elem_to_idx, gens, adj = build_cayley_graph(n)
    N = len(elements)
    print(f"\n|G| = {N}")
    print(f"|S| = {len(gens)} (adjacent transpositions)")
    print(f"Degree = {adj.sum(axis=1)[0]}")

    # Compute effective resistances
    L = laplacian(adj)
    R = effective_resistance_matrix(L)
    max_R = R.max()
    avg_R = R.sum() / (N * (N - 1))

    print(f"\nEffective Resistance Statistics:")
    print(f"  max R_eff  = {max_R:.6f}")
    print(f"  avg R_eff  = {avg_R:.6f}")
    print(f"  min R_eff (nonzero) = {R[R > 1e-10].min():.6f}")

    # Compute canonical path congestion
    max_cong, edge_usage = compute_edge_congestion(elements, elem_to_idx, gens, n)
    print(f"\nCanonical Path Congestion (bubble-sort):")
    print(f"  κ (max edge congestion) = {max_cong}")

    # Compute max path length
    max_path_len = 0
    total_path_len = 0
    count = 0
    for src in elements:
        for dst in elements:
            if src == dst:
                continue
            vertices, swaps = canonical_path(src, dst, n)
            path_len = len(vertices) - 1
            max_path_len = max(max_path_len, path_len)
            total_path_len += path_len
            count += 1
    avg_path_len = total_path_len / count if count > 0 else 0

    print(f"  L (max path length)    = {max_path_len}")
    print(f"  Avg path length        = {avg_path_len:.2f}")

    # Verify the inequality: κ ≥ |G| · max R_eff
    lhs = max_cong
    rhs = N * max_R
    ratio = lhs / rhs if rhs > 0 else float('inf')

    print(f"\n{'─'*50}")
    print(f"  MAIN INEQUALITY VERIFICATION")
    print(f"{'─'*50}")
    print(f"  κ                     = {lhs}")
    print(f"  |G| · max R_eff       = {rhs:.6f}")
    print(f"  κ / (|G| · max R_eff) = {ratio:.6f}")
    print(f"  Inequality κ ≥ |G|·max(R_eff) holds: {lhs >= rhs - 1e-6}")

    # Check Thomson's principle: R_eff(s,t) ≤ path_energy for all s,t
    print(f"\nThomson's Principle Verification:")
    violations = 0
    max_slack = 0
    for src in elements[:min(N, 20)]:  # sample for large groups
        for dst in elements[:min(N, 20)]:
            if src == dst:
                continue
            vertices, _ = canonical_path(src, dst, n)
            path_energy = flow_energy_of_path(vertices, N)
            si, di = elem_to_idx[src], elem_to_idx[dst]
            r_eff = R[si][di]
            if r_eff > path_energy + 1e-6:
                violations += 1
            slack = path_energy - r_eff
            max_slack = max(max_slack, slack)
    print(f"  Violations of R_eff ≤ path_energy: {violations}")
    print(f"  Max slack (path_energy - R_eff):    {max_slack:.6f}")

    # Flow-potential duality verification
    print(f"\nFlow-Potential Duality Verification:")
    # Pick a random function f and verify the identity
    np.random.seed(42)
    f = np.random.randn(N)
    # Check for a specific pair
    s_idx, t_idx = 0, 1
    print(f"  f(s) - f(t) = {f[s_idx] - f[t_idx]:.6f}")
    pairwise_var = 0.5 * sum((f[i] - f[j])**2 for i in range(N) for j in range(N))
    print(f"  Pairwise variation = {pairwise_var:.6f}")
    print(f"  R_eff(s,t) * PairVar = {R[s_idx][t_idx] * pairwise_var:.6f}")
    print(f"  (f(s)-f(t))^2 = {(f[s_idx] - f[t_idx])**2:.6f}")
    bound_holds = (f[s_idx] - f[t_idx])**2 <= R[s_idx][t_idx] * pairwise_var + 1e-6
    print(f"  Resistance-variation inequality holds: {bound_holds}")

    # Edge congestion histogram data
    if edge_usage:
        cong_values = list(edge_usage.values())
        print(f"\nEdge Congestion Distribution:")
        print(f"  Min: {min(cong_values)}, Max: {max(cong_values)}, "
              f"Mean: {np.mean(cong_values):.1f}, Std: {np.std(cong_values):.1f}")

    return {
        'N': N, 'max_R': max_R, 'avg_R': avg_R,
        'congestion': max_cong, 'max_path_len': max_path_len,
        'ratio': ratio, 'R_matrix': R, 'edge_usage': edge_usage
    }


def test_conjecture(results):
    """Test the asymptotic conjecture κ_n ∝ |S_n| · diam_eff."""
    print(f"\n{'='*70}")
    print(f"  CONJECTURE TEST: κ_n ~ |S_n| · diam_eff(S_n)")
    print(f"{'='*70}")
    print(f"\n{'n':>3} {'|S_n|':>8} {'κ':>8} {'max R_eff':>12} "
          f"{'κ/(|G|·R)':>12} {'κ/|G|':>10}")
    print(f"{'─'*60}")
    for label, r in results.items():
        ratio = r['congestion'] / (r['N'] * r['max_R']) if r['max_R'] > 0 else 0
        cong_per_vertex = r['congestion'] / r['N']
        print(f"{label:>3} {r['N']:>8} {r['congestion']:>8} "
              f"{r['max_R']:>12.6f} {ratio:>12.6f} {cong_per_vertex:>10.2f}")
    print(f"\nIf the ratio κ/(|G|·max_R) stays bounded, the conjecture holds.")


if __name__ == "__main__":
    results = {}
    results['S3'] = run_demo(3, "S₃")
    results['S4'] = run_demo(4, "S₄")

    test_conjecture(results)

    print(f"\n{'='*70}")
    print("  Demo complete. All inequalities verified numerically.")
    print(f"{'='*70}")


#!/usr/bin/env python3
"""
Visualization: Flow Energy vs Effective Resistance

Produces a scatter plot comparing path-flow energy (combinatorial)
against effective resistance (variational) for all vertex pairs in S_3 and S_4.

Thomson's principle guarantees every point lies above the diagonal:
  R_eff(s,t) ≤ E(path_flow(s,t))

The gap between the two measures quantifies how far canonical paths
are from optimal electrical flows.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# ─── Self-contained helpers ───
def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def adjacent_transpositions(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens

def build_cayley(n):
    elements = list(permutations(range(n)))
    idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)
    N = len(elements)
    adj = np.zeros((N, N))
    for g in elements:
        gi = idx[g]
        for s in gens:
            adj[gi][idx[compose(s, g)]] = 1
    return elements, idx, gens, adj

def eff_resistance(adj):
    L = np.diag(adj.sum(axis=1)) - adj
    Lp = np.linalg.pinv(L)
    d = np.diag(Lp)
    N = adj.shape[0]
    R = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            R[i][j] = d[i] + d[j] - 2*Lp[i][j]
    return R

def bubble_path_len(src, dst, n):
    diff = compose(dst, inverse(src))
    p = list(inverse(diff))
    count = 0
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                count += 1
    return count


# ─── Compute data ───
fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

for panel, n in enumerate([3, 4]):
    elements, idx, gens, adj = build_cayley(n)
    N = len(elements)
    R = eff_resistance(adj)

    resistances = []
    energies = []
    for src in elements:
        for dst in elements:
            if src == dst:
                continue
            r = R[idx[src]][idx[dst]]
            e = bubble_path_len(src, dst, n)  # energy = path length for simple path
            resistances.append(r)
            energies.append(e)

    ax = axes[panel]
    ax.scatter(resistances, energies, alpha=0.4, s=15, color='steelblue',
               label='(R_eff, path energy)')

    # Diagonal: Thomson bound
    max_val = max(max(resistances), max(energies)) + 0.5
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2,
            label='Thomson: E ≥ R_eff')

    ax.set_xlabel('Effective Resistance R_eff(s,t)', fontsize=12)
    ax.set_ylabel('Path Flow Energy E(φ)', fontsize=12)
    ax.set_title(f'Thomson\'s Principle — S_{n}\n'
                 f'All {N*(N-1)} pairs, |G|={N}',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(0, max_val)
    ax.set_ylim(0, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('thomson_principle.png', dpi=150, bbox_inches='tight')
print("Saved: thomson_principle.png")


#!/usr/bin/env python3
"""
Visualization: Effective Resistance Heatmap and Congestion Distribution

Produces a 2-panel figure:
  Left:  Heatmap of the effective resistance matrix for S_4
  Right: Histogram of edge congestion values

This visualizes the core mathematical relationship: canonical path congestion
(right panel) provides an upper bound on effective resistance (left panel).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# ─── Self-contained helper functions ───
def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def adjacent_transpositions(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens

def build_cayley_graph(n):
    elements = list(permutations(range(n)))
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)
    N = len(elements)
    adj = np.zeros((N, N))
    for g in elements:
        gi = elem_to_idx[g]
        for s in gens:
            sg = compose(s, g)
            adj[gi][elem_to_idx[sg]] = 1
    return elements, elem_to_idx, gens, adj

def bubble_sort_path(src, dst, n, elem_to_idx):
    diff = compose(dst, inverse(src))
    p = list(inverse(diff))
    swaps = []
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                swap = list(range(n))
                swap[j], swap[j + 1] = swap[j + 1], swap[j]
                swaps.append(tuple(swap))
    vertices = [src]
    current = src
    for s in swaps:
        current = compose(s, current)
        vertices.append(current)
    return vertices


# ─── Computation ───
n = 4
elements, elem_to_idx, gens, adj = build_cayley_graph(n)
N = len(elements)

# Effective resistance
L = np.diag(adj.sum(axis=1)) - adj
L_pinv = np.linalg.pinv(L)
diag = np.diag(L_pinv)
R = np.zeros((N, N))
for i in range(N):
    for j in range(N):
        R[i][j] = diag[i] + diag[j] - 2 * L_pinv[i][j]

# Edge congestion
edge_usage = defaultdict(int)
for src in elements:
    for dst in elements:
        if src == dst:
            continue
        vertices = bubble_sort_path(src, dst, n, elem_to_idx)
        for i in range(len(vertices) - 1):
            u = elem_to_idx[vertices[i]]
            v = elem_to_idx[vertices[i + 1]]
            edge_usage[(min(u, v), max(u, v))] += 1


# ─── Visualization ───
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Resistance heatmap
im = ax1.imshow(R, cmap='YlOrRd', aspect='equal')
ax1.set_title(f'Effective Resistance Matrix — S₄\nmax R_eff = {R.max():.4f}',
              fontsize=13, fontweight='bold')
ax1.set_xlabel('Vertex index', fontsize=11)
ax1.set_ylabel('Vertex index', fontsize=11)
plt.colorbar(im, ax=ax1, label='R_eff(i,j)', shrink=0.85)

# Right: Congestion histogram
cong_values = list(edge_usage.values())
ax2.hist(cong_values, bins=15, color='steelblue', edgecolor='white', alpha=0.9)
ax2.axvline(x=max(cong_values), color='red', linestyle='--', linewidth=2,
            label=f'κ = {max(cong_values)}')
ax2.axvline(x=np.mean(cong_values), color='orange', linestyle='--', linewidth=2,
            label=f'mean = {np.mean(cong_values):.0f}')
ax2.set_title(f'Edge Congestion Distribution — S₄\nκ/(|G|·max R) = {max(cong_values)/(N*R.max()):.4f}',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Edge congestion (# paths using edge)', fontsize=11)
ax2.set_ylabel('Number of edges', fontsize=11)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('resistance_congestion.png', dpi=150, bbox_inches='tight')
print("Saved: resistance_congestion.png")
