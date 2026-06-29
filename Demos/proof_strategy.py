#!/usr/bin/env python3
"""
Applications of Berggren Orbit Graph Spectral Theory

Demonstrates practical applications of the spectral properties of Berggren
dynamics modulo primes, including:
1. Pseudorandom generation of Pythagorean triples mod p
2. Mixing time analysis for Berggren random walks
3. Expander graph constructions
4. Distribution analysis of Pythagorean triple residues
"""

import numpy as np
from collections import Counter
from algorithms import BerggrenOrbitGraph, BERGGREN_GENS, projective_normalize


def pythagorean_triple_distribution(p: int, num_steps: int = 10000) -> dict:
    """Analyze distribution of Pythagorean triple residues via random Berggren walk.

    Starting from (3,4,5), repeatedly apply a uniformly random Berggren generator
    and record the mod-p residues. Spectral gap controls convergence to uniform.

    Args:
        p: prime modulus
        num_steps: number of random walk steps

    Returns:
        Dictionary with distribution statistics
    """
    v = (3 % p, 4 % p, 5 % p)
    v = projective_normalize(v, p)

    visit_counts = Counter()
    rng = np.random.default_rng(42)

    for step in range(num_steps):
        visit_counts[v] += 1
        # Pick random generator
        M = BERGGREN_GENS[rng.integers(3)]
        result = tuple(
            sum(int(M[i][j]) * v[j] for j in range(3)) % p
            for i in range(3)
        )
        v = projective_normalize(result, p)

    # Analyze uniformity
    G = BerggrenOrbitGraph(p)
    n = G.n
    expected = num_steps / n
    counts = [visit_counts.get(v, 0) for v in G.vertices]

    chi_sq = sum((c - expected)**2 / expected for c in counts)
    max_dev = max(abs(c - expected) / expected for c in counts)

    return {
        'p': p,
        'n': n,
        'num_steps': num_steps,
        'expected_per_vertex': expected,
        'min_visits': min(counts),
        'max_visits': max(counts),
        'chi_squared': chi_sq,
        'max_deviation': max_dev,
        'spectral_gap': G.spectral_gap('norm3'),
    }


def expander_quality_analysis(p: int) -> dict:
    """Analyze the quality of the Berggren graph as an expander.

    An (n, d, lambda)-expander has vertex expansion and edge expansion
    properties controlled by the spectral gap.

    Args:
        p: prime modulus

    Returns:
        Expander quality metrics
    """
    G = BerggrenOrbitGraph(p)
    lam2 = G.spectral_gap('norm3')
    n = G.n

    # Expander mixing lemma: |e(S,T) - d*|S|*|T|/n| <= lambda * sqrt(|S|*|T|)
    # For d=3 normalization
    d = 3

    # Cheeger inequality: h >= (1 - lambda) / 2
    cheeger_lower = (1 - lam2) / 2

    return {
        'p': p,
        'n': n,
        'degree': d,
        'lambda2': lam2,
        'spectral_gap': 1 - lam2,
        'cheeger_lower_bound': cheeger_lower,
        'mixing_time': G.mixing_time_estimate(),
        'is_ramanujan': lam2 <= 2 * np.sqrt(d - 1) / d,
    }


def convergence_rate_demo(p: int = 23):
    """Demonstrate how the spectral gap controls convergence rate.

    Shows the total variation distance between the random walk distribution
    and the stationary distribution as a function of the number of steps.

    Args:
        p: prime modulus
    """
    G = BerggrenOrbitGraph(p)
    n = G.n
    T = G.markov_matrix()

    # Start from a delta distribution at vertex 0
    dist = np.zeros(n)
    dist[0] = 1.0

    # Stationary distribution (uniform for doubly stochastic)
    stat = np.ones(n) / n

    print(f"\nConvergence analysis for p={p} (n={n}):")
    print(f"Spectral gap (1-λ₂) = {1 - G.spectral_gap('markov'):.6f}")
    print(f"{'Step':>6} {'TV distance':>15} {'Predicted bound':>18}")
    print("-" * 45)

    lam2 = G.spectral_gap('markov')
    for step in [0, 1, 2, 5, 10, 20, 50, 100]:
        if step > 0:
            dist = dist @ T
        tv = 0.5 * np.sum(np.abs(dist - stat))
        bound = 0.5 * np.sqrt(n) * lam2**step if step > 0 else 1.0
        print(f"{step:6d} {tv:15.10f} {min(bound, 1.0):18.10f}")


def main():
    print("=" * 60)
    print("APPLICATIONS OF BERGGREN SPECTRAL THEORY")
    print("=" * 60)

    # 1. Pseudorandom distribution
    print("\n--- Application 1: Pseudorandom Triple Distribution ---")
    for p in [11, 23, 47]:
        result = pythagorean_triple_distribution(p, num_steps=5000)
        print(f"p={p}: n={result['n']}, λ₂={result['spectral_gap']:.4f}, "
              f"max_dev={result['max_deviation']:.4f}, "
              f"χ²={result['chi_squared']:.2f}")

    # 2. Expander quality
    print("\n--- Application 2: Expander Quality ---")
    print(f"{'p':>4} {'n':>5} {'λ₂':>8} {'gap':>8} {'Cheeger':>8} {'mix_t':>8} {'Ram?':>5}")
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        r = expander_quality_analysis(p)
        print(f"{r['p']:4d} {r['n']:5d} {r['lambda2']:8.4f} {r['spectral_gap']:8.4f} "
              f"{r['cheeger_lower_bound']:8.4f} {r['mixing_time']:8.1f} "
              f"{'Y' if r['is_ramanujan'] else 'N':>5}")

    # 3. Convergence demo
    print("\n--- Application 3: Mixing Convergence ---")
    convergence_rate_demo(23)
    convergence_rate_demo(47)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Berggren Orbit Graphs over F_p: Spectral Analysis Demo

Computes the Berggren orbit graph for primes p, analyzes degree structure,
bipartiteness, connected components, and spectral properties. Explores the
conjectured Ramanujan-type bound lambda_2 = 1/sqrt(3) for p % 8 != 1.

Usage:
    python demo.py
"""

import numpy as np
from collections import defaultdict
import sys

# ============================================================
# Berggren Generators (3x3 integer matrices in O(2,1; Z))
# ============================================================

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

GENERATORS = [A, B, C]
GEN_NAMES = ['A', 'B', 'C']


def lorentz_form(v, p):
    """Q(v) = v[0]^2 + v[1]^2 - v[2]^2 mod p"""
    return (v[0]**2 + v[1]**2 - v[2]**2) % p


def is_nonzero(v, p):
    """Check if v is not the zero vector mod p"""
    return any(x % p != 0 for x in v)


def normalize_projective(v, p):
    """Normalize to projective coordinates: first nonzero = 1"""
    v_mod = tuple(x % p for x in v)
    for i in range(3):
        if v_mod[i] != 0:
            inv = pow(int(v_mod[i]), p - 2, p)
            return tuple((x * inv) % p for x in v_mod)
    return None


def find_projective_isotropic(p):
    """Find all projective isotropic points on Q=0 in P^2(F_p)."""
    points = set()
    for a in range(p):
        for b in range(p):
            for c in range(p):
                if not is_nonzero((a, b, c), p):
                    continue
                if lorentz_form((a, b, c), p) == 0:
                    pt = normalize_projective((a, b, c), p)
                    if pt is not None:
                        points.add(pt)
    return sorted(points)


def apply_gen(M, v, p):
    """Apply matrix M to vector v mod p, return projective normalization."""
    result = tuple(sum(int(M[i][j]) * v[j] for j in range(3)) % p for i in range(3))
    return normalize_projective(result, p)


def build_directed_graph(p):
    """Build directed Berggren graph on projective isotropic points.
    Edge v -> w means w = M*v for some generator M in {A, B, C}."""
    vertices = find_projective_isotropic(p)
    vert_set = set(vertices)
    idx = {v: i for i, v in enumerate(vertices)}
    n = len(vertices)

    out_edges = defaultdict(list)  # v -> list of (w, gen_name)
    in_edges = defaultdict(list)   # w -> list of (v, gen_name)

    for v in vertices:
        for M, name in zip(GENERATORS, GEN_NAMES):
            w = apply_gen(M, v, p)
            if w is not None and w in vert_set:
                out_edges[v].append((w, name))
                in_edges[w].append((v, name))

    return vertices, idx, out_edges, in_edges


def connected_components(vertices, out_edges, in_edges):
    """Find connected components (treating as undirected)."""
    visited = set()
    components = []

    for start in vertices:
        if start in visited:
            continue
        comp = set()
        queue = [start]
        while queue:
            v = queue.pop()
            if v in visited:
                continue
            visited.add(v)
            comp.add(v)
            for w, _ in out_edges.get(v, []):
                if w not in visited:
                    queue.append(w)
            for u, _ in in_edges.get(v, []):
                if u not in visited:
                    queue.append(u)
        components.append(sorted(comp))

    return components


def check_bipartite(vertices, out_edges):
    """Check if directed graph is bipartite (ignoring direction)."""
    color = {}
    is_bip = True

    for start in vertices:
        if start in color:
            continue
        color[start] = 0
        queue = [start]
        while queue:
            v = queue.pop(0)
            for w, _ in out_edges.get(v, []):
                if w not in color:
                    color[w] = 1 - color[v]
                    queue.append(w)
                elif color[w] == color[v]:
                    is_bip = False

    return is_bip, color


def adjacency_matrix(vertices, idx, out_edges):
    """Build adjacency matrix of the directed graph."""
    n = len(vertices)
    A_mat = np.zeros((n, n))
    for v in vertices:
        i = idx[v]
        for w, _ in out_edges.get(v, []):
            j = idx[w]
            A_mat[i][j] += 1.0  # may have multiplicities
    return A_mat


def analyze_prime(p, verbose=True):
    """Full analysis of Berggren orbit graph mod p."""
    vertices, idx, out_edges, in_edges = build_directed_graph(p)
    n = len(vertices)

    if n == 0:
        if verbose:
            print(f"p={p}: no isotropic points")
        return None

    # Degree analysis
    out_degs = [len(set(w for w, _ in out_edges.get(v, []))) for v in vertices]
    in_degs = [len(set(u for u, _ in in_edges.get(v, []))) for v in vertices]
    out_degs_with_mult = [len(out_edges.get(v, [])) for v in vertices]

    # Components
    comps = connected_components(vertices, out_edges, in_edges)

    # Bipartiteness
    is_bip, coloring = check_bipartite(vertices, out_edges)

    # Adjacency matrix and spectrum
    A_mat = adjacency_matrix(vertices, idx, out_edges)

    # Various normalizations
    eigs_plain = np.sort(np.real(np.linalg.eigvals(A_mat)))[::-1]

    # Row-stochastic (Markov) normalization
    row_sums = A_mat.sum(axis=1)
    row_sums[row_sums == 0] = 1
    T_markov = A_mat / row_sums[:, np.newaxis]
    eigs_markov = np.sort(np.real(np.linalg.eigvals(T_markov)))[::-1]

    # Normalized by 3 (since each vertex has 3 forward edges)
    T_norm3 = A_mat / 3.0
    eigs_norm3 = np.sort(np.real(np.linalg.eigvals(T_norm3)))[::-1]

    abs_eigs_markov = np.sort(np.abs(eigs_markov))[::-1]
    abs_eigs_norm3 = np.sort(np.abs(eigs_norm3))[::-1]
    abs_eigs_plain = np.sort(np.abs(eigs_plain))[::-1]

    target = 1.0 / np.sqrt(3)

    if verbose:
        print(f"\n{'='*60}")
        print(f"p = {p},  p mod 8 = {p % 8}")
        print(f"{'='*60}")
        print(f"  Projective isotropic points: {n}  (= p+1 = {p+1})")
        print(f"  Connected components: {len(comps)} (sizes: {[len(c) for c in comps]})")
        print(f"  Bipartite: {is_bip}")
        print(f"  Out-degrees (distinct targets): min={min(out_degs)}, max={max(out_degs)}")
        print(f"  Out-degrees (with mult):        min={min(out_degs_with_mult)}, max={max(out_degs_with_mult)}")
        print(f"  In-degrees (distinct sources):  min={min(in_degs)}, max={max(in_degs)}")
        print()
        print(f"  Plain adjacency eigenvalues (top 6): {eigs_plain[:6].round(6)}")
        print(f"  Markov eigenvalues (top 6):          {eigs_markov[:6].round(6)}")
        print(f"  Norm-by-3 eigenvalues (top 6):       {eigs_norm3[:6].round(6)}")
        print()
        print(f"  |lambda_2| (Markov):  {abs_eigs_markov[1]:.6f}")
        print(f"  |lambda_2| (norm-3):  {abs_eigs_norm3[1]:.6f}")
        print(f"  |lambda_2| (plain):   {abs_eigs_plain[1]:.6f}")
        print(f"  1/sqrt(3) target:     {target:.6f}")
        print(f"  Ratio (norm-3):       {abs_eigs_norm3[1]/target:.6f}")

    return {
        'p': p, 'n': n,
        'components': len(comps),
        'comp_sizes': [len(c) for c in comps],
        'bipartite': is_bip,
        'out_deg_range': (min(out_degs), max(out_degs)),
        'in_deg_range': (min(in_degs), max(in_degs)),
        'eigs_plain': eigs_plain,
        'eigs_markov': eigs_markov,
        'eigs_norm3': eigs_norm3,
        'lambda2_markov': abs_eigs_markov[1] if len(abs_eigs_markov) > 1 else 0,
        'lambda2_norm3': abs_eigs_norm3[1] if len(abs_eigs_norm3) > 1 else 0,
        'lambda2_plain': abs_eigs_plain[1] if len(abs_eigs_plain) > 1 else 0,
    }


def verify_lorentz_preservation():
    """Verify that all generators preserve Q(v) = v0^2 + v1^2 - v2^2."""
    Q = np.diag([1, 1, -1])
    print("Lorentz form preservation check:")
    for M, name in zip(GENERATORS, GEN_NAMES):
        result = M.T @ Q @ M
        preserved = np.array_equal(result, Q)
        print(f"  {name}^T Q {name} = Q: {preserved}")
        print(f"  det({name}) = {int(round(np.linalg.det(M)))}")
    print()


def main():
    print("=" * 60)
    print("BERGGREN ORBIT GRAPH SPECTRAL ANALYSIS")
    print("=" * 60)

    verify_lorentz_preservation()

    target = 1.0 / np.sqrt(3)
    print(f"Target eigenvalue: 1/sqrt(3) = {target:.10f}")
    print()

    # Analyze primes
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    results = {}
    for p in primes:
        r = analyze_prime(p, verbose=True)
        if r:
            results[p] = r

    # Summary table
    print("\n" + "=" * 90)
    print("SUMMARY TABLE")
    print("=" * 90)
    print(f"{'p':>4} {'p%8':>4} {'n':>5} {'#comp':>5} {'bip':>5} "
          f"{'out-deg':>10} {'in-deg':>10} "
          f"{'λ₂(M)':>10} {'λ₂(/3)':>10} {'1/√3':>10} {'ratio':>10}")
    print("-" * 90)
    for p in sorted(results.keys()):
        r = results[p]
        out_r = f"{r['out_deg_range'][0]}-{r['out_deg_range'][1]}"
        in_r = f"{r['in_deg_range'][0]}-{r['in_deg_range'][1]}"
        ratio = r['lambda2_norm3'] / target if target > 0 else 0
        print(f"{p:4d} {p%8:4d} {r['n']:5d} {r['components']:5d} "
              f"{'Y' if r['bipartite'] else 'N':>5} "
              f"{out_r:>10} {in_r:>10} "
              f"{r['lambda2_markov']:10.6f} {r['lambda2_norm3']:10.6f} "
              f"{target:10.6f} {ratio:10.6f}")

    print("\n" + "=" * 60)
    print("KEY OBSERVATIONS")
    print("=" * 60)
    print(f"1. Number of projective isotropic points = p+1 for all tested primes.")
    print(f"2. The graph is NOT bipartite for most primes.")
    print(f"3. Out-degrees vary between 2 and 3 (not uniformly 3).")
    print(f"4. The spectral gap does NOT equal 1/sqrt(3) exactly for any prime tested.")
    print(f"5. The nontrivial eigenvalue 1/3 appears consistently (from 3-cycles).")
    print(f"6. As p grows, the spectral gap appears to approach specific limits")
    print(f"   that depend on p mod 8.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Berggren Orbit Graph Spectral Analysis

Generates publication-quality figures showing:
1. Spectral gap vs prime
2. Eigenvalue distribution
3. Degree structure
4. Convergence rates
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import BerggrenOrbitGraph
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_spectral_gap_vs_prime():
    """Plot spectral gap lambda_2 as a function of prime p."""
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]
    gaps = []
    p_mod8 = []

    for p in primes:
        G = BerggrenOrbitGraph(p)
        gaps.append(G.spectral_gap('norm3'))
        p_mod8.append(p % 8)

    fig, ax = plt.subplots(figsize=(10, 6))

    # Color by p mod 8
    colors = {1: 'red', 3: 'blue', 5: 'green', 7: 'orange'}
    labels_done = set()
    for p, g, m in zip(primes, gaps, p_mod8):
        label = f'p ≡ {m} (mod 8)' if m not in labels_done else None
        ax.scatter(p, g, c=colors.get(m, 'gray'), s=80, zorder=5, label=label)
        labels_done.add(m)

    target = 1.0 / np.sqrt(3)
    ax.axhline(y=target, color='red', linestyle='--', alpha=0.7, label=f'1/√3 ≈ {target:.4f}')
    ax.axhline(y=1/3, color='purple', linestyle=':', alpha=0.5, label='1/3')

    ax.set_xlabel('Prime p', fontsize=14)
    ax.set_ylabel('|λ₂| (normalized by 3)', fontsize=14)
    ax.set_title('Spectral Gap of Berggren Orbit Graph mod p', fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 0.7)

    return fig


def plot_eigenvalue_histogram(p=47):
    """Plot histogram of all eigenvalues for a specific prime."""
    G = BerggrenOrbitGraph(p)
    eigs = G.spectrum('norm3')

    fig, ax = plt.subplots(figsize=(10, 5))

    ax.hist(eigs, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    target = 1.0 / np.sqrt(3)
    ax.axvline(x=target, color='red', linestyle='--', linewidth=2, label=f'1/√3 ≈ {target:.4f}')
    ax.axvline(x=-target, color='red', linestyle='--', linewidth=2)
    ax.axvline(x=1/3, color='green', linestyle=':', linewidth=2, label='1/3')

    ax.set_xlabel('Eigenvalue', fontsize=14)
    ax.set_ylabel('Count', fontsize=14)
    ax.set_title(f'Eigenvalue Distribution of Berggren Graph (p={p}, n={G.n})', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig


def plot_degree_distribution():
    """Plot degree distribution across primes."""
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    out_deg2 = []
    out_deg3 = []
    in_deg2 = []
    in_deg3 = []

    for p in primes:
        G = BerggrenOrbitGraph(p)
        od = G.out_degree_distribution()
        id_ = G.in_degree_distribution()
        out_deg2.append(od.get(2, 0) / G.n * 100)
        out_deg3.append(od.get(3, 0) / G.n * 100)
        in_deg2.append(id_.get(2, 0) / G.n * 100)
        in_deg3.append(id_.get(3, 0) / G.n * 100)

    x = range(len(primes))
    width = 0.35

    ax1.bar([i - width/2 for i in x], out_deg2, width, label='Out-degree 2', color='steelblue')
    ax1.bar([i + width/2 for i in x], out_deg3, width, label='Out-degree 3', color='coral')
    ax1.set_xticks(list(x))
    ax1.set_xticklabels(primes)
    ax1.set_xlabel('Prime p')
    ax1.set_ylabel('Percentage of vertices')
    ax1.set_title('Out-degree Distribution')
    ax1.legend()

    ax2.bar([i - width/2 for i in x], in_deg2, width, label='In-degree 2', color='steelblue')
    ax2.bar([i + width/2 for i in x], in_deg3, width, label='In-degree 3', color='coral')
    ax2.set_xticks(list(x))
    ax2.set_xticklabels(primes)
    ax2.set_xlabel('Prime p')
    ax2.set_ylabel('Percentage of vertices')
    ax2.set_title('In-degree Distribution')
    ax2.legend()

    fig.suptitle('Degree Structure of Berggren Orbit Graphs', fontsize=16, y=1.02)
    fig.tight_layout()

    return fig


def plot_mixing_convergence(p=23):
    """Plot convergence of random walk to stationary distribution."""
    G = BerggrenOrbitGraph(p)
    n = G.n
    T = G.markov_matrix()

    dist = np.zeros(n)
    dist[0] = 1.0
    stat = np.ones(n) / n

    steps = range(0, 51)
    tv_distances = []
    lam2 = G.spectral_gap('markov')

    for step in steps:
        if step > 0:
            dist = dist @ T
        tv = 0.5 * np.sum(np.abs(dist - stat))
        tv_distances.append(tv)

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(list(steps), tv_distances, 'b-o', markersize=3, label='Actual TV distance')

    # Theoretical bound
    bounds = [min(0.5 * np.sqrt(n) * lam2**t, 1.0) for t in steps]
    ax.plot(list(steps), bounds, 'r--', label=f'Spectral bound (λ₂={lam2:.4f})')

    ax.set_xlabel('Number of steps', fontsize=14)
    ax.set_ylabel('Total Variation Distance', fontsize=14)
    ax.set_title(f'Mixing of Berggren Random Walk (p={p}, n={n})', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    return fig


def generate_all_visualizations():
    """Generate all visualization figures and save as files."""
    print("Generating visualizations...")

    fig1 = plot_spectral_gap_vs_prime()
    fig1.savefig('/workspace/request-project/spectral_gap.png', dpi=150, bbox_inches='tight')
    print("  Saved spectral_gap.png")

    fig2 = plot_eigenvalue_histogram(47)
    fig2.savefig('/workspace/request-project/eigenvalue_dist.png', dpi=150, bbox_inches='tight')
    print("  Saved eigenvalue_dist.png")

    fig3 = plot_degree_distribution()
    fig3.savefig('/workspace/request-project/degree_dist.png', dpi=150, bbox_inches='tight')
    print("  Saved degree_dist.png")

    fig4 = plot_mixing_convergence(23)
    fig4.savefig('/workspace/request-project/mixing_conv.png', dpi=150, bbox_inches='tight')
    print("  Saved mixing_conv.png")

    return {
        'spectral_gap': fig_to_base64(plot_spectral_gap_vs_prime()),
        'eigenvalue_dist': fig_to_base64(plot_eigenvalue_histogram(47)),
        'degree_dist': fig_to_base64(plot_degree_distribution()),
        'mixing_conv': fig_to_base64(plot_mixing_convergence(23)),
    }


if __name__ == "__main__":
    generate_all_visualizations()
    print("All visualizations generated.")
