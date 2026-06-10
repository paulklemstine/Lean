"""
Algorithms for Multi-Criteria Truthful Approximation Mechanisms.

Implements threshold-rounded covering mechanisms with critical-value payments
for hypergraph covering games.

Core algorithms:
- LP fractional relaxation for weighted hypergraph covering
- Threshold rounding with configurable threshold
- Critical-value payment computation
- Bid monotonicity verification
- Simultaneous multi-objective approximation evaluation
"""

from __future__ import annotations
import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass, field
from fractions import Fraction


@dataclass
class HypergraphInstance:
    """A hypergraph covering game instance.

    Attributes:
        n_vertices: Number of vertices (agents)
        edges: List of edges, each a list of vertex indices
        rank: Maximum edge size
    """
    n_vertices: int
    edges: List[List[int]]
    rank: int = 0

    def __post_init__(self):
        if self.edges:
            self.rank = max(len(e) for e in self.edges)


@dataclass
class MechanismOutput:
    """Output of a truthful covering mechanism.

    Attributes:
        selected: Set of selected vertices (the transversal)
        payments: Payment to each vertex
        fractional_solution: The underlying fractional LP solution
        is_feasible: Whether the transversal covers all edges
        approximation_ratios: Approximation ratio for each objective
    """
    selected: List[int]
    payments: np.ndarray
    fractional_solution: np.ndarray
    is_feasible: bool
    approximation_ratios: Dict[str, float] = field(default_factory=dict)


def generate_random_hypergraph(
    n_vertices: int,
    n_edges: int,
    max_rank: int,
    seed: Optional[int] = None
) -> HypergraphInstance:
    """Generate a random hypergraph with bounded rank.

    Args:
        n_vertices: Number of vertices
        n_edges: Number of edges
        max_rank: Maximum edge size
        seed: Random seed for reproducibility

    Returns:
        A random HypergraphInstance
    """
    rng = np.random.default_rng(seed)
    edges = []
    for _ in range(n_edges):
        size = rng.integers(2, max_rank + 1)
        edge = sorted(rng.choice(n_vertices, size=min(size, n_vertices), replace=False).tolist())
        edges.append(edge)
    return HypergraphInstance(n_vertices=n_vertices, edges=edges)


def solve_fractional_covering(
    instance: HypergraphInstance,
    costs: np.ndarray
) -> np.ndarray:
    """Solve the fractional covering LP relaxation using a simple iterative method.

    Minimizes sum(costs[v] * x[v]) subject to:
        sum(x[v] for v in edge) >= 1 for each edge
        0 <= x[v] <= 1 for each v

    Uses a greedy/proportional allocation for simplicity (no external LP solver needed).

    Args:
        instance: The hypergraph instance
        costs: Cost vector for each vertex

    Returns:
        Fractional solution x in [0, 1]^n
    """
    n = instance.n_vertices
    x = np.zeros(n)

    # Iteratively satisfy uncovered edges
    edge_slack = np.ones(len(instance.edges))  # How much coverage each edge still needs

    for iteration in range(100):  # Fixed-point iteration
        for i, edge in enumerate(instance.edges):
            if edge_slack[i] <= 1e-10:
                continue
            # Distribute coverage proportionally to 1/cost
            edge_costs = np.array([max(costs[v], 1e-10) for v in edge])
            inv_costs = 1.0 / edge_costs
            total_inv = inv_costs.sum()
            for j, v in enumerate(edge):
                contribution = edge_slack[i] * inv_costs[j] / total_inv
                x[v] = min(1.0, x[v] + contribution)
        # Recompute slack
        for i, edge in enumerate(instance.edges):
            edge_slack[i] = max(0, 1.0 - sum(x[v] for v in edge))

    return np.clip(x, 0, 1)


def threshold_round(
    x: np.ndarray,
    threshold: float
) -> List[int]:
    """Apply threshold rounding: select all vertices with x[v] >= threshold.

    Args:
        x: Fractional solution
        threshold: Rounding threshold (typically 1/rank)

    Returns:
        List of selected vertex indices
    """
    return [v for v in range(len(x)) if x[v] >= threshold]


def is_transversal(
    instance: HypergraphInstance,
    selected: List[int]
) -> bool:
    """Check whether a set of vertices covers every edge.

    Args:
        instance: The hypergraph instance
        selected: Set of selected vertices

    Returns:
        True if every edge has at least one selected vertex
    """
    selected_set = set(selected)
    return all(any(v in selected_set for v in edge) for edge in instance.edges)


def compute_critical_payments(
    instance: HypergraphInstance,
    bids: np.ndarray,
    threshold: float,
    selected: List[int]
) -> np.ndarray:
    """Compute critical-value payments for each selected agent.

    For each selected agent v, the critical payment is the maximum bid at which
    v would still be selected. This is found by binary search.

    Args:
        instance: The hypergraph instance
        bids: Current bid profile
        threshold: Rounding threshold
        selected: Currently selected vertices

    Returns:
        Payment vector (0 for unselected agents)
    """
    n = instance.n_vertices
    payments = np.zeros(n)

    for v in selected:
        # Binary search for the critical bid
        lo, hi = bids[v], bids[v] * 100 + 10.0
        for _ in range(50):  # Binary search iterations
            mid = (lo + hi) / 2
            # Create modified bid profile
            modified_bids = bids.copy()
            modified_bids[v] = mid
            # Solve with modified bids
            x_mod = solve_fractional_covering(instance, modified_bids)
            if x_mod[v] >= threshold:
                lo = mid
            else:
                hi = mid
        payments[v] = lo

    return payments


def objective_cost(
    weights: np.ndarray,
    selected: List[int]
) -> float:
    """Compute the weighted objective cost of a selected set.

    Args:
        weights: Weight vector
        selected: Selected vertex indices

    Returns:
        Sum of weights over selected vertices
    """
    return sum(weights[v] for v in selected)


def fractional_objective_cost(
    weights: np.ndarray,
    x: np.ndarray
) -> float:
    """Compute the fractional weighted objective cost.

    Args:
        weights: Weight vector
        x: Fractional solution

    Returns:
        Sum of weights[v] * x[v]
    """
    return float(np.dot(weights, x))


def run_mechanism(
    instance: HypergraphInstance,
    bids: np.ndarray,
    objectives: List[np.ndarray],
    objective_names: Optional[List[str]] = None,
    threshold: Optional[float] = None
) -> MechanismOutput:
    """Run the complete multi-criteria truthful mechanism.

    1. Solve fractional covering LP
    2. Apply threshold rounding
    3. Compute critical payments
    4. Evaluate approximation ratios for all objectives

    Args:
        instance: The hypergraph instance
        bids: Agent bid profile (reported costs)
        objectives: List of weight vectors for different objectives
        objective_names: Optional names for objectives
        threshold: Rounding threshold (default: 1/rank)

    Returns:
        MechanismOutput with selected set, payments, and approximation ratios
    """
    if threshold is None:
        threshold = 1.0 / max(instance.rank, 1)

    if objective_names is None:
        objective_names = [f"obj_{i}" for i in range(len(objectives))]

    # Step 1: Solve fractional relaxation
    x = solve_fractional_covering(instance, bids)

    # Step 2: Threshold rounding
    selected = threshold_round(x, threshold)

    # Step 3: Feasibility check
    feasible = is_transversal(instance, selected)

    # Step 4: Critical payments
    payments = compute_critical_payments(instance, bids, threshold, selected)

    # Step 5: Evaluate approximation ratios
    ratios = {}
    for name, w in zip(objective_names, objectives):
        int_cost = objective_cost(w, selected)
        frac_cost = fractional_objective_cost(w, x)
        if frac_cost > 1e-10:
            ratios[name] = int_cost / frac_cost
        else:
            ratios[name] = 1.0

    return MechanismOutput(
        selected=selected,
        payments=payments,
        fractional_solution=x,
        is_feasible=feasible,
        approximation_ratios=ratios
    )


def test_truthfulness(
    instance: HypergraphInstance,
    true_costs: np.ndarray,
    n_deviations: int = 100,
    threshold: Optional[float] = None,
    seed: Optional[int] = None
) -> Tuple[bool, List[dict]]:
    """Test whether the mechanism is truthful by checking random deviations.

    For each agent, try random alternative bids and verify that truthful
    reporting gives at least as much utility.

    Args:
        instance: The hypergraph instance
        true_costs: True cost profile
        n_deviations: Number of random deviations to test per agent
        threshold: Rounding threshold
        seed: Random seed

    Returns:
        (is_truthful, violations) where violations lists any profitable deviations
    """
    rng = np.random.default_rng(seed)
    if threshold is None:
        threshold = 1.0 / max(instance.rank, 1)

    n = instance.n_vertices
    violations = []

    # Truthful outcome
    x_truth = solve_fractional_covering(instance, true_costs)
    selected_truth = threshold_round(x_truth, threshold)
    payments_truth = compute_critical_payments(instance, true_costs, threshold, selected_truth)

    for v in range(n):
        # Truthful utility
        if v in selected_truth:
            utility_truth = payments_truth[v] - true_costs[v]
        else:
            utility_truth = 0.0

        # Try deviations
        for _ in range(n_deviations):
            alt_bid = rng.uniform(0, true_costs[v] * 3 + 1.0)
            modified_bids = true_costs.copy()
            modified_bids[v] = alt_bid

            x_dev = solve_fractional_covering(instance, modified_bids)
            selected_dev = threshold_round(x_dev, threshold)
            payments_dev = compute_critical_payments(instance, modified_bids, threshold, selected_dev)

            if v in selected_dev:
                utility_dev = payments_dev[v] - true_costs[v]
            else:
                utility_dev = 0.0

            if utility_dev > utility_truth + 1e-6:
                violations.append({
                    'agent': v,
                    'true_cost': true_costs[v],
                    'alt_bid': alt_bid,
                    'utility_truth': utility_truth,
                    'utility_dev': utility_dev,
                    'profit': utility_dev - utility_truth
                })

    return len(violations) == 0, violations


def generate_objective_cone(
    n_vertices: int,
    n_objectives: int,
    seed: Optional[int] = None
) -> List[np.ndarray]:
    """Generate a random cone of nonnegative linear objectives.

    Args:
        n_vertices: Number of vertices
        n_objectives: Number of objectives to generate
        seed: Random seed

    Returns:
        List of nonnegative weight vectors
    """
    rng = np.random.default_rng(seed)
    return [rng.uniform(0, 1, size=n_vertices) for _ in range(n_objectives)]


if __name__ == "__main__":
    # Example usage
    print("=== Multi-Criteria Truthful Mechanism Example ===\n")

    instance = generate_random_hypergraph(8, 6, 3, seed=42)
    print(f"Hypergraph: {instance.n_vertices} vertices, {len(instance.edges)} edges, rank {instance.rank}")
    print(f"Edges: {instance.edges}\n")

    bids = np.array([1.0, 2.0, 1.5, 3.0, 0.5, 2.5, 1.0, 2.0])
    objectives = generate_objective_cone(8, 3, seed=42)

    result = run_mechanism(instance, bids, objectives, ["fairness", "efficiency", "equity"])

    print(f"Selected vertices: {result.selected}")
    print(f"Payments: {np.round(result.payments, 4)}")
    print(f"Feasible: {result.is_feasible}")
    print(f"Approximation ratios: {result.approximation_ratios}\n")

    is_truthful, violations = test_truthfulness(instance, bids, n_deviations=50, seed=42)
    print(f"Truthfulness test: {'PASSED' if is_truthful else 'FAILED'}")
    if violations:
        print(f"  {len(violations)} violations found")
