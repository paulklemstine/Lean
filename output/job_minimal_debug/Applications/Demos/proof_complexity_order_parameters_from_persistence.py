#!/usr/bin/env python3
"""
Applications of dependency hypergraph persistence to real-world proof systems.

Demonstrates how the topological order parameter can be used to:
1. Diagnose SAT/resolution proof hardness
2. Guide adaptive tactic selection in automated theorem provers
3. Classify proof traces by structural complexity
4. Detect phase transitions in parameterized proof families
"""

import itertools
import random
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

from algorithms import HypergraphFiltration, detect_phase_transition


# ──────────────────────────────────────────────────────────────────────
# Application 1: SAT Resolution Proof Analysis
# ──────────────────────────────────────────────────────────────────────

def resolution_trace_to_hypergraph(
    clauses: List[Set[int]],
    derivation_order: Optional[List[int]] = None
) -> HypergraphFiltration:
    """
    Convert a SAT resolution derivation into a weighted dependency hypergraph.

    Each clause becomes a vertex. Each resolution step (resolving clauses
    C1 and C2 to produce C3) becomes a hyperedge {C1, C2, C3} with weight
    equal to the derivation step number.

    Args:
        clauses: List of clause sets (each clause is a set of signed literals).
        derivation_order: Order in which clauses were derived.
                         If None, uses index order.

    Returns:
        HypergraphFiltration modeling the resolution proof.
    """
    n = len(clauses)
    vertices = set(range(n))

    if derivation_order is None:
        derivation_order = list(range(n))

    # Create dependency edges from clause relationships
    edges: List[Tuple[FrozenSet[int], int]] = []
    for step, clause_idx in enumerate(derivation_order):
        clause = clauses[clause_idx]
        # Find potential parent clauses (those that could resolve to this clause)
        for i in range(clause_idx):
            for j in range(i + 1, clause_idx):
                c_i = clauses[i]
                c_j = clauses[j]
                # Check if clauses i and j could resolve
                shared_vars = {abs(l) for l in c_i} & {abs(l) for l in c_j}
                for var in shared_vars:
                    if (var in c_i and -var in c_j) or (-var in c_i and var in c_j):
                        resolvent = (c_i | c_j) - {var, -var}
                        if resolvent == clause:
                            edges.append((frozenset({i, j, clause_idx}), step))
                            break

    # Add pair edges for clauses sharing variables (dependency relation)
    for i in range(n):
        for j in range(i + 1, n):
            shared = {abs(l) for l in clauses[i]} & {abs(l) for l in clauses[j]}
            if shared:
                weight = max(derivation_order.index(i),
                           derivation_order.index(j)) if i in derivation_order and j in derivation_order else n
                edges.append((frozenset({i, j}), weight))

    if not edges:
        edges = [(frozenset({0}), 0)]  # Ensure at least one edge

    return HypergraphFiltration(vertices, edges)


def analyze_sat_proof():
    """Demonstrate SAT resolution analysis."""
    print("=" * 70)
    print("APPLICATION 1: SAT Resolution Proof Analysis")
    print("=" * 70)

    # Simple example: pigeonhole-style clauses
    # 3 pigeons, 2 holes: provably unsatisfiable
    clauses = [
        {1, 2},      # pigeon 1 in hole 1 or 2
        {3, 4},      # pigeon 2 in hole 1 or 2
        {5, 6},      # pigeon 3 in hole 1 or 2
        {-1, -3},    # not both pigeon 1 and 2 in hole 1
        {-2, -4},    # not both pigeon 1 and 2 in hole 2
        {-1, -5},    # not both pigeon 1 and 3 in hole 1
        {-2, -6},    # not both pigeon 1 and 3 in hole 2
        {-3, -5},    # not both pigeon 2 and 3 in hole 1
        {-4, -6},    # not both pigeon 2 and 3 in hole 2
    ]

    H = resolution_trace_to_hypergraph(clauses)
    curve = H.hardness_curve()

    print(f"\nPigeonhole (3 pigeons, 2 holes): {len(clauses)} clauses")
    print(f"{'Scale':>5} {'Width':>5} {'βgap':>5}")
    for k, w, bg in curve:
        print(f"{k:>5} {w:>5} {bg:>5}")

    transition = detect_phase_transition(curve)
    print(f"\nPhase transition detected at scale: {transition}")
    print(f"Interpretation: Co-dependencies become complex at step {transition}")


# ──────────────────────────────────────────────────────────────────────
# Application 2: Adaptive Tactic Selection
# ──────────────────────────────────────────────────────────────────────

class AdaptiveProverSimulator:
    """
    Simulates an adaptive theorem prover that uses topological
    diagnostics to choose tactics.
    """

    def __init__(self, H: HypergraphFiltration):
        self.H = H
        self.current_scale = 0
        self.history: List[Dict] = []

    def step(self) -> Dict:
        """
        Advance one filtration step and diagnose.

        Returns:
            Dictionary with scale, diagnostics, and recommended action.
        """
        k = self.current_scale
        bg = self.H.beta_gap(k)
        w = self.H.width_at(k)
        is_cone, apex = self.H.is_cone_at(k)
        new_pairs = len(self.H.new_pairs_at(k))

        if is_cone:
            action = "COMPRESS"
            reason = f"Cone at apex {apex}: exploit hub structure"
        elif bg != 0:
            action = "DECOMPOSE"
            reason = f"Topological obstruction (βgap={bg}): split into subproblems"
        elif new_pairs > 0 and w > 2:
            action = "WIDEN"
            reason = f"{new_pairs} new co-dependencies: broaden search width"
        else:
            action = "CONTINUE"
            reason = "No topological signal: continue current strategy"

        result = {
            'scale': k,
            'beta_gap': bg,
            'width': w,
            'is_cone': is_cone,
            'new_pairs': new_pairs,
            'action': action,
            'reason': reason
        }
        self.history.append(result)
        self.current_scale += 1
        return result


def simulate_adaptive_prover():
    """Demonstrate adaptive tactic selection."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Adaptive Tactic Selection")
    print("=" * 70)

    # Create a hypergraph that transitions from easy to hard
    n = 8
    vertices = set(range(n))
    edges = []

    # Phase 1: Star-like dependencies (easy, cone structure)
    for i in range(1, 4):
        edges.append((frozenset({0, i}), i))

    # Phase 2: Cross-dependencies emerge (transition)
    for i in range(2, 5):
        for j in range(i + 1, 6):
            edges.append((frozenset({i, j}), i + j))

    # Phase 3: Dense dependencies (hard)
    for i in range(4, 8):
        for j in range(i + 1, 8):
            edges.append((frozenset({i, j, 0}), i + j + 2))

    H = HypergraphFiltration(vertices, edges)
    simulator = AdaptiveProverSimulator(H)

    print(f"\n{'Scale':>5} {'βgap':>5} {'Width':>5} {'Pairs':>5} {'Action':>12} {'Reason'}")
    print("-" * 90)

    for _ in range(min(H.max_weight + 1, 20)):
        result = simulator.step()
        print(f"{result['scale']:>5} {result['beta_gap']:>5} "
              f"{result['width']:>5} {result['new_pairs']:>5} "
              f"{result['action']:>12} {result['reason']}")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Proof Trace Classification
# ──────────────────────────────────────────────────────────────────────

def extract_topological_features(H: HypergraphFiltration) -> Dict[str, float]:
    """
    Extract a feature vector from a hypergraph filtration for classification.

    Features:
    - max_beta: Maximum |βgap| across all scales
    - transition_scale: First scale where βgap ≠ 0 (normalized)
    - cone_fraction: Fraction of scales where the complex is a cone
    - max_width: Maximum width across all scales
    - width_growth_rate: Average width increase per scale
    - pair_density: Average number of new pairs per scale
    """
    curve = H.hardness_curve()
    max_k = len(curve) - 1

    betas = [abs(bg) for _, _, bg in curve]
    widths = [w for _, w, _ in curve]

    max_beta = max(betas) if betas else 0
    transition = next((k for k, _, bg in curve if bg != 0), max_k + 1)
    transition_normalized = transition / (max_k + 1) if max_k > 0 else 1.0

    cone_count = sum(1 for k in range(max_k + 1) if H.is_cone_at(k)[0])
    cone_fraction = cone_count / (max_k + 1) if max_k >= 0 else 1.0

    max_width = max(widths) if widths else 0
    width_growth = (widths[-1] - widths[0]) / max_k if max_k > 0 else 0

    total_new_pairs = sum(len(H.new_pairs_at(k)) for k in range(max_k + 1))
    pair_density = total_new_pairs / (max_k + 1) if max_k >= 0 else 0

    return {
        'max_beta': max_beta,
        'transition_scale': transition_normalized,
        'cone_fraction': cone_fraction,
        'max_width': max_width,
        'width_growth_rate': width_growth,
        'pair_density': pair_density
    }


def classify_proof_traces():
    """Demonstrate proof trace classification."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Proof Trace Classification")
    print("=" * 70)

    # Generate diverse proof-like hypergraphs
    families = {
        'star_easy': [],
        'layered_medium': [],
        'dense_hard': [],
    }

    for trial in range(5):
        n = 8
        seed = 42 + trial
        random.seed(seed)

        # Easy: star-like
        verts = set(range(n))
        edges = [(frozenset({0, i}), i) for i in range(1, n)]
        families['star_easy'].append(HypergraphFiltration(verts, edges))

        # Medium: layered
        edges = []
        for i in range(n):
            for j in range(i + 1, min(i + 3, n)):
                edges.append((frozenset({i, j}), j))
        if edges:
            families['layered_medium'].append(HypergraphFiltration(verts, edges))

        # Hard: dense random
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < 0.6:
                    edges.append((frozenset({i, j}), random.randint(1, n)))
        if edges:
            families['dense_hard'].append(HypergraphFiltration(verts, edges))

    print(f"\n{'Family':<20} {'max|β|':>7} {'Trans':>7} {'Cone%':>7} "
          f"{'MaxW':>5} {'WGrowth':>8} {'PairDen':>8}")
    print("-" * 75)

    for family_name, instances in families.items():
        for i, H in enumerate(instances):
            features = extract_topological_features(H)
            print(f"{family_name + f'_{i}':<20} "
                  f"{features['max_beta']:>7.1f} "
                  f"{features['transition_scale']:>7.3f} "
                  f"{features['cone_fraction']:>7.3f} "
                  f"{features['max_width']:>5} "
                  f"{features['width_growth_rate']:>8.2f} "
                  f"{features['pair_density']:>8.2f}")


# ──────────────────────────────────────────────────────────────────────
# Application 4: Phase Transition Detection
# ──────────────────────────────────────────────────────────────────────

def phase_transition_detection():
    """Detect and characterize phase transitions in parameterized families."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Phase Transition Detection")
    print("=" * 70)

    print("\nErdős–Rényi-style random dependency graphs:")
    print(f"{'n':>4} {'p':>6} {'Trans':>6} {'MaxBeta':>8} {'MaxWidth':>9} {'Classification':>15}")
    print("-" * 55)

    for n in [6, 8, 10]:
        for p in [0.1, 0.3, 0.5, 0.7, 0.9]:
            random.seed(42)
            verts = set(range(n))
            edges = []
            for i in range(n):
                for j in range(i + 1, n):
                    if random.random() < p:
                        edges.append((frozenset({i, j}), random.randint(1, n)))
            if not edges:
                edges = [(frozenset({0}), 0)]

            H = HypergraphFiltration(verts, edges)
            curve = H.hardness_curve()
            transition = detect_phase_transition(curve)
            max_beta = max(abs(bg) for _, _, bg in curve)
            max_width = max(w for _, w, _ in curve)

            if max_beta == 0:
                classification = "TRIVIAL"
            elif transition is not None and transition <= 2:
                classification = "HARD"
            else:
                classification = "MODERATE"

            trans_str = str(transition) if transition is not None else "never"
            print(f"{n:>4} {p:>6.1f} {trans_str:>6} {max_beta:>8} "
                  f"{max_width:>9} {classification:>15}")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    analyze_sat_proof()
    simulate_adaptive_prover()
    classify_proof_traces()
    phase_transition_detection()
    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demonstration of Persistence of Dependency Hypergraphs.

Constructs benchmark weighted dependency hypergraphs, computes filtration
statistics (support complex, co-dependency time, width, betaGap), and
visualizes threshold behavior comparing topological vs syntactic baselines.
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List, Set, Tuple, FrozenSet

# ──────────────────────────────────────────────────────────────────────
# Core data structures
# ──────────────────────────────────────────────────────────────────────

class WeightedDepHypergraph:
    """A weighted dependency hypergraph on a finite vertex set."""

    def __init__(self, vertices: Set[int], edges: List[Tuple[FrozenSet[int], int]]):
        """
        Args:
            vertices: Set of vertex labels.
            edges: List of (vertex_set, weight) pairs.
        """
        self.vertices = vertices
        self.edges = edges  # list of (frozenset of vertices, weight)
        for vs, _ in edges:
            assert len(vs) >= 1, "Each edge must cover at least one vertex"
            assert vs <= vertices, "Edge vertices must be a subset of the vertex set"

    def active_edges(self, k: int) -> List[Tuple[FrozenSet[int], int]]:
        """Return edges with weight ≤ k."""
        return [(vs, w) for vs, w in self.edges if w <= k]

    def support_complex(self, k: int) -> Set[FrozenSet[int]]:
        """All nonempty subsets of active edge vertex sets at scale k."""
        result = set()
        for vs, w in self.edges:
            if w <= k:
                for r in range(1, len(vs) + 1):
                    for subset in itertools.combinations(vs, r):
                        result.add(frozenset(subset))
        return result

    def width_at(self, k: int) -> int:
        """Maximum cardinality of an active edge's vertex set."""
        active = self.active_edges(k)
        return max((len(vs) for vs, _ in active), default=0)

    def codependency_time(self, u: int, v: int) -> int:
        """First scale at which u and v are jointly covered by some edge."""
        times = [w for vs, w in self.edges if u in vs and v in vs]
        return min(times) if times else float('inf')

    def beta_gap(self, k: int) -> int:
        """Reduced Euler characteristic of the support complex at scale k."""
        sc = self.support_complex(k)
        if not sc:
            return 0
        euler_sum = sum((-1) ** (len(s) + 1) for s in sc)
        return euler_sum - 1

    def is_cone_at(self, k: int) -> Tuple[bool, int]:
        """Check if the support complex at scale k is a cone. Returns (is_cone, apex)."""
        sc = self.support_complex(k)
        if not sc:
            return True, -1
        for apex in self.vertices:
            if all(frozenset(set(s) | {apex}) in sc for s in sc):
                return True, apex
        return False, -1


# ──────────────────────────────────────────────────────────────────────
# Benchmark families
# ──────────────────────────────────────────────────────────────────────

def benchmark_family(n: int, m: int) -> WeightedDepHypergraph:
    """
    Layered pair-dependency hypergraph on Fin(n).
    For each pair (i, j) with i < j < m, add edge {i, j} with weight j.
    """
    vertices = set(range(n))
    edges = []
    for i in range(n):
        for j in range(i + 1, min(m, n)):
            edges.append((frozenset({i, j}), j))
    return WeightedDepHypergraph(vertices, edges)


def star_family(n: int) -> WeightedDepHypergraph:
    """
    Star hypergraph: all edges contain vertex 0 (the hub).
    Edge {0, i} has weight i. This is always a cone.
    """
    vertices = set(range(n))
    edges = [(frozenset({0, i}), i) for i in range(1, n)]
    return WeightedDepHypergraph(vertices, edges)


def cycle_family(n: int) -> WeightedDepHypergraph:
    """
    Cycle graph on n vertices. Edge {i, (i+1) mod n} has weight i+1.
    The last edge closes the cycle, creating nontrivial topology.
    """
    vertices = set(range(n))
    edges = [(frozenset({i, (i + 1) % n}), i + 1) for i in range(n)]
    return WeightedDepHypergraph(vertices, edges)


# ──────────────────────────────────────────────────────────────────────
# Visualization
# ──────────────────────────────────────────────────────────────────────

def compute_hardness_curve(H: WeightedDepHypergraph, max_scale: int):
    """Compute (scale, width, betaGap) triples."""
    return [(k, H.width_at(k), H.beta_gap(k)) for k in range(max_scale + 1)]


def plot_phase_transition(n_values: List[int], filename: str = "phase_transition.png"):
    """
    Plot betaGap and width across scales for the benchmark family,
    showing the phase transition from easy to hard regimes.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: betaGap for benchmark family across m values
    ax = axes[0, 0]
    n = 8
    for m in [0, 2, 4, 6, 8]:
        H = benchmark_family(n, m)
        max_k = n
        curve = compute_hardness_curve(H, max_k)
        scales = [c[0] for c in curve]
        betas = [c[2] for c in curve]
        ax.plot(scales, betas, marker='o', markersize=3, label=f'm={m}')
    ax.set_xlabel('Filtration scale k')
    ax.set_ylabel('βgap (reduced Euler char.)')
    ax.set_title(f'Order Parameter vs Scale (n={n})')
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Panel 2: Width surrogate
    ax = axes[0, 1]
    for m in [0, 2, 4, 6, 8]:
        H = benchmark_family(n, m)
        max_k = n
        curve = compute_hardness_curve(H, max_k)
        scales = [c[0] for c in curve]
        widths = [c[1] for c in curve]
        ax.plot(scales, widths, marker='s', markersize=3, label=f'm={m}')
    ax.set_xlabel('Filtration scale k')
    ax.set_ylabel('Width surrogate')
    ax.set_title(f'Width vs Scale (n={n})')
    ax.legend()

    # Panel 3: Star vs Cycle comparison
    ax = axes[1, 0]
    n_test = 7
    H_star = star_family(n_test)
    H_cycle = cycle_family(n_test)
    max_k = n_test + 1

    curve_star = compute_hardness_curve(H_star, max_k)
    curve_cycle = compute_hardness_curve(H_cycle, max_k)

    ax.plot([c[0] for c in curve_star], [c[2] for c in curve_star],
            'b-o', markersize=4, label='Star (cone = easy)')
    ax.plot([c[0] for c in curve_cycle], [c[2] for c in curve_cycle],
            'r-s', markersize=4, label='Cycle (non-cone = hard)')
    ax.set_xlabel('Filtration scale k')
    ax.set_ylabel('βgap')
    ax.set_title('Star vs Cycle: Topological Phase Contrast')
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Panel 4: Co-dependency time heatmap
    ax = axes[1, 1]
    n_heat = 6
    m_heat = 6
    H = benchmark_family(n_heat, m_heat)
    matrix = np.zeros((n_heat, n_heat))
    for i in range(n_heat):
        for j in range(n_heat):
            t = H.codependency_time(i, j)
            matrix[i][j] = t if t != float('inf') else -1
    im = ax.imshow(matrix, cmap='viridis', interpolation='nearest')
    ax.set_xlabel('Vertex j')
    ax.set_ylabel('Vertex i')
    ax.set_title('Co-dependency Time Matrix')
    plt.colorbar(im, ax=ax)

    plt.tight_layout()
    plt.savefig(filename, dpi=150)
    plt.close()
    print(f"Phase transition plot saved to {filename}")


def plot_scaling_analysis(filename: str = "scaling_analysis.png"):
    """
    Analyze how the first nonzero betaGap scale changes with problem size.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    n_range = range(4, 16)
    for m_frac in [0.25, 0.5, 0.75, 1.0]:
        first_nonzero_scales = []
        ns = []
        for n in n_range:
            m = max(2, int(m_frac * n))
            H = benchmark_family(n, m)
            first_nonzero = None
            for k in range(n + 1):
                if H.beta_gap(k) != 0:
                    first_nonzero = k
                    break
            if first_nonzero is not None:
                first_nonzero_scales.append(first_nonzero)
                ns.append(n)
        if ns:
            ax.plot(ns, first_nonzero_scales, 'o-', label=f'm/n={m_frac:.2f}')

    ax.set_xlabel('Number of vertices n')
    ax.set_ylabel('First nonzero βgap scale')
    ax.set_title('Finite-Size Scaling of Topological Phase Transition')
    ax.legend()
    plt.tight_layout()
    plt.savefig(filename, dpi=150)
    plt.close()
    print(f"Scaling analysis saved to {filename}")


def print_detailed_example():
    """Print a detailed walkthrough of one example."""
    print("=" * 70)
    print("DETAILED EXAMPLE: Benchmark family n=5, m=4")
    print("=" * 70)

    H = benchmark_family(5, 4)
    print(f"\nVertices: {sorted(H.vertices)}")
    print(f"Edges:")
    for vs, w in sorted(H.edges, key=lambda x: x[1]):
        print(f"  {set(vs)} with weight {w}")

    print(f"\nFiltration analysis:")
    for k in range(6):
        sc = H.support_complex(k)
        w = H.width_at(k)
        bg = H.beta_gap(k)
        is_cone, apex = H.is_cone_at(k)
        n_simplices = len(sc)
        n_pairs = sum(1 for s in sc if len(s) == 2)

        print(f"\n  Scale k={k}:")
        print(f"    Active edges: {len(H.active_edges(k))}")
        print(f"    Support complex size: {n_simplices} simplices ({n_pairs} pairs)")
        print(f"    Width: {w}")
        print(f"    βgap: {bg}")
        print(f"    Is cone: {is_cone}" + (f" (apex={apex})" if is_cone and apex >= 0 else ""))

    print(f"\nCo-dependency times:")
    for i in range(5):
        for j in range(i + 1, 5):
            t = H.codependency_time(i, j)
            t_str = str(t) if t != float('inf') else "∞"
            print(f"  ({i},{j}): {t_str}")

    print("\n" + "=" * 70)
    print("COMPARISON: Star (easy) vs Cycle (hard) on 5 vertices")
    print("=" * 70)

    for name, H in [("Star", star_family(5)), ("Cycle", cycle_family(5))]:
        print(f"\n{name} family:")
        for k in range(7):
            bg = H.beta_gap(k)
            w = H.width_at(k)
            is_cone, _ = H.is_cone_at(k)
            print(f"  k={k}: βgap={bg:+d}, width={w}, cone={is_cone}")


def baseline_comparison():
    """Compare betaGap against naive syntactic baselines."""
    print("\n" + "=" * 70)
    print("BASELINE COMPARISON: βgap vs syntactic features")
    print("=" * 70)

    results = []
    for n in [5, 6, 7, 8]:
        for m_frac in [0.0, 0.25, 0.5, 0.75, 1.0]:
            m = int(m_frac * n)
            H = benchmark_family(n, m)
            max_k = n

            # Syntactic baselines
            n_edges = len(H.edges)
            avg_weight = np.mean([w for _, w in H.edges]) if H.edges else 0
            max_weight = max((w for _, w in H.edges), default=0)

            # Topological features
            max_beta = max(abs(H.beta_gap(k)) for k in range(max_k + 1))
            max_width = H.width_at(max_k)
            first_nonzero = next((k for k in range(max_k + 1) if H.beta_gap(k) != 0), -1)

            results.append({
                'n': n, 'm': m, 'm/n': m_frac,
                'edges': n_edges, 'avg_wt': avg_weight, 'max_wt': max_weight,
                'max_|β|': max_beta, 'max_w': max_width,
                'first_β≠0': first_nonzero
            })

    header = f"{'n':>3} {'m':>3} {'m/n':>5} | {'#edges':>6} {'avg_wt':>7} {'max_wt':>6} | {'max|β|':>6} {'max_w':>5} {'1st_β≠0':>8}"
    print(header)
    print("-" * len(header))
    for r in results:
        fnz = str(r['first_β≠0']) if r['first_β≠0'] >= 0 else "never"
        print(f"{r['n']:>3} {r['m']:>3} {r['m/n']:>5.2f} | {r['edges']:>6} {r['avg_wt']:>7.1f} {r['max_wt']:>6} | {r['max_|β|']:>6} {r['max_w']:>5} {fnz:>8}")


if __name__ == "__main__":
    print_detailed_example()
    baseline_comparison()

    try:
        plot_phase_transition([5, 8, 12])
        plot_scaling_analysis()
    except Exception as e:
        print(f"\nPlotting skipped (matplotlib issue): {e}")

    print("\nDemo complete.")
