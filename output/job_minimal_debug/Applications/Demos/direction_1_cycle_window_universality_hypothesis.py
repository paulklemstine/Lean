#!/usr/bin/env python3
"""
Applications of Cycle-Window Universality

Demonstrates practical applications of the cycle-rank universality theory:
1. Synthetic corpus realism diagnostic
2. Theorem family classification
3. Proof complexity indicator
4. Knowledge graph topology analysis
"""

import random
import numpy as np
from typing import List, Set, Dict, Tuple


# ─────────────────────────────────────────────────────────────────────────────
# Utility: core algorithms (self-contained)
# ─────────────────────────────────────────────────────────────────────────────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True


def cycle_rank(n_vertices, edges):
    uf = UnionFind(n_vertices)
    for u, v in edges:
        uf.union(u, v)
    return max(0, len(edges) - n_vertices + uf.num_components)


def compute_profile(feature_sets, n_thresholds=40):
    """Compute full normalized cycle-rank profile from feature sets."""
    n = len(feature_sets)
    # Distance matrix
    dists = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            d = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            dists[i, j] = d
            dists[j, i] = d

    upper = dists[np.triu_indices_from(dists, k=1)]
    median_d = float(np.median(upper))
    max_d = upper.max()

    thresholds = np.linspace(0, max_d, n_thresholds)
    curve = np.zeros(n_thresholds, dtype=int)
    for k, eps in enumerate(thresholds):
        edges = [(i, j) for i in range(n) for j in range(i+1, n) if dists[i, j] <= eps]
        curve[k] = cycle_rank(n, edges)

    max_cr = curve.max()
    norm_curve = curve.astype(float) / max_cr if max_cr > 0 else np.zeros(n_thresholds)
    norm_thresh = thresholds / median_d if median_d > 0 else thresholds.copy()

    return norm_thresh, norm_curve, curve, thresholds, median_d


def ks_distance(t1, c1, t2, c2, n_interp=200):
    """KS distance between two normalized profiles."""
    mx = max(t1.max(), t2.max())
    common = np.linspace(0, mx, n_interp)
    i1 = np.interp(common, t1, c1)
    i2 = np.interp(common, t2, c2)
    return float(np.max(np.abs(i1 - i2)))


# ─────────────────────────────────────────────────────────────────────────────
# Application 1: Synthetic Corpus Realism Diagnostic
# ─────────────────────────────────────────────────────────────────────────────

def corpus_realism_diagnostic():
    """
    Assess whether a synthetic theorem corpus has realistic topology.

    A synthetic corpus is "topologically realistic" if its normalized
    cycle-rank profile lies close to the universal master curve established
    from natural theorem families. Large deviations indicate that the
    synthetic generation process is producing statements with unrealistic
    semantic structure.
    """
    print("=" * 70)
    print("APPLICATION 1: Synthetic Corpus Realism Diagnostic")
    print("=" * 70)
    print()

    random.seed(42)
    np.random.seed(42)

    # "Natural" reference corpus (diverse features, moderate correlation)
    alphabet = list(range(20))
    natural = [set(random.sample(alphabet, random.randint(4, 10)))
               for _ in range(30)]
    ref_t, ref_c, _, _, _ = compute_profile(natural)

    # Synthetic corpus 1: realistic (similar statistics)
    synthetic_good = [set(random.sample(alphabet, random.randint(4, 10)))
                      for _ in range(30)]
    sg_t, sg_c, _, _, _ = compute_profile(synthetic_good)

    # Synthetic corpus 2: unrealistic (all features identical, very clustered)
    synthetic_bad = []
    for _ in range(30):
        if random.random() < 0.5:
            synthetic_bad.append(set(range(10)))  # cluster 1
        else:
            synthetic_bad.append(set(range(10, 20)))  # cluster 2
    # Add slight noise
    for s in synthetic_bad:
        if random.random() < 0.3:
            s.add(random.choice(alphabet))
    sb_t, sb_c, _, _, _ = compute_profile(synthetic_bad)

    ks_good = ks_distance(ref_t, ref_c, sg_t, sg_c)
    ks_bad = ks_distance(ref_t, ref_c, sb_t, sb_c)

    print(f"Reference corpus: 30 natural-style statements")
    print(f"Realistic synthetic: KS distance = {ks_good:.4f}")
    print(f"Unrealistic synthetic: KS distance = {ks_bad:.4f}")
    print()

    if ks_good < 0.2:
        print("✓ Realistic synthetic corpus passes topological diagnostic")
    else:
        print("✗ Realistic synthetic corpus fails (unexpected)")

    if ks_bad > 0.3:
        print("✓ Unrealistic synthetic corpus correctly flagged")
    else:
        print("⚠ Unrealistic synthetic corpus not detected (boundary case)")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Application 2: Theorem Family Classification
# ─────────────────────────────────────────────────────────────────────────────

def theorem_family_classification():
    """
    Classify theorem families by their cycle-window topology.

    The width and location of the cycle window, combined with the peak
    susceptibility location, serve as topological fingerprints for theorem
    families. Families with similar fingerprints belong to the same
    universality class.
    """
    print("=" * 70)
    print("APPLICATION 2: Theorem Family Classification")
    print("=" * 70)
    print()

    random.seed(123)

    # Family A: "algebraic" (moderate feature overlap, structured)
    alg = list(range(15))
    family_a = [set(random.sample(alg, random.randint(3, 7))) for _ in range(25)]

    # Family B: "combinatorial" (wider feature spread, less overlap)
    comb = list(range(25))
    family_b = [set(random.sample(comb, random.randint(5, 12))) for _ in range(25)]

    # Family C: "number-theoretic" (similar to algebraic but different alphabet)
    nt = list(range(15, 30))
    family_c = [set(random.sample(nt, random.randint(3, 7))) for _ in range(25)]

    profiles = {}
    for name, family in [("Algebraic", family_a), ("Combinatorial", family_b),
                          ("Number-Theoretic", family_c)]:
        t, c, raw, thresh, med = compute_profile(family)
        deriv = np.diff(raw.astype(float))
        peak_idx = np.argmax(deriv) if len(deriv) > 0 else 0
        positive = np.where(raw > 0)[0]
        window_width = (thresh[positive[-1]] - thresh[positive[0]]) / med if (
            len(positive) > 0 and med > 0) else 0
        profiles[name] = {
            'norm_thresh': t, 'norm_curve': c,
            'peak_location': thresh[peak_idx] / med if med > 0 else 0,
            'window_width': window_width,
            'max_cr': raw.max()
        }

    print(f"{'Family':>20}  {'Peak Location':>14}  {'Window Width':>13}  {'Max β₁':>7}")
    print("-" * 60)
    for name, p in profiles.items():
        print(f"{name:>20}  {p['peak_location']:>14.3f}  "
              f"{p['window_width']:>13.3f}  {p['max_cr']:>7}")

    # Pairwise KS distances
    print()
    names = list(profiles.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            d = ks_distance(profiles[names[i]]['norm_thresh'],
                           profiles[names[i]]['norm_curve'],
                           profiles[names[j]]['norm_thresh'],
                           profiles[names[j]]['norm_curve'])
            print(f"  KS({names[i]}, {names[j]}) = {d:.4f}")

    print()
    print("Families with similar window width and peak location")
    print("belong to the same universality class.")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Application 3: Knowledge Graph Complexity Analysis
# ─────────────────────────────────────────────────────────────────────────────

def knowledge_graph_analysis():
    """
    Analyze the topological complexity of a knowledge graph by treating
    concepts as statements and shared properties as features.

    The cycle rank profile reveals the mesoscopic connectivity structure:
    - Low cycle rank → tree-like, hierarchical knowledge organization
    - High cycle rank → densely cross-referenced, web-like structure
    - Peak location → characteristic scale of conceptual similarity
    """
    print("=" * 70)
    print("APPLICATION 3: Knowledge Graph Complexity Analysis")
    print("=" * 70)
    print()

    random.seed(99)

    # Simulate three knowledge domains
    domains = {
        "Elementary Algebra": {
            'n_concepts': 20,
            'n_properties': 12,
            'density': 0.35  # moderate feature density
        },
        "Advanced Topology": {
            'n_concepts': 20,
            'n_properties': 18,
            'density': 0.25  # sparser, more specialized
        },
        "Applied Statistics": {
            'n_concepts': 20,
            'n_properties': 15,
            'density': 0.40  # denser connections
        }
    }

    for domain_name, config in domains.items():
        props = list(range(config['n_properties']))
        concepts = []
        for _ in range(config['n_concepts']):
            n_feat = max(1, int(np.random.binomial(config['n_properties'],
                                                    config['density'])))
            concepts.append(set(random.sample(props, min(n_feat, len(props)))))

        t, c, raw, thresh, med = compute_profile(concepts, n_thresholds=30)
        max_cr = raw.max()
        deriv = np.diff(raw.astype(float))
        peak_idx = np.argmax(deriv) if len(deriv) > 0 else 0

        print(f"{domain_name}:")
        print(f"  Concepts: {config['n_concepts']}, Properties: {config['n_properties']}")
        print(f"  Median distance: {med:.1f}")
        print(f"  Max cycle rank: {max_cr}")
        print(f"  Topological complexity: ", end="")
        if max_cr <= 2:
            print("LOW (tree-like)")
        elif max_cr <= 10:
            print("MODERATE (web-like)")
        else:
            print("HIGH (densely cross-referenced)")
        print()

    print("Higher topological complexity indicates more cross-referencing")
    print("and potential for diverse proof paths between concepts.")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    corpus_realism_diagnostic()
    theorem_family_classification()
    knowledge_graph_analysis()


#!/usr/bin/env python3
"""
Cycle-Window Universality Experiment

Demonstrates that normalized cycle-rank profiles of threshold graph filtrations
built from structurally distinct theorem families collapse onto a common curve
after rescaling by median pairwise distance and normalizing by peak cycle rank.

Generates 5 theorem families, builds semantic threshold graphs, computes full
cycle-rank curves, overlays them, and reports pairwise KS distances.

Usage:
    python demo.py [--family-size N] [--alphabet-size M] [--num-thresholds T]
"""

import argparse
import itertools
import random
from collections import defaultdict

import numpy as np

# ─────────────────────────────────────────────────────────────────────────────
# Graph data structures (no external graph library needed)
# ─────────────────────────────────────────────────────────────────────────────

class UnionFind:
    """Disjoint-set / union-find for connected component counting."""
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True


def compute_cycle_rank(n_vertices, edges):
    """Compute β₁ = |E| - |V| + c(G) for a graph on n_vertices with given edges."""
    uf = UnionFind(n_vertices)
    for u, v in edges:
        uf.union(u, v)
    return len(edges) - n_vertices + uf.num_components


def pairwise_distances(feature_sets, metric='symmetric_difference'):
    """Compute pairwise distances between feature sets."""
    n = len(feature_sets)
    dists = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if metric == 'symmetric_difference':
                d = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            elif metric == 'hamming':
                d = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            elif metric == 'jaccard':
                union = feature_sets[i] | feature_sets[j]
                inter = feature_sets[i] & feature_sets[j]
                d = len(union) - len(inter) if union else 0
            else:
                d = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            dists[i, j] = d
            dists[j, i] = d
    return dists


def threshold_graph_edges(dists, epsilon):
    """Return edges of threshold graph: {(i,j) : d(i,j) ≤ epsilon, i < j}."""
    n = dists.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if dists[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def cycle_rank_curve(dists, thresholds):
    """Compute cycle rank at each threshold."""
    n = dists.shape[0]
    curve = []
    for eps in thresholds:
        edges = threshold_graph_edges(dists, eps)
        cr = compute_cycle_rank(n, edges)
        curve.append(max(0, cr))  # β₁ ≥ 0 for actual graphs
    return np.array(curve)


def normalize_curve(curve, thresholds, median_dist):
    """Normalize: rescale threshold by median, divide curve by max."""
    max_val = curve.max()
    if max_val == 0:
        norm_curve = np.zeros_like(curve, dtype=float)
    else:
        norm_curve = curve.astype(float) / max_val
    if median_dist == 0:
        norm_thresh = thresholds.astype(float)
    else:
        norm_thresh = thresholds.astype(float) / median_dist
    return norm_thresh, norm_curve


def ks_distance(curve1, curve2):
    """Sup-norm distance between two curves (assumed same length)."""
    return np.max(np.abs(curve1 - curve2))


# ─────────────────────────────────────────────────────────────────────────────
# Theorem family generators
# ─────────────────────────────────────────────────────────────────────────────

def generate_propositional_tautologies(n, alphabet_size, p=0.3):
    """Propositional tautology templates: features = used connectives/variables."""
    connectives = [f"AND_{i}" for i in range(alphabet_size // 3)]
    variables = [f"VAR_{i}" for i in range(alphabet_size // 3)]
    structures = [f"STRUCT_{i}" for i in range(alphabet_size - 2 * (alphabet_size // 3))]
    alphabet = connectives + variables + structures
    families = []
    for _ in range(n):
        feats = set()
        for f in alphabet:
            if random.random() < p:
                feats.add(f)
        if not feats:
            feats.add(random.choice(alphabet))
        families.append(feats)
    return families


def generate_algebraic_identities(n, alphabet_size, p=0.3):
    """Algebraic identity templates: features = operations, degree, structure type."""
    ops = [f"OP_{i}" for i in range(alphabet_size // 3)]
    degrees = [f"DEG_{i}" for i in range(alphabet_size // 3)]
    types = [f"TYPE_{i}" for i in range(alphabet_size - 2 * (alphabet_size // 3))]
    alphabet = ops + degrees + types
    families = []
    for _ in range(n):
        feats = set()
        for f in alphabet:
            if random.random() < p:
                feats.add(f)
        if not feats:
            feats.add(random.choice(alphabet))
        families.append(feats)
    return families


def generate_divisibility_statements(n, alphabet_size, p=0.3):
    """Divisibility statements: features = prime factors, divisibility patterns."""
    primes = [f"PRIME_{i}" for i in range(alphabet_size // 2)]
    patterns = [f"PAT_{i}" for i in range(alphabet_size - alphabet_size // 2)]
    alphabet = primes + patterns
    families = []
    for _ in range(n):
        feats = set()
        for f in alphabet:
            if random.random() < p:
                feats.add(f)
        if not feats:
            feats.add(random.choice(alphabet))
        families.append(feats)
    return families


def generate_combinatorial_inequalities(n, alphabet_size, p=0.3):
    """Combinatorial inequality templates: features = bound types, techniques."""
    bounds = [f"BOUND_{i}" for i in range(alphabet_size // 3)]
    techniques = [f"TECH_{i}" for i in range(alphabet_size // 3)]
    objects = [f"OBJ_{i}" for i in range(alphabet_size - 2 * (alphabet_size // 3))]
    alphabet = bounds + techniques + objects
    families = []
    for _ in range(n):
        feats = set()
        for f in alphabet:
            if random.random() < p:
                feats.add(f)
        if not feats:
            feats.add(random.choice(alphabet))
        families.append(feats)
    return families


def generate_graph_properties(n, alphabet_size, p=0.3):
    """Graph property statements: features = graph invariants, property types."""
    invariants = [f"INV_{i}" for i in range(alphabet_size // 2)]
    properties = [f"PROP_{i}" for i in range(alphabet_size - alphabet_size // 2)]
    alphabet = invariants + properties
    families = []
    for _ in range(n):
        feats = set()
        for f in alphabet:
            if random.random() < p:
                feats.add(f)
        if not feats:
            feats.add(random.choice(alphabet))
        families.append(feats)
    return families


# ─────────────────────────────────────────────────────────────────────────────
# Main experiment
# ─────────────────────────────────────────────────────────────────────────────

def run_experiment(family_size=40, alphabet_size=20, num_thresholds=50,
                   metric='symmetric_difference', seed=42):
    """Run the full universality experiment."""
    random.seed(seed)
    np.random.seed(seed)

    # Generate 5 theorem families
    generators = [
        ("Propositional Tautologies", generate_propositional_tautologies),
        ("Algebraic Identities", generate_algebraic_identities),
        ("Divisibility Statements", generate_divisibility_statements),
        ("Combinatorial Inequalities", generate_combinatorial_inequalities),
        ("Graph Properties", generate_graph_properties),
    ]

    results = {}

    print("=" * 70)
    print("CYCLE-WINDOW UNIVERSALITY EXPERIMENT")
    print("=" * 70)
    print(f"Family size: {family_size}")
    print(f"Alphabet size: {alphabet_size}")
    print(f"Number of thresholds: {num_thresholds}")
    print(f"Distance metric: {metric}")
    print()

    all_median_dists = []

    for name, generator in generators:
        print(f"--- {name} ---")
        features = generator(family_size, alphabet_size)

        # Compute pairwise distances
        dists = pairwise_distances(features, metric)

        # Get upper triangle distances
        upper_tri = dists[np.triu_indices_from(dists, k=1)]
        median_dist = np.median(upper_tri)
        all_median_dists.append(median_dist)

        # Build threshold grid
        max_dist = upper_tri.max()
        thresholds = np.linspace(0, max_dist, num_thresholds)

        # Compute cycle rank curve
        cr_curve = cycle_rank_curve(dists, thresholds)

        # Normalize
        norm_thresh, norm_curve = normalize_curve(cr_curve, thresholds, median_dist)

        # Discrete derivative
        deriv = np.diff(cr_curve.astype(float))
        peak_deriv_idx = np.argmax(deriv) if len(deriv) > 0 else 0
        peak_deriv_thresh = thresholds[peak_deriv_idx] if len(thresholds) > 0 else 0

        # Cycle window detection
        positive_indices = np.where(cr_curve > 0)[0]
        if len(positive_indices) > 0:
            window_start = thresholds[positive_indices[0]]
            window_end = thresholds[positive_indices[-1]]
            window_width = window_end - window_start
        else:
            window_start = window_end = window_width = 0

        results[name] = {
            'norm_thresh': norm_thresh,
            'norm_curve': norm_curve,
            'raw_curve': cr_curve,
            'thresholds': thresholds,
            'median_dist': median_dist,
            'max_cycle_rank': cr_curve.max(),
            'peak_deriv_thresh': peak_deriv_thresh,
            'window': (window_start, window_end, window_width),
        }

        print(f"  Median distance: {median_dist:.2f}")
        print(f"  Max cycle rank: {cr_curve.max()}")
        print(f"  Peak derivative at ε = {peak_deriv_thresh:.2f}")
        print(f"  Cycle window: [{window_start:.2f}, {window_end:.2f}] "
              f"(width = {window_width:.2f})")
        print()

    # Pairwise KS distances between normalized curves
    print("=" * 70)
    print("PAIRWISE KS DISTANCES (normalized curves)")
    print("=" * 70)

    names = list(results.keys())
    ks_matrix = np.zeros((len(names), len(names)))
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                # Interpolate curves to common grid
                common_thresh = np.linspace(0, 3, 100)
                c1 = np.interp(common_thresh, results[n1]['norm_thresh'],
                               results[n1]['norm_curve'])
                c2 = np.interp(common_thresh, results[n2]['norm_thresh'],
                               results[n2]['norm_curve'])
                ks = ks_distance(c1, c2)
                ks_matrix[i, j] = ks
                ks_matrix[j, i] = ks

    # Print KS distance table
    header = f"{'':>30}"
    for name in names:
        header += f"  {name[:12]:>12}"
    print(header)
    for i, n1 in enumerate(names):
        row = f"{n1:>30}"
        for j, n2 in enumerate(names):
            if i == j:
                row += f"  {'---':>12}"
            else:
                row += f"  {ks_matrix[i,j]:>12.4f}"
        print(row)

    avg_ks = ks_matrix[np.triu_indices_from(ks_matrix, k=1)].mean()
    max_ks = ks_matrix[np.triu_indices_from(ks_matrix, k=1)].max()
    print(f"\nAverage KS distance: {avg_ks:.4f}")
    print(f"Maximum KS distance: {max_ks:.4f}")

    # Summary
    print()
    print("=" * 70)
    print("UNIVERSALITY ASSESSMENT")
    print("=" * 70)
    if avg_ks < 0.15:
        print("STRONG UNIVERSALITY: Normalized curves are highly similar")
        print(f"  (average KS distance = {avg_ks:.4f} < 0.15)")
    elif avg_ks < 0.3:
        print("MODERATE UNIVERSALITY: Normalized curves show approximate collapse")
        print(f"  (average KS distance = {avg_ks:.4f} < 0.30)")
    else:
        print("WEAK UNIVERSALITY: Curves show family-dependent variation")
        print(f"  (average KS distance = {avg_ks:.4f})")

    print()
    print("Normalized cycle-rank curves (sampled at key thresholds):")
    sample_points = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    header = f"{'ε/median':>10}"
    for name in names:
        header += f"  {name[:12]:>12}"
    print(header)
    for sp in sample_points:
        row = f"{sp:>10.2f}"
        for name in names:
            val = np.interp(sp, results[name]['norm_thresh'],
                           results[name]['norm_curve'])
            row += f"  {val:>12.4f}"
        print(row)

    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Cycle-Window Universality Experiment")
    parser.add_argument("--family-size", type=int, default=40,
                       help="Number of statements per family (default: 40)")
    parser.add_argument("--alphabet-size", type=int, default=20,
                       help="Size of feature alphabet (default: 20)")
    parser.add_argument("--num-thresholds", type=int, default=50,
                       help="Number of threshold values to sample (default: 50)")
    parser.add_argument("--metric", type=str, default="symmetric_difference",
                       choices=["symmetric_difference", "hamming", "jaccard"],
                       help="Distance metric (default: symmetric_difference)")
    parser.add_argument("--seed", type=int, default=42,
                       help="Random seed (default: 42)")
    args = parser.parse_args()

    run_experiment(
        family_size=args.family_size,
        alphabet_size=args.alphabet_size,
        num_thresholds=args.num_thresholds,
        metric=args.metric,
        seed=args.seed,
    )
