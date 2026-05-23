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
