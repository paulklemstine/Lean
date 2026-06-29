"""
Algorithms for Persistent Homology of Modular Matrix Product Walks

This module implements the core computational pipeline for studying universality
in random walks on SL₂(𝔽_p) via meeting-time filtrations and persistence proxies.

Key algorithms:
1. Modular matrix arithmetic in SL₂(𝔽_p)
2. Random walk simulation on SL₂(𝔽_p)
3. Meeting-time filtration construction
4. Persistence proxy computation (Betti numbers, cycle defect)
5. Universality summary statistics
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import math


# ============================================================
# 1. Modular Matrix Arithmetic
# ============================================================

def mat_mul_mod(A: np.ndarray, B: np.ndarray, p: int) -> np.ndarray:
    """Multiply two 2x2 matrices modulo p.

    Args:
        A: 2x2 integer matrix
        B: 2x2 integer matrix
        p: prime modulus

    Returns:
        (A @ B) mod p as 2x2 numpy array
    """
    return (A @ B) % p


def mat_inv_mod(A: np.ndarray, p: int) -> np.ndarray:
    """Compute the inverse of a 2x2 matrix in SL₂(𝔽_p).

    For SL₂, det = 1, so A^{-1} = [[d, -b], [-c, a]] mod p.

    Args:
        A: 2x2 integer matrix with det ≡ 1 (mod p)
        p: prime modulus

    Returns:
        A^{-1} mod p
    """
    a, b, c, d = A[0, 0], A[0, 1], A[1, 0], A[1, 1]
    return np.array([[d, (-b) % p], [(-c) % p, a]]) % p


def mat_to_tuple(A: np.ndarray) -> Tuple[int, ...]:
    """Convert a 2x2 matrix to a hashable tuple."""
    return tuple(A.flatten())


def tuple_to_mat(t: Tuple[int, ...]) -> np.ndarray:
    """Convert a tuple back to a 2x2 matrix."""
    return np.array(t).reshape(2, 2)


def reduce_mod_p(A: np.ndarray, p: int) -> np.ndarray:
    """Reduce an integer matrix modulo p."""
    return A % p


def sl2_order(p: int) -> int:
    """Order of SL₂(𝔽_p) = p(p²-1) for prime p ≥ 2.

    Args:
        p: prime number

    Returns:
        |SL₂(𝔽_p)|
    """
    return p * (p * p - 1)


# ============================================================
# 2. Generator Sets
# ============================================================

def standard_generators() -> List[np.ndarray]:
    """Standard generators for SL₂(ℤ): S = [[0,-1],[1,0]], T = [[1,1],[0,1]].

    These generate SL₂(ℤ) and their reductions generate SL₂(𝔽_p) for all primes p ≥ 5.

    Returns:
        List of 2x2 integer matrices [S, S^{-1}, T, T^{-1}]
    """
    S = np.array([[0, -1], [1, 0]])
    T = np.array([[1, 1], [0, 1]])
    S_inv = np.array([[0, 1], [-1, 0]])
    T_inv = np.array([[1, -1], [0, 1]])
    return [S, S_inv, T, T_inv]


def unipotent_generators() -> List[np.ndarray]:
    """Unipotent generators: U = [[1,1],[0,1]], L = [[1,0],[1,1]] and inverses.

    These generate SL₂(ℤ) (classical fact).

    Returns:
        List of 2x2 integer matrices [U, U^{-1}, L, L^{-1}]
    """
    U = np.array([[1, 1], [0, 1]])
    L = np.array([[1, 0], [1, 1]])
    U_inv = np.array([[1, -1], [0, 1]])
    L_inv = np.array([[1, 0], [-1, 1]])
    return [U, U_inv, L, L_inv]


def biased_generators() -> Tuple[List[np.ndarray], List[float]]:
    """Biased measure on unipotent generators.

    Same support as unipotent_generators but with non-uniform weights.
    U has weight 0.4, L has weight 0.1, inverses split remaining mass.

    Returns:
        (generators, weights) where weights sum to 1
    """
    gens = unipotent_generators()
    weights = [0.4, 0.1, 0.1, 0.4]
    return gens, weights


# ============================================================
# 3. Random Walk Simulation
# ============================================================

def simulate_walk(generators: List[np.ndarray],
                  p: int,
                  T: int,
                  weights: Optional[List[float]] = None,
                  seed: Optional[int] = None) -> List[np.ndarray]:
    """Simulate a random walk on SL₂(𝔽_p).

    Starting from the identity, at each step multiply by a random generator
    (reduced mod p).

    Args:
        generators: list of integer matrices generating SL₂(ℤ)
        p: prime modulus
        T: number of steps
        weights: probability weights for generators (uniform if None)
        seed: random seed for reproducibility

    Returns:
        List of T+1 matrices representing the walk trajectory

    Time complexity: O(T) matrix multiplications mod p
    Space complexity: O(T) to store trajectory
    """
    rng = np.random.RandomState(seed)
    if weights is None:
        weights = [1.0 / len(generators)] * len(generators)

    gens_mod = [reduce_mod_p(g, p) for g in generators]
    identity = np.eye(2, dtype=int) % p
    trajectory = [identity.copy()]

    current = identity.copy()
    for _ in range(T):
        idx = rng.choice(len(gens_mod), p=weights)
        current = mat_mul_mod(current, gens_mod[idx], p)
        trajectory.append(current.copy())

    return trajectory


# ============================================================
# 4. Meeting-Time Filtration
# ============================================================

def build_visited_set(trajectory: List[np.ndarray], t: int) -> Set[Tuple[int, ...]]:
    """Compute visitedSet(x, t) — states visited up to time t.

    Mirrors the Lean definition:
      visitedSet x t = (filter (· ≤ t) univ).image x

    Args:
        trajectory: list of states (matrices)
        t: time index (0-indexed)

    Returns:
        Set of visited states as tuples

    Time complexity: O(t)
    """
    visited = set()
    for i in range(min(t + 1, len(trajectory))):
        visited.add(mat_to_tuple(trajectory[i]))
    return visited


def build_first_appearance(trajectory: List[np.ndarray]) -> Dict[Tuple[int, ...], int]:
    """Compute first-appearance times for all visited states.

    Args:
        trajectory: list of states

    Returns:
        Dictionary mapping state → first time it appears

    Time complexity: O(T)
    """
    first_time = {}
    for t, state in enumerate(trajectory):
        key = mat_to_tuple(state)
        if key not in first_time:
            first_time[key] = t
    return first_time


def compute_collapse_time(trajectory: List[np.ndarray]) -> int:
    """Compute the collapse time: max of first-appearance times.

    This is the earliest time by which all eventually-visited states
    have appeared. After this time, the meeting-time graph is complete.

    Args:
        trajectory: list of states

    Returns:
        Collapse time (integer)

    Time complexity: O(T)
    """
    first_times = build_first_appearance(trajectory)
    return max(first_times.values()) if first_times else 0


def build_meeting_time_graph(trajectory: List[np.ndarray],
                              t: int) -> Dict[Tuple[int, ...], Set[Tuple[int, ...]]]:
    """Build the meeting-time graph at time t.

    An edge exists between states a and b if both have appeared by time t.
    (This means the graph at time t is the complete graph on visitedSet(x, t).)

    Args:
        trajectory: list of states
        t: time index

    Returns:
        Adjacency dict: state → set of neighbors

    Time complexity: O(|visited|²)
    """
    visited = build_visited_set(trajectory, t)
    adj = defaultdict(set)
    visited_list = list(visited)
    for i in range(len(visited_list)):
        for j in range(i + 1, len(visited_list)):
            adj[visited_list[i]].add(visited_list[j])
            adj[visited_list[j]].add(visited_list[i])
    return dict(adj)


# ============================================================
# 5. Persistence Proxies
# ============================================================

def betti_0_profile(trajectory: List[np.ndarray]) -> List[int]:
    """Compute Betti-0 (number of connected components) at each time step.

    In the meeting-time filtration, at time t the graph is complete on
    visitedSet(x, t), so β₀ = |visitedSet(x, t)| until all states
    are connected (which happens immediately since cliques are connected).

    Actually, in our filtration, at each time t the graph is a clique
    on visited vertices, so β₀ = 1 if any vertex is visited (always true),
    and β₀ = 0 if nothing is visited (impossible since T ≥ 0).

    But for the first-encounter filtration (edges weighted by max first-appearance
    time of endpoints), β₀ starts high and decreases. We compute this version.

    Args:
        trajectory: list of states

    Returns:
        List of β₀ values at each filtration level

    Time complexity: O(T · α(T)) using union-find
    """
    first_times = build_first_appearance(trajectory)
    states = sorted(first_times.keys(), key=lambda s: first_times[s])
    T = len(trajectory) - 1

    # Union-Find
    parent = {}
    rank = {}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True

    betti0 = []
    components = 0
    added = []

    for t in range(T + 1):
        key = mat_to_tuple(trajectory[t])
        if key not in parent:
            parent[key] = key
            rank[key] = 0
            components += 1
            # Connect to all previously seen vertices
            # (in meeting-time filtration, new vertex connects to all existing)
            for prev in added:
                if union(key, prev):
                    components -= 1
            added.append(key)
        betti0.append(components)

    return betti0


def first_encounter_filtration_betti0(trajectory: List[np.ndarray]) -> List[int]:
    """Compute β₀ profile for the first-encounter edge filtration.

    Edge {a,b} has filtration value max(firstAppearance(a), firstAppearance(b)).
    At filtration level t, include all edges with value ≤ t.

    Args:
        trajectory: list of states

    Returns:
        β₀ at each filtration level 0, 1, ..., T

    Time complexity: O(T²)
    """
    first_times = build_first_appearance(trajectory)
    all_states = list(first_times.keys())
    T = len(trajectory) - 1

    # Build edge list with filtration values
    edges = []
    for i in range(len(all_states)):
        for j in range(i + 1, len(all_states)):
            a, b = all_states[i], all_states[j]
            filt_val = max(first_times[a], first_times[b])
            edges.append((filt_val, a, b))
    edges.sort()

    # Union-Find
    parent = {}
    rank = {}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True

    # Initialize: add vertices at their first-appearance times
    betti0 = [0] * (T + 1)
    components = 0
    edge_idx = 0

    # Sort vertices by first-appearance time
    sorted_states = sorted(all_states, key=lambda s: first_times[s])
    state_idx = 0

    for t in range(T + 1):
        # Add new vertices
        while state_idx < len(sorted_states) and first_times[sorted_states[state_idx]] <= t:
            s = sorted_states[state_idx]
            parent[s] = s
            rank[s] = 0
            components += 1
            state_idx += 1

        # Add edges
        while edge_idx < len(edges) and edges[edge_idx][0] <= t:
            _, a, b = edges[edge_idx]
            if a in parent and b in parent:
                if union(a, b):
                    components -= 1
            edge_idx += 1

        betti0[t] = components

    return betti0


def cycle_count_proxy(trajectory: List[np.ndarray], t: int) -> int:
    """Compute a 1-cycle proxy: number of independent cycles in the meeting-time graph.

    For a graph with V vertices and E edges, the cycle rank is E - V + C
    where C is the number of connected components.

    In the meeting-time filtration, the graph at time t is complete on
    visitedSet(x, t), so:
    - V = |visitedSet(x, t)|
    - E = V(V-1)/2
    - C = 1 (if V ≥ 1)
    - cycle_rank = V(V-1)/2 - V + 1 = (V-1)(V-2)/2

    Args:
        trajectory: list of states
        t: time index

    Returns:
        Cycle rank of the meeting-time graph

    Time complexity: O(t)
    """
    visited = build_visited_set(trajectory, t)
    V = len(visited)
    if V <= 1:
        return 0
    return (V - 1) * (V - 2) // 2


def persistence_summary(trajectory: List[np.ndarray]) -> Dict:
    """Compute persistence summary statistics for a trajectory.

    Returns a dictionary with:
    - collapse_time: when all visited states have appeared
    - total_visited: number of distinct states visited
    - betti0_profile: β₀ at each time step
    - cycle_proxy_profile: cycle rank proxy at each time step
    - normalized_collapse: collapse_time / log(|visited|)

    Args:
        trajectory: list of states

    Returns:
        Dictionary of summary statistics

    Time complexity: O(T²) for full computation
    """
    T = len(trajectory) - 1
    collapse = compute_collapse_time(trajectory)
    total = len(build_visited_set(trajectory, T))
    betti0 = first_encounter_filtration_betti0(trajectory)

    cycle_profile = []
    for t in range(T + 1):
        cycle_profile.append(cycle_count_proxy(trajectory, t))

    norm_collapse = collapse / math.log(max(total, 2))

    return {
        'collapse_time': collapse,
        'total_visited': total,
        'betti0_profile': betti0,
        'cycle_proxy_profile': cycle_profile,
        'normalized_collapse': norm_collapse,
        'T': T
    }


# ============================================================
# 6. Universality Testing
# ============================================================

def universality_distance(summary1: Dict, summary2: Dict) -> float:
    """Compute a distance between two persistence summaries.

    Uses L² distance between normalized β₀ profiles as a simple metric.

    Args:
        summary1: first persistence summary
        summary2: second persistence summary

    Returns:
        Distance between summaries (non-negative float)
    """
    b1 = np.array(summary1['betti0_profile'], dtype=float)
    b2 = np.array(summary2['betti0_profile'], dtype=float)

    # Normalize by total visited
    if summary1['total_visited'] > 0:
        b1 /= summary1['total_visited']
    if summary2['total_visited'] > 0:
        b2 /= summary2['total_visited']

    # Resample to common length
    n = max(len(b1), len(b2))
    if len(b1) < n:
        b1 = np.interp(np.linspace(0, 1, n), np.linspace(0, 1, len(b1)), b1)
    if len(b2) < n:
        b2 = np.interp(np.linspace(0, 1, n), np.linspace(0, 1, len(b2)), b2)

    return float(np.sqrt(np.mean((b1 - b2) ** 2)))


def run_universality_test(primes: List[int],
                          time_multiplier: float = 2.0,
                          n_trials: int = 10,
                          seed: int = 42) -> Dict:
    """Run the universality test across multiple primes.

    For each prime p, simulates walks with different generator sets
    and compares persistence summaries at time T = c * log(p).

    Args:
        primes: list of primes to test
        time_multiplier: constant c in T = c * log(p)
        n_trials: number of independent walks per configuration
        seed: base random seed

    Returns:
        Dictionary with test results

    Time complexity: O(|primes| * n_trials * T² * |generators|)
    """
    results = {
        'primes': primes,
        'time_multiplier': time_multiplier,
        'configs': {}
    }

    configs = {
        'standard_uniform': (standard_generators(), None),
        'unipotent_uniform': (unipotent_generators(), None),
        'unipotent_biased': biased_generators(),
    }

    for config_name, (gens, weights) in configs.items():
        config_results = []
        for p in primes:
            T = max(int(time_multiplier * math.log(p)), 5)
            summaries = []
            for trial in range(n_trials):
                traj = simulate_walk(gens, p, T, weights, seed=seed + trial + p * 1000)
                summ = persistence_summary(traj)
                summaries.append(summ)

            avg_collapse = np.mean([s['collapse_time'] for s in summaries])
            avg_visited = np.mean([s['total_visited'] for s in summaries])
            avg_norm_collapse = np.mean([s['normalized_collapse'] for s in summaries])

            config_results.append({
                'p': p,
                'T': T,
                'avg_collapse_time': float(avg_collapse),
                'avg_visited': float(avg_visited),
                'avg_normalized_collapse': float(avg_norm_collapse),
                'group_order': sl2_order(p),
            })

        results['configs'][config_name] = config_results

    return results


if __name__ == '__main__':
    # Quick test
    primes = [5, 7, 11, 13]
    results = run_universality_test(primes, time_multiplier=3.0, n_trials=5)
    for config, data in results['configs'].items():
        print(f"\n{config}:")
        for entry in data:
            print(f"  p={entry['p']:3d}, T={entry['T']:3d}, "
                  f"collapse={entry['avg_collapse_time']:.1f}, "
                  f"visited={entry['avg_visited']:.1f}, "
                  f"norm_collapse={entry['avg_normalized_collapse']:.2f}")
