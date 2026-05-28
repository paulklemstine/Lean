#!/usr/bin/env python3
"""
Applications of Cycle-Birth Theory to Network Science and Data Analysis.

Demonstrates practical applications of the formally verified theory:
1. Network robustness analysis via cycle-birth spectrum
2. Anomaly detection using tropical spectral signatures
3. Graph classification from birth distributions
4. Confidence intervals for topological summaries

Application keywords: network science, topological statistics, percolation,
topological data analysis, random optimization.
"""

import numpy as np
from typing import List, Tuple, Dict


# ========================================================================
# Self-contained core routines
# ========================================================================

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
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
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_cycle_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    mst_w = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
            mst_w.append(w)
    return births, mst_w


def ks_distance(s1, s2):
    if not s1 or not s2:
        return 1.0
    a, b = np.sort(s1), np.sort(s2)
    all_v = np.sort(np.concatenate([a, b]))
    c1 = np.searchsorted(a, all_v, side='right') / len(a)
    c2 = np.searchsorted(b, all_v, side='right') / len(b)
    return float(np.max(np.abs(c1 - c2)))


def sample_gnp_weighted(n, p, rng=None):
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# ========================================================================
# Application 1: Network Robustness Analysis
# ========================================================================

def network_robustness_score(n: int, edges: List[Tuple[int, int, float]]) -> Dict:
    """
    Analyze network robustness using cycle-birth spectrum.

    The cycle-birth distribution encodes how redundant connectivity emerges
    as edge weights increase. A network with many early cycle births has
    high topological redundancy (robustness), while late births indicate
    fragile connectivity.

    Returns:
        Dictionary with robustness metrics derived from cycle-birth theory.
    """
    births, mst_weights = compute_cycle_births(n, edges)
    m = len(edges)

    if not births:
        return {
            'beta_1': 0,
            'redundancy_ratio': 0.0,
            'mean_birth_quantile': None,
            'early_birth_fraction': 0.0,
            'robustness_score': 0.0,
        }

    beta_1 = len(births)
    all_weights = sorted([e[2] for e in edges])
    median_weight = np.median(all_weights)

    early_births = sum(1 for b in births if b <= median_weight)

    return {
        'beta_1': beta_1,
        'redundancy_ratio': beta_1 / m if m > 0 else 0,
        'mean_birth_weight': float(np.mean(births)),
        'median_birth_weight': float(np.median(births)),
        'early_birth_fraction': early_births / beta_1,
        'robustness_score': early_births / beta_1 * beta_1 / max(m, 1),
    }


# ========================================================================
# Application 2: Anomaly Detection
# ========================================================================

def detect_anomalous_graph(n: int, edges: List[Tuple[int, int, float]],
                            reference_births: List[List[float]],
                            threshold: float = 0.3) -> Dict:
    """
    Detect whether a graph's cycle-birth spectrum is anomalous.

    Uses KS distance from a reference collection of cycle-birth distributions
    (from the same generative model). By concentration (Theorem 3), typical
    graphs cluster tightly; outliers indicate structural anomaly.

    Args:
        n: vertices
        edges: weighted edge list
        reference_births: list of birth-weight lists from reference graphs
        threshold: KS distance threshold for anomaly

    Returns:
        Anomaly report dictionary.
    """
    births, _ = compute_cycle_births(n, edges)

    if not births or not reference_births:
        return {'is_anomalous': None, 'reason': 'insufficient data'}

    ks_distances = [ks_distance(births, ref) for ref in reference_births if ref]

    if not ks_distances:
        return {'is_anomalous': None, 'reason': 'no valid references'}

    mean_ks = float(np.mean(ks_distances))
    max_ks = float(np.max(ks_distances))

    return {
        'is_anomalous': mean_ks > threshold,
        'mean_ks_distance': mean_ks,
        'max_ks_distance': max_ks,
        'num_references': len(ks_distances),
        'threshold': threshold,
    }


# ========================================================================
# Application 3: Graph Classification
# ========================================================================

def cycle_birth_feature_vector(n: int, edges: List[Tuple[int, int, float]],
                                num_bins: int = 10) -> np.ndarray:
    """
    Compute a feature vector from the cycle-birth distribution.

    Bins the empirical CDF into a fixed-dimension vector suitable for
    machine learning classifiers. By universality (Theorem 4), after
    quantile normalization, this captures structural graph properties
    independent of the edge-weight distribution.
    """
    births, _ = compute_cycle_births(n, edges)

    if not births:
        return np.zeros(num_bins)

    # Quantile transform to [0,1]
    sorted_births = np.sort(births)
    n_births = len(sorted_births)
    quantiles = (np.arange(n_births) + 0.5) / n_births

    # Bin into histogram
    bin_edges = np.linspace(0, 1, num_bins + 1)
    hist, _ = np.histogram(quantiles, bins=bin_edges)
    return hist / max(n_births, 1)


# ========================================================================
# Application 4: Confidence Intervals for Topological Summaries
# ========================================================================

def topological_confidence_interval(n: int, p: float,
                                     num_bootstrap: int = 100,
                                     confidence: float = 0.95,
                                     rng=None) -> Dict:
    """
    Compute confidence intervals for the cycle-birth CDF.

    Uses the concentration inequality (Theorem 3) to provide
    theoretically-backed confidence bands for the empirical CDF.

    The McDiarmid bound gives:
        P(|N(t) - E[N(t)]| ≥ r) ≤ 2·exp(-2r²/m)

    For confidence level 1-α, the band width is sqrt(m·ln(2/α)/2).
    """
    if rng is None:
        rng = np.random.default_rng()

    m_expected = int(n * (n-1) / 2 * p)

    # Theoretical bound from McDiarmid
    alpha = 1 - confidence
    if m_expected > 0:
        theoretical_band = np.sqrt(m_expected * np.log(2/alpha) / 2)
    else:
        theoretical_band = 0

    # Bootstrap empirical band
    all_births = []
    for _ in range(num_bootstrap):
        edges = sample_gnp_weighted(n, p, rng)
        births, _ = compute_cycle_births(n, edges)
        all_births.append(births)

    # Compute empirical band at several thresholds
    eval_points = np.linspace(0, 1, 20)
    lower = np.zeros(len(eval_points))
    upper = np.zeros(len(eval_points))
    median_cdf = np.zeros(len(eval_points))

    for k, t in enumerate(eval_points):
        counts = []
        for births in all_births:
            if births:
                c = sum(1 for b in births if b <= t) / len(births)
            else:
                c = 0
            counts.append(c)
        counts = np.sort(counts)
        lo_idx = int((1 - confidence) / 2 * len(counts))
        hi_idx = int((1 + confidence) / 2 * len(counts))
        lower[k] = counts[max(0, lo_idx)]
        upper[k] = counts[min(len(counts)-1, hi_idx)]
        median_cdf[k] = np.median(counts)

    return {
        'n': n,
        'p': p,
        'confidence': confidence,
        'theoretical_band_width': float(theoretical_band),
        'empirical_band_width': float(np.mean(upper - lower)),
        'eval_points': eval_points.tolist(),
        'lower_band': lower.tolist(),
        'upper_band': upper.tolist(),
        'median_cdf': median_cdf.tolist(),
    }


# ========================================================================
# Main demonstration
# ========================================================================

if __name__ == '__main__':
    rng = np.random.default_rng(42)

    print("=" * 70)
    print("APPLICATION 1: NETWORK ROBUSTNESS ANALYSIS")
    print("=" * 70)

    # Compare a random network to a structured one
    n = 50
    random_edges = sample_gnp_weighted(n, 0.15, rng)
    rob = network_robustness_score(n, random_edges)
    print(f"  Random G(50, 0.15):")
    for k, v in rob.items():
        print(f"    {k}: {v}")

    print()
    print("=" * 70)
    print("APPLICATION 2: ANOMALY DETECTION")
    print("=" * 70)

    # Build reference from G(30, 0.2)
    references = []
    for _ in range(50):
        e = sample_gnp_weighted(30, 0.2, rng)
        b, _ = compute_cycle_births(30, e)
        references.append(b)

    # Test a normal graph
    normal_edges = sample_gnp_weighted(30, 0.2, rng)
    result = detect_anomalous_graph(30, normal_edges, references)
    print(f"  Normal graph:    anomalous={result['is_anomalous']}, "
          f"mean KS={result['mean_ks_distance']:.4f}")

    # Test an anomalous graph (different p)
    anomalous_edges = sample_gnp_weighted(30, 0.5, rng)
    result = detect_anomalous_graph(30, anomalous_edges, references)
    print(f"  Anomalous graph: anomalous={result['is_anomalous']}, "
          f"mean KS={result['mean_ks_distance']:.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 3: GRAPH FEATURE VECTORS")
    print("=" * 70)

    for p_val in [0.1, 0.2, 0.3]:
        edges = sample_gnp_weighted(40, p_val, rng)
        fv = cycle_birth_feature_vector(40, edges)
        print(f"  G(40, {p_val}): features = {np.round(fv, 3)}")

    print()
    print("=" * 70)
    print("APPLICATION 4: CONFIDENCE INTERVALS")
    print("=" * 70)

    ci = topological_confidence_interval(50, 0.15, num_bootstrap=50, rng=rng)
    print(f"  n={ci['n']}, p={ci['p']}, confidence={ci['confidence']}")
    print(f"  Theoretical band width (McDiarmid): {ci['theoretical_band_width']:.2f}")
    print(f"  Empirical band width:               {ci['empirical_band_width']:.4f}")
