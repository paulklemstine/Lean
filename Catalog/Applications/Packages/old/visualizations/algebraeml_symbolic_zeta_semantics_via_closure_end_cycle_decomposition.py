"""
Algorithms for Closure Dynamical System Analysis

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass


@dataclass
class ClosureDynamics:
    """A finite closure dynamical system.

    Attributes:
        states: List of states (finite set).
        step: The step function mapping states to states.
        name: Optional descriptive name.
    """
    states: List[int]
    step: Callable[[int], int]
    name: str = "unnamed"

    @property
    def card(self) -> int:
        return len(self.states)


def enumerate_periodic_points(sys: ClosureDynamics, n: int) -> Set[int]:
    """Enumerate all n-periodic points of the system.

    A point x is n-periodic if step^[n](x) = x.

    Time complexity: O(n · |states|)
    Space complexity: O(|states|)

    Args:
        sys: The closure dynamical system.
        n: The period.

    Returns:
        Set of n-periodic points.
    """
    result = set()
    for x in sys.states:
        y = x
        for _ in range(n):
            y = sys.step(y)
        if y == x:
            result.add(x)
    return result


def periodic_count(sys: ClosureDynamics, n: int) -> int:
    """Count n-periodic points.

    Time: O(n · |states|)
    """
    return len(enumerate_periodic_points(sys, n))


def build_transition_matrix(sys: ClosureDynamics) -> np.ndarray:
    """Build the transition matrix A where A[i][j] = 1 iff step(i) = j.

    Time complexity: O(|states|)
    Space complexity: O(|states|²)

    For deterministic systems, each row has exactly one 1.
    """
    N = sys.card
    idx = {s: i for i, s in enumerate(sys.states)}
    A = np.zeros((N, N), dtype=int)
    for i, s in enumerate(sys.states):
        j = idx[sys.step(s)]
        A[i][j] = 1
    return A


def compute_trace_formula(sys: ClosureDynamics, max_n: int) -> List[int]:
    """Compute periodic counts via the matrix trace formula.

    Uses tr(A^n) = |Fix_n(step)|, which gives an alternative
    computation via matrix exponentiation.

    Time: O(max_n · |states|^ω) where ω ≈ 2.37 is the matrix multiplication exponent.
    Space: O(|states|²)
    """
    A = build_transition_matrix(sys)
    result = []
    An = np.eye(sys.card, dtype=int)
    for n in range(max_n + 1):
        result.append(int(np.trace(An)))
        An = An @ A
    return result


def detect_eventual_periodicity(
    sys: ClosureDynamics, max_n: int = 100
) -> Optional[Tuple[int, int]]:
    """Detect the eventual periodicity of the orbit counting sequence.

    Returns (N, p) such that for all n ≥ N:
        periodic_count(n + p) = periodic_count(n)

    Time: O(max_n² · |states|)
    Space: O(max_n)

    Returns None if no period found within max_n steps.
    """
    counts = [periodic_count(sys, n) for n in range(max_n + 1)]

    for p in range(1, max_n // 2 + 1):
        for N in range(max_n - p + 1):
            if all(counts[n + p] == counts[n]
                   for n in range(N, max_n - p + 1)):
                return (N, p)
    return None


def compute_capacity(sys: ClosureDynamics) -> float:
    """Compute the closure capacity = log(|states|).

    This is the finite analogue of topological entropy.
    """
    return float(np.log(sys.card))


def compute_certified_radius(sys: ClosureDynamics) -> float:
    """Compute the certified radius = 1/(1 + capacity).

    Positive, at most 1, and antitone in capacity.
    Provides a lipschitz_certified_robustness surrogate.
    """
    return 1.0 / (1.0 + compute_capacity(sys))


def find_cycle_decomposition(
    sys: ClosureDynamics
) -> Tuple[List[List[int]], List[List[int]]]:
    """Decompose the functional graph into tails and cycles.

    Returns:
        (tails, cycles): Lists of tail paths and cycle lists.

    Time: O(|states|)
    Space: O(|states|)
    """
    visited = {}  # state -> (visit_order, path_id)
    tails = []
    cycles = []

    for start in sys.states:
        if start in visited:
            continue

        path = []
        x = start
        while x not in visited:
            visited[x] = len(path)
            path.append(x)
            x = sys.step(x)

        if x in [p for p in path]:
            # Found a new cycle
            cycle_start_idx = path.index(x)
            tail = path[:cycle_start_idx]
            cycle = path[cycle_start_idx:]
            if tail:
                tails.append(tail)
            cycles.append(cycle)
        # else: x was visited in a previous component

    return tails, cycles


def orbit_hash_collision_bound(sys: ClosureDynamics, n: int, q: int) -> float:
    """Estimate collision probability for q queries after n iterations.

    Based on the birthday paradox: collision probability ≈ q²/(2·|Fix_n|).
    This is relevant to post_quantum_security state-collision auditing.

    Args:
        sys: The dynamical system (modeling an iterated hash).
        n: Number of iterations.
        q: Number of queries.

    Returns:
        Estimated collision probability (may exceed 1 for large q).
    """
    fix_n = periodic_count(sys, n)
    if fix_n == 0:
        return 1.0  # No periodic points means all queries collide eventually
    return q * q / (2.0 * fix_n)


def verify_conjugacy(
    sys1: ClosureDynamics, sys2: ClosureDynamics,
    h: Dict[int, int], max_n: int = 20
) -> bool:
    """Verify that h is a conjugacy between sys1 and sys2.

    Checks:
    1. h is a bijection between state sets
    2. h(step1(x)) = step2(h(x)) for all x
    3. Periodic counts agree (consequence, verified independently)
    """
    # Check bijection
    if set(h.keys()) != set(sys1.states):
        return False
    if set(h.values()) != set(sys2.states):
        return False
    if len(set(h.values())) != len(h):
        return False

    # Check equivariance
    for x in sys1.states:
        if h[sys1.step(x)] != sys2.step(h[x]):
            return False

    # Verify periodic count agreement
    for n in range(max_n + 1):
        if periodic_count(sys1, n) != periodic_count(sys2, n):
            return False

    return True


# ─── Example usage ─────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: doubling map mod 7
    sys = ClosureDynamics(
        states=list(range(7)),
        step=lambda x: (2 * x) % 7,
        name="Doubling mod 7"
    )

    print(f"System: {sys.name}")
    print(f"Capacity: {compute_capacity(sys):.4f}")
    print(f"Certified radius: {compute_certified_radius(sys):.4f}")

    print("\nPeriodic counts (direct):")
    for n in range(10):
        print(f"  n={n}: {periodic_count(sys, n)}")

    print("\nPeriodic counts (trace formula):")
    traces = compute_trace_formula(sys, 9)
    for n, t in enumerate(traces):
        print(f"  n={n}: {t}")

    result = detect_eventual_periodicity(sys, 30)
    if result:
        N, p = result
        print(f"\nEventual periodicity: period {p} starting at N={N}")

    tails, cycles = find_cycle_decomposition(sys)
    print(f"\nCycle decomposition:")
    for i, c in enumerate(cycles):
        print(f"  Cycle {i}: {c} (length {len(c)})")
    for i, t in enumerate(tails):
        print(f"  Tail {i}: {t}")

    print(f"\nCollision bound (q=100, n=3): {orbit_hash_collision_bound(sys, 3, 100):.4f}")


"""
Applications of Closure Dynamical Zeta Semantics

Real-world applications to cryptography, ML robustness, and physics.
"""

import numpy as np
from typing import List, Dict, Tuple