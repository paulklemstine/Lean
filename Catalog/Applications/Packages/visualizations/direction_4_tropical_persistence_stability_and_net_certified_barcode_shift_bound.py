"""
Algorithms for Tropical Persistence Stability and Certified Robustness.

Implements the core algorithms from the research paper:
1. Sublevel-set filtration computation
2. Sup-norm distance between weight functions
3. Certified barcode shift bound
4. Event robustness certification
5. Rank function computation
6. Merge/birth threshold computation

All algorithms have formal correctness guarantees from the Lean proofs.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class WeightedGraph:
    """A finite graph with real-valued edge weights.

    Attributes:
        n_vertices: Number of vertices
        edges: List of (u, v) pairs
        weights: Array of edge weights, one per edge
    """
    n_vertices: int
    edges: List[Tuple[int, int]]
    weights: np.ndarray

    @property
    def n_edges(self) -> int:
        return len(self.edges)

    def sublevel_edges(self, t: float) -> List[int]:
        """Return indices of edges with weight ≤ t.

        Corresponds to tropicalSublevelSet in the Lean formalization.
        Complexity: O(|E|)
        """
        return [i for i, w in enumerate(self.weights) if w <= t]

    def sublevel_edge_count(self, t: float) -> int:
        """Count edges with weight ≤ t.

        Corresponds to sublevelEdgeCount in the Lean formalization.
        Complexity: O(|E|)
        """
        return int(np.sum(self.weights <= t))


def weight_sup_dist(w: np.ndarray, w_prime: np.ndarray) -> float:
    """Compute the sup-norm distance between two weight functions.

    Corresponds to weightSupDist in the Lean formalization.

    Args:
        w: First weight function (array of reals)
        w_prime: Second weight function (array of reals)

    Returns:
        max_e |w(e) - w'(e)|

    Complexity: O(|E|)
    """
    return float(np.max(np.abs(w - w_prime)))


def certified_barcode_shift_bound(w: np.ndarray, w_prime: np.ndarray) -> float:
    """Compute the certified upper bound on barcode displacement.

    Corresponds to certifiedBarcodeShiftBound in the Lean formalization.
    By Theorem 3 (tropical_bottleneck_stability), this bounds the
    interleaving distance between the tropical filtrations.

    Args:
        w: Original weight function
        w_prime: Perturbed weight function

    Returns:
        Certified upper bound on barcode displacement

    Complexity: O(|E|)
    """
    return weight_sup_dist(w, w_prime)


def merge_threshold(w: np.ndarray) -> float:
    """Compute the merge threshold (maximum edge weight).

    Corresponds to mergeThreshold in the Lean formalization.
    By Theorem 5 (component_merge_threshold_lipschitz), this is
    1-Lipschitz in the sup norm.

    Complexity: O(|E|)
    """
    return float(np.max(w))


def birth_threshold(w: np.ndarray) -> float:
    """Compute the birth threshold (minimum edge weight).

    Corresponds to birthThreshold in the Lean formalization.
    By Theorem 6 (birth_threshold_lipschitz), this is
    1-Lipschitz in the sup norm.

    Complexity: O(|E|)
    """
    return float(np.min(w))


def filtration_diameter(w: np.ndarray) -> float:
    """Compute the filtration diameter (max - min edge weight).

    By Theorem 7 (filtration_diameter_stability), this changes
    by at most 2ε under ε-perturbation.

    Complexity: O(|E|)
    """
    return float(np.max(w) - np.min(w))


def has_long_bar(w: np.ndarray, L: float) -> bool:
    """Check if the weight function has a long bar of lifetime ≥ L.

    Corresponds to hasLongBar in the Lean formalization.
    A long bar exists iff max(w) - min(w) ≥ L.

    Complexity: O(|E|)
    """
    return float(np.max(w) - np.min(w)) >= L


def long_bar_is_robust(w: np.ndarray, L: float, delta: float) -> bool:
    """Check if a long bar of lifetime L is certifiably robust under δ-perturbation.

    By Theorem 4 (long_bar_robust_under_perturbation), a bar of lifetime
    ≥ L + 2δ survives δ-perturbation with a bar of lifetime ≥ L.

    Args:
        w: Weight function
        L: Target bar lifetime
        delta: Perturbation bound

    Returns:
        True if the bar is certifiably robust

    Complexity: O(|E|)
    """
    return has_long_bar(w, L + 2 * delta)


@dataclass
class RobustnessCertificate:
    """A certified robustness report for a weighted graph.

    Fields:
        sup_dist: The sup-norm distance between original and perturbed weights
        interleaving_bound: Certified bound on interleaving distance (= sup_dist)
        merge_shift_bound: Certified bound on merge threshold shift (≤ sup_dist)
        birth_shift_bound: Certified bound on birth threshold shift (≤ sup_dist)
        diameter_shift_bound: Certified bound on diameter shift (≤ 2 * sup_dist)
        long_bar_robust: Whether the longest bar survives perturbation
        long_bar_margin: Margin of robustness for the longest bar
    """
    sup_dist: float
    interleaving_bound: float
    merge_shift_bound: float
    birth_shift_bound: float
    diameter_shift_bound: float
    long_bar_robust: bool
    long_bar_margin: float


def compute_robustness_certificate(
    w: np.ndarray,
    w_prime: np.ndarray,
    target_bar_length: Optional[float] = None
) -> RobustnessCertificate:
    """Compute a full robustness certificate for a weight perturbation.

    This is the main computational method that turns edge-weight uncertainty
    into a certified topological uncertainty bound.

    Args:
        w: Original weight function
        w_prime: Perturbed weight function
        target_bar_length: If provided, check robustness of a bar this long

    Returns:
        RobustnessCertificate with all certified bounds

    Complexity: O(|E|)
    """
    eps = weight_sup_dist(w, w_prime)

    if target_bar_length is None:
        target_bar_length = filtration_diameter(w) / 2

    diameter = filtration_diameter(w)
    margin = diameter - target_bar_length - 2 * eps
    robust = margin >= 0

    return RobustnessCertificate(
        sup_dist=eps,
        interleaving_bound=eps,
        merge_shift_bound=eps,
        birth_shift_bound=eps,
        diameter_shift_bound=2 * eps,
        long_bar_robust=robust,
        long_bar_margin=margin
    )


def compute_rank_function(w: np.ndarray, thresholds: np.ndarray) -> np.ndarray:
    """Compute the sublevel edge count at each threshold.

    The rank function t ↦ |{e : w(e) ≤ t}| is 1-Lipschitz stable
    by Theorem 2 (tropical_rank_one_lipschitz).

    Args:
        w: Weight function
        thresholds: Array of threshold values

    Returns:
        Array of edge counts at each threshold

    Complexity: O(|E| × |thresholds|)
    """
    return np.array([int(np.sum(w <= t)) for t in thresholds])


def critical_values(w: np.ndarray) -> np.ndarray:
    """Compute the critical values of the weight function.

    These are the sorted unique edge weights, which are the thresholds
    at which the sublevel-set filtration changes.

    Complexity: O(|E| log |E|)
    """
    return np.sort(np.unique(w))


# ---- Graph generators ----

def complete_graph(n: int, seed: Optional[int] = None) -> WeightedGraph:
    """Generate a complete graph K_n with random Uniform[0,1] weights."""
    rng = np.random.default_rng(seed)
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    weights = rng.uniform(0, 1, len(edges))
    return WeightedGraph(n, edges, weights)


def cycle_graph(n: int, seed: Optional[int] = None) -> WeightedGraph:
    """Generate a cycle graph C_n with random Uniform[0,1] weights."""
    rng = np.random.default_rng(seed)
    edges = [(i, (i+1) % n) for i in range(n)]
    weights = rng.uniform(0, 1, len(edges))
    return WeightedGraph(n, edges, weights)


def grid_graph(rows: int, cols: int, seed: Optional[int] = None) -> WeightedGraph:
    """Generate a grid graph with random Uniform[0,1] weights."""
    rng = np.random.default_rng(seed)
    n = rows * cols
    edges = []
    for r in range(rows):
        for c in range(cols):
            v = r * cols + c
            if c + 1 < cols:
                edges.append((v, v + 1))
            if r + 1 < rows:
                edges.append((v, v + cols))
    weights = rng.uniform(0, 1, len(edges))
    return WeightedGraph(n, edges, weights)


def erdos_renyi_graph(n: int, p: float, seed: Optional[int] = None) -> WeightedGraph:
    """Generate an Erdős-Rényi random graph G(n, p) with random weights."""
    rng = np.random.default_rng(seed)
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j))
    weights = rng.uniform(0, 1, len(edges)) if edges else np.array([])
    return WeightedGraph(n, edges, weights)


def perturb_weights(w: np.ndarray, epsilon: float,
                    seed: Optional[int] = None) -> np.ndarray:
    """Perturb weights by adding Uniform[-ε, ε] noise.

    Guarantees |w(e) - w'(e)| ≤ ε for all e.
    """
    rng = np.random.default_rng(seed)
    noise = rng.uniform(-epsilon, epsilon, len(w))
    return w + noise


if __name__ == "__main__":
    # Quick demonstration
    print("=== Tropical Persistence Stability: Algorithm Demo ===\n")

    G = complete_graph(10, seed=42)
    eps = 0.05
    w_perturbed = perturb_weights(G.weights, eps, seed=123)

    cert = compute_robustness_certificate(G.weights, w_perturbed)

    print(f"Graph: K_10 with {G.n_edges} edges")
    print(f"Perturbation bound: ε = {eps}")
    print(f"Actual sup distance: {cert.sup_dist:.6f}")
    print(f"Certified interleaving bound: {cert.interleaving_bound:.6f}")
    print(f"Merge threshold shift bound: {cert.merge_shift_bound:.6f}")
    print(f"Birth threshold shift bound: {cert.birth_shift_bound:.6f}")
    print(f"Diameter shift bound: {cert.diameter_shift_bound:.6f}")
    print(f"Long bar robust: {cert.long_bar_robust}")
    print(f"Robustness margin: {cert.long_bar_margin:.6f}")
