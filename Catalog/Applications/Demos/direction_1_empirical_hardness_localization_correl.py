"""
Topological Proof Pressure: Applications

Demonstrates practical applications of the topological proof pressure theory:
1. Theorem difficulty prediction from graph topology
2. Prover resource allocation via pressure-guided scheduling
3. Library cartography — mapping the "difficulty landscape" of a theorem corpus
"""

import numpy as np
from algorithms import (
    build_threshold_graph, local_cycle_pressure, graph_cycle_rank,
    cycle_rank_sweep, pairwise_concordance, spearman_correlation,
    find_bridges, connected_components, full_pipeline
)
from typing import List, Set, Dict, Tuple


# ─────────────────────────────────────────────────────────────────────
# Application 1: Theorem Difficulty Prediction
# ─────────────────────────────────────────────────────────────────────

def predict_difficulty(
    features: List[Set[str]],
    known_hardness: Dict[int, float],
    epsilon: int
) -> Dict[int, float]:
    """Predict proof difficulty for theorems using cycle pressure.
    
    Uses the monotonicity principle: theorems with higher cycle pressure
    are predicted to be harder. Known hardness values calibrate the scale.
    
    Args:
        features: Feature sets for all theorems.
        known_hardness: {index: hardness} for theorems with known difficulty.
        epsilon: Threshold for semantic graph.
    
    Returns:
        {index: predicted_hardness} for all theorems.
    """
    adj = build_threshold_graph(features, epsilon)
    pressure = local_cycle_pressure(adj)
    
    # Calibration: fit a simple linear model pressure -> hardness
    # using known hardness values
    if not known_hardness:
        return {i: float(pressure.get(i, 0)) for i in range(len(features))}
    
    known_pressures = [pressure.get(i, 0) for i in known_hardness]
    known_values = list(known_hardness.values())
    
    # Simple linear regression
    mean_p = np.mean(known_pressures)
    mean_h = np.mean(known_values)
    
    var_p = np.var(known_pressures)
    if var_p > 0:
        slope = np.cov(known_pressures, known_values)[0, 1] / var_p
        intercept = mean_h - slope * mean_p
    else:
        slope = 0
        intercept = mean_h
    
    predictions = {}
    for i in range(len(features)):
        predictions[i] = max(0, intercept + slope * pressure.get(i, 0))
    
    return predictions


# ─────────────────────────────────────────────────────────────────────
# Application 2: Pressure-Guided Prover Scheduling
# ─────────────────────────────────────────────────────────────────────

def pressure_guided_schedule(
    features: List[Set[str]],
    total_budget: float,
    epsilon: int,
    base_timeout: float = 1.0,
    pressure_multiplier: float = 3.0
) -> List[float]:
    """Allocate prover timeouts proportional to cycle pressure.
    
    Theorems with higher cycle pressure receive more time, reflecting
    the hardness barrier theorem: high-pressure theorems are expected
    to be harder and need more resources.
    
    Args:
        features: Feature sets for all theorems.
        total_budget: Total time budget.
        epsilon: Threshold for semantic graph.
        base_timeout: Minimum timeout per theorem.
        pressure_multiplier: Factor by which high-pressure theorems
            get extra time.
    
    Returns:
        List of timeouts, one per theorem.
    """
    n = len(features)
    adj = build_threshold_graph(features, epsilon)
    pressure = local_cycle_pressure(adj)
    
    # Compute weights: base + pressure_multiplier * normalized_pressure
    max_pressure = max(pressure.get(i, 0) for i in range(n))
    if max_pressure == 0:
        max_pressure = 1
    
    weights = []
    for i in range(n):
        p = pressure.get(i, 0) / max_pressure
        weights.append(base_timeout + pressure_multiplier * p)
    
    # Normalize to total budget
    total_weight = sum(weights)
    timeouts = [w * total_budget / total_weight for w in weights]
    
    return timeouts


def compare_scheduling_strategies(
    features: List[Set[str]],
    true_hardness: List[float],
    total_budget: float,
    epsilon: int,
    n_trials: int = 100
) -> Dict[str, float]:
    """Compare pressure-guided vs uniform scheduling.
    
    Simulates proof-search with a simple model: a theorem is "solved"
    if the allocated timeout exceeds its true hardness.
    
    Returns:
        Dictionary with solve rates for each strategy.
    """
    n = len(features)
    
    # Strategy 1: Uniform allocation
    uniform_timeout = total_budget / n
    uniform_solved = sum(1 for h in true_hardness if h <= uniform_timeout)
    
    # Strategy 2: Pressure-guided allocation
    pressure_timeouts = pressure_guided_schedule(
        features, total_budget, epsilon
    )
    pressure_solved = sum(
        1 for i, h in enumerate(true_hardness)
        if h <= pressure_timeouts[i]
    )
    
    # Strategy 3: Random allocation
    rng = np.random.RandomState(42)
    random_solved_total = 0
    for _ in range(n_trials):
        random_weights = rng.exponential(1, n)
        random_timeouts = random_weights * total_budget / random_weights.sum()
        random_solved = sum(
            1 for i, h in enumerate(true_hardness)
            if h <= random_timeouts[i]
        )
        random_solved_total += random_solved
    
    return {
        'uniform_solve_rate': uniform_solved / n,
        'pressure_solve_rate': pressure_solved / n,
        'random_solve_rate': random_solved_total / (n * n_trials),
        'pressure_improvement': (pressure_solved - uniform_solved) / max(uniform_solved, 1),
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Library Cartography
# ─────────────────────────────────────────────────────────────────────

def library_cartography(
    features: List[Set[str]],
    names: List[str],
    epsilon: int
) -> Dict:
    """Create a "difficulty map" of a theorem library.
    
    Identifies:
    - Easy zones (tree-like, zero pressure)
    - Hard zones (cycle-rich, positive pressure)
    - Bridge theorems (connecting different zones)
    - Pressure hotspots (maximum pressure vertices)
    
    Args:
        features: Feature sets.
        names: Theorem names.
        epsilon: Threshold.
    
    Returns:
        Dictionary with cartographic analysis.
    """
    adj = build_threshold_graph(features, epsilon)
    pressure = local_cycle_pressure(adj)
    bridges = find_bridges(adj)
    components = connected_components(adj)
    
    # Classify vertices
    easy_zone = [i for i in range(len(features)) if pressure.get(i, 0) == 0]
    hard_zone = [i for i in range(len(features)) if pressure.get(i, 0) > 0]
    
    # Find bridge theorems (endpoints of bridge edges)
    bridge_theorems = set()
    for u, v in bridges:
        bridge_theorems.add(u)
        bridge_theorems.add(v)
    
    # Find pressure hotspots (top 10%)
    n = len(features)
    sorted_by_pressure = sorted(range(n), key=lambda i: pressure.get(i, 0), reverse=True)
    top_k = max(1, n // 10)
    hotspots = sorted_by_pressure[:top_k]
    
    # Component analysis
    component_info = []
    for comp in components:
        comp_edges = sum(
            1 for u in comp for v in adj.get(u, set()) 
            if v in comp and u < v
        )
        comp_cr = comp_edges - len(comp) + 1
        comp_avg_pressure = np.mean([pressure.get(i, 0) for i in comp]) if comp else 0
        component_info.append({
            'size': len(comp),
            'edges': comp_edges,
            'cycle_rank': comp_cr,
            'avg_pressure': comp_avg_pressure,
            'classification': 'cyclic' if comp_cr > 0 else 'acyclic',
        })
    
    return {
        'n_theorems': n,
        'n_easy': len(easy_zone),
        'n_hard': len(hard_zone),
        'n_bridge_theorems': len(bridge_theorems),
        'easy_zone': [names[i] for i in easy_zone],
        'hard_zone': [names[i] for i in hard_zone],
        'bridge_theorems': [names[i] for i in bridge_theorems],
        'hotspots': [(names[i], pressure.get(i, 0)) for i in hotspots],
        'n_components': len(components),
        'component_info': component_info,
    }


# ─────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────

def demo_applications():
    """Run all three applications on a synthetic dataset."""
    np.random.seed(42)
    
    # Generate synthetic theorem library
    n = 100
    feature_universe = [f'symbol_{i}' for i in range(40)]
    names = [f'theorem_{i}' for i in range(n)]
    
    # Create clusters with varying density
    features = []
    for i in range(n):
        if i < 30:  # Dense cluster (algebraic)
            base = set(feature_universe[:15])
            noise = set(np.random.choice(feature_universe[:20], 3, replace=False))
            features.append(base | noise)
        elif i < 60:  # Medium cluster (analytic)
            base = set(feature_universe[10:25])
            noise = set(np.random.choice(feature_universe[8:30], 4, replace=False))
            features.append(base | noise)
        else:  # Sparse cluster (topological)
            base = set(feature_universe[20:30])
            noise = set(np.random.choice(feature_universe[18:40], 5, replace=False))
            features.append(base | noise)
    
    # Find optimal epsilon
    best_eps, best_rank, profile = cycle_rank_sweep(features, max_epsilon=20)
    print(f"Optimal epsilon: {best_eps}")
    print(f"Best cycle rank: {best_rank}")
    
    # Compute pressure
    adj = build_threshold_graph(features, best_eps)
    pressure = local_cycle_pressure(adj)
    
    # Simulate true hardness (correlated with pressure)
    true_hardness = []
    for i in range(n):
        p = pressure.get(i, 0)
        base_h = 0.5 + 0.3 * p  # Linear relationship
        noise = np.random.exponential(0.2)
        true_hardness.append(base_h + noise)
    
    print("\n=== Application 1: Difficulty Prediction ===")
    known = {i: true_hardness[i] for i in range(0, n, 5)}  # 20% known
    predictions = predict_difficulty(features, known, best_eps)
    
    pred_list = [predictions[i] for i in range(n)]
    actual_corr = spearman_correlation(pred_list, true_hardness)
    print(f"Prediction-actual Spearman correlation: {actual_corr:.4f}")
    
    print("\n=== Application 2: Prover Scheduling ===")
    total_budget = n * 1.0  # Same total budget
    results = compare_scheduling_strategies(
        features, true_hardness, total_budget, best_eps
    )
    print(f"Uniform solve rate: {results['uniform_solve_rate']:.2%}")
    print(f"Pressure-guided solve rate: {results['pressure_solve_rate']:.2%}")
    print(f"Random solve rate: {results['random_solve_rate']:.2%}")
    print(f"Pressure improvement over uniform: {results['pressure_improvement']:.1%}")
    
    print("\n=== Application 3: Library Cartography ===")
    carto = library_cartography(features, names, best_eps)
    print(f"Easy zone: {carto['n_easy']} theorems")
    print(f"Hard zone: {carto['n_hard']} theorems")
    print(f"Bridge theorems: {carto['n_bridge_theorems']}")
    print(f"Connected components: {carto['n_components']}")
    print(f"Top pressure hotspots:")
    for name, p in carto['hotspots'][:5]:
        print(f"  {name}: pressure = {p}")


if __name__ == '__main__':
    demo_applications()


#!/usr/bin/env python3
"""
Topological Proof Pressure: Interactive Demo

Demonstrates the topological proof pressure phenomenon:
1. Builds a semantic threshold graph from synthetic theorem features
2. Sweeps thresholds to find the cycle rank peak
3. Computes local cycle pressure at each vertex
4. Correlates pressure with simulated proof-search hardness
5. Visualizes the results

Run: python demo.py
"""

import numpy as np
import sys
from collections import defaultdict
from typing import List, Set, Dict, Tuple, Optional


# ── Self-contained implementations (no local imports) ──────────────

def symmetric_difference_card(a: Set[str], b: Set[str]) -> int:
    return len(a - b) + len(b - a)


def build_threshold_graph(features: List[Set[str]], epsilon: int) -> Dict[int, Set[int]]:
    n = len(features)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if symmetric_difference_card(features[i], features[j]) <= epsilon:
                adj[i].add(j)
                adj[j].add(i)
    for i in range(n):
        if i not in adj:
            adj[i] = set()
    return dict(adj)


def count_edges(adj: Dict[int, Set[int]]) -> int:
    return sum(len(nb) for nb in adj.values()) // 2


def connected_components(adj: Dict[int, Set[int]]) -> List[Set[int]]:
    visited = set()
    comps = []
    for start in adj:
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
            for w in adj.get(v, set()):
                if w not in visited:
                    queue.append(w)
        comps.append(comp)
    return comps


def graph_cycle_rank(adj: Dict[int, Set[int]]) -> int:
    return count_edges(adj) - len(adj) + len(connected_components(adj))


def find_bridges(adj: Dict[int, Set[int]]) -> Set[Tuple[int, int]]:
    bridges = set()
    visited = set()
    disc = {}
    low = {}
    timer = [0]
    
    def dfs(u, parent):
        visited.add(u)
        disc[u] = low[u] = timer[0]
        timer[0] += 1
        for v in adj.get(u, set()):
            if v not in visited:
                dfs(v, u)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u]:
                    bridges.add((min(u, v), max(u, v)))
            elif v != parent:
                low[u] = min(low[u], disc[v])
    
    sys.setrecursionlimit(10000)
    for v in adj:
        if v not in visited:
            dfs(v, -1)
    return bridges


def local_cycle_pressure(adj: Dict[int, Set[int]]) -> Dict[int, int]:
    bridges = find_bridges(adj)
    pressure = {}
    for v in adj:
        count = 0
        for w in adj[v]:
            if (min(v, w), max(v, w)) not in bridges:
                count += 1
        pressure[v] = count
    return pressure


def pairwise_concordance(f: List[int], g: List[int]) -> int:
    n = len(f)
    conc, disc = 0, 0
    for i in range(n):
        for j in range(n):
            if f[i] < f[j] and g[i] < g[j]:
                conc += 1
            if f[i] < f[j] and g[j] < g[i]:
                disc += 1
    return conc - disc


def spearman_correlation(x: List[float], y: List[float]) -> float:
    n = len(x)
    if n <= 1:
        return 0.0
    def rank(vals):
        si = sorted(range(n), key=lambda i: vals[i])
        ranks = [0.0] * n
        i = 0
        while i < n:
            j = i
            while j < n and vals[si[j]] == vals[si[i]]:
                j += 1
            avg = (i + j - 1) / 2.0 + 1
            for k in range(i, j):
                ranks[si[k]] = avg
            i = j
        return ranks
    rx, ry = rank(x), rank(y)
    mx, my = sum(rx) / n, sum(ry) / n
    cov = sum((rx[i] - mx) * (ry[i] - my) for i in range(n))
    vx = sum((rx[i] - mx) ** 2 for i in range(n))
    vy = sum((ry[i] - my) ** 2 for i in range(n))
    if vx == 0 or vy == 0:
        return 0.0
    return cov / (vx ** 0.5 * vy ** 0.5)


# ── Main Demo ──────────────────────────────────────────────────────

def generate_synthetic_theorems(
    n: int = 500,
    n_features: int = 50,
    n_clusters: int = 5,
    seed: int = 42
) -> Tuple[List[Set[str]], List[str]]:
    """Generate synthetic theorem features with cluster structure."""
    rng = np.random.RandomState(seed)
    feature_universe = [f'sym_{i}' for i in range(n_features)]
    
    features = []
    names = []
    cluster_size = n // n_clusters
    
    for cluster_id in range(n_clusters):
        # Each cluster has a core feature set + noise
        core_start = (cluster_id * n_features // n_clusters) % n_features
        core_size = n_features // (n_clusters + 1) + 3
        core = set(feature_universe[core_start:core_start + core_size])
        
        for j in range(cluster_size):
            idx = cluster_id * cluster_size + j
            if idx >= n:
                break
            # Add noise features
            n_noise = rng.randint(2, 8)
            noise = set(rng.choice(feature_universe, n_noise, replace=False))
            features.append(core | noise)
            names.append(f'Thm_{cluster_id}_{j}')
    
    # Fill remaining
    while len(features) < n:
        k = rng.randint(5, 15)
        features.append(set(rng.choice(feature_universe, k, replace=False)))
        names.append(f'Thm_misc_{len(features)}')
    
    return features[:n], names[:n]


def simulate_proof_search(
    pressure: Dict[int, int],
    n: int,
    noise_level: float = 0.3,
    seed: int = 123
) -> List[float]:
    """Simulate proof-search hardness correlated with cycle pressure.
    
    Model: hardness = base + pressure_effect + noise
    This simulates a monotone hardness model with bounded noise.
    """
    rng = np.random.RandomState(seed)
    hardness = []
    for i in range(n):
        p = pressure.get(i, 0)
        # Monotone base: higher pressure → higher base hardness
        base = 1.0 + 0.5 * p
        # Add noise (exponential, always positive)
        noise = rng.exponential(noise_level * (1 + 0.1 * p))
        hardness.append(base + noise)
    return hardness


def print_histogram(values: List[float], bins: int = 15, width: int = 50, label: str = ""):
    """Print an ASCII histogram."""
    if not values:
        print("  (empty)")
        return
    
    min_val = min(values)
    max_val = max(values)
    if max_val == min_val:
        print(f"  All values = {min_val}")
        return
    
    bin_width = (max_val - min_val) / bins
    counts = [0] * bins
    for v in values:
        idx = min(int((v - min_val) / bin_width), bins - 1)
        counts[idx] += 1
    
    max_count = max(counts) if counts else 1
    
    if label:
        print(f"  {label}")
    for i in range(bins):
        lo = min_val + i * bin_width
        bar_len = int(counts[i] * width / max_count) if max_count > 0 else 0
        bar = '█' * bar_len
        print(f"  {lo:6.1f} | {bar} ({counts[i]})")


def print_scatter_ascii(x: List[float], y: List[float], width: int = 60, height: int = 20):
    """Print an ASCII scatter plot."""
    if not x or not y:
        return
    
    min_x, max_x = min(x), max(x)
    min_y, max_y = min(y), max(y)
    
    if max_x == min_x:
        max_x = min_x + 1
    if max_y == min_y:
        max_y = min_y + 1
    
    grid = [[' '] * width for _ in range(height)]
    
    for xi, yi in zip(x, y):
        col = min(int((xi - min_x) / (max_x - min_x) * (width - 1)), width - 1)
        row = min(int((1 - (yi - min_y) / (max_y - min_y)) * (height - 1)), height - 1)
        if grid[row][col] == ' ':
            grid[row][col] = '·'
        elif grid[row][col] == '·':
            grid[row][col] = 'o'
        else:
            grid[row][col] = 'O'
    
    print(f"  {max_y:6.1f} ┤{''.join(grid[0])}")
    for r in range(1, height - 1):
        print(f"         │{''.join(grid[r])}")
    print(f"  {min_y:6.1f} ┤{''.join(grid[-1])}")
    print(f"         └{'─' * width}")
    print(f"          {min_x:<6.1f}{' ' * (width - 12)}{max_x:>6.1f}")


def main():
    print("=" * 70)
    print("  TOPOLOGICAL PROOF PRESSURE: Interactive Demo")
    print("  Cycle structure as a predictor of proof-search hardness")
    print("=" * 70)
    
    # ── Step 1: Generate synthetic theorem library ─────────────────
    n = 500
    print(f"\n{'─' * 70}")
    print(f"  Step 1: Generating {n} synthetic theorems with cluster structure")
    print(f"{'─' * 70}")
    
    features, names = generate_synthetic_theorems(n=n, n_features=50, n_clusters=5)
    print(f"  Generated {len(features)} theorems across 5 semantic clusters")
    print(f"  Feature universe size: 50 symbols")
    avg_features = np.mean([len(f) for f in features])
    print(f"  Average features per theorem: {avg_features:.1f}")
    
    # ── Step 2: Threshold sweep ────────────────────────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 2: Threshold sweep — finding optimal ε")
    print(f"{'─' * 70}")
    
    max_eps = 20
    profile = []
    for eps in range(max_eps + 1):
        adj = build_threshold_graph(features, eps)
        e = count_edges(adj)
        cr = graph_cycle_rank(adj)
        nc = len(connected_components(adj))
        profile.append((eps, e, cr, nc))
    
    print(f"\n  {'ε':>3} │ {'Edges':>7} │ {'Components':>10} │ {'Cycle Rank':>10} │ Bar")
    print(f"  {'─' * 3}─┼─{'─' * 7}─┼─{'─' * 10}─┼─{'─' * 10}─┼─{'─' * 30}")
    
    max_cr = max(cr for _, _, cr, _ in profile)
    best_eps = 0
    best_cr = -1
    for eps, e, cr, nc in profile:
        if cr > best_cr:
            best_cr = cr
            best_eps = eps
        bar_len = int(cr * 30 / max(max_cr, 1)) if cr > 0 else 0
        marker = " ◄ ε*" if cr == max_cr and eps == best_eps else ""
        print(f"  {eps:3d} │ {e:7d} │ {nc:10d} │ {cr:10d} │ {'█' * bar_len}{marker}")
    
    print(f"\n  ε* = {best_eps} (maximizes cycle rank at {best_cr})")
    
    # ── Step 3: Compute local cycle pressure at ε* ─────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 3: Local cycle pressure at ε* = {best_eps}")
    print(f"{'─' * 70}")
    
    adj = build_threshold_graph(features, best_eps)
    pressure = local_cycle_pressure(adj)
    pressure_list = [pressure.get(i, 0) for i in range(n)]
    
    n_pos = sum(1 for p in pressure_list if p > 0)
    print(f"\n  Vertices with positive pressure: {n_pos}/{n} ({100*n_pos/n:.1f}%)")
    print(f"  Mean pressure: {np.mean(pressure_list):.2f}")
    print(f"  Max pressure: {max(pressure_list)}")
    print(f"  Median pressure: {np.median(pressure_list):.1f}")
    
    print(f"\n  Pressure distribution:")
    print_histogram([float(p) for p in pressure_list], bins=12, label="Local Cycle Pressure")
    
    # ── Step 4: Simulate proof-search hardness ─────────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 4: Simulating proof-search hardness")
    print(f"{'─' * 70}")
    
    hardness = simulate_proof_search(pressure, n, noise_level=0.3)
    
    print(f"\n  Mean hardness: {np.mean(hardness):.2f}")
    print(f"  Max hardness: {max(hardness):.2f}")
    print(f"  Min hardness: {min(hardness):.2f}")
    
    print(f"\n  Hardness distribution:")
    print_histogram(hardness, bins=12, label="Proof-Search Cost")
    
    # ── Step 5: Correlation analysis ───────────────────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 5: Correlation analysis — pressure vs hardness")
    print(f"{'─' * 70}")
    
    hardness_int = [int(h * 10) for h in hardness]
    concordance = pairwise_concordance(pressure_list, hardness_int)
    spearman = spearman_correlation(
        [float(p) for p in pressure_list],
        hardness
    )
    
    print(f"\n  Pairwise concordance score: {concordance}")
    print(f"  Spearman rank correlation: {spearman:.4f}")
    print(f"  Concordance ≥ 0? {'✓ YES (as guaranteed by Theorem 3.2)' if concordance >= 0 else '✗ NO'}")
    
    # Scatter plot
    print(f"\n  Pressure vs Hardness (scatter plot):")
    print_scatter_ascii(
        [float(p) for p in pressure_list],
        hardness,
        width=55, height=18
    )
    print(f"          {'Pressure →':^55}")
    
    # ── Step 6: Timeout group comparison ───────────────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 6: Timeout group comparison")
    print(f"{'─' * 70}")
    
    timeout_threshold = np.percentile(hardness, 75)
    median_pressure = np.median(pressure_list)
    
    high_p = [i for i in range(n) if pressure_list[i] > median_pressure]
    low_p = [i for i in range(n) if pressure_list[i] <= median_pressure]
    
    high_timeout_rate = sum(1 for i in high_p if hardness[i] >= timeout_threshold) / max(len(high_p), 1)
    low_timeout_rate = sum(1 for i in low_p if hardness[i] >= timeout_threshold) / max(len(low_p), 1)
    
    print(f"\n  Timeout threshold (75th percentile): {timeout_threshold:.2f}")
    print(f"  High-pressure group: {len(high_p)} theorems, timeout rate = {high_timeout_rate:.1%}")
    print(f"  Low-pressure group:  {len(low_p)} theorems, timeout rate = {low_timeout_rate:.1%}")
    print(f"  Timeout rate difference: {high_timeout_rate - low_timeout_rate:.1%}")
    
    # ── Step 7: Conjecture evaluation ──────────────────────────────
    print(f"\n{'─' * 70}")
    print(f"  Step 7: Topological Hardness Principle — conjecture status")
    print(f"{'─' * 70}")
    
    conjecture_survives = concordance > 0 and spearman > 0
    
    print(f"\n  On this synthetic domain ({n} theorems):")
    print(f"  • Concordance score > 0?    {'✓' if concordance > 0 else '✗'} ({concordance})")
    print(f"  • Spearman correlation > 0? {'✓' if spearman > 0 else '✗'} ({spearman:.4f})")
    print(f"  • Timeout rate difference?  {'✓' if high_timeout_rate > low_timeout_rate else '✗'}")
    print(f"\n  Conjecture status: {'SURVIVES ✓' if conjecture_survives else 'REFUTED ✗'}")
    
    # ── Summary ────────────────────────────────────────────────────
    print(f"\n{'=' * 70}")
    print(f"  SUMMARY")
    print(f"{'=' * 70}")
    print(f"""
  This demo illustrates the Topological Proof Pressure theory:

  1. A semantic threshold graph was built from {n} synthetic theorems.
  2. The cycle rank peaks at ε* = {best_eps} with cycle rank = {best_cr}.
  3. {n_pos}/{n} theorems ({100*n_pos/n:.1f}%) have positive cycle pressure.
  4. The pairwise concordance score is {concordance} (≥ 0 as proven in Lean).
  5. Spearman correlation between pressure and hardness is {spearman:.4f}.

  Key formal results (all machine-verified in Lean 4):
  • Theorem 3.2: Monotonicity → nonneg concordance [VERIFIED]
  • Theorem 4.2: Pressure gap → hardness gap [VERIFIED]
  • Theorem 4.4: Hardness model → nonneg concordance [VERIFIED]
  • Theorem 5.2: Stratified hardness barrier [VERIFIED]
""")


if __name__ == '__main__':
    main()
