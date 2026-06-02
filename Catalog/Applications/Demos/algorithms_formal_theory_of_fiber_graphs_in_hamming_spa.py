"""
Fiber Graph Algorithms for Hamming Spaces

Implements core algorithms for additive scoring functions on Hamming spaces,
including fiber computation, bridge detection, and fiber graph construction.
"""

from typing import List, Tuple, Dict, Set, Optional
import numpy as np
from itertools import product


class WeightSystem:
    """Additive weight system w: [n] x [q] -> Z."""

    def __init__(self, weights: np.ndarray):
        """
        Args:
            weights: Array of shape (n, q) where weights[i][a] = w_i(a).
        """
        self.weights = weights
        self.n, self.q = weights.shape

    @classmethod
    def random(cls, n: int, q: int, low: int = -10, high: int = 10,
               position_separating: bool = False) -> "WeightSystem":
        """Generate a random weight system."""
        if position_separating:
            weights = np.zeros((n, q), dtype=int)
            for i in range(n):
                vals = np.random.choice(range(low, high + 1), size=q, replace=False)
                weights[i] = vals
        else:
            weights = np.random.randint(low, high + 1, size=(n, q))
        return cls(weights)

    def score(self, config: Tuple[int, ...]) -> int:
        """Compute additive score of a configuration."""
        return sum(self.weights[i][config[i]] for i in range(self.n))

    def score_delta(self, pos: int, a: int, b: int) -> int:
        """Score delta at position pos from symbol a to symbol b."""
        return int(self.weights[pos][b] - self.weights[pos][a])

    def is_position_separating(self) -> bool:
        """Check if weight system is position-separating (injective at each position)."""
        for i in range(self.n):
            if len(set(self.weights[i])) < self.q:
                return False
        return True


def all_configs(n: int, q: int) -> List[Tuple[int, ...]]:
    """Enumerate all configurations in [q]^n."""
    return list(product(range(q), repeat=n))


def compute_fiber(ws: WeightSystem, target: int) -> List[Tuple[int, ...]]:
    """Compute the fiber f^{-1}(target)."""
    return [c for c in all_configs(ws.n, ws.q) if ws.score(c) == target]


def hamming_distance(x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    """Compute Hamming distance between two configurations."""
    return sum(1 for a, b in zip(x, y) if a != b)


def diff_positions(x: Tuple[int, ...], y: Tuple[int, ...]) -> Set[int]:
    """Positions where two configurations differ."""
    return {i for i in range(len(x)) if x[i] != y[i]}


def detect_bridge(ws: WeightSystem, x: Tuple[int, ...],
                  y: Tuple[int, ...], pos: int) -> Optional[Tuple[int, ...]]:
    """
    Detect a bridge through position pos from x to y.

    Returns the bridge configuration if it exists, None otherwise.
    Bridge through pos: z agrees with x except at pos (where z[pos] = y[pos]),
    and score(z) = score(x).

    By Bridge Duality, bridge exists iff score_delta(pos, x[pos], y[pos]) == 0.

    Complexity: O(1) time given the weight system.
    """
    delta = ws.score_delta(pos, x[pos], y[pos])
    if delta == 0:
        z = list(x)
        z[pos] = y[pos]
        return tuple(z)
    return None


def verify_bridge_duality(ws: WeightSystem, x: Tuple[int, ...],
                          y: Tuple[int, ...]) -> Dict:
    """
    Verify bridge duality for two configurations differing at exactly 2 positions.

    Returns dict with bridge existence at each position and duality verification.
    """
    diffs = diff_positions(x, y)
    assert len(diffs) == 2, f"Configurations must differ at exactly 2 positions, got {len(diffs)}"
    assert ws.score(x) == ws.score(y), "Configurations must have equal score"

    i, j = sorted(diffs)
    bridge_i = detect_bridge(ws, x, y, i) is not None
    bridge_j = detect_bridge(ws, x, y, j) is not None

    return {
        "positions": (i, j),
        "bridge_through_i": bridge_i,
        "bridge_through_j": bridge_j,
        "duality_holds": bridge_i == bridge_j,
        "delta_i": ws.score_delta(i, x[i], y[i]),
        "delta_j": ws.score_delta(j, x[j], y[j]),
    }


def build_fiber_graph(ws: WeightSystem, target: int) -> Dict:
    """
    Build the fiber graph for a given target score.

    Returns dict with vertices (configurations) and edges (pairs at Hamming distance 1).
    """
    fiber = compute_fiber(ws, target)
    edges = []
    for idx_a, a in enumerate(fiber):
        for idx_b, b in enumerate(fiber):
            if idx_a < idx_b and hamming_distance(a, b) == 1:
                edges.append((idx_a, idx_b))

    return {
        "vertices": fiber,
        "edges": edges,
        "num_vertices": len(fiber),
        "num_edges": len(edges),
    }


def fiber_graph_adjacency_matrix(ws: WeightSystem, target: int) -> np.ndarray:
    """Compute the adjacency matrix of the fiber graph."""
    graph = build_fiber_graph(ws, target)
    n = graph["num_vertices"]
    if n == 0:
        return np.array([])
    adj = np.zeros((n, n))
    for i, j in graph["edges"]:
        adj[i][j] = 1
        adj[j][i] = 1
    return adj


def spectral_gap(ws: WeightSystem, target: int) -> Optional[float]:
    """
    Compute the spectral gap of the fiber graph's normalized Laplacian.

    Returns lambda_2 (second smallest eigenvalue of the normalized Laplacian),
    or None if the fiber has fewer than 2 vertices.
    """
    adj = fiber_graph_adjacency_matrix(ws, target)
    n = adj.shape[0]
    if n < 2:
        return None

    # Degree matrix
    degrees = adj.sum(axis=1)
    if np.any(degrees == 0):
        return 0.0  # Isolated vertices

    # Normalized Laplacian: L = I - D^{-1/2} A D^{-1/2}
    d_inv_sqrt = np.diag(1.0 / np.sqrt(degrees))
    laplacian = np.eye(n) - d_inv_sqrt @ adj @ d_inv_sqrt

    eigenvalues = np.sort(np.linalg.eigvalsh(laplacian))
    return float(eigenvalues[1]) if len(eigenvalues) > 1 else None


def fiber_size_distribution(ws: WeightSystem) -> Dict[int, int]:
    """Compute the distribution of fiber sizes."""
    scores: Dict[int, int] = {}
    for config in all_configs(ws.n, ws.q):
        s = ws.score(config)
        scores[s] = scores.get(s, 0) + 1
    return scores


def score_swap(ws: WeightSystem, config: Tuple[int, ...],
               pos_i: int, val_i: int,
               pos_j: int, val_j: int) -> Tuple[int, ...]:
    """
    Apply a score-preserving double swap.

    Requires: w[pos_i][val_i] == w[pos_i][config[pos_i]]
    and w[pos_j][val_j] == w[pos_j][config[pos_j]].
    """
    assert ws.weights[pos_i][val_i] == ws.weights[pos_i][config[pos_i]], \
        "Weight match required at position i"
    assert ws.weights[pos_j][val_j] == ws.weights[pos_j][config[pos_j]], \
        "Weight match required at position j"
    result = list(config)
    result[pos_i] = val_i
    result[pos_j] = val_j
    return tuple(result)
