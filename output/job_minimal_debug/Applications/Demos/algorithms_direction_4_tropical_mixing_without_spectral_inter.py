"""
Algorithms for Tropical Mixing Theory

Implements the core computational methods for constructing tropical path systems,
computing tropical diameter and congestion, and producing certified mixing-time
upper bounds from these quantities.

Keywords: tropical geometry, Markov chain mixing, canonical paths, Newton subdivision
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from collections import defaultdict
import heapq


class TropicalPathSystem:
    """A tropical path system on a finite state space.

    For each ordered pair (x, y), assigns a canonical path as a list of states.
    The path starts at x and ends at y.

    Attributes:
        n_states: Number of states in the state space.
        adjacency: Adjacency list representation of the state graph.
        paths: Dictionary mapping (x, y) pairs to canonical paths.
    """

    def __init__(self, n_states: int, adjacency: Dict[int, List[int]]):
        """Initialize with a state graph.

        Args:
            n_states: Number of states.
            adjacency: Dict mapping each state to its list of neighbors.
        """
        self.n_states = n_states
        self.adjacency = adjacency
        self.paths: Dict[Tuple[int, int], List[int]] = {}
        self._compute_shortest_paths()

    def _compute_shortest_paths(self):
        """Compute shortest paths between all pairs using BFS."""
        for source in range(self.n_states):
            # BFS from source
            dist = [-1] * self.n_states
            parent = [-1] * self.n_states
            dist[source] = 0
            queue = [source]
            head = 0

            while head < len(queue):
                u = queue[head]
                head += 1
                for v in self.adjacency.get(u, []):
                    if dist[v] == -1:
                        dist[v] = dist[u] + 1
                        parent[v] = u
                        queue.append(v)

            # Reconstruct paths
            for target in range(self.n_states):
                if dist[target] == -1 and source != target:
                    # Not reachable; store trivial path
                    self.paths[(source, target)] = [source]
                    continue
                path = []
                v = target
                while v != -1:
                    path.append(v)
                    v = parent[v]
                path.reverse()
                self.paths[(source, target)] = path

    def get_path(self, x: int, y: int) -> List[int]:
        """Get the canonical path from x to y.

        Args:
            x: Source state.
            y: Target state.

        Returns:
            List of states forming the path from x to y.
        """
        return self.paths.get((x, y), [x])

    def path_length(self, x: int, y: int) -> int:
        """Get the tropical path length from x to y (number of edges).

        Args:
            x: Source state.
            y: Target state.

        Returns:
            Number of edges in the canonical path.
        """
        return max(0, len(self.get_path(x, y)) - 1)


def compute_tropical_diameter(path_system: TropicalPathSystem) -> int:
    """Compute the tropical diameter bound of a path system.

    The diameter is the maximum path length over all ordered pairs (x, y).

    Args:
        path_system: A TropicalPathSystem instance.

    Returns:
        The tropical diameter bound D(P).

    Example:
        >>> adj = {0: [1, 2], 1: [0, 2], 2: [0, 1]}
        >>> ps = TropicalPathSystem(3, adj)
        >>> compute_tropical_diameter(ps)
        1
    """
    max_length = 0
    for x in range(path_system.n_states):
        for y in range(path_system.n_states):
            length = path_system.path_length(x, y)
            max_length = max(max_length, length)
    return max_length


def compute_tropical_vertex_congestion(path_system: TropicalPathSystem) -> int:
    """Compute the tropical vertex congestion of a path system.

    For each vertex v, count how many ordered pairs (x, y) have v on their
    canonical path. Return the maximum such count.

    Args:
        path_system: A TropicalPathSystem instance.

    Returns:
        The maximum vertex load C_v(P).

    Example:
        >>> adj = {0: [1], 1: [0, 2], 2: [1]}
        >>> ps = TropicalPathSystem(3, adj)
        >>> compute_tropical_vertex_congestion(ps)
        9
    """
    load = defaultdict(int)
    for x in range(path_system.n_states):
        for y in range(path_system.n_states):
            for v in path_system.get_path(x, y):
                load[v] += 1

    if not load:
        return 0
    return max(load.values())


def certified_mixing_bound(gamma: float, D: int, pi_min: float) -> float:
    """Compute the certified mixing-time upper bound.

    The bound is Γ * D * log(1/π_min), which is the direct tropical
    mixing bound from Theorem A.

    Args:
        gamma: Congestion bound Γ > 0.
        D: Diameter bound D ≥ 0.
        pi_min: Minimum stationary probability 0 < π_min ≤ 1.

    Returns:
        The certified mixing-time upper bound.

    Raises:
        ValueError: If inputs are out of range.

    Example:
        >>> certified_mixing_bound(10.0, 5, 0.01)
        230.25850929940458
    """
    if gamma <= 0:
        raise ValueError(f"Congestion bound must be positive, got {gamma}")
    if D < 0:
        raise ValueError(f"Diameter must be nonneg, got {D}")
    if pi_min <= 0 or pi_min > 1:
        raise ValueError(f"π_min must be in (0, 1], got {pi_min}")

    return gamma * D * np.log(1.0 / pi_min)


def build_lorentzian_state_graph(d: int, n: int) -> Dict[int, List[int]]:
    """Build a state graph mimicking a Lorentzian polynomial subdivision.

    Constructs the dual graph of a simplex subdivision: states are
    lattice points in the simplex {(i1,...,in) : i1+...+in ≤ d},
    and two states are adjacent if they differ in exactly one coordinate
    by ±1.

    Args:
        d: Degree of the polynomial.
        n: Number of variables.

    Returns:
        Adjacency list representation of the state graph.
    """
    from itertools import product as iproduct

    # Generate lattice points in the simplex
    states = []
    def gen_points(remaining_deg, dim, current):
        if dim == 0:
            states.append(tuple(current))
            return
        for i in range(remaining_deg + 1):
            gen_points(remaining_deg - i, dim - 1, current + [i])

    gen_points(d, n, [])

    state_to_idx = {s: i for i, s in enumerate(states)}
    adjacency = defaultdict(list)

    for i, s in enumerate(states):
        for coord in range(n):
            for delta in [-1, 1]:
                neighbor = list(s)
                neighbor[coord] += delta
                neighbor_tuple = tuple(neighbor)
                if neighbor_tuple in state_to_idx:
                    j = state_to_idx[neighbor_tuple]
                    if j not in adjacency[i]:
                        adjacency[i].append(j)

    return dict(adjacency), states


def compute_empirical_mixing_time(K: np.ndarray, pi: np.ndarray,
                                   threshold: float = 0.25) -> int:
    """Estimate the mixing time of a Markov chain by power iteration.

    Starting from the worst initial state, compute the number of steps
    until the total variation distance to stationarity drops below threshold.

    Args:
        K: Transition matrix (n x n).
        pi: Stationary distribution (n,).
        threshold: Total variation distance threshold (default 1/4).

    Returns:
        Estimated mixing time.
    """
    n = K.shape[0]
    max_steps = 10000

    worst_mixing = 0
    for start in range(min(n, 20)):  # Check a subset of starting states
        dist = np.zeros(n)
        dist[start] = 1.0

        for t in range(1, max_steps + 1):
            dist = dist @ K
            tv_dist = 0.5 * np.sum(np.abs(dist - pi))
            if tv_dist < threshold:
                worst_mixing = max(worst_mixing, t)
                break
        else:
            worst_mixing = max(worst_mixing, max_steps)

    return worst_mixing


def construct_lazy_walk(adjacency: Dict[int, List[int]],
                        n_states: int) -> Tuple[np.ndarray, np.ndarray]:
    """Construct the lazy simple random walk on a graph.

    The lazy walk stays put with probability 1/2 and moves to a
    uniform random neighbor with probability 1/2.

    Args:
        adjacency: Adjacency list.
        n_states: Number of states.

    Returns:
        Tuple of (transition matrix K, stationary distribution pi).
    """
    K = np.zeros((n_states, n_states))

    for i in range(n_states):
        neighbors = adjacency.get(i, [])
        deg = len(neighbors)
        if deg > 0:
            K[i, i] = 0.5
            for j in neighbors:
                K[i, j] += 0.5 / deg
        else:
            K[i, i] = 1.0

    # Stationary distribution: proportional to degree
    degrees = np.array([len(adjacency.get(i, [])) for i in range(n_states)],
                       dtype=float)
    degrees = np.maximum(degrees, 1)
    pi = degrees / degrees.sum()

    return K, pi


def full_tropical_mixing_analysis(d: int, n: int) -> Dict:
    """Perform a complete tropical mixing analysis for a Lorentzian-like polynomial.

    Args:
        d: Degree of the polynomial.
        n: Number of variables.

    Returns:
        Dictionary containing all computed quantities:
        - n_states: Number of states
        - diameter: Tropical diameter
        - congestion: Vertex congestion
        - pi_min: Minimum stationary probability
        - certified_bound: Certified mixing-time upper bound
        - empirical_mixing: Empirical mixing time
        - dn_bound: d * n bound
    """
    adj, states = build_lorentzian_state_graph(d, n)
    n_states = len(states)

    if n_states == 0:
        return {"n_states": 0, "diameter": 0, "congestion": 0,
                "pi_min": 1.0, "certified_bound": 0.0,
                "empirical_mixing": 0, "dn_bound": d * n}

    ps = TropicalPathSystem(n_states, adj)
    diameter = compute_tropical_diameter(ps)
    congestion = compute_tropical_vertex_congestion(ps)

    K, pi = construct_lazy_walk(adj, n_states)
    pi_min = max(pi.min(), 1e-15)

    cert_bound = certified_mixing_bound(float(congestion), diameter, pi_min)
    emp_mixing = compute_empirical_mixing_time(K, pi)

    return {
        "n_states": n_states,
        "diameter": diameter,
        "congestion": congestion,
        "pi_min": pi_min,
        "certified_bound": cert_bound,
        "empirical_mixing": emp_mixing,
        "dn_bound": d * n,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("Tropical Mixing Theory — Algorithm Demonstrations")
    print("=" * 70)

    # Example 1: Simple path graph
    print("\n--- Example 1: Path graph P_5 ---")
    adj = {0: [1], 1: [0, 2], 2: [1, 3], 3: [2, 4], 4: [3]}
    ps = TropicalPathSystem(5, adj)
    print(f"Diameter: {compute_tropical_diameter(ps)}")
    print(f"Congestion: {compute_tropical_vertex_congestion(ps)}")
    print(f"Path 0→4: {ps.get_path(0, 4)}")
    print(f"Certified bound (Γ=15, D=4, πmin=0.1): "
          f"{certified_mixing_bound(15, 4, 0.1):.2f}")

    # Example 2: Lorentzian-like analysis
    print("\n--- Example 2: Lorentzian polynomial d=3, n=3 ---")
    result = full_tropical_mixing_analysis(3, 3)
    for key, val in result.items():
        print(f"  {key}: {val}")

    # Example 3: Scaling study
    print("\n--- Example 3: Scaling study ---")
    print(f"{'d':>3} {'n':>3} {'states':>8} {'diam':>6} {'cong':>8} "
          f"{'cert':>12} {'emp':>6} {'d*n':>5}")
    for d in [2, 3, 4]:
        for n_var in [2, 3, 4]:
            result = full_tropical_mixing_analysis(d, n_var)
            print(f"{d:>3} {n_var:>3} {result['n_states']:>8} "
                  f"{result['diameter']:>6} {result['congestion']:>8} "
                  f"{result['certified_bound']:>12.1f} "
                  f"{result['empirical_mixing']:>6} {result['dn_bound']:>5}")
