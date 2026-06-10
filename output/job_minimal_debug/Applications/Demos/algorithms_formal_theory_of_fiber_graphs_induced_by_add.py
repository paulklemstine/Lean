#!/usr/bin/env python3
"""
Algorithms for Fiber Graph Analysis

Type-hinted implementations of the core algorithms for computing
fiber graph properties from additive scoring systems.
"""

from typing import Dict, List, Tuple, Set, Optional, Callable
from itertools import product
from collections import defaultdict, deque


# Type aliases
Config = Tuple[int, ...]
WeightFunc = Dict[int, int]
WeightSystem = List[WeightFunc]
Edge = Tuple[Config, Config]


def additive_score(weights: WeightSystem, config: Config) -> int:
    """Compute additive score S(x) = Σ_i w_i(x_i)."""
    return sum(w[x] for w, x in zip(weights, config))


def score_delta(w: WeightFunc, a: int, b: int) -> int:
    """Score delta δ(a,b) = w(b) - w(a)."""
    return w[b] - w[a]


def compute_fiber(
    weights: WeightSystem,
    target: int,
    alphabet: List[int]
) -> List[Config]:
    """Compute the fiber {x | S(x) = target}."""
    n = len(weights)
    return [
        cfg for cfg in product(alphabet, repeat=n)
        if additive_score(weights, cfg) == target
    ]


def fiber_graph_adjacency(
    configs: List[Config]
) -> Dict[Config, List[Config]]:
    """Build adjacency list for the fiber graph (Hamming distance 1)."""
    adj: Dict[Config, List[Config]] = defaultdict(list)
    config_set = set(configs)

    for x in configs:
        for i in range(len(x)):
            for y in config_set:
                if sum(1 for a, b in zip(x, y) if a != b) == 1:
                    adj[x].append(y)
    return dict(adj)


def fiber_graph_adjacency_fast(
    configs: List[Config],
    alphabet: List[int]
) -> Dict[Config, List[Config]]:
    """Build adjacency list efficiently using single-position modifications."""
    config_set = set(configs)
    adj: Dict[Config, List[Config]] = {cfg: [] for cfg in configs}

    for x in configs:
        for i in range(len(x)):
            for v in alphabet:
                if v == x[i]:
                    continue
                y = list(x)
                y[i] = v
                y_tuple = tuple(y)
                if y_tuple in config_set:
                    adj[x].append(y_tuple)
    return adj


def fiber_degree(
    weights: WeightSystem,
    config: Config,
    alphabet: List[int]
) -> int:
    """Compute the fiber degree: number of Hamming-adjacent same-score configs."""
    target = additive_score(weights, config)
    degree = 0
    for i in range(len(config)):
        for v in alphabet:
            if v == config[i]:
                continue
            modified = list(config)
            modified[i] = v
            if additive_score(weights, tuple(modified)) == target:
                degree += 1
    return degree


def find_bridges(
    weights: WeightSystem,
    config: Config,
    alphabet: List[int]
) -> List[Tuple[int, int]]:
    """Find all bridges from a configuration: (position, new_value) pairs."""
    target = additive_score(weights, config)
    bridges = []
    for i in range(len(config)):
        for v in alphabet:
            if v == config[i]:
                continue
            modified = list(config)
            modified[i] = v
            if additive_score(weights, tuple(modified)) == target:
                bridges.append((i, v))
    return bridges


def connected_components(
    configs: List[Config],
    adj: Dict[Config, List[Config]]
) -> List[List[Config]]:
    """Find connected components of the fiber graph via BFS."""
    visited: Set[Config] = set()
    components: List[List[Config]] = []

    for start in configs:
        if start in visited:
            continue
        component: List[Config] = []
        queue = deque([start])
        visited.add(start)

        while queue:
            curr = queue.popleft()
            component.append(curr)
            for neighbor in adj.get(curr, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        components.append(component)

    return components


def cheeger_constant_estimate(
    configs: List[Config],
    adj: Dict[Config, List[Config]]
) -> float:
    """Estimate the Cheeger constant (edge expansion) of the fiber graph.

    h(G) = min_{S: |S| ≤ |V|/2} |∂S| / |S|
    where ∂S is the edge boundary of S.

    This is a sampling-based estimate for tractability.
    """
    n = len(configs)
    if n <= 1:
        return float('inf')

    min_expansion = float('inf')

    # Try all subsets of size 1 to n//2 for small graphs
    if n <= 16:
        from itertools import combinations
        for size in range(1, n // 2 + 1):
            for subset in combinations(range(n), size):
                s = {configs[i] for i in subset}
                boundary = sum(
                    1 for x in s
                    for y in adj.get(x, [])
                    if y not in s
                )
                expansion = boundary / len(s)
                min_expansion = min(min_expansion, expansion)
    else:
        # Heuristic: try random subsets
        import random
        for _ in range(min(1000, n * 10)):
            size = random.randint(1, n // 2)
            s = set(random.sample(configs, size))
            boundary = sum(
                1 for x in s
                for y in adj.get(x, [])
                if y not in s
            )
            expansion = boundary / len(s)
            min_expansion = min(min_expansion, expansion)

    return min_expansion


def total_delta_vector(
    weights: WeightSystem,
    x: Config,
    y: Config
) -> List[int]:
    """Compute the total delta vector δ_i(x_i, y_i) for all positions."""
    return [score_delta(w, a, b) for w, a, b in zip(weights, x, y)]


def verify_bridge_duality(
    weights: WeightSystem,
    alphabet: List[int]
) -> Tuple[int, int]:
    """Verify bridge duality for all qualifying pairs.

    Returns (total_pairs_checked, violations).
    """
    n = len(weights)
    all_configs = list(product(alphabet, repeat=n))
    checked = 0
    violations = 0

    for x in all_configs:
        for y in all_configs:
            if x >= y:
                continue
            diff = [i for i in range(n) if x[i] != y[i]]
            if len(diff) != 2:
                continue
            if additive_score(weights, x) != additive_score(weights, y):
                continue

            i, j = diff
            wi_match = weights[i][x[i]] == weights[i][y[i]]
            wj_match = weights[j][x[j]] == weights[j][y[j]]
            checked += 1
            if wi_match != wj_match:
                violations += 1

    return checked, violations


def is_weight_injective(w: WeightFunc) -> bool:
    """Check if a weight function is injective."""
    return len(set(w.values())) == len(w)


def fiber_size_distribution(
    weights: WeightSystem,
    alphabet: List[int]
) -> Dict[int, int]:
    """Compute the distribution of fiber sizes."""
    n = len(weights)
    score_counts: Dict[int, int] = defaultdict(int)
    for cfg in product(alphabet, repeat=n):
        s = additive_score(weights, cfg)
        score_counts[s] += 1
    return dict(sorted(score_counts.items()))


if __name__ == "__main__":
    # Example usage
    weights: WeightSystem = [
        {0: 0, 1: 1, 2: 3},
        {0: 0, 1: 2, 2: 5},
        {0: 0, 1: 4, 2: 7},
    ]
    alphabet = [0, 1, 2]

    print("Weight system:")
    for i, w in enumerate(weights):
        print(f"  w_{i}: {w}")

    print(f"\nFiber size distribution:")
    dist = fiber_size_distribution(weights, alphabet)
    for score_val, count in dist.items():
        print(f"  score={score_val}: {count} configs")

    print(f"\nBridge duality verification:")
    checked, violations = verify_bridge_duality(weights, alphabet)
    print(f"  Checked {checked} pairs, {violations} violations")

    # Fiber graph analysis for a specific target
    target = 5
    f = compute_fiber(weights, target, alphabet)
    if f:
        adj = fiber_graph_adjacency_fast(f, alphabet)
        comps = connected_components(f, adj)
        print(f"\nFiber(score={target}): {len(f)} configs, "
              f"{len(comps)} components")
        if len(f) <= 16:
            h = cheeger_constant_estimate(f, adj)
            print(f"  Cheeger constant ≈ {h:.3f}")
