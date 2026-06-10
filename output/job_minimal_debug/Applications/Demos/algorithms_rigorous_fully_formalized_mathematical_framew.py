"""
Multi-Objective Refinement Systems (MORS) — Algorithms

Type-hinted implementations of the core MORS algorithms:
1. Pareto dominance checking
2. Pareto frontier computation
3. Multi-objective optimizer simulation
4. Weighted chain bound computation
"""

from typing import List, Tuple, Callable, Optional, Set
import itertools


# --- Core Types ---

ComplexityVector = Tuple[int, ...]  # k-dimensional complexity vector


def pareto_dominates(x: ComplexityVector, y: ComplexityVector) -> bool:
    """Check if x Pareto-dominates y: x[i] <= y[i] for all i, x[j] < y[j] for some j."""
    if len(x) != len(y):
        raise ValueError("Vectors must have same dimension")
    all_le = all(xi <= yi for xi, yi in zip(x, y))
    some_lt = any(xi < yi for xi, yi in zip(x, y))
    return all_le and some_lt


def total_complexity(x: ComplexityVector) -> int:
    """Sum of all components."""
    return sum(x)


def weighted_total(x: ComplexityVector, weights: Tuple[int, ...]) -> int:
    """Weighted sum of components."""
    return sum(w * c for w, c in zip(weights, x))


# --- Pareto Frontier ---

def compute_pareto_frontier(
    points: List[ComplexityVector],
) -> List[ComplexityVector]:
    """
    Compute the Pareto frontier: all points not dominated by any other.

    Time complexity: O(n^2 * k) where n = len(points), k = dimension.

    Returns list of Pareto-optimal points.
    """
    frontier: List[ComplexityVector] = []
    for p in points:
        dominated = False
        for q in points:
            if pareto_dominates(q, p):
                dominated = True
                break
        if not dominated:
            frontier.append(p)
    return frontier


def compute_pareto_frontier_fast(
    points: List[ComplexityVector],
) -> List[ComplexityVector]:
    """
    Compute Pareto frontier using incremental filtering (Kung et al. style).

    For each new point, remove dominated points from the current frontier
    and add the new point if not dominated.

    Average case: much faster than O(n^2) for random inputs.
    """
    frontier: List[ComplexityVector] = []
    for p in points:
        # Check if p is dominated by any frontier point
        if any(pareto_dominates(q, p) for q in frontier):
            continue
        # Remove frontier points dominated by p
        frontier = [q for q in frontier if not pareto_dominates(p, q)]
        frontier.append(p)
    return frontier


# --- Multi-Objective Optimizer Simulation ---

def simulate_pareto_optimizer(
    initial: ComplexityVector,
    step: Callable[[ComplexityVector], ComplexityVector],
    max_steps: int = 10000,
) -> List[ComplexityVector]:
    """
    Simulate a Pareto optimizer, recording the orbit.

    The step function must satisfy:
      step(x)[i] <= x[i] for all i (componentwise non-increasing)

    Returns the orbit [x, step(x), step^2(x), ...] until convergence or max_steps.
    """
    orbit: List[ComplexityVector] = [initial]
    current = initial
    for _ in range(max_steps):
        next_val = step(current)
        # Verify componentwise non-increase
        assert all(
            ni <= ci for ni, ci in zip(next_val, current)
        ), f"Step function increased a component: {current} -> {next_val}"
        if next_val == current:
            break
        orbit.append(next_val)
        current = next_val
    return orbit


# --- Chain Analysis ---

def verify_pareto_chain(chain: List[ComplexityVector]) -> bool:
    """Verify that a sequence forms a valid Pareto refinement chain."""
    for i in range(len(chain) - 1):
        if not pareto_dominates(chain[i + 1], chain[i]):
            return False
    return True


def chain_independence_dimension(chain: List[ComplexityVector]) -> int:
    """
    Count the number of objectives that are ever strictly improved along the chain.
    """
    if len(chain) < 2:
        return 0
    k = len(chain[0])
    improved: Set[int] = set()
    for i in range(len(chain) - 1):
        for j in range(k):
            if chain[i + 1][j] < chain[i][j]:
                improved.add(j)
    return len(improved)


# --- Weighted Analysis ---

def optimal_weights_for_chain(
    chain: List[ComplexityVector],
) -> Tuple[int, ...]:
    """
    Find positive integer weights that minimize the weighted chain bound.

    The weighted bound is: len(chain)-1 <= sum(w[i] * chain[0][i]).
    We want to minimize this bound (i.e., concentrate weight on small components).

    Heuristic: assign weight inversely proportional to initial component value.
    """
    initial = chain[0]
    k = len(initial)
    if all(c == 0 for c in initial):
        return tuple(1 for _ in range(k))
    # Assign weight inversely proportional to component value (minimum 1)
    max_val = max(initial) + 1
    weights = tuple(max(1, max_val - c) for c in initial)
    return weights


# --- Collapse Analysis ---

def collapse_information_loss(
    points: List[ComplexityVector],
) -> List[Tuple[ComplexityVector, ComplexityVector]]:
    """
    Find pairs where the collapsed (total complexity) order disagrees
    with the Pareto order.

    Returns pairs (x, y) where total(x) < total(y) but x does NOT
    Pareto-dominate y.
    """
    mismatches: List[Tuple[ComplexityVector, ComplexityVector]] = []
    for x, y in itertools.combinations(points, 2):
        tx, ty = total_complexity(x), total_complexity(y)
        if tx < ty and not pareto_dominates(x, y):
            mismatches.append((x, y))
        elif ty < tx and not pareto_dominates(y, x):
            mismatches.append((y, x))
    return mismatches


if __name__ == "__main__":
    # Quick self-test
    assert pareto_dominates((1, 2), (2, 3))
    assert not pareto_dominates((1, 3), (2, 2))

    frontier = compute_pareto_frontier([(3, 1), (1, 3), (2, 2), (4, 4)])
    print(f"Pareto frontier of [(3,1),(1,3),(2,2),(4,4)]: {frontier}")

    print("All self-tests passed.")
"""

"""
